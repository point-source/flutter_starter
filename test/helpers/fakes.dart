/// Fake data factories for use in tests.
///
/// Provides deterministic, reusable instances of domain entities with
/// sensible defaults that can be overridden per-test via named parameters.
library;

import 'package:flutter_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_starter/features/profile/domain/entities/profile.dart';

/// Factory methods for creating fake domain entities.
///
/// Each method returns an instance with sensible defaults. Override any
/// field by passing named parameters:
///
/// ```dart
/// final admin = FakeData.user(name: 'Admin');
/// ```
class FakeData {
  /// Create a fake [User] entity.
  static User user({
    String id = 'user-1',
    String email = 'test@example.com',
    String name = 'Test User',
    String? avatarUrl,
  }) => .new(id: id, email: email, name: name, avatarUrl: avatarUrl);

  /// Create a fake [Profile] entity.
  static Profile profile({
    String id = 'user-1',
    String email = 'test@example.com',
    String name = 'Test User',
    String? avatarUrl,
    String? bio,
    String? phoneNumber,
  }) => .new(
    id: id,
    email: email,
    name: name,
    avatarUrl: avatarUrl,
    bio: bio,
    phoneNumber: phoneNumber,
  );
}
