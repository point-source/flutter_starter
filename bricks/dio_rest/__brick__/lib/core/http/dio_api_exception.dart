/// Dio-specific exceptions used inside the optional REST data layer.
library;

/// Describe a transport failure before a repository maps it to [Failure].
sealed class DioApiException implements Exception {
  /// Create a transport exception.
  const DioApiException(this.message, {this.statusCode});

  /// Human-readable transport detail.
  final String message;

  /// HTTP status code when a response was received.
  final int? statusCode;

  @override
  String toString() => '$runtimeType: $message';
}

/// Represent an HTTP response or other server-side failure.
final class ServerException extends DioApiException {
  /// Create a server exception.
  const ServerException(super.message, {super.statusCode});
}

/// Represent a connection failure.
final class NetworkException extends DioApiException {
  /// Create a network exception.
  const NetworkException([super.message = 'No internet connection']);
}

/// Represent a request timeout.
final class RestTimeoutException extends DioApiException {
  /// Create a timeout exception.
  const RestTimeoutException([super.message = 'Request timed out']);
}
