/// Data transfer object for profile API responses.
///
/// Maps directly to the JSON structure returned by the profile
/// endpoints. Converted to a domain [Profile] via [ProfileMapper].
library;

import 'package:dart_mappable/dart_mappable.dart';

part 'profile_dto.mapper.dart';

/// Profile data as returned by the API.
@MappableClass()
class ProfileDto with ProfileDtoMappable {
  /// Create a [ProfileDto] from the server's JSON payload.
  const ProfileDto({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.phoneNumber,
  });

  /// Deserialize from a JSON map.
  ///
  /// Bridges [dart_mappable]'s mapper to the `fromJson` factory that
  /// [retrofit_generator] expects on the model class.
  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      ProfileDtoMapper.fromMap(json);

  /// Unique identifier.
  final String id;

  /// Email address.
  final String email;

  /// Display name.
  final String name;

  /// Avatar image URL.
  final String? avatarUrl;

  /// Biography text.
  final String? bio;

  /// Phone number.
  final String? phoneNumber;
}
