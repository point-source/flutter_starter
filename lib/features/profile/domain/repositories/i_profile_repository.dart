/// Define the contract for profile data operations.
///
/// Implemented by [ProfileRepository] in the data layer. Used by
/// [ProfileViewModel] to decouple the UI from data source details.
library;

import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/profile/domain/entities/profile.dart';

/// Repository contract for profile operations.
abstract interface class IProfileRepository {
  /// Fetch the current user's profile.
  Future<Result<Profile>> getProfile();

  /// Update the current user's profile.
  Future<Result<Profile>> updateProfile({
    String? name,
    String? bio,
    String? phoneNumber,
  });
}
