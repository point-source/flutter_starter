/// Dio interceptor that automatically refreshes expired access tokens.
///
/// Extends [QueuedInterceptor] so that when a 401 is received, all
/// subsequent requests are queued while the token refresh is in progress.
/// Once the token is refreshed, all queued requests are retried with the
/// new token. If the refresh fails, all queued requests are rejected and
/// [onAuthExpired] is called to notify the app of session expiry.
library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/storage/token_storage.dart';

/// Handles automatic token refresh on 401 responses.
///
/// Uses [QueuedInterceptor] to serialize concurrent 401 handling.
/// Only the first 401 triggers a refresh — subsequent requests wait
/// for the refresh to complete and then retry with the new token.
///
/// The [onAuthExpired] callback is invoked when the refresh token
/// itself is invalid, signaling the app to redirect to login.
class RefreshTokenInterceptor extends QueuedInterceptor {
  /// Creates a [RefreshTokenInterceptor].
  ///
  /// [tokenStorage] is used to read/write tokens.
  /// [dio] is a separate Dio instance for the refresh call to avoid
  /// interceptor recursion.
  /// [onAuthExpired] is called when the refresh token is rejected.
  RefreshTokenInterceptor({
    required ITokenStorage tokenStorage,
    required Dio dio,
    required void Function() onAuthExpired,
    this.refreshPath = '/auth/refresh',
  }) : _tokenStorage = tokenStorage,
       _dio = dio,
       _onAuthExpired = onAuthExpired;

  final ITokenStorage _tokenStorage;
  final Dio _dio;
  final void Function() _onAuthExpired;

  /// Guard to prevent redundant refresh attempts.
  ///
  /// Although [QueuedInterceptor] serializes `onError` calls, a second
  /// batch of 401 responses may arrive after the first refresh completes.
  /// This flag ensures we only refresh once and retry with the current token.
  bool _isRefreshing = false;

  /// The API path used to refresh the access token.
  final String refreshPath;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized responses
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Don't retry if the failing request was the refresh call itself
    if (err.requestOptions.path.endsWith(refreshPath)) {
      await _tokenStorage.clearTokens();
      _onAuthExpired();
      handler.next(err);
      return;
    }

    // If a refresh is already in flight, retry with the current token
    // rather than triggering another refresh cycle.
    if (_isRefreshing) {
      final currentToken = await _tokenStorage.getAccessToken();
      if (currentToken != null) {
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $currentToken';
        try {
          final response = await _dio.fetch<Object?>(options);
          handler.resolve(response);
          return;
        } on DioException catch (retryError) {
          handler.next(retryError);
          return;
        }
      }
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final refreshed = await _attemptRefresh();
      if (!refreshed) {
        handler.next(err);
        return;
      }

      // Retry the original request with the new token
      final newToken = await _tokenStorage.getAccessToken();
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer ${newToken ?? ""}';

      final response = await _dio.fetch<Object?>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Attempts to refresh the access token using the stored refresh token.
  ///
  /// Returns `true` if the refresh was successful, `false` otherwise.
  Future<bool> _attemptRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      await _tokenStorage.clearTokens();
      _onAuthExpired();
      return false;
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        refreshPath,
        data: {'refresh_token': refreshToken},
      );

      final data = response.data;
      if (data == null) {
        await _tokenStorage.clearTokens();
        _onAuthExpired();
        return false;
      }

      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      if (newAccessToken == null) {
        await _tokenStorage.clearTokens();
        _onAuthExpired();
        return false;
      }

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken ?? refreshToken,
      );

      return true;
    } on DioException {
      await _tokenStorage.clearTokens();
      _onAuthExpired();
      return false;
    }
  }
}
