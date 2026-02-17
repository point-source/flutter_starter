/// Fake [IProfileRepository] for development without a backend.
///
/// Returns hard-coded [Profile] data for all operations, with no network
/// calls. This is the default implementation used by the template.
library;

import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/profile/domain/entities/profile.dart';
import 'package:flutter_starter/features/profile/domain/repositories/i_profile_repository.dart';

/// [IProfileRepository] implementation that returns fake data immediately.
///
/// Useful for UI development when no backend is available. Replace with a
/// real implementation when connecting to a backend.
class MockProfileRepository implements IProfileRepository {
  /// Create a [MockProfileRepository].
  const MockProfileRepository();

  static const _mockProfile = Profile(
    id: 'mock-user-001',
    email: 'dev@example.com',
    name: 'Dev User',
    bio: 'A mock user for development.',
  );

  @override
  Future<Result<Profile>> getProfile() async => const Success(_mockProfile);

  @override
  Future<Result<Profile>> updateProfile({
    String? name,
    String? bio,
    String? phoneNumber,
  }) async => Success(
    _mockProfile.copyWith(
      name: name ?? _mockProfile.name,
      bio: bio ?? _mockProfile.bio,
      phoneNumber: phoneNumber ?? _mockProfile.phoneNumber,
    ),
  );
}
