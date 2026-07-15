/// Map Dio failures to REST-layer exceptions for repositories to consume.
library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/http/dio_api_exception.dart';

/// Convert [DioException] details without exposing them above repositories.
class ErrorInterceptor extends Interceptor {
  /// Create an error interceptor.
  const ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const RestTimeoutException(),
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse => ServerException(
        _responseMessage(err.response?.data),
        statusCode: err.response?.statusCode,
      ),
      DioExceptionType.cancel => const ServerException('Request was cancelled'),
      DioExceptionType.badCertificate => const ServerException(
        'The server certificate was rejected',
      ),
      DioExceptionType.unknown => ServerException(
        err.message ?? 'Unknown REST error',
      ),
      _ => ServerException(err.message ?? 'REST request failed'),
    };

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

  String _responseMessage(Object? data) {
    if (data case {'message': final String message}) return message;
    if (data case {'error': final String message}) return message;
    return 'Server error';
  }
}
