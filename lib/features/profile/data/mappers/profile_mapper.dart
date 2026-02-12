/// Convert [ProfileDto] data transfer objects to domain [Profile] entities.
///
/// Provides an extension method on [ProfileDto] for clean, readable
/// mapping in the repository layer.
library;

import 'package:flutter_starter/features/profile/data/models/profile_dto.dart';
import 'package:flutter_starter/features/profile/domain/entities/profile.dart';

/// Map [ProfileDto] to domain [Profile].
extension ProfileDtoMapper on ProfileDto {
  /// Convert this DTO to a domain [Profile] entity.
  Profile toDomain() => .new(
    id: id,
    email: email,
    name: name,
    avatarUrl: avatarUrl,
    bio: bio,
    phoneNumber: phoneNumber,
  );
}
