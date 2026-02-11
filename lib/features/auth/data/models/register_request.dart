/// Data transfer object for registration requests.
///
/// Serialised and sent as the request body when creating a new user
/// account with email, password, and display name.
library;

import 'package:dart_mappable/dart_mappable.dart';

part 'register_request.mapper.dart';

/// Request body for the registration endpoint.
///
/// Contains the information required to create a new user account.
@MappableClass()
class RegisterRequest with RegisterRequestMappable {
  /// Create a [RegisterRequest] with the given account details.
  const RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  /// The email address for the new account.
  final String email;

  /// The password for the new account.
  final String password;

  /// The display name for the new user.
  final String name;
}
