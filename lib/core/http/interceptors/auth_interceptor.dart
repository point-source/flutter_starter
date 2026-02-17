/// Dio interceptor that attaches the Bearer token to outgoing requests.
///
/// Reads the access token from [ITokenStorage] and adds it as an
/// `Authorization` header. Requests to auth endpoints (login, register)
/// are excluded since they don't require authentication.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_starter/core/storage/token_storage.dart';

/// Adds the stored access token to every authenticated request.
///
/// Skips token injection for requests that already have an Authorization
/// header or for unauthenticated endpoints like login and register.
class AuthInterceptor extends Interceptor {
  /// Creates an [AuthInterceptor] with the given [tokenStorage].
  const AuthInterceptor(this._tokenStorage);

  final ITokenStorage _tokenStorage;

  /// Paths that should not have an auth token attached.
  static const _publicPaths = ['/auth/login', '/auth/register'];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip if this is a public endpoint
    final isPublic = _publicPaths.any(options.path.endsWith);
    if (isPublic) {
      handler.next(options);
      return;
    }

    // Skip if an Authorization header is already set
    if (options.headers.containsKey('Authorization')) {
      handler.next(options);
      return;
    }

    try {
      final token = await _tokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } on Exception catch (_) {
      // Storage read failed — proceed without token rather than crashing
      // the entire request pipeline. The request will likely receive a 401
      // which the RefreshTokenInterceptor can handle.
      assert(() {
        debugPrint('AuthInterceptor: failed to read access token');
        return true;
      }());
    }

    handler.next(options);
  }
}
