/// Data transfer object for authentication responses.
///
/// Returned by the login and register endpoints. Contains the session
/// tokens and the authenticated user's profile data.
library;

import 'package:dart_mappable/dart_mappable.dart';

import 'package:flutter_starter/features/auth/data/models/user_dto.dart';

part 'auth_response.mapper.dart';

/// Response body from login and register endpoints.
///
/// Contains an [accessToken] for API authorization, a [refreshToken]
/// for obtaining new access tokens, and the authenticated [user]'s
/// profile data.
@MappableClass()
class AuthResponse with AuthResponseMappable {
  /// Create an [AuthResponse] from the server's JSON payload.
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  /// Deserialize from a JSON map.
  ///
  /// Bridges [dart_mappable]'s mapper to the `fromJson` factory that
  /// [retrofit_generator] expects on the model class.
  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      AuthResponseMapper.fromMap(json);

  /// Short-lived token used to authorize API requests.
  final String accessToken;

  /// Long-lived token used to obtain a new access token.
  final String refreshToken;

  /// Profile data of the authenticated user.
  final UserDto user;
}
