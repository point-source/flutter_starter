/// Tests for [AuthRepository].
///
/// Validates that the repository correctly delegates to [AuthService] and
/// [ITokenStorage], maps responses to domain entities, converts HTTP
/// errors to [AuthFailure] subtypes, and persists or clears tokens at
/// the appropriate moments.
library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/features/auth/data/models/auth_response.dart';
import 'package:flutter_starter/features/auth/data/models/login_request.dart';
import 'package:flutter_starter/features/auth/data/models/register_request.dart';
import 'package:flutter_starter/features/auth/data/models/user_dto.dart';
import 'package:flutter_starter/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_starter/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockTokenStorage mockTokenStorage;
  late AuthRepository repository;

  /// Reusable test data.
  const testUserDto = UserDto(
    id: 'user-1',
    email: 'test@example.com',
    name: 'Test User',
  );

  const testAuthResponse = AuthResponse(
    accessToken: 'access-token-123',
    refreshToken: 'refresh-token-456',
    user: testUserDto,
  );

  setUp(() {
    mockAuthService = MockAuthService();
    mockTokenStorage = MockTokenStorage();
    repository = AuthRepository(mockAuthService, mockTokenStorage);

    // Register fallback values for mocktail argument matchers.
    registerFallbackValue(const LoginRequest(email: '', password: ''));
    registerFallbackValue(
      const RegisterRequest(email: '', password: '', name: ''),
    );
  });

  /// Tests for [AuthRepository.login].
  group('login', () {
    /// Returns a [Success] containing the mapped [User] on a successful
    /// API response.
    test('returns Success with user on success', () async {
      when(
        () => mockAuthService.login(any()),
      ).thenAnswer((_) async => testAuthResponse);
      when(
        () => mockTokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.login('test@example.com', 'password123');

      expect(result.isSuccess, isTrue);
      final user = result.getOrNull();
      expect(user, isNotNull);
      expect(user!.id, 'user-1');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
    });

    /// Saves both access and refresh tokens after a successful login.
    test('saves tokens on success', () async {
      when(
        () => mockAuthService.login(any()),
      ).thenAnswer((_) async => testAuthResponse);
      when(
        () => mockTokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});

      await repository.login('test@example.com', 'password123');

      verify(
        () => mockTokenStorage.saveTokens(
          accessToken: 'access-token-123',
          refreshToken: 'refresh-token-456',
        ),
      ).called(1);
    });

    /// Returns an [Err] with [InvalidCredentials] when the server
    /// responds with a 401 status code.
    test('returns Err with InvalidCredentials on 401', () async {
      when(() => mockAuthService.login(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          error: const ServerException('Unauthorized', statusCode: 401),
        ),
      );

      final result = await repository.login(
        'test@example.com',
        'wrong-password',
      );

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('should not succeed'),
        failure: (f) => expect(f, isA<InvalidCredentials>()),
      );
    });

    /// Returns an [Err] with [AuthServerError] for non-401/409 server
    /// errors.
    test('returns Err with AuthServerError on generic server error', () async {
      when(() => mockAuthService.login(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          error: const ServerException('Internal error', statusCode: 500),
        ),
      );

      final result = await repository.login('test@example.com', 'password123');

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('should not succeed'),
        failure: (f) => expect(f, isA<AuthServerError>()),
      );
    });

    /// Returns an [Err] with [UnexpectedFailure] for non-Dio exceptions.
    test(
      'returns Err with UnexpectedFailure on unexpected exception',
      () async {
        when(
          () => mockAuthService.login(any()),
        ).thenThrow(Exception('something broke'));

        final result = await repository.login(
          'test@example.com',
          'password123',
        );

        expect(result.isFailure, isTrue);
        result.when(
          success: (_) => fail('should not succeed'),
          failure: (f) => expect(f, isA<UnexpectedFailure>()),
        );
      },
    );
  });

  /// Tests for [AuthRepository.logout].
  group('logout', () {
    /// Clears tokens and returns Success on a clean server logout.
    test('clears tokens and returns Success on success', () async {
      when(() => mockAuthService.logout()).thenAnswer((_) async {});
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result.isSuccess, isTrue);
      verify(() => mockTokenStorage.clearTokens()).called(1);
    });

    /// Clears tokens even when the server request fails with a
    /// [DioException].
    test('clears tokens even on server error', () async {
      when(
        () => mockAuthService.logout(),
      ).thenThrow(DioException(requestOptions: RequestOptions()));
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      final result = await repository.logout();

      // The repository swallows server errors on logout and still
      // returns Success after clearing local tokens.
      expect(result.isSuccess, isTrue);
      verify(() => mockTokenStorage.clearTokens()).called(1);
    });

    /// Clears tokens even when an unexpected exception occurs, but
    /// returns an Err in that case.
    test('clears tokens on unexpected exception and returns Err', () async {
      when(
        () => mockAuthService.logout(),
      ).thenThrow(Exception('network stack crashed'));
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      final result = await repository.logout();

      // Unexpected (non-Dio) exceptions still clear tokens but return Err.
      expect(result.isFailure, isTrue);
      verify(() => mockTokenStorage.clearTokens()).called(1);
    });
  });

  /// Tests for [AuthRepository.getCurrentUser].
  group('getCurrentUser', () {
    /// Returns Success(null) when no access token is stored, without
    /// hitting the network.
    test('returns Success(null) when no token exists', () async {
      when(
        () => mockTokenStorage.getAccessToken(),
      ).thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), isNull);
      verifyNever(() => mockAuthService.getCurrentUser());
    });

    /// Returns Success with the mapped User when a token is stored and
    /// the server responds successfully.
    test('returns Success with user when token exists', () async {
      when(
        () => mockTokenStorage.getAccessToken(),
      ).thenAnswer((_) async => 'access-token-123');
      when(
        () => mockAuthService.getCurrentUser(),
      ).thenAnswer((_) async => testUserDto);

      final result = await repository.getCurrentUser();

      expect(result.isSuccess, isTrue);
      final user = result.getOrNull();
      expect(user, isNotNull);
      expect(user!.id, 'user-1');
      expect(user.email, 'test@example.com');
    });

    /// Clears tokens and returns Success(null) when the server responds
    /// with 401, indicating the session is no longer valid.
    test('clears tokens and returns Success(null) on 401', () async {
      when(
        () => mockTokenStorage.getAccessToken(),
      ).thenAnswer((_) async => 'expired-token');
      when(() => mockAuthService.getCurrentUser()).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          error: const ServerException('Unauthorized', statusCode: 401),
        ),
      );
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      final result = await repository.getCurrentUser();

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), isNull);
      verify(() => mockTokenStorage.clearTokens()).called(1);
    });
  });
}
