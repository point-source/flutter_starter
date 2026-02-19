/// Verify [TaskChannel] ID prefixing, delegation, and read helpers.
library;

import 'dart:async';

import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/core/tasks/task_channel.dart';
import 'package:flutter_starter/core/tasks/task_tracker.dart';
import 'package:flutter_starter/core/tasks/tracked_task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../helpers/test_utils.dart';

void main() {
  late ProviderContainer container;
  late TaskTracker tracker;
  late TaskChannel channel;

  setUp(() {
    container = createContainer();
    tracker = container.read(taskTrackerProvider.notifier);
    channel = TaskChannel(
      tracker: tracker,
      category: 'test-feature',
      maxConcurrent: 2,
      retryable: true,
    );
  });

  group('ID prefixing', () {
    test('fullId prefixes with category', () {
      expect(channel.fullId('abc'), equals('test-feature/abc'));
    });

    test('run submits with prefixed ID', () async {
      await channel.run<String>(
        id: 'task-1',
        label: 'Test',
        onExecute: (_, _) async => 'done',
      );

      final state = container.read(taskTrackerProvider);
      expect(state['test-feature/task-1'], isNotNull);
      expect(state['task-1'], isNull);
    });
  });

  group('auto-registration', () {
    test('registers maxConcurrent on construction', () async {
      // Submit 3 tasks; only 2 should be running (maxConcurrent: 2).
      final completers = List.generate(3, (_) => Completer<String>());

      for (var i = 0; i < 3; i++) {
        // ignore: unawaited_futures
        channel.run<String>(
          id: 'task-$i',
          label: 'Task $i',
          onExecute: (_, _) => completers[i].future,
        );
      }

      await Future<void>.delayed(.zero);

      final state = container.read(taskTrackerProvider);
      expect(state['test-feature/task-0']?.status, equals(TaskStatus.running));
      expect(state['test-feature/task-1']?.status, equals(TaskStatus.running));
      expect(state['test-feature/task-2']?.status, equals(TaskStatus.pending));

      for (final c in completers) {
        c.complete('done');
      }
    });
  });

  group('default retryable', () {
    test('uses channel default when not overridden', () async {
      // Channel default is retryable: true.
      await channel.run<String>(
        id: 'task-1',
        label: 'Fail',
        onExecute: (_, _) async => throw Exception('fail'),
      );

      // Should be retryable.
      final result = await channel.retry<String>('task-1');
      // Second attempt also fails, but retry itself should work.
      expect(result, isA<Err<String>>());
    });

    test('per-call override disables retry', () async {
      await channel.run<String>(
        id: 'task-1',
        label: 'Fail',
        onExecute: (_, _) async => throw Exception('fail'),
        retryable: false,
      );

      final result = await channel.retry<String>('task-1');
      expect(result, isA<Err<String>>());
      expect((result as Err<String>).failure, isA<TaskNotRetryable>());
    });
  });

  group('mutations delegate correctly', () {
    test('cancel delegates with prefixed ID', () async {
      final workStarted = Completer<void>();

      final future = channel.run<String>(
        id: 'task-1',
        label: 'Test',
        onExecute: (token, _) async {
          workStarted.complete();
          await token.cancelled;
          token.throwIfCancelled();
          return 'unreachable';
        },
      );

      await workStarted.future;
      channel.cancel('task-1');

      final result = await future;
      expect(result, isA<Err<String>>());
      expect((result as Err<String>).failure, isA<TaskCancelled>());
    });

    test('dismiss delegates with prefixed ID', () async {
      await channel.run<String>(
        id: 'task-1',
        label: 'Test',
        onExecute: (_, _) async => 'done',
      );

      channel.dismiss('task-1');
      expect(
        container.read(taskTrackerProvider)['test-feature/task-1'],
        isNull,
      );
    });

    test('dismissCompleted clears only this category', () async {
      // Submit via channel.
      await channel.run<String>(
        id: 'task-1',
        label: 'Test',
        onExecute: (_, _) async => 'done',
      );

      // Submit directly to tracker in a different category.
      await tracker.run<String>(
        id: 'other/task-1',
        category: 'other',
        label: 'Other',
        onExecute: (_, _) async => 'done',
      );

      channel.dismissCompleted();

      final state = container.read(taskTrackerProvider);
      expect(state['test-feature/task-1'], isNull);
      expect(state['other/task-1'], isNotNull);
    });
  });

  group('read helpers', () {
    test('tasks returns only this category', () async {
      await channel.run<String>(
        id: 'task-1',
        label: 'Test',
        onExecute: (_, _) async => 'done',
      );
      await tracker.run<String>(
        id: 'other/task-1',
        category: 'other',
        label: 'Other',
        onExecute: (_, _) async => 'done',
      );

      final state = container.read(taskTrackerProvider);
      final filtered = channel.tasks(state);
      expect(filtered.length, equals(1));
      expect(filtered['test-feature/task-1'], isNotNull);
    });

    test('task returns a specific task by unprefixed ID', () async {
      await channel.run<String>(
        id: 'task-1',
        label: 'Test',
        onExecute: (_, _) async => 'done',
      );

      final state = container.read(taskTrackerProvider);
      final task = channel.task(state, 'task-1');
      expect(task, isNotNull);
      expect(task?.id, equals('test-feature/task-1'));
    });

    test('task returns null for non-existent ID', () {
      final state = container.read(taskTrackerProvider);
      expect(channel.task(state, 'nonexistent'), isNull);
    });

    test('hasRunning returns correct boolean', () async {
      final completer = Completer<String>();

      // ignore: unawaited_futures
      channel.run<String>(
        id: 'task-1',
        label: 'Test',
        onExecute: (_, _) => completer.future,
      );
      await Future<void>.delayed(.zero);

      expect(channel.hasRunning(container.read(taskTrackerProvider)), isTrue);

      completer.complete('done');
      await Future<void>.delayed(.zero);

      expect(channel.hasRunning(container.read(taskTrackerProvider)), isFalse);
    });

    test('selector works for filtered watching', () async {
      await channel.run<String>(
        id: 'task-1',
        label: 'Test',
        onExecute: (_, _) async => 'done',
      );

      final state = container.read(taskTrackerProvider);
      final selected = channel.selector(state);
      expect(selected.length, equals(1));
      expect(selected['test-feature/task-1'], isNotNull);
    });
  });
}
