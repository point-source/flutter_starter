/// Tests for [AuthStateRepo].
///
/// Uses a [ProviderContainer] with a mocked [IAuthRepository] to verify
/// that the notifier correctly translates repository results into
/// [AsyncValue<AuthState>] transitions.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/auth/data/providers/auth_providers.dart';
import 'package:flutter_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_starter/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_utils.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  /// Helper to create a container with the auth repository overridden.
  ProviderContainer createAuthContainer() => createContainer(
    overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
  );

  /// Tests for the initial [build] method.
  group('build', () {
    /// Resolves to unauthenticated when the repository has no current user.
    test('returns unauthenticated when no user exists', () async {
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Success<User?>(null));

      final container = createAuthContainer();

      // Read the provider to trigger build().
      final future = container.read(authStateRepoProvider.future);
      final state = await future;

      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
    });

    /// Resolves to authenticated with the user when a session exists.
    test('returns authenticated when user exists', () async {
      final testUser = FakeData.user();

      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => Success<User?>(testUser));

      final container = createAuthContainer();

      final state = await container.read(authStateRepoProvider.future);

      expect(state.isAuthenticated, isTrue);
      expect(state.user, isNotNull);
      expect(state.user!.email, 'test@example.com');
    });

    /// Resolves to unauthenticated when getCurrentUser returns a failure.
    test('returns unauthenticated on failure', () async {
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Err<User?>(AuthServerError()));

      final container = createAuthContainer();

      final state = await container.read(authStateRepoProvider.future);

      expect(state.isAuthenticated, isFalse);
    });
  });

  /// Tests for [AuthStateRepo.login].
  group('login', () {
    /// Transitions to authenticated state on a successful login.
    test('transitions to authenticated on success', () async {
      final testUser = FakeData.user();

      // Stub build() to start unauthenticated.
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Success<User?>(null));
      when(
        () => mockAuthRepository.login(any(), any()),
      ).thenAnswer((_) async => Success(testUser));

      final container = createAuthContainer();

      // Wait for build() to complete.
      await container.read(authStateRepoProvider.future);

      // Perform login.
      final notifier = container.read(authStateRepoProvider.notifier);
      final result = await notifier.login('test@example.com', 'password123');

      expect(result.isSuccess, isTrue);

      final state = container.read(authStateRepoProvider);
      expect(state.hasValue, isTrue);
      expect(state.requireValue.isAuthenticated, isTrue);
      expect(state.requireValue.user!.email, 'test@example.com');
    });

    /// Transitions to error state when login fails.
    test('transitions to error on failure', () async {
      // Stub build() to start unauthenticated.
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Success<User?>(null));
      when(
        () => mockAuthRepository.login(any(), any()),
      ).thenAnswer((_) async => const Err(InvalidCredentials()));

      final container = createAuthContainer();

      // Wait for build() to complete.
      await container.read(authStateRepoProvider.future);

      // Perform login.
      final notifier = container.read(authStateRepoProvider.notifier);
      final result = await notifier.login('test@example.com', 'wrong-password');

      expect(result.isFailure, isTrue);

      final state = container.read(authStateRepoProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<InvalidCredentials>());
    });
  });

  /// Tests for [AuthStateRepo.register].
  group('register', () {
    /// Transitions to authenticated state on a successful registration.
    test('transitions to authenticated on success', () async {
      final testUser = FakeData.user();

      // Stub build() to start unauthenticated.
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Success<User?>(null));
      when(
        () => mockAuthRepository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => Success(testUser));

      final container = createAuthContainer();

      // Wait for build() to complete.
      await container.read(authStateRepoProvider.future);

      // Perform registration.
      final notifier = container.read(authStateRepoProvider.notifier);
      final result = await notifier.register(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
      );

      expect(result.isSuccess, isTrue);

      final state = container.read(authStateRepoProvider);
      expect(state.hasValue, isTrue);
      expect(state.requireValue.isAuthenticated, isTrue);
      expect(state.requireValue.user!.email, 'test@example.com');
    });

    /// Transitions to error state when registration fails.
    test('transitions to error on failure', () async {
      // Stub build() to start unauthenticated.
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Success<User?>(null));
      when(
        () => mockAuthRepository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => const Err(EmailAlreadyInUse()));

      final container = createAuthContainer();

      // Wait for build() to complete.
      await container.read(authStateRepoProvider.future);

      // Perform registration.
      final notifier = container.read(authStateRepoProvider.notifier);
      final result = await notifier.register(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
      );

      expect(result.isFailure, isTrue);

      final state = container.read(authStateRepoProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<EmailAlreadyInUse>());
    });
  });

  /// Tests for [AuthStateRepo.logout].
  group('logout', () {
    /// Transitions to unauthenticated state after logout.
    test('transitions to unauthenticated', () async {
      final testUser = FakeData.user();

      // Start authenticated.
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => Success<User?>(testUser));
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => const Success<void>(null));

      final container = createAuthContainer();

      // Wait for build() -- should be authenticated.
      final initialState = await container.read(authStateRepoProvider.future);
      expect(initialState.isAuthenticated, isTrue);

      // Perform logout.
      final notifier = container.read(authStateRepoProvider.notifier);
      await notifier.logout();

      final state = container.read(authStateRepoProvider);
      expect(state.hasValue, isTrue);
      expect(state.requireValue.isAuthenticated, isFalse);
      expect(state.requireValue.user, isNull);
    });
  });
}
