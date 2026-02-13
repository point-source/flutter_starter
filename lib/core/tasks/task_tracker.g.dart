// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_tracker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(TaskTracker)
final taskTrackerProvider = TaskTrackerProvider._();

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
final class TaskTrackerProvider
    extends $NotifierProvider<TaskTracker, IMap<String, TrackedTask>> {
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
  TaskTrackerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskTrackerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskTrackerHash();

  @$internal
  @override
  TaskTracker create() => TaskTracker();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IMap<String, TrackedTask> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IMap<String, TrackedTask>>(value),
    );
  }
}

String _$taskTrackerHash() => r'8935944c20ffc7f43851c7928c3f21cedc94dd33';

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

abstract class _$TaskTracker extends $Notifier<IMap<String, TrackedTask>> {
  IMap<String, TrackedTask> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<IMap<String, TrackedTask>, IMap<String, TrackedTask>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IMap<String, TrackedTask>, IMap<String, TrackedTask>>,
              IMap<String, TrackedTask>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
