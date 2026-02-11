/// Tests for [ProfileRepository].
///
/// Validates that the repository correctly delegates to [ProfileService],
/// maps responses to domain entities, converts HTTP errors to
/// [ProfileFailure] subtypes, and handles unexpected exceptions.
library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/features/profile/data/models/profile_dto.dart';
import 'package:flutter_starter/features/profile/data/models/update_profile_request.dart';
import 'package:flutter_starter/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_starter/features/profile/domain/failures/profile_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockProfileService mockProfileService;
  late ProfileRepository repository;

  /// Reusable test data.
  const testProfileDto = ProfileDto(
    id: 'user-1',
    email: 'test@example.com',
    name: 'Test User',
    avatarUrl: 'https://example.com/avatar.jpg',
    bio: 'Test bio',
    phoneNumber: '+1234567890',
  );

  setUp(() {
    mockProfileService = MockProfileService();
    repository = ProfileRepository(mockProfileService);

    // Register fallback values for mocktail argument matchers.
    registerFallbackValue(
      const UpdateProfileRequest(name: '', bio: '', phoneNumber: ''),
    );
  });

  /// Tests for [ProfileRepository.getProfile].
  group('getProfile', () {
    /// Returns a [Success] containing the mapped [Profile] on a successful
    /// API response.
    test('returns Success with profile on success', () async {
      when(
        () => mockProfileService.getProfile(),
      ).thenAnswer((_) async => testProfileDto);

      final result = await repository.getProfile();

      expect(result.isSuccess, isTrue);
      final profile = result.getOrNull();
      expect(profile, isNotNull);
      expect(profile!.id, 'user-1');
      expect(profile.email, 'test@example.com');
      expect(profile.name, 'Test User');
      expect(profile.bio, 'Test bio');
      expect(profile.phoneNumber, '+1234567890');
    });

    /// Returns an [Err] with [ProfileNotFound] when the server responds
    /// with a 404 status code.
    test('returns Err with ProfileNotFound on 404', () async {
      when(() => mockProfileService.getProfile()).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          error: const ServerException('Not found', statusCode: 404),
        ),
      );

      final result = await repository.getProfile();

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('should not succeed'),
        failure: (f) => expect(f, isA<ProfileNotFound>()),
      );
    });

    /// Returns an [Err] with [BadResponse] for generic server errors.
    test('returns Err with BadResponse on generic server error', () async {
      when(() => mockProfileService.getProfile()).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          error: const ServerException('Internal error', statusCode: 500),
        ),
      );

      final result = await repository.getProfile();

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('should not succeed'),
        failure: (f) => expect(f, isA<BadResponse>()),
      );
    });

    /// Returns an [Err] with [UnexpectedFailure] for non-Dio exceptions.
    test(
      'returns Err with UnexpectedFailure on unexpected exception',
      () async {
        when(
          () => mockProfileService.getProfile(),
        ).thenThrow(Exception('something broke'));

        final result = await repository.getProfile();

        expect(result.isFailure, isTrue);
        result.when(
          success: (_) => fail('should not succeed'),
          failure: (f) => expect(f, isA<UnexpectedFailure>()),
        );
      },
    );
  });

  /// Tests for [ProfileRepository.updateProfile].
  group('updateProfile', () {
    /// Returns a [Success] containing the updated [Profile] on a successful
    /// API response.
    test('returns Success with updated profile on success', () async {
      const updatedDto = ProfileDto(
        id: 'user-1',
        email: 'test@example.com',
        name: 'Updated Name',
        avatarUrl: 'https://example.com/avatar.jpg',
        bio: 'Updated bio',
        phoneNumber: '+1234567890',
      );

      when(
        () => mockProfileService.updateProfile(any()),
      ).thenAnswer((_) async => updatedDto);

      final result = await repository.updateProfile(
        name: 'Updated Name',
        bio: 'Updated bio',
      );

      expect(result.isSuccess, isTrue);
      final profile = result.getOrNull();
      expect(profile, isNotNull);
      expect(profile!.name, 'Updated Name');
      expect(profile.bio, 'Updated bio');
    });

    /// Returns an [Err] with [ProfileUpdateRejected] when the server
    /// responds with a 422 status code.
    test('returns Err with ProfileUpdateRejected on 422', () async {
      when(() => mockProfileService.updateProfile(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          error: const ServerException('Validation failed', statusCode: 422),
        ),
      );

      final result = await repository.updateProfile(name: 'Invalid Name');

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('should not succeed'),
        failure: (f) => expect(f, isA<ProfileUpdateRejected>()),
      );
    });

    /// Returns an [Err] with [UnexpectedFailure] for non-Dio exceptions.
    test(
      'returns Err with UnexpectedFailure on unexpected exception',
      () async {
        when(
          () => mockProfileService.updateProfile(any()),
        ).thenThrow(Exception('something broke'));

        final result = await repository.updateProfile(
          name: 'Test',
          bio: 'Test bio',
        );

        expect(result.isFailure, isTrue);
        result.when(
          success: (_) => fail('should not succeed'),
          failure: (f) => expect(f, isA<UnexpectedFailure>()),
        );
      },
    );
  });
}
