/// Verify [TaskTracker] lifecycle, throttling, cancellation, retry, and
/// filtering extensions.
library;

import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/core/logging/logger_provider.dart';
import 'package:flutter_starter/core/tasks/task_progress.dart';
import 'package:flutter_starter/core/tasks/task_tracker.dart';
import 'package:flutter_starter/core/tasks/tracked_task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_utils.dart';

void main() {
  late ProviderContainer container;
  late TaskTracker tracker;

  setUp(() {
    container = createContainer(
      overrides: [loggerProvider.overrideWithValue(MockAppLogger())],
    );
    tracker = container.read(taskTrackerProvider.notifier);
  });

  IMap<String, TrackedTask> currentState() =>
      container.read(taskTrackerProvider);

  // -----------------------------------------------------------------------
  // run()
  // -----------------------------------------------------------------------

  group('run', () {
    test('successful work completes with Success', () async {
      final result = await tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'Test',
        onExecute: (_, _) async => 'hello',
      );

      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, equals('hello'));
    });

    test('task transitions through pending → running → completed', () async {
      final workStarted = Completer<void>();
      final workComplete = Completer<String>();

      final future = tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'Test',
        onExecute: (_, _) async {
          workStarted.complete();
          return workComplete.future;
        },
      );

      await workStarted.future;
      expect(currentState()['task-1']?.status, equals(TaskStatus.running));

      workComplete.complete('done');
      await future;
      expect(currentState()['task-1']?.status, equals(TaskStatus.completed));
    });

    test('failing work completes with Err', () async {
      final result = await tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'Test',
        onExecute: (_, _) async => throw Exception('boom'),
      );

      expect(result, isA<Err<String>>());
      expect(currentState()['task-1']?.status, equals(TaskStatus.failed));
    });

    test('rejects duplicate non-terminal task', () async {
      final workComplete = Completer<String>();

      // Start a task that blocks.
      // ignore: unawaited_futures
      tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'Test',
        onExecute: (_, _) => workComplete.future,
      );

      // Wait for it to start running.
      await Future<void>.delayed(.zero);

      // Try to submit another with the same ID.
      final result = await tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'Test 2',
        onExecute: (_, _) async => 'nope',
      );

      expect(result, isA<Err<String>>());
      expect((result as Err<String>).failure, isA<TaskAlreadyRunning>());

      // Clean up.
      workComplete.complete('done');
    });

    test('replaces terminal task with same ID', () async {
      // First task completes.
      await tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'First',
        onExecute: (_, _) async => 'first',
      );
      expect(currentState()['task-1']?.status, equals(TaskStatus.completed));

      // Second task with same ID starts.
      final result = await tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'Second',
        onExecute: (_, _) async => 'second',
      );

      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, equals('second'));
    });

    test('progress reporting updates state', () async {
      final progressValues = <TaskProgress>[];
      final workStarted = Completer<void>();
      final continueWork = Completer<void>();

      final future = tracker.run<void>(
        id: 'task-1',
        category: 'test',
        label: 'Test',
        onExecute: (_, report) async {
          workStarted.complete();
          report(const TaskProgress.determinate(0.5));
          await continueWork.future;
        },
      );

      await workStarted.future;
      // Give microtask queue a chance to process.
      await Future<void>.delayed(.zero);
      progressValues.add(currentState()['task-1']!.progress);

      continueWork.complete();
      await future;

      // ignore: avoid-unsafe-collection-methods
      expect(progressValues.first, equals(const TaskProgress.determinate(0.5)));
      // After completion, progress is set to 1.0.
      expect(
        currentState()['task-1']?.progress,
        equals(const TaskProgress.determinate(1)),
      );
    });
  });

  // -----------------------------------------------------------------------
  // cancel()
  // -----------------------------------------------------------------------

  group('cancel', () {
    test('cancels a running task', () async {
      final workStarted = Completer<void>();

      final future = tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'Test',
        onExecute: (token, _) async {
          workStarted.complete();
          // Simulate work that checks cancellation.
          await Future<void>.delayed(const Duration(milliseconds: 50));
          token.throwIfCancelled();
          return 'done';
        },
      );

      await workStarted.future;
      tracker.cancel('task-1');

      final result = await future;
      expect(result, isA<Err<String>>());
      expect((result as Err<String>).failure, isA<TaskCancelled>());
      expect(currentState()['task-1']?.status, equals(TaskStatus.cancelled));
    });

    test('cancels a pending (throttled) task immediately', () async {
      tracker.registerCategory('throttled', maxConcurrent: 1);

      final firstComplete = Completer<String>();

      // First task occupies the slot.
      // ignore: unawaited_futures
      tracker.run<String>(
        id: 'task-1',
        category: 'throttled',
        label: 'First',
        onExecute: (_, _) => firstComplete.future,
      );
      await Future<void>.delayed(.zero);

      // Second task is pending.
      final secondFuture = tracker.run<String>(
        id: 'task-2',
        category: 'throttled',
        label: 'Second',
        onExecute: (_, _) async => 'second',
      );

      expect(currentState()['task-2']?.status, equals(TaskStatus.pending));

      // Cancel the pending task.
      tracker.cancel('task-2');
      final result = await secondFuture;

      expect(result, isA<Err<String>>());
      expect((result as Err<String>).failure, isA<TaskCancelled>());
      expect(currentState()['task-2']?.status, equals(TaskStatus.cancelled));

      // Clean up.
      firstComplete.complete('done');
    });

    test('does nothing for non-existent task', () {
      expect(() => tracker.cancel('nonexistent'), returnsNormally);
    });

    test('does nothing for terminal task', () async {
      await tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'Test',
        onExecute: (_, _) async => 'done',
      );

      expect(() => tracker.cancel('task-1'), returnsNormally);
      expect(currentState()['task-1']?.status, equals(TaskStatus.completed));
    });
  });

  // -----------------------------------------------------------------------
  // retry()
  // -----------------------------------------------------------------------

  group('retry', () {
    test('retries a failed retryable task', () async {
      var attempts = 0;

      // First attempt fails.
      await tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'Test',
        retryable: true,
        onExecute: (_, _) async {
          attempts++;
          if (attempts == 1) throw Exception('fail');
          return 'success';
        },
      );
      expect(currentState()['task-1']?.status, equals(TaskStatus.failed));

      // Retry succeeds.
      final result = await tracker.retry<String>('task-1');
      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, equals('success'));
      expect(attempts, equals(2));
    });

    test('returns TaskNotRetryable for non-retryable task', () async {
      await tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'Test',
        onExecute: (_, _) async => throw Exception('fail'),
      );

      final result = await tracker.retry<String>('task-1');
      expect(result, isA<Err<String>>());
      expect((result as Err<String>).failure, isA<TaskNotRetryable>());
    });

    test('returns TaskNotFound for non-existent task', () async {
      final result = await tracker.retry<String>('nonexistent');
      expect(result, isA<Err<String>>());
      expect((result as Err<String>).failure, isA<TaskNotFound>());
    });

    test('returns TaskAlreadyRunning for running task', () async {
      final workComplete = Completer<String>();

      // ignore: unawaited_futures
      tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'Test',
        retryable: true,
        onExecute: (_, _) => workComplete.future,
      );

      await Future<void>.delayed(.zero);

      final result = await tracker.retry<String>('task-1');
      expect(result, isA<Err<String>>());
      expect((result as Err<String>).failure, isA<TaskAlreadyRunning>());

      workComplete.complete('done');
    });
  });

  // -----------------------------------------------------------------------
  // dismiss()
  // -----------------------------------------------------------------------

  group('dismiss', () {
    test('removes a completed task', () async {
      await tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'Test',
        onExecute: (_, _) async => 'done',
      );
      expect(currentState()['task-1'], isNotNull);

      tracker.dismiss('task-1');
      expect(currentState()['task-1'], isNull);
    });

    test('does not remove a running task', () async {
      final workComplete = Completer<String>();

      // ignore: unawaited_futures
      tracker.run<String>(
        id: 'task-1',
        category: 'test',
        label: 'Test',
        onExecute: (_, _) => workComplete.future,
      );

      await Future<void>.delayed(.zero);
      tracker.dismiss('task-1');
      expect(currentState()['task-1'], isNotNull);

      workComplete.complete('done');
    });

    test('dismissCompleted removes all terminal tasks', () async {
      await tracker.run<String>(
        id: 'task-1',
        category: 'a',
        label: 'Test 1',
        onExecute: (_, _) async => 'done',
      );
      await tracker.run<String>(
        id: 'task-2',
        category: 'b',
        label: 'Test 2',
        onExecute: (_, _) async => throw Exception('fail'),
      );

      expect(currentState().length, equals(2));

      tracker.dismissCompleted();
      expect(currentState().length, equals(0));
    });

    test('dismissCompleted with category only removes that category', () async {
      await tracker.run<String>(
        id: 'task-1',
        category: 'a',
        label: 'Test 1',
        onExecute: (_, _) async => 'done',
      );
      await tracker.run<String>(
        id: 'task-2',
        category: 'b',
        label: 'Test 2',
        onExecute: (_, _) async => 'done',
      );

      tracker.dismissCompleted(category: 'a');
      expect(currentState()['task-1'], isNull);
      expect(currentState()['task-2'], isNotNull);
    });
  });

  // -----------------------------------------------------------------------
  // Throttling
  // -----------------------------------------------------------------------

  group('throttling', () {
    test('limits concurrent tasks per category', () async {
      tracker.registerCategory('throttled', maxConcurrent: 2);

      final completers = List.generate(4, (_) => Completer<String>());

      for (var i = 0; i < 4; i++) {
        // ignore: unawaited_futures
        tracker.run<String>(
          id: 'task-$i',
          category: 'throttled',
          label: 'Task $i',
          // ignore: avoid-unsafe-collection-methods
          onExecute: (_, _) => completers[i].future,
        );
      }

      await Future<void>.delayed(.zero);

      // First 2 should be running, last 2 pending.
      expect(currentState()['task-0']?.status, equals(TaskStatus.running));
      expect(currentState()['task-1']?.status, equals(TaskStatus.running));
      expect(currentState()['task-2']?.status, equals(TaskStatus.pending));
      expect(currentState()['task-3']?.status, equals(TaskStatus.pending));

      // Complete one — a pending task should start.
      // ignore: avoid-unsafe-collection-methods
      completers[0].complete('done');
      await Future<void>.delayed(.zero);

      expect(currentState()['task-0']?.status, equals(TaskStatus.completed));
      expect(currentState()['task-2']?.status, equals(TaskStatus.running));
      // Verify task-3 is still pending after task-2 was promoted.
      expect(currentState()['task-3']?.status, same(TaskStatus.pending));

      // Clean up.
      for (var i = 1; i < 4; i++) {
        // ignore: avoid-unsafe-collection-methods
        if (!completers[i].isCompleted) completers[i].complete('done');
      }
    });

    test('cancelling a running task starts the next pending one', () async {
      tracker.registerCategory('throttled', maxConcurrent: 1);

      final firstStarted = Completer<void>();
      final secondComplete = Completer<String>();

      // ignore: unawaited_futures
      tracker.run<String>(
        id: 'task-1',
        category: 'throttled',
        label: 'First',
        onExecute: (token, _) async {
          firstStarted.complete();
          await token.cancelled;
          token.throwIfCancelled();
          return 'unreachable';
        },
      );

      // ignore: unawaited_futures, cascade_invocations
      tracker.run<String>(
        id: 'task-2',
        category: 'throttled',
        label: 'Second',
        onExecute: (_, _) => secondComplete.future,
      );

      await firstStarted.future;
      expect(currentState()['task-2']?.status, equals(TaskStatus.pending));

      // Cancel the running task.
      tracker.cancel('task-1');
      await Future<void>.delayed(.zero);

      // The pending task should now be running.
      expect(currentState()['task-2']?.status, equals(TaskStatus.running));

      secondComplete.complete('done');
    });

    test('unregistered categories run all tasks immediately', () async {
      final completers = List.generate(3, (_) => Completer<String>());

      for (var i = 0; i < 3; i++) {
        // ignore: unawaited_futures
        tracker.run<String>(
          id: 'task-$i',
          category: 'unlimited',
          label: 'Task $i',
          // ignore: avoid-unsafe-collection-methods
          onExecute: (_, _) => completers[i].future,
        );
      }

      await Future<void>.delayed(.zero);

      for (var i = 0; i < 3; i++) {
        expect(currentState()['task-$i']?.status, equals(TaskStatus.running));
      }

      // Clean up.
      for (final c in completers) {
        c.complete('done');
      }
    });
  });

  // -----------------------------------------------------------------------
  // IMap filtering extensions
  // -----------------------------------------------------------------------

  group('TaskMapFilters', () {
    test('byCategory returns only matching tasks', () async {
      await tracker.run<String>(
        id: 'a-1',
        category: 'a',
        label: 'A1',
        onExecute: (_, _) async => 'done',
      );
      await tracker.run<String>(
        id: 'b-1',
        category: 'b',
        label: 'B1',
        onExecute: (_, _) async => 'done',
      );

      final filtered = currentState().byCategory('a');
      expect(filtered.length, equals(1));
      expect(filtered['a-1'], isNotNull);
    });

    test('runningInCategory returns only running tasks in category', () async {
      tracker.registerCategory('cat', maxConcurrent: 1);

      final completer1 = Completer<String>();
      final completer2 = Completer<String>();

      // ignore: unawaited_futures
      final future1 = tracker.run<String>(
        id: 'task-1',
        category: 'cat',
        label: 'Running',
        onExecute: (_, _) => completer1.future,
      );
      // ignore: unawaited_futures
      final future2 = tracker.run<String>(
        id: 'task-2',
        category: 'cat',
        label: 'Pending',
        onExecute: (_, _) => completer2.future,
      );

      await Future<void>.delayed(.zero);

      final running = currentState().runningInCategory('cat');
      expect(running.length, equals(1));
      expect(running['task-1'], isNotNull);

      // Clean up: complete both tasks and await them so async callbacks
      // finish before the container is disposed.
      completer1.complete('done');
      completer2.complete('done');
      await future1;
      await future2;
    });

    test('hasRunningIn returns correct boolean', () async {
      final completer = Completer<String>();

      // ignore: unawaited_futures
      tracker.run<String>(
        id: 'task-1',
        category: 'cat',
        label: 'Test',
        onExecute: (_, _) => completer.future,
      );
      await Future<void>.delayed(.zero);

      expect(currentState().hasRunningIn('cat'), isTrue);
      expect(currentState().hasRunningIn('other'), isFalse);

      completer.complete('done');
      await Future<void>.delayed(.zero);

      expect(currentState().hasRunningIn('cat'), isFalse);
    });

    test('terminalInCategory returns only terminal tasks', () async {
      await tracker.run<String>(
        id: 'task-1',
        category: 'cat',
        label: 'Done',
        onExecute: (_, _) async => 'done',
      );

      final completer = Completer<String>();
      final future = tracker.run<String>(
        id: 'task-2',
        category: 'cat',
        label: 'Running',
        onExecute: (_, _) => completer.future,
      );

      await Future<void>.delayed(.zero);

      final terminal = currentState().terminalInCategory('cat');
      expect(terminal.length, equals(1));
      expect(terminal['task-1'], isNotNull);

      completer.complete('done');
      await future;
    });
  });
}
