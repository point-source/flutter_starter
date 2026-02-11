/// Base failure type and infrastructure failure hierarchy.
///
/// All failures in the application extend [Failure]. Infrastructure failures
/// (network, server, cache) are defined here. Feature-specific failures
/// are defined in each feature's `domain/failures/` directory.
///
/// Failures are values, not exceptions. They flow through the type system
/// via [Result] rather than being thrown and caught.
library;

/// Base class for all failures in the application.
///
/// Every failure carries a human-readable [message] for logging and
/// an optional [stackTrace] for debugging. Feature-specific failures
/// should extend this class in their own feature-specific hierarchy.
///
/// ```dart
/// sealed class AuthFailure extends Failure {
///   const AuthFailure(super.message, [super.stackTrace]);
/// }
/// ```
abstract class Failure {
  /// Creates a [Failure] with a descriptive [message] and optional [stackTrace].
  const Failure(this.message, [this.stackTrace]);

  /// A human-readable description of what went wrong.
  final String message;

  /// The stack trace at the point of failure, if available.
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// Exception wrapper for [Failure] values that need to be thrown.
///
/// Use this in view models where an [AsyncNotifier.build] method must throw
/// on failure (to produce an [AsyncError]), but the repository returns a
/// [Result] containing a [Failure] value rather than an exception.
///
/// ```dart
/// return result.when(
///   success: (data) => data,
///   failure: (failure) => throw FailureException(failure),
/// );
/// ```
class FailureException implements Exception {
  /// Create a [FailureException] wrapping the given [failure].
  const FailureException(this.failure);

  /// The underlying [Failure] value.
  final Failure failure;

  @override
  String toString() => 'FailureException: ${failure.message}';
}

// ---------------------------------------------------------------------------
// Infrastructure failures — shared across all features
// ---------------------------------------------------------------------------

/// Failures related to network connectivity.
sealed class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure(super.message, [super.stackTrace]);
}

/// The device has no internet connection.
final class NoConnection extends NetworkFailure {
  /// Creates a [NoConnection] failure.
  const NoConnection([StackTrace? stackTrace])
    : super('No internet connection', stackTrace);
}

/// The request timed out before receiving a response.
final class Timeout extends NetworkFailure {
  /// Creates a [Timeout] failure.
  const Timeout([StackTrace? stackTrace])
    : super('Request timed out', stackTrace);
}

/// Failures related to server responses.
sealed class ServerFailure extends Failure {
  /// Creates a [ServerFailure].
  const ServerFailure(super.message, [super.stackTrace]);
}

/// The server returned an error response.
final class BadResponse extends ServerFailure {
  /// Creates a [BadResponse] failure with the HTTP [statusCode].
  const BadResponse(this.statusCode, [String? message, StackTrace? stackTrace])
    : super(message ?? 'Server error ($statusCode)', stackTrace);

  /// The HTTP status code returned by the server.
  final int statusCode;
}

/// The request was rejected because the user is not authenticated.
final class Unauthorized extends ServerFailure {
  /// Creates an [Unauthorized] failure.
  const Unauthorized([StackTrace? stackTrace])
    : super('Unauthorized', stackTrace);
}

/// The authenticated user does not have permission for this operation.
final class Forbidden extends ServerFailure {
  /// Creates a [Forbidden] failure.
  const Forbidden([StackTrace? stackTrace]) : super('Forbidden', stackTrace);
}

/// The requested resource was not found on the server.
final class NotFound extends ServerFailure {
  /// Creates a [NotFound] failure.
  const NotFound([StackTrace? stackTrace]) : super('Not found', stackTrace);
}

/// Failures related to local cache/storage operations.
sealed class CacheFailure extends Failure {
  /// Creates a [CacheFailure].
  const CacheFailure(super.message, [super.stackTrace]);
}

/// Failed to read data from local storage.
final class CacheReadFailure extends CacheFailure {
  /// Creates a [CacheReadFailure].
  const CacheReadFailure([StackTrace? stackTrace])
    : super('Failed to read from cache', stackTrace);
}

/// Failed to write data to local storage.
final class CacheWriteFailure extends CacheFailure {
  /// Creates a [CacheWriteFailure].
  const CacheWriteFailure([StackTrace? stackTrace])
    : super('Failed to write to cache', stackTrace);
}

/// An unexpected failure that doesn't fit other categories.
///
/// Use sparingly — prefer creating specific failure types when possible.
final class UnexpectedFailure extends Failure {
  /// Creates an [UnexpectedFailure] with the original [error].
  const UnexpectedFailure(this.error, [StackTrace? stackTrace])
    : super('An unexpected error occurred', stackTrace);

  /// The original error or exception that caused this failure.
  final Object error;

  @override
  String toString() => 'UnexpectedFailure: $error';
}
