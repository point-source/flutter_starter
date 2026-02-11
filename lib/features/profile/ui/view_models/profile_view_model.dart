/// Manage profile state and expose CRUD operations to the UI.
///
/// Provides the [ProfileViewModel] notifier and companion providers
/// for the [ProfileService] and [IProfileRepository].
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_starter/core/network/dio_provider.dart';
import 'package:flutter_starter/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_starter/features/profile/data/services/profile_service.dart';
import 'package:flutter_starter/features/profile/domain/entities/profile.dart';
import 'package:flutter_starter/features/profile/domain/repositories/i_profile_repository.dart';

part 'profile_view_model.g.dart';

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

/// Create a [ProfileService] backed by the application's [Dio] instance.
@riverpod
ProfileService profileService(Ref ref) {
  return ProfileService(ref.read(dioProvider));
}

/// Create an [IProfileRepository] wired to the profile service.
@riverpod
IProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(ref.read(profileServiceProvider));
}

// ---------------------------------------------------------------------------
// Profile view model
// ---------------------------------------------------------------------------

/// Notifier that manages the profile lifecycle.
///
/// Loads the profile on initialization and provides an [updateProfile]
/// method for saving edits.
@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  Future<Profile> build() async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.getProfile();

    return result.when(
      success: (profile) => profile,
      failure: (failure) => throw failure,
    );
  }

  /// Update the profile with the given fields.
  ///
  /// Sets state to loading, then either the updated profile or an error.
  Future<void> updateProfile({
    String? name,
    String? bio,
    String? phoneNumber,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.updateProfile(
      name: name,
      bio: bio,
      phoneNumber: phoneNumber,
    );

    state = result.when(
      success: AsyncData.new,
      failure: (failure) => AsyncError(failure, StackTrace.current),
    );
  }
}
