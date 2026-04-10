/// Tests for [AuthStateRepo].
///
/// Uses a [ProviderContainer] with a mocked [IAuthRepository] to verify
/// that the notifier correctly translates repository results into
/// [AsyncValue<AuthState>] transitions.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/core/logging/logger_provider.dart';
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
  late MockAppLogger mockLogger;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockLogger = MockAppLogger();
  });

  /// Helper to create a container with the auth repository overridden.
  ProviderContainer createAuthContainer() => createContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockAuthRepository),
      loggerProvider.overrideWithValue(mockLogger),
    ],
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

  /// Tests for the derived [isAuthenticatedProvider] and the in-flight
  /// loading-state behaviour of [AuthStateRepo] mutators.
  ///
  /// These pin two related contracts:
  ///
  /// 1. While `build()` is still pending on cold start the boolean is
  ///    `false`. The splash gate in `lib/app.dart` is what prevents the
  ///    router (and therefore [AuthGuard]) from observing this transient
  ///    state — if anyone changes [isAuthenticatedProvider] to return a
  ///    different value during loading, that gate needs to be revisited.
  /// 2. After the initial resolution, in-flight mutations preserve the
  ///    previous data via `copyWithPrevious(state)`, so subsequent loading
  ///    transitions still report `hasValue == true`. The splash gate
  ///    relies on this to avoid flashing on every login/register/logout.
  group('isAuthenticated provider and loading transitions', () {
    test('returns false while build() is still pending (cold-start race)', () {
      final pending = Completer<Result<User?>>();
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) => pending.future);

      final container = createAuthContainer();

      // Force build() to start without awaiting it.
      final asyncValue = container.read(authStateRepoProvider);
      expect(asyncValue.isLoading, isTrue);
      expect(asyncValue.hasValue, isFalse);
      expect(asyncValue.hasError, isFalse);

      // The boolean derived for AuthGuard collapses loading to false.
      expect(container.read(isAuthenticatedProvider), isFalse);

      // Avoid leaking the pending future past the test.
      pending.complete(const Success<User?>(null));
    });

    test('returns true after build() resolves to authenticated', () async {
      final testUser = FakeData.user();
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => Success<User?>(testUser));

      final container = createAuthContainer();
      await container.read(authStateRepoProvider.future);

      expect(container.read(isAuthenticatedProvider), isTrue);
    });

    test('preserves previous data during login transition', () async {
      // Start unauthenticated.
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Success<User?>(null));

      // Hold the login response open so we can inspect the loading state.
      final loginPending = Completer<Result<User>>();
      when(
        () => mockAuthRepository.login(any(), any()),
      ).thenAnswer((_) => loginPending.future);

      final container = createAuthContainer();
      await container.read(authStateRepoProvider.future);

      final notifier = container.read(authStateRepoProvider.notifier);
      // Kick off the login but do not await it.
      final loginFuture = notifier.login('test@example.com', 'password123');

      // Mid-flight: still loading, but previous data is preserved.
      final inFlight = container.read(authStateRepoProvider);
      expect(inFlight.isLoading, isTrue);
      expect(inFlight.hasValue, isTrue);
      expect(inFlight.requireValue.isAuthenticated, isFalse);

      // Resolve and verify final state.
      loginPending.complete(Success(FakeData.user()));
      await loginFuture;

      final finalState = container.read(authStateRepoProvider);
      expect(finalState.hasValue, isTrue);
      expect(finalState.isLoading, isFalse);
      expect(finalState.requireValue.isAuthenticated, isTrue);
    });

    test('preserves previous data during logout transition', () async {
      final testUser = FakeData.user();

      // Start authenticated.
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => Success<User?>(testUser));

      // Hold the logout response open so we can inspect the loading state.
      final logoutPending = Completer<Result<void>>();
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) => logoutPending.future);

      final container = createAuthContainer();
      final initial = await container.read(authStateRepoProvider.future);
      expect(initial.isAuthenticated, isTrue);

      final notifier = container.read(authStateRepoProvider.notifier);
      // Kick off the logout but do not await it.
      final logoutFuture = notifier.logout();

      // Mid-flight: still loading, but previous (authenticated) data
      // is preserved so the splash gate in app.dart will not re-trigger.
      final inFlight = container.read(authStateRepoProvider);
      expect(inFlight.isLoading, isTrue);
      expect(inFlight.hasValue, isTrue);
      expect(inFlight.requireValue.isAuthenticated, isTrue);

      // Resolve and verify final state.
      logoutPending.complete(const Success<void>(null));
      await logoutFuture;

      final finalState = container.read(authStateRepoProvider);
      expect(finalState.hasValue, isTrue);
      expect(finalState.isLoading, isFalse);
      expect(finalState.requireValue.isAuthenticated, isFalse);
    });
  });
}
