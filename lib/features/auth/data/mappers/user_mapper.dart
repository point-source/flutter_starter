/// Map [UserDto] to the domain [User] entity.
///
/// This extension keeps mapping logic close to the DTO while allowing
/// the domain layer to remain free of data-layer dependencies.
library;

import 'package:flutter_starter/features/auth/data/models/user_dto.dart';
import 'package:flutter_starter/features/auth/domain/entities/user.dart';

/// Add a [toDomain] conversion method to [UserDto].
///
/// Used by the repository to translate API responses into domain entities
/// before returning them to the view model layer.
extension UserDtoMapper on UserDto {
  /// Convert this [UserDto] to a domain [User] entity.
  User toDomain() {
    return User(
      id: id,
      email: email,
      name: name,
      avatarUrl: avatarUrl,
    );
  }
}
