/// Log REST requests without exposing sensitive headers.
library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/logging/app_logger.dart';

/// Record request outcomes through the application's logger.
class RestLoggingInterceptor extends Interceptor {
  /// Create a REST logging interceptor.
  const RestLoggingInterceptor(this._logger);

  final IAppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug('${options.method} ${options.uri.path}', tag: 'http');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug(
      '${response.statusCode ?? '?'} ${response.requestOptions.uri.path}',
      tag: 'http',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.warning(
      '${err.response?.statusCode ?? '?'} ${err.requestOptions.uri.path}',
      tag: 'http',
    );
    handler.next(err);
  }
}
