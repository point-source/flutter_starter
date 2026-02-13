# Architecture Rule 13: Background Tasks

## Overview

Long-running user-initiated tasks (file uploads, data syncs, batch processing) are tracked by a centralised **TaskTracker** provider in `core/tasks/`. Features interact through a **TaskChannel** wrapper that scopes operations to a single category, auto-prefixes IDs, and provides filtered reads — so feature code never touches the global tracker directly.

## File Layout

```
core/tasks/
  task_progress.dart       -- Sealed progress hierarchy
  tracked_task.dart        -- TrackedTask model + TaskStatus enum
  cancellation_token.dart  -- Cooperative cancellation (pure Dart, no Dio)
  task_tracker.dart        -- TaskTracker notifier, failures, IMap filters
  task_tracker.g.dart      -- Generated Riverpod code
  task_channel.dart        -- Feature-scoped wrapper
```

## Key Types

| Type | Purpose |
|---|---|
| `TaskTracker` | `@Riverpod(keepAlive: true)` notifier. State is `IMap<String, TrackedTask>`. |
| `TaskChannel` | Plain class. Binds a category, concurrency limit, and defaults. |
| `TrackedTask` | Immutable model: `id`, `category`, `label`, `status`, `progress`, `failure`, `result`. |
| `TaskStatus` | Enum: `pending`, `running`, `completed`, `failed`, `cancelled`. |
| `TaskProgress` | Sealed class: `IndeterminateProgress`, `DeterminateProgress(fraction)`, `PhasedProgress(label, [fraction])`. |
| `CancellationToken` | Cooperative cancel signal. Pure Dart — no Dio dependency. |
| `TaskWork<T>` | Typedef: `Future<T> Function(CancellationToken, void Function(TaskProgress))`. |

## Feature Integration Pattern

### 1. Create a TaskChannel provider

Each feature creates a single `@riverpod` provider that returns a `TaskChannel`:

```dart
@riverpod
TaskChannel uploadTasks(Ref ref) => TaskChannel(
  tracker: ref.read(taskTrackerProvider.notifier),
  category: 'uploads',
  maxConcurrent: 3,
  retryable: true,
);
```

### 2. Submit tasks from a ViewModel

```dart
@riverpod
class AvatarUploadViewModel extends _$AvatarUploadViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> upload(Uint8List bytes) async {
    final channel = ref.read(uploadTasksProvider);

    final result = await channel.run<String>(
      id: 'avatar',         // becomes 'uploads/avatar'
      label: 'Uploading avatar',
      work: (token, report) async {
        report(TaskProgress.determinate(0));
        final url = await _uploadWithProgress(bytes, token, report);
        return url;
      },
    );

    result.when(
      success: (url) => state = AsyncData(null),
      failure: (f) => state = AsyncError(f, StackTrace.current),
    );
  }
}
```

### 3. Watch tasks from the UI

Use `ref.watch` with the channel's `selector` to rebuild only when this feature's tasks change:

```dart
class UploadStatusBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channel = ref.read(uploadTasksProvider);
    final tasks = ref.watch(
      taskTrackerProvider.select(channel.selector),
    );

    return Column(
      children: [
        for (final entry in tasks.entries)
          _UploadTile(task: entry.value),
      ],
    );
  }
}
```

### 4. Query individual tasks

```dart
final task = channel.task(allTasks, 'avatar');  // looks up 'uploads/avatar'
final isUploading = channel.hasRunning(allTasks);
```

### 5. Cancel, retry, dismiss

```dart
channel.cancel('avatar');
await channel.retry<String>('avatar');
channel.dismiss('avatar');
channel.dismissCompleted();
```

## Progress Reporting

The work function receives a `report` callback. Call it with any `TaskProgress` variant:

```dart
// Numeric progress (progress bar)
report(TaskProgress.determinate(bytesSent / totalBytes));

// Labeled phase (status text)
report(const TaskProgress.phased('Compressing'));

// Phase with numeric sub-progress
report(TaskProgress.phased('Uploading', bytesSent / totalBytes));

// Unknown duration (spinner)
report(const TaskProgress.indeterminate());
```

The UI reads `TrackedTask.progress` and pattern-matches:

```dart
switch (task.progress) {
  IndeterminateProgress() => const CircularProgressIndicator(),
  DeterminateProgress(:final fraction) =>
    LinearProgressIndicator(value: fraction),
  PhasedProgress(:final label, :final fraction) => Column(
    children: [
      Text(label),
      if (fraction != null) LinearProgressIndicator(value: fraction),
    ],
  ),
}
```

## Cooperative Cancellation

`CancellationToken` is pure Dart. Features that use Dio bridge to Dio's `CancelToken` themselves:

```dart
work: (token, report) async {
  final dioCancel = CancelToken();
  token.cancelled.then((_) => dioCancel.cancel('Task cancelled'));

  final response = await dio.post(
    '/upload',
    data: formData,
    cancelToken: dioCancel,
    onSendProgress: (sent, total) {
      report(TaskProgress.determinate(sent / total));
    },
  );

  return response.data['url'] as String;
}
```

For non-Dio work, check at safe points:

```dart
work: (token, report) async {
  for (final chunk in chunks) {
    token.throwIfCancelled();
    await processChunk(chunk);
    report(TaskProgress.determinate(processed / total));
  }
  return 'done';
}
```

## Throttling

Categories with a registered `maxConcurrent` limit queue excess tasks as `TaskStatus.pending` and auto-promote them when slots open:

```dart
// In the TaskChannel constructor:
TaskChannel(
  tracker: tracker,
  category: 'uploads',
  maxConcurrent: 3,   // at most 3 concurrent uploads
);

// Or manually:
tracker.registerCategory('uploads', maxConcurrent: 3);
```

Tasks submitted beyond the limit enter `pending` state. When a running task completes, fails, or is cancelled, the next pending task starts automatically.

## Retry

Tasks submitted with `retryable: true` retain their work factory after failure or cancellation. Call `retry<T>()` to re-execute with a fresh `CancellationToken`:

```dart
final result = await channel.retry<String>('avatar');
```

Non-retryable tasks return `Err(TaskNotRetryable(...))` on retry attempts.

## Task Failures

The tracker defines four failure types (all extend `Failure`):

| Failure | When |
|---|---|
| `TaskAlreadyRunning` | Submitting a task with an ID that is already running or pending |
| `TaskCancelled` | Task was cancelled (returned from `run()` or `retry()`) |
| `TaskNotRetryable` | Calling `retry()` on a task that was not marked retryable |
| `TaskNotFound` | Calling `retry()` with an unknown ID |

## IMap Filtering Extensions

`TaskMapFilters` on `IMap<String, TrackedTask>` provides efficient queries:

| Method | Returns |
|---|---|
| `byCategory(category)` | All tasks in the category |
| `runningInCategory(category)` | Only running tasks in the category |
| `terminalInCategory(category)` | Only completed/failed/cancelled tasks |
| `hasRunningIn(category)` | `bool` — any running task in the category |

These are used internally by `TaskChannel` and can be used directly with `ref.watch(...select(...))` if needed.

## DO

- Create one `TaskChannel` per feature category.
- Use the channel's `selector` getter with `ref.watch` for efficient UI rebuilds.
- Report progress via the `report` callback — do not mutate tracker state directly.
- Bridge to Dio's `CancelToken` inside the work function, not in the tracker.
- Use `PhasedProgress` for multi-step tasks to give the user context.
- Mark tasks as `retryable: true` when the operation is safe to repeat.
- Await all task futures in tests before disposing the `ProviderContainer`.

## DO NOT

- Do not use `taskTrackerProvider` directly from feature code — use `TaskChannel`.
- Do not make `TrackedTask` generic — task results are typed at the `run<T>()` / `retry<T>()` call site and returned via the `Future<Result<T>>`.
- Do not store sensitive data in `TrackedTask.result` — it is held in memory as `Object?`.
- Do not use `@MappableClass` for `TaskProgress` or `TrackedTask` — they are state types, not serialised DTOs (see rule 06).
- Do not use `@Riverpod` annotations on `TaskChannel` — it is a plain class returned from a functional provider.
- Do not create categories without a concurrency limit unless unbounded parallelism is intentional.
