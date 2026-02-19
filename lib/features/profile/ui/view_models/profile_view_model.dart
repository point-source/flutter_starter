/// Manage profile state and expose CRUD operations to the UI.
///
/// Provides the [ProfileViewModel] notifier that the profile page
/// watches to react to loading, data, and error states. Infrastructure
/// providers ([profileServiceProvider], [profileRepositoryProvider])
/// live in `data/providers/profile_providers.dart`.
library;

import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/core/logging/logger_provider.dart';
import 'package:flutter_starter/features/profile/data/providers/profile_providers.dart';
import 'package:flutter_starter/features/profile/domain/entities/profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_view_model.g.dart';

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
      failure: (failure) {
        ref
            .read(loggerProvider)
            .warning(
              'Failed to load profile',
              data: {'failure': failure.toString()},
              tag: 'profile',
            );
        throw FailureException(failure);
      },
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
      failure: (failure) {
        ref
            .read(loggerProvider)
            .warning(
              'Failed to update profile',
              data: {'failure': failure.toString()},
              tag: 'profile',
            );
        return AsyncError(
          FailureException(failure),
          failure.stackTrace ?? .current,
        );
      },
    );
  }
}
