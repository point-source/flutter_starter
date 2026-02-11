/// Data transfer object for login requests.
///
/// Serialised and sent as the request body when authenticating a user
/// with email and password credentials.
library;

import 'package:dart_mappable/dart_mappable.dart';

part 'login_request.mapper.dart';

/// Request body for the login endpoint.
///
/// Contains the user's [email] and [password] for credential-based
/// authentication.
@MappableClass()
class LoginRequest with LoginRequestMappable {
  /// Create a [LoginRequest] with the given credentials.
  const LoginRequest({required this.email, required this.password});

  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;
}
