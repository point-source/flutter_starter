/// Data transfer object for user data returned by the API.
///
/// This DTO mirrors the JSON shape returned by the server. Use the
/// [UserDtoMapper] extension to convert it to a domain [User] entity.
library;

import 'package:dart_mappable/dart_mappable.dart';

part 'user_dto.mapper.dart';

/// Server representation of a user.
///
/// Deserialized from JSON responses and converted to a domain [User]
/// entity via [UserDtoMapper.toDomain].
@MappableClass()
class UserDto with UserDtoMappable {
  /// Create a [UserDto] from API response fields.
  const UserDto({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
  });

  /// Deserialize from a JSON map.
  ///
  /// Bridges [dart_mappable]'s mapper to the `fromJson` factory that
  /// [retrofit_generator] expects on the model class.
  factory UserDto.fromJson(Map<String, dynamic> json) =>
      UserDtoMapper.fromMap(json);

  /// Unique identifier assigned by the server.
  final String id;

  /// The user's email address.
  final String email;

  /// The user's display name.
  final String name;

  /// URL of the user's avatar image, or `null` if not set.
  final String? avatarUrl;
}
