/// Riverpod providers for the configured [Dio] HTTP client.
///
/// Creates a Dio instance with the full interceptor chain:
/// 1. [AuthInterceptor] — adds Bearer token
/// 2. [RefreshTokenInterceptor] — auto-refreshes on 401
/// 3. [LoggingInterceptor] — logs requests/responses
/// 4. [ErrorInterceptor] — maps DioException to AppException
///
/// Also provides a separate "plain" Dio instance for the refresh
/// interceptor to use, avoiding interceptor recursion.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/env/app_environment.dart';
import 'package:flutter_starter/core/logging/logger_provider.dart';
import 'package:flutter_starter/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_starter/core/network/interceptors/error_interceptor.dart';
import 'package:flutter_starter/core/network/interceptors/logging_interceptor.dart';
import 'package:flutter_starter/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:flutter_starter/core/storage/token_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

/// Callback type for when the auth session expires.
///
/// Passed to [RefreshTokenInterceptor] to bridge the gap between
/// Dio's interceptor chain and Riverpod's provider tree.
typedef AuthExpiredCallback = void Function();

/// Provides the main [Dio] instance with all interceptors configured.
///
/// This is the Dio instance that all retrofit services should use.
/// It includes auth, refresh, logging, and error interceptors.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  final logger = ref.read(loggerProvider);

  // Plain Dio for refresh requests (no auth/refresh interceptors to avoid loops)
  final refreshDio = Dio(
    BaseOptions(baseUrl: AppEnvironment.current.apiBaseUrl),
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnvironment.current.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(tokenStorage),
    RefreshTokenInterceptor(
      tokenStorage: tokenStorage,
      dio: refreshDio,
      onAuthExpired: () {
        // Invalidate auth state — this triggers the auth guard to redirect
        // to the login screen. The actual provider invalidation is wired
        // up in bootstrap.dart where we have access to the ProviderContainer.
        ref.invalidateSelf();
      },
    ),
    LoggingInterceptor(logger),
    ErrorInterceptor(),
  ]);

  return dio;
}
