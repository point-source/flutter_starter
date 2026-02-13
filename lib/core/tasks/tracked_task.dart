/// Represent a tracked background task and its lifecycle state.
///
/// [TrackedTask] is the public state type held in the [TaskTracker]'s
/// `IMap<String, TrackedTask>`. It is a plain class (no dart_mappable)
/// because it is never serialised to JSON.
///
/// See also:
/// - [TaskStatus] for the lifecycle enum.
/// - [TaskProgress] for the progress hierarchy.
library;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/core/tasks/task_progress.dart';

/// Enumerate the lifecycle states of a tracked task.
enum TaskStatus {
  /// Queued but not yet started (throttled or waiting for a slot).
  pending,

  /// Currently executing.
  running,

  /// Finished successfully.
  completed,

  /// Finished with an error.
  failed,

  /// Cancelled by the user or system.
  cancelled,
}

/// Represent a tracked background task with its current lifecycle state.
///
/// Equality is based on all fields so that Riverpod `.select()` can
/// detect changes to individual tasks within the `IMap`.
@immutable
class TrackedTask {
  /// Create a [TrackedTask].
  const TrackedTask({
    required this.id,
    required this.category,
    required this.label,
    required this.status,
    this.progress = const TaskProgress.indeterminate(),
    this.failure,
    this.result,
    this.createdAt,
  });

  /// Unique identifier for this task (includes category prefix).
  final String id;

  /// Category for grouping, filtering, and throttle scoping.
  final String category;

  /// Human-readable label for UI display.
  final String label;

  /// Current lifecycle status.
  final TaskStatus status;

  /// Current progress, defaulting to indeterminate.
  final TaskProgress progress;

  /// The failure that caused [TaskStatus.failed], or `null`.
  final Failure? failure;

  /// The successful result value when [TaskStatus.completed], or `null`.
  ///
  /// Typed as [Object?] because the `IMap` holds heterogeneous tasks.
  /// Type safety is preserved at the [TaskTracker.run] call boundary
  /// via the typed `Completer<Result<T>>`.
  final Object? result;

  /// When this task was first created.
  final DateTime? createdAt;

  /// Whether this task is in a terminal state.
  bool get isTerminal => switch (status) {
    TaskStatus.completed || TaskStatus.failed || TaskStatus.cancelled => true,
    TaskStatus.pending || TaskStatus.running => false,
  };

  /// Create a copy with the given fields replaced.
  ///
  /// Nullable fields use a `T? Function()?` wrapper so callers can
  /// explicitly set them to `null` via `failure: () => null`.
  TrackedTask copyWith({
    String? id,
    String? category,
    String? label,
    TaskStatus? status,
    TaskProgress? progress,
    Failure? Function()? failure,
    Object? Function()? result,
    DateTime? createdAt,
  }) =>
      TrackedTask(
        id: id ?? this.id,
        category: category ?? this.category,
        label: label ?? this.label,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        failure: failure != null ? failure() : this.failure,
        result: result != null ? result() : this.result,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackedTask &&
          id == other.id &&
          category == other.category &&
          label == other.label &&
          status == other.status &&
          progress == other.progress &&
          failure == other.failure &&
          result == other.result &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    category,
    label,
    status,
    progress,
    failure,
    result,
    createdAt,
  );

  @override
  String toString() =>
      'TrackedTask(id: $id, category: $category, status: $status, '
      'progress: $progress)';
}
