/// Represent a user profile in the domain layer.
///
/// Contains editable profile fields beyond the basic user info.
/// Created by mapping a [ProfileDto] from the data layer.
library;

import 'package:dart_mappable/dart_mappable.dart';

part 'profile.mapper.dart';

/// A user's profile with editable fields.
@MappableClass()
class Profile with ProfileMappable {
  /// Create a [Profile].
  const Profile({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.phoneNumber,
  });

  /// Unique identifier.
  final String id;

  /// Email address.
  final String email;

  /// Display name.
  final String name;

  /// URL of the avatar image, or `null` if not set.
  final String? avatarUrl;

  /// Short biography text.
  final String? bio;

  /// Phone number.
  final String? phoneNumber;
}
