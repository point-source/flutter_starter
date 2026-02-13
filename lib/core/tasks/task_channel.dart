/// Provide a feature-scoped handle for submitting and querying tasks.
///
/// [TaskChannel] pre-binds a [category], optional [maxConcurrent] limit,
/// and default [retryable] flag so that feature code does not repeat
/// these values on every call. It auto-prefixes task IDs with the
/// category to avoid cross-feature collisions.
///
/// ```dart
/// @riverpod
/// TaskChannel profileTasks(Ref ref) => TaskChannel(
///   tracker: ref.read(taskTrackerProvider.notifier),
///   category: 'profile',
///   maxConcurrent: 3,
///   retryable: true,
/// );
/// ```
library;

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/core/tasks/task_tracker.dart';
import 'package:flutter_starter/core/tasks/tracked_task.dart';

/// A feature-scoped wrapper around [TaskTracker].
///
/// Binds [category], [maxConcurrent], and [retryable] defaults once so
/// that callers only need to provide [id], [label], and [work].
class TaskChannel {
  /// Create a [TaskChannel].
  ///
  /// If [maxConcurrent] is provided, [TaskTracker.registerCategory] is
  /// called immediately to set the concurrency limit.
  TaskChannel({
    required TaskTracker tracker,
    required this.category,
    int? maxConcurrent,
    this.retryable = false,
  }) : _tracker = tracker {
    if (maxConcurrent != null) {
      _tracker.registerCategory(category, maxConcurrent: maxConcurrent);
    }
  }

  final TaskTracker _tracker;

  /// The category bound to this channel.
  final String category;

  /// The default retryable flag for tasks submitted via this channel.
  final bool retryable;

  // -----------------------------------------------------------------------
  // ID prefixing
  // -----------------------------------------------------------------------

  /// Build a full task ID by prefixing with the [category].
  String fullId(String id) => '$category/$id';

  // -----------------------------------------------------------------------
  // Mutations (delegate to TaskTracker)
  // -----------------------------------------------------------------------

  /// Submit a task. Only [id], [label], and [work] are required.
  ///
  /// [id] is auto-prefixed with [category]. [retryable] defaults to the
  /// channel's default but can be overridden per-call.
  Future<Result<T>> run<T>({
    required String id,
    required String label,
    required TaskWork<T> work,
    bool? retryable,
  }) =>
      _tracker.run<T>(
        id: fullId(id),
        category: category,
        label: label,
        retryable: retryable ?? this.retryable,
        work: work,
      );

  /// Cancel a task by [id] (auto-prefixed).
  void cancel(String id) => _tracker.cancel(fullId(id));

  /// Retry a failed or cancelled task by [id] (auto-prefixed).
  Future<Result<T>> retry<T>(String id) => _tracker.retry<T>(fullId(id));

  /// Dismiss a terminal task by [id] (auto-prefixed).
  void dismiss(String id) => _tracker.dismiss(fullId(id));

  /// Dismiss all terminal tasks in this channel's [category].
  void dismissCompleted() => _tracker.dismissCompleted(category: category);

  // -----------------------------------------------------------------------
  // Reads (query the IMap, filtered to this channel's category)
  // -----------------------------------------------------------------------

  /// Return all tasks in this channel's [category].
  IMap<String, TrackedTask> tasks(IMap<String, TrackedTask> allTasks) =>
      allTasks.byCategory(category);

  /// Return a single task by [id] (auto-prefixed), or `null`.
  TrackedTask? task(IMap<String, TrackedTask> allTasks, String id) =>
      allTasks[fullId(id)];

  /// Whether any task in this channel's [category] is currently running.
  bool hasRunning(IMap<String, TrackedTask> allTasks) =>
      allTasks.hasRunningIn(category);

  /// A Riverpod `.select()` function for this channel's [category].
  ///
  /// ```dart
  /// final tasks = ref.watch(taskTrackerProvider.select(channel.selector));
  /// ```
  IMap<String, TrackedTask> Function(IMap<String, TrackedTask>) get selector =>
      (allTasks) => allTasks.byCategory(category);
}
