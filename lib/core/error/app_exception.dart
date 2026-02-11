/// Exception types used at the service/repository boundary.
///
/// These exceptions are thrown by services (retrofit, data sources) and
/// caught by repositories, which convert them into [Failure] types
/// wrapped in [Result]. They should never propagate to the UI layer.
///
/// See also:
/// - [ErrorInterceptor] which converts [DioException] to these types
/// - Repository implementations which catch these and return [Err]
library;

/// Base class for all application exceptions.
///
/// Unlike [Failure], exceptions are used for control flow within the
/// data layer. Repositories catch these and convert them to [Failure]s.
sealed class AppException implements Exception {
  /// Creates an [AppException] with a [message] and optional [statusCode].
  const AppException(this.message, {this.statusCode});

  /// A description of what went wrong.
  final String message;

  /// The HTTP status code, if this originated from an HTTP response.
  final int? statusCode;

  @override
  String toString() =>
      '${switch (this) {
        ServerException() => 'ServerException',
        NetworkException() => 'NetworkException',
        TimeoutException() => 'TimeoutException',
        ParseException() => 'ParseException',
        CacheException() => 'CacheException',
      }}: $message';
}

/// Exception thrown when the server returns an error response.
final class ServerException extends AppException {
  /// Creates a [ServerException].
  const ServerException(super.message, {super.statusCode});
}

/// Exception thrown when there is no network connectivity.
final class NetworkException extends AppException {
  /// Creates a [NetworkException].
  const NetworkException([super.message = 'No internet connection']);
}

/// Exception thrown when a request times out.
final class TimeoutException extends AppException {
  /// Creates a [TimeoutException].
  const TimeoutException([super.message = 'Request timed out']);
}

/// Exception thrown when response parsing fails.
final class ParseException extends AppException {
  /// Creates a [ParseException] with the original [error].
  const ParseException(
    this.error, [
    String message = 'Failed to parse response',
  ]) : super(message);

  /// The original parsing error.
  final Object error;
}

/// Exception thrown when a local cache operation fails.
final class CacheException extends AppException {
  /// Creates a [CacheException].
  const CacheException([super.message = 'Cache operation failed']);
}
