/// Provide the configured Dio client installed by the REST capability.
library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/http/interceptors/error_interceptor.dart';
import 'package:flutter_starter/core/http/interceptors/logging_interceptor.dart';
import 'package:flutter_starter/core/http/rest_config.dart';
import 'package:flutter_starter/core/logging/logger_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

/// Provide the shared REST client for generated Retrofit services.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final client = Dio(
    BaseOptions(
      baseUrl: RestConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ),
  );
  client.interceptors.addAll([
    RestLoggingInterceptor(ref.read(loggerProvider)),
    const ErrorInterceptor(),
  ]);
  return client;
}
