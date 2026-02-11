/// Dio interceptor that logs HTTP requests and responses.
///
/// Uses [IAppLogger] so that logs go to the console in development
/// and to Sentry as breadcrumbs in production. Redacts sensitive
/// headers like Authorization to avoid leaking tokens in logs.
library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/logging/app_logger.dart';

/// Logs outgoing HTTP requests and incoming responses.
///
/// Sensitive headers (Authorization, Cookie) are redacted in log output.
/// Request/response bodies are only logged at debug level to avoid
/// noise in production.
class LoggingInterceptor extends Interceptor {
  /// Creates a [LoggingInterceptor] with the given [logger].
  LoggingInterceptor(this._logger);

  final IAppLogger _logger;

  /// Headers whose values should be redacted in logs.
  static const _sensitiveHeaders = {'authorization', 'cookie', 'set-cookie'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug(
      '→ ${options.method} ${options.uri}',
      tag: 'HTTP',
      data: {
        'headers': _redactHeaders(options.headers),
      },
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}',
      tag: 'HTTP',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.warning(
      '✕ ${err.response?.statusCode ?? "?"} ${err.requestOptions.method} '
      '${err.requestOptions.uri}: ${err.message}',
      tag: 'HTTP',
    );
    handler.next(err);
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) =>
      headers.map(
        (key, value) => MapEntry(
          key,
          _sensitiveHeaders.contains(key.toLowerCase()) ? '[REDACTED]' : value,
        ),
      );
}
