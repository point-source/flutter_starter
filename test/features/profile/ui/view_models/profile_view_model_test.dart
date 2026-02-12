/// Tests for [ProfileViewModel].
///
/// Uses a [ProviderContainer] with a mocked [IProfileRepository] to verify
/// that the view model correctly translates repository results into
/// [AsyncValue<Profile>] transitions.
// ignore_for_file: no-empty-block

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/profile/domain/failures/profile_failure.dart';
import 'package:flutter_starter/features/profile/ui/view_models/profile_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_utils.dart';

void main() {
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
  });

  /// Helper to create a container with the profile repository overridden.
  ProviderContainer createProfileContainer() => createContainer(
    overrides: [
      profileRepositoryProvider.overrideWithValue(mockProfileRepository),
    ],
  );

  /// Tests for the initial [build] method.
  group('build', () {
    /// Resolves to profile when the repository returns success.
    test('returns profile on success', () async {
      final testProfile = FakeData.profile();

      when(
        () => mockProfileRepository.getProfile(),
      ).thenAnswer((_) async => Success(testProfile));

      final container = createProfileContainer();

      // Read the provider to trigger build().
      final future = container.read(profileViewModelProvider.future);
      final profile = await future;

      expect(profile.id, 'user-1');
      expect(profile.email, 'test@example.com');
      expect(profile.name, 'Test User');
    });

    /// Throws when getProfile returns a failure, resulting in AsyncError.
    test('throws on failure', () async {
      when(
        () => mockProfileRepository.getProfile(),
      ).thenAnswer((_) async => const Err(ProfileNotFound()));

      final container = createProfileContainer();

      // Listen to the provider and expect it to eventually have an error.
      final sub = container.listen(profileViewModelProvider, (_, _) {});

      // Wait for the provider to complete its async operation.
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // The state should be in error.
      final state = container.read(profileViewModelProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<FailureException>());

      sub.close();
    });
  });

  /// Tests for [ProfileViewModel.updateProfile].
  group('updateProfile', () {
    /// Transitions to updated profile on success.
    test('transitions to updated profile on success', () async {
      final initialProfile = FakeData.profile();
      final updatedProfile = FakeData.profile(
        name: 'Updated Name',
        bio: 'Updated bio',
      );

      // Stub build() to start with initial profile.
      when(
        () => mockProfileRepository.getProfile(),
      ).thenAnswer((_) async => Success(initialProfile));
      when(
        () => mockProfileRepository.updateProfile(
          name: any(named: 'name'),
          bio: any(named: 'bio'),
          phoneNumber: any(named: 'phoneNumber'),
        ),
      ).thenAnswer((_) async => Success(updatedProfile));

      final container = createProfileContainer();

      // Wait for build() to complete.
      await container.read(profileViewModelProvider.future);

      // Perform update.
      final notifier = container.read(profileViewModelProvider.notifier);
      await notifier.updateProfile(name: 'Updated Name', bio: 'Updated bio');

      final state = container.read(profileViewModelProvider);
      expect(state.hasValue, isTrue);
      expect(state.requireValue.name, 'Updated Name');
      expect(state.requireValue.bio, 'Updated bio');
    });

    /// Transitions to error on failure.
    test('transitions to error on failure', () async {
      final initialProfile = FakeData.profile();

      // Stub build() to start with initial profile.
      when(
        () => mockProfileRepository.getProfile(),
      ).thenAnswer((_) async => Success(initialProfile));
      when(
        () => mockProfileRepository.updateProfile(
          name: any(named: 'name'),
          bio: any(named: 'bio'),
          phoneNumber: any(named: 'phoneNumber'),
        ),
      ).thenAnswer((_) async => const Err(ProfileUpdateRejected()));

      final container = createProfileContainer();

      // Wait for build() to complete.
      await container.read(profileViewModelProvider.future);

      // Perform update.
      final notifier = container.read(profileViewModelProvider.notifier);
      await notifier.updateProfile(name: 'Invalid Name');

      final state = container.read(profileViewModelProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<FailureException>());
    });
  });
}
