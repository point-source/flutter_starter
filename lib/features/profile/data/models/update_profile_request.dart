/// Request body for the profile update endpoint.
///
/// Only non-null fields are included in the serialized JSON,
/// allowing partial updates.
library;

import 'package:dart_mappable/dart_mappable.dart';

part 'update_profile_request.mapper.dart';

/// Request payload for updating a user's profile.
@MappableClass()
class UpdateProfileRequest with UpdateProfileRequestMappable {
  /// Create an [UpdateProfileRequest] with the fields to update.
  const UpdateProfileRequest({this.name, this.bio, this.phoneNumber});

  /// Updated display name, or `null` to keep unchanged.
  final String? name;

  /// Updated biography, or `null` to keep unchanged.
  final String? bio;

  /// Updated phone number, or `null` to keep unchanged.
  final String? phoneNumber;
}
