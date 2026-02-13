/// Verify [TrackedTask] construction, copyWith, equality, and isTerminal.
library;

import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/core/tasks/task_progress.dart';
import 'package:flutter_starter/core/tasks/tracked_task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TrackedTask makeTask({
    String id = 'test-id',
    String category = 'test',
    String label = 'Test task',
    TaskStatus status = .pending,
    TaskProgress progress = const TaskProgress.indeterminate(),
    Failure? failure,
    Object? result,
    DateTime? createdAt,
  }) => .new(
    id: id,
    category: category,
    label: label,
    status: status,
    progress: progress,
    failure: failure,
    result: result,
    createdAt: createdAt,
  );

  group('isTerminal', () {
    test('returns false for pending', () {
      expect(makeTask().isTerminal, isFalse);
    });

    test('returns false for running', () {
      expect(makeTask(status: .running).isTerminal, isFalse);
    });

    test('returns true for completed', () {
      expect(makeTask(status: .completed).isTerminal, isTrue);
    });

    test('returns true for failed', () {
      expect(makeTask(status: .failed).isTerminal, isTrue);
    });

    test('returns true for cancelled', () {
      expect(makeTask(status: .cancelled).isTerminal, isTrue);
    });
  });

  group('copyWith', () {
    test('preserves unchanged fields', () {
      final now = DateTime.now();
      final task = makeTask(
        id: 'abc',
        category: 'uploads',
        label: 'Upload file',
        status: .running,
        progress: const TaskProgress.determinate(0.5),
        createdAt: now,
      );
      final copy = task.copyWith(status: .completed);

      expect(copy.id, equals('abc'));
      expect(copy.category, equals('uploads'));
      expect(copy.label, equals('Upload file'));
      expect(copy.status, equals(TaskStatus.completed));
      expect(copy.progress, equals(const TaskProgress.determinate(0.5)));
      expect(copy.createdAt, equals(now));
    });

    test('explicitly clears failure with () => null', () {
      final task = makeTask(
        status: .failed,
        failure: const UnexpectedFailure('oops'),
      );
      expect(task.failure, isNotNull);

      final copy = task.copyWith(failure: () => null);
      expect(copy.failure, isNull);
    });

    test('explicitly clears result with () => null', () {
      final task = makeTask(status: .completed, result: 'some-url');
      expect(task.result, equals('some-url'));

      final copy = task.copyWith(result: () => null);
      expect(copy.result, isNull);
    });

    test('sets failure from null to a value', () {
      final task = makeTask();
      final copy = task.copyWith(
        failure: () => const UnexpectedFailure('boom'),
      );
      expect(copy.failure, isA<UnexpectedFailure>());
    });
  });

  group('equality', () {
    test('identical tasks are equal', () {
      final now = DateTime(2025);
      final a = makeTask(createdAt: now);
      expect(a, equals(makeTask(createdAt: now)));
      expect(a.hashCode, equals(makeTask(createdAt: now).hashCode));
    });

    test('tasks with different status are not equal', () {
      final a = makeTask();
      final b = makeTask(status: .running);
      expect(a, isNot(equals(b)));
    });

    test('tasks with different progress are not equal', () {
      final a = makeTask(progress: const TaskProgress.determinate(0.1));
      final b = makeTask(progress: const TaskProgress.determinate(0.9));
      expect(a, isNot(equals(b)));
    });

    test('tasks with different ids are not equal', () {
      final a = makeTask(id: 'a');
      final b = makeTask(id: 'b');
      expect(a, isNot(equals(b)));
    });
  });

  group('toString', () {
    test('includes key fields', () {
      final str = makeTask(
        id: 'abc',
        category: 'uploads',
        status: .running,
      ).toString();
      expect(str, contains('abc'));
      expect(str, contains('uploads'));
      expect(str, contains('running'));
    });
  });
}
