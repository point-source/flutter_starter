/// Enable cooperative cancellation of background tasks.
///
/// [CancellationToken] is a pure Dart abstraction with no dependency on
/// Dio or any HTTP library. Features that make Dio calls can bridge to
/// Dio's `CancelToken` in their work function:
///
/// ```dart
/// work: (token, report) async {
///   final dioCancel = CancelToken();
///   token.cancelled.then((_) => dioCancel.cancel('Task cancelled'));
///   return dio.post(url, cancelToken: dioCancel);
/// }
/// ```
library;

import 'dart:async';

/// Enable cooperative cancellation of a background task.
///
/// The [TaskTracker] creates one token per task and calls [cancel] when
/// the user requests cancellation. The work function checks cancellation
/// via [throwIfCancelled] at safe checkpoints, or races against the
/// [cancelled] future for long-running non-cancellable operations.
class CancellationToken {
  /// Create a [CancellationToken].
  CancellationToken();

  bool _isCancelled = false;
  final Completer<void> _completer = Completer<void>();

  /// Whether cancellation has been requested.
  bool get isCancelled => _isCancelled;

  /// A future that completes when cancellation is requested.
  ///
  /// Use with [Future.any] to race a long-running operation against
  /// cancellation:
  ///
  /// ```dart
  /// await Future.any([longOperation(), token.cancelled]);
  /// token.throwIfCancelled();
  /// ```
  Future<void> get cancelled => _completer.future;

  /// Request cancellation.
  ///
  /// Sets [isCancelled] to `true` and completes the [cancelled] future.
  /// This method is idempotent — calling it multiple times is safe.
  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  /// Throw [CancelledException] if cancellation has been requested.
  ///
  /// Call this at safe checkpoints within the work function to
  /// cooperatively respond to cancellation.
  void throwIfCancelled() {
    if (_isCancelled) throw const CancelledException();
  }
}

/// Exception thrown by [CancellationToken.throwIfCancelled].
///
/// Caught internally by the [TaskTracker] to transition the task to
/// [TaskStatus.cancelled]. Should never propagate to feature code.
class CancelledException implements Exception {
  /// Create a [CancelledException].
  const CancelledException();

  @override
  String toString() => 'CancelledException: Task was cancelled';
}
