/// Manage background task lifecycle, progress, cancellation, and throttling.
///
/// Provides the [TaskTracker] Riverpod notifier that orchestrates all
/// tracked tasks across features. Also defines task-specific [Failure]
/// types and [IMap] filtering extensions.
///
/// Features should use [TaskChannel] for a scoped, lower-boilerplate API
/// rather than interacting with [TaskTracker] directly.
library;

import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/core/tasks/cancellation_token.dart';
import 'package:flutter_starter/core/tasks/task_progress.dart';
import 'package:flutter_starter/core/tasks/tracked_task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_tracker.g.dart';

// ---------------------------------------------------------------------------
// Typedef
// ---------------------------------------------------------------------------

/// The signature of a work function submitted to [TaskTracker.run].
///
/// Receives a [CancellationToken] for cooperative cancellation and a
/// [report] callback for progress updates. Returns the task's result
/// value — the tracker wraps it in [Result] automatically.
typedef TaskWork<T> =
    Future<T> Function(
      CancellationToken token,
      void Function(TaskProgress progress) report,
    );

// ---------------------------------------------------------------------------
// Internal bookkeeping
// ---------------------------------------------------------------------------

/// Store the execute callback, cancellation token, and completer for a task.
///
/// Held in a separate mutable map from the public [IMap] state so that
/// function references and tokens do not leak into the immutable state.
class _TaskEntry<T> {
  const _TaskEntry({
    required this.onExecute,
    required this.token,
    required this.completer,
    required this.retryable,
  });

  final TaskWork<T> onExecute;
  final CancellationToken token;
  final Completer<Result<T>> completer;
  final bool retryable;

  /// Complete the completer with a cancellation failure.
  ///
  /// This preserves the generic [T] so that `Err<T>` matches the
  /// `Completer<Result<T>>` type, avoiding the `Err<dynamic>` mismatch
  /// that occurs when accessing the entry as `_TaskEntry<dynamic>`.
  void completeWithCancellation(String id) {
    if (!completer.isCompleted) {
      completer.complete(Err<T>(TaskCancelled('Task "$id" was cancelled')));
    }
  }

  /// Execute the callback with proper generic typing preserved.
  ///
  /// This method exists so that the generic [T] is captured at the
  /// call site (where `_TaskEntry<T>` is constructed) rather than
  /// being lost when the entry is stored as `_TaskEntry<dynamic>`.
  Future<void> execute(
    void Function(String, TaskProgress) reportProgress,
    String id,
    void Function<R>(String, _TaskEntry<R>, R) onCompleted,
    void Function<R>(String, _TaskEntry<R>, Failure) onFailed,
    void Function<R>(String, _TaskEntry<R>) onCancelled,
  ) async {
    try {
      final result = await onExecute(
        token,
        (progress) => reportProgress(id, progress),
      );

      if (token.isCancelled) {
        onCancelled<T>(id, this);
        return;
      }

      onCompleted<T>(id, this, result);
    } on CancelledException catch (_) {
      onCancelled<T>(id, this);
    } on Exception catch (e, st) {
      onFailed<T>(id, this, UnexpectedFailure(e, st));
    }
  }
}

// ---------------------------------------------------------------------------
// TaskTracker notifier
// ---------------------------------------------------------------------------

/// Track, throttle, cancel, and retry background tasks across all features.
///
/// State is an `IMap<String, TrackedTask>` holding every active or
/// recently-terminal task. Use [TaskChannel] for feature-scoped access.
///
/// ```dart
/// final tracker = ref.read(taskTrackerProvider.notifier);
/// tracker.registerCategory('uploads', maxConcurrent: 3);
///
/// final result = await tracker.run<String>(
///   id: 'upload/avatar',
///   category: 'uploads',
///   label: 'Uploading avatar',
///   onExecute: (token, report) async {
///     report(TaskProgress.determinate(0));
///     // ... do work ...
///     return 'https://cdn.example.com/avatar.png';
///   },
/// );
/// ```
@Riverpod(keepAlive: true)
class TaskTracker extends _$TaskTracker {
  final Map<String, _TaskEntry<Object?>> _entries = {};
  final Map<String, int> _categoryLimits = {};

  @override
  IMap<String, TrackedTask> build() => const IMapConst({});

  // -----------------------------------------------------------------------
  // Public API
  // -----------------------------------------------------------------------

  /// Register a concurrency limit for a [category].
  ///
  /// Tasks in this category are throttled so at most [maxConcurrent] run
  /// simultaneously. Excess tasks queue as [TaskStatus.pending] and start
  /// automatically when slots open.
  ///
  /// Call once per category during feature initialisation. Calling again
  /// for the same category overwrites the previous limit.
  void registerCategory(String category, {required int maxConcurrent}) {
    assert(maxConcurrent > 0, 'maxConcurrent must be positive');
    _categoryLimits[category] = maxConcurrent;
  }

  /// Submit a background task for tracking.
  ///
  /// Returns a [Future] that completes with [Success] containing the
  /// result, or [Err] containing a [Failure] if the task fails, is
  /// cancelled, or cannot be started.
  ///
  /// If a task with the same [id] already exists and is not in a terminal
  /// state, returns [Err] with [TaskAlreadyRunning].
  ///
  /// When [retryable] is `true` the [onExecute] callback is retained so the task
  /// can be re-run via [retry] after failure or cancellation.
  Future<Result<T>> run<T>({
    required String id,
    required String category,
    required String label,
    required TaskWork<T> onExecute,
    bool retryable = false,
  }) {
    // Reject duplicate non-terminal tasks.
    final existing = state[id];
    if (existing != null && !existing.isTerminal) {
      return Future.value(
        Err(TaskAlreadyRunning('Task "$id" is already running')),
      );
    }

    final token = CancellationToken();
    final completer = Completer<Result<T>>();

    _entries[id] = _TaskEntry<T>(
      onExecute: onExecute,
      token: token,
      completer: completer,
      retryable: retryable,
    );

    state = state.add(
      id,
      TrackedTask(
        id: id,
        category: category,
        label: label,
        status: .pending,
        createdAt: DateTime.now(),
      ),
    );

    _tryStartNext(category);

    return completer.future;
  }

  /// Cancel a task by [id].
  ///
  /// Pending tasks are immediately transitioned to [TaskStatus.cancelled].
  /// Running tasks receive a cancellation signal via the
  /// [CancellationToken]; the callback should cooperatively check
  /// [CancellationToken.throwIfCancelled].
  void cancel(String id) {
    final task = state[id];
    if (task == null || task.isTerminal) return;

    final entry = _entries[id];
    entry?.token.cancel();

    if (task.status == .pending) {
      // Pending tasks can be cancelled immediately.
      state = state.add(id, task.copyWith(status: .cancelled));
      entry?.completeWithCancellation(id);
      _cleanupEntry(id, retainIfRetryable: true);
      _tryStartNext(task.category);
    } else {
      // Running tasks: set status for immediate UI feedback. The
      // _executeWork method handles completer completion when the
      // work function responds to cancellation.
      state = state.add(id, task.copyWith(status: .cancelled));
    }
  }

  /// Retry a previously failed or cancelled task.
  ///
  /// Only works if the task was submitted with `retryable: true` and is
  /// in a terminal state. The stored callback is re-executed with a
  /// fresh [CancellationToken].
  Future<Result<T>> retry<T>(String id) {
    final task = state[id];
    if (task == null) {
      return Future.value(Err(TaskNotFound('Task "$id" not found')));
    }
    if (!task.isTerminal) {
      return Future.value(
        Err(TaskAlreadyRunning('Task "$id" is not in a terminal state')),
      );
    }

    final entry = _entries[id];
    if (entry == null || !entry.retryable) {
      return Future.value(Err(TaskNotRetryable('Task "$id" is not retryable')));
    }

    // Extract callback before removing the entry.
    final onExecute = entry.onExecute as TaskWork<T>;
    _entries.remove(id);

    return run(
      id: id,
      category: task.category,
      label: task.label,
      retryable: true,
      onExecute: onExecute,
    );
  }

  /// Remove a terminal task from the state map.
  void dismiss(String id) {
    final task = state[id];
    if (task == null || !task.isTerminal) return;
    state = state.remove(id);
    _cleanupEntry(id, retainIfRetryable: false);
  }

  /// Remove all terminal tasks, optionally filtered by [category].
  void dismissCompleted({String? category}) {
    final toRemove = state.entries
        .where(
          (e) =>
              e.value.isTerminal &&
              (category == null || e.value.category == category),
        )
        .toList();

    for (final e in toRemove) {
      state = state.remove(e.key);
      _cleanupEntry(e.key, retainIfRetryable: false);
    }
  }

  // -----------------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------------

  /// Start pending tasks in [category] up to the concurrency limit.
  void _tryStartNext(String category) {
    final limit = _categoryLimits[category];

    if (limit == null) {
      // No throttle — start all pending.
      final pending = state.entries
          .where(
            (e) => e.value.category == category && e.value.status == .pending,
          )
          .toList();
      for (final e in pending) {
        _startTask(e.key);
      }
      return;
    }

    final runningCount = state.values
        .where((t) => t.category == category && t.status == .running)
        .length;

    var available = limit - runningCount;

    final pending = state.entries
        .where(
          (e) => e.value.category == category && e.value.status == .pending,
        )
        .toList();

    for (final e in pending) {
      if (available <= 0) break;
      _startTask(e.key);
      available--;
    }
  }

  /// Transition a task from pending to running and execute its callback.
  void _startTask(String id) {
    final task = state[id];
    final entry = _entries[id];
    if (task == null || entry == null) return;

    state = state.add(id, task.copyWith(status: .running));
    // Delegate to the entry's execute method so the generic T is
    // preserved from when the entry was constructed.
    entry.execute(
      _reportProgress,
      id,
      _onTaskCompleted,
      _onTaskFailed,
      _onTaskCancelled,
    );
  }

  /// Update a task's progress in the state map.
  void _reportProgress(String id, TaskProgress progress) {
    final task = state[id];
    if (task == null || task.status != .running) return;
    state = state.add(id, task.copyWith(progress: progress));
  }

  void _onTaskCompleted<T>(String id, _TaskEntry<T> entry, T result) {
    final task = state[id];
    if (task == null) return;

    state = state.add(
      id,
      task.copyWith(
        status: .completed,
        progress: const TaskProgress.determinate(1),
        result: () => result,
      ),
    );
    if (!entry.completer.isCompleted) {
      entry.completer.complete(Success(result));
    }
    _cleanupEntry(id, retainIfRetryable: false);
    _tryStartNext(task.category);
  }

  void _onTaskFailed<T>(String id, _TaskEntry<T> entry, Failure failure) {
    final task = state[id];
    if (task == null) return;

    state = state.add(
      id,
      task.copyWith(status: .failed, failure: () => failure),
    );
    if (!entry.completer.isCompleted) {
      entry.completer.complete(Err(failure));
    }
    _cleanupEntry(id, retainIfRetryable: true);
    _tryStartNext(task.category);
  }

  void _onTaskCancelled<T>(String id, _TaskEntry<T> entry) {
    final task = state[id];
    if (task == null) return;

    if (task.status != .cancelled) {
      state = state.add(id, task.copyWith(status: .cancelled));
    }

    if (!entry.completer.isCompleted) {
      entry.completer.complete(Err(TaskCancelled('Task "$id" was cancelled')));
    }
    _cleanupEntry(id, retainIfRetryable: true);
    _tryStartNext(task.category);
  }

  /// Remove internal bookkeeping for a task.
  ///
  /// When [retainIfRetryable] is `true` the entry is kept if the task
  /// was submitted with `retryable: true`, so [retry] can re-use the
  /// stored callback.
  void _cleanupEntry(String id, {required bool retainIfRetryable}) {
    final entry = _entries[id];
    if (entry == null) return;
    if (retainIfRetryable && entry.retryable) return;
    _entries.remove(id);
  }
}

// ---------------------------------------------------------------------------
// Task-specific failures
// ---------------------------------------------------------------------------

/// A task with the same ID is already running or pending.
final class TaskAlreadyRunning extends Failure {
  /// Create a [TaskAlreadyRunning] failure.
  const TaskAlreadyRunning(super.message);
}

/// The task was cancelled by the user or system.
final class TaskCancelled extends Failure {
  /// Create a [TaskCancelled] failure.
  const TaskCancelled(super.message);
}

/// The task is not retryable (was not submitted with `retryable: true`).
final class TaskNotRetryable extends Failure {
  /// Create a [TaskNotRetryable] failure.
  const TaskNotRetryable(super.message);
}

/// The task was not found in the tracker.
final class TaskNotFound extends Failure {
  /// Create a [TaskNotFound] failure.
  const TaskNotFound(super.message);
}

// ---------------------------------------------------------------------------
// IMap filtering extensions
// ---------------------------------------------------------------------------

/// Convenience filters on an `IMap<String, TrackedTask>`.
///
/// Use with Riverpod `.select()` for efficient per-feature watching:
///
/// ```dart
/// final uploads = ref.watch(
///   taskTrackerProvider.select((map) => map.byCategory('uploads')),
/// );
/// ```
extension TaskMapFilters on IMap<String, TrackedTask> {
  /// Return all tasks in the given [category].
  IMap<String, TrackedTask> byCategory(String category) =>
      removeWhere((_, task) => task.category != category);

  /// Return all running tasks in [category].
  IMap<String, TrackedTask> runningInCategory(String category) => removeWhere(
    (_, task) => task.category != category || task.status != .running,
  );

  /// Return all terminal tasks in [category].
  IMap<String, TrackedTask> terminalInCategory(String category) =>
      removeWhere((_, task) => task.category != category || !task.isTerminal);

  /// Whether any task in [category] is currently running.
  bool hasRunningIn(String category) => values.any(
    (task) => task.category == category && task.status == .running,
  );
}
