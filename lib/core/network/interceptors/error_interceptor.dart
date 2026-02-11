/// Dio interceptor that converts [DioException] into typed [AppException]s.
///
/// This is the boundary where Dio's error model is translated into the
/// application's exception model. Repositories then catch [AppException]s
/// and convert them into [Failure]s wrapped in [Result].
library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';

/// Converts [DioException] errors into typed [AppException] subtypes.
///
/// Placed last in the interceptor chain so it processes errors after
/// all other interceptors (auth, refresh, logging) have had their turn.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioException(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  AppException _mapDioException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _mapBadResponse(err);

      case DioExceptionType.cancel:
        return const ServerException('Request was cancelled');

      case DioExceptionType.badCertificate:
        return const ServerException('Invalid SSL certificate');

      case DioExceptionType.unknown:
        if (err.error != null) {
          return ServerException('Unexpected error: ${err.error}');
        }
        return ServerException(err.message ?? 'Unknown error');
    }
  }

  ServerException _mapBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    // Try to extract error message from response body
    String message;
    if (data is Map<String, dynamic>) {
      message = (data['message'] as String?) ??
          (data['error'] as String?) ??
          'Server error';
    } else {
      message = 'Server error';
    }

    return ServerException(
      message,
      statusCode: statusCode,
    );
  }
}
