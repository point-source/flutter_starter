/// Retrofit service for authentication API endpoints.
///
/// Defines the HTTP contract for login, registration, logout, and
/// session retrieval. The generated implementation delegates to [Dio]
/// and handles JSON serialisation via dart_mappable.
library;

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:flutter_starter/features/auth/data/models/auth_response.dart';
import 'package:flutter_starter/features/auth/data/models/login_request.dart';
import 'package:flutter_starter/features/auth/data/models/register_request.dart';
import 'package:flutter_starter/features/auth/data/models/user_dto.dart';

part 'auth_service.g.dart';

/// HTTP client for the authentication API.
///
/// Each method maps to a single REST endpoint. The generated
/// [_AuthService] implementation handles request building, body
/// serialisation, and response parsing.
@RestApi()
abstract class AuthService {
  /// Create an [AuthService] backed by the given [dio] instance.
  factory AuthService(Dio dio) = _AuthService;

  /// Authenticate with email and password credentials.
  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  /// Create a new user account.
  @POST('/auth/register')
  Future<AuthResponse> register(@Body() RegisterRequest request);

  /// End the current session on the server.
  @POST('/auth/logout')
  Future<void> logout();

  /// Retrieve the profile of the currently authenticated user.
  @GET('/auth/me')
  Future<UserDto> getCurrentUser();
}
