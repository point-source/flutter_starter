/// Tests for [MockProfileRepository].
///
/// Smoke tests to verify the mock implementation returns expected data
/// and supports the full [IProfileRepository] contract.
library;

import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:flutter_starter/features/profile/domain/entities/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockProfileRepository repository;

  setUp(() {
    repository = const MockProfileRepository();
  });

  group('getProfile', () {
    test('returns Success with mock profile', () async {
      final result = await repository.getProfile();

      expect(result.isSuccess, isTrue);
      final profile = result.getOrNull()!;
      expect(profile.id, 'mock-user-001');
      expect(profile.email, 'dev@example.com');
      expect(profile.name, 'Dev User');
    });
  });

  group('updateProfile', () {
    test('returns Success with updated name', () async {
      final result = await repository.updateProfile(name: 'New Name');

      expect(result, isA<Success<Profile>>());
      final profile = result.getOrNull()!;
      expect(profile.name, 'New Name');
      expect(profile.email, 'dev@example.com');
    });

    test('returns Success with updated bio', () async {
      final result = await repository.updateProfile(bio: 'Updated bio');

      expect(result.isSuccess, isTrue);
      final profile = result.getOrNull()!;
      expect(profile.bio, 'Updated bio');
    });

    test('returns Success with updated phone number', () async {
      final result = await repository.updateProfile(phoneNumber: '+1234567890');

      expect(result.isSuccess, isTrue);
      final profile = result.getOrNull()!;
      expect(profile.phoneNumber, '+1234567890');
    });
  });
}
