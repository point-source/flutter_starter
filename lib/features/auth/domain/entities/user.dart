/// Represent an authenticated user in the domain layer.
///
/// This entity is the canonical representation of a user throughout the
/// application. It is created by mapping a [UserDto] from the data layer
/// and consumed by view models and UI widgets. Because it is a value type,
/// two [User] instances with identical fields are considered equal.
library;

import 'package:dart_mappable/dart_mappable.dart';

part 'user.mapper.dart';

/// An authenticated user with profile information.
///
/// All fields are required except [avatarUrl], which may be absent when
/// the user has not uploaded a profile picture.
@MappableClass()
class User with UserMappable {
  /// Create a [User] with the given profile fields.
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
  });

  /// Unique identifier assigned by the server.
  final String id;

  /// The user's email address.
  final String email;

  /// The user's display name.
  final String name;

  /// URL of the user's avatar image, or `null` if not set.
  final String? avatarUrl;
}
