/// Implement [IAuthRepository] using the REST API and secure token storage.
///
/// This is the concrete data-layer implementation of the auth repository
/// contract. It delegates network calls to [AuthService], persists tokens
/// via [ITokenStorage], and maps all outcomes into [Result] values with
/// feature-specific [AuthFailure] types.
library;

import 'package:dio/dio.dart';

import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/core/storage/token_storage.dart';
import 'package:flutter_starter/features/auth/data/mappers/user_mapper.dart';
import 'package:flutter_starter/features/auth/data/models/login_request.dart';
import 'package:flutter_starter/features/auth/data/models/register_request.dart';
import 'package:flutter_starter/features/auth/data/services/auth_service.dart';
import 'package:flutter_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_starter/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_starter/features/auth/domain/repositories/i_auth_repository.dart';

/// REST-backed implementation of [IAuthRepository].
///
/// Wraps every service call in try/catch and returns [Result] values.
/// On success, DTOs are mapped to domain entities and tokens are
/// persisted. On failure, [DioException] errors (which carry an
/// [AppException] from [ErrorInterceptor]) are mapped to the
/// appropriate [AuthFailure] subtype.
class AuthRepository implements IAuthRepository {
  /// Create an [AuthRepository] with the given dependencies.
  const AuthRepository(this._authService, this._tokenStorage);

  final AuthService _authService;
  final ITokenStorage _tokenStorage;

  @override
  Future<Result<User>> login(String email, String password) async {
    try {
      final response = await _authService.login(
        LoginRequest(email: email, password: password),
      );
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return Success(response.user.toDomain());
    } on DioException catch (e, st) {
      return Err(_mapDioException(e, st));
    } on Exception catch (e, st) {
      return Err(UnexpectedFailure(e, st));
    }
  }

  @override
  Future<Result<User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _authService.register(
        RegisterRequest(email: email, password: password, name: name),
      );
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return Success(response.user.toDomain());
    } on DioException catch (e, st) {
      return Err(_mapDioException(e, st));
    } on Exception catch (e, st) {
      return Err(UnexpectedFailure(e, st));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _authService.logout();
      await _tokenStorage.clearTokens();
      return const Success(null);
    } on DioException catch (_) {
      // Always clear tokens locally even if the server call fails
      await _tokenStorage.clearTokens();
      return const Success(null);
    } on Exception catch (e, st) {
      // Still clear tokens on unexpected errors
      await _tokenStorage.clearTokens();
      return Err(UnexpectedFailure(e, st));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return const Success(null);
      }
      final userDto = await _authService.getCurrentUser();
      return Success(userDto.toDomain());
    } on DioException catch (e, st) {
      final failure = _mapDioException(e, st);
      if (failure is InvalidCredentials || failure is SessionExpired) {
        await _tokenStorage.clearTokens();
        return const Success(null);
      }
      return Err(failure);
    } on Exception catch (e, st) {
      return Err(UnexpectedFailure(e, st));
    }
  }

  /// Map a [DioException] to the appropriate [AuthFailure].
  ///
  /// The [ErrorInterceptor] wraps the original error as an [AppException]
  /// inside [DioException.error], preserving the HTTP status code.
  AuthFailure _mapDioException(DioException e, StackTrace st) {
    final error = e.error;
    if (error is AppException) {
      return switch (error.statusCode) {
        401 => InvalidCredentials(st),
        409 => EmailAlreadyInUse(st),
        _ => AuthServerError(error.message, st),
      };
    }
    return AuthServerError(e.message ?? 'Unknown auth error', st);
  }
}
