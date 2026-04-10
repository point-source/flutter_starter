/// Cold-start widget tests for [App].
///
/// These pin the contract that protects against the AuthGuard race
/// described in the bug "AuthGuard race on cold start drops persisted
/// sessions". Specifically:
///
/// 1. While the initial auth-state resolution is pending, the app shows
///    the bootstrap splash and never lets the router run its guards.
/// 2. Once the resolution completes with a restored session, the app
///    lands on the authenticated shell — not on /login.
/// 3. Once the resolution completes with no session, the app lands on
///    /login as expected.
/// 4. After the cold-start splash has been retired, in-flight mutations
///    (login/register/logout) do **not** re-trigger the splash. This
///    relies on [AuthStateRepo] mutators preserving previous data via
///    `copyWithPrevious(state)`.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/app.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/core/logging/logger_provider.dart';
import 'package:flutter_starter/core/storage/shared_prefs_provider.dart';
import 'package:flutter_starter/features/auth/data/providers/auth_providers.dart';
import 'package:flutter_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_starter/features/auth/ui/pages/login_page.dart';
import 'package:flutter_starter/features/dashboard/ui/pages/dashboard_page.dart';
import 'package:flutter_starter/gen/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fakes.dart';
import 'helpers/mocks.dart';

void main() {
  late SharedPreferences sharedPreferences;
  late MockAuthRepository mockAuthRepository;
  late MockAppLogger mockLogger;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    sharedPreferences = await SharedPreferences.getInstance();
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockLogger = MockAppLogger();
  });

  /// Pump the real [App] widget tree with the test mocks plugged in.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(sharedPreferences),
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          loggerProvider.overrideWithValue(mockLogger),
        ],
        child: TranslationProvider(child: const App()),
      ),
    );
  }

  group('cold-start auth gating', () {
    testWidgets('shows splash while initial auth state is loading', (
      tester,
    ) async {
      // getCurrentUser hangs forever — we will only inspect the splash.
      final pending = Completer<Result<User?>>();
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) => pending.future);

      await pumpApp(tester);
      // Single pump only — pumpAndSettle would hang on the pending future.
      await tester.pump();

      expect(find.byKey(const Key('auth-bootstrap-splash')), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(DashboardPage), findsNothing);

      // Resolve so the test does not leave a dangling completer.
      pending.complete(const Success<User?>(null));
      await tester.pumpAndSettle();
    });

    testWidgets('navigates to authenticated shell when a session is restored', (
      tester,
    ) async {
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => Success<User?>(FakeData.user()));

      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(find.byType(DashboardPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byKey(const Key('auth-bootstrap-splash')), findsNothing);
    });

    testWidgets('navigates to login when no session exists', (tester) async {
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Success<User?>(null));

      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(DashboardPage), findsNothing);
      expect(find.byKey(const Key('auth-bootstrap-splash')), findsNothing);
    });

    testWidgets(
      'does not flash splash during a login mutation after cold start',
      (tester) async {
        // Cold-start unauthenticated so we land on LoginPage.
        when(
          () => mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Success<User?>(null));

        // Hold the login response open so the mutation stays in-flight.
        final loginPending = Completer<Result<User>>();
        when(
          () => mockAuthRepository.login(any(), any()),
        ).thenAnswer((_) => loginPending.future);

        await pumpApp(tester);
        await tester.pumpAndSettle();
        expect(find.byType(LoginPage), findsOneWidget);

        // Reach into the running ProviderScope to trigger the mutation
        // directly. We deliberately bypass LoginPage's onPressed handler
        // so this test stays focused on the splash gate — the post-login
        // navigation back to the shell is LoginPage's responsibility and
        // is covered by the "session is restored" test above.
        final element = tester.element(find.byType(LoginPage));
        final container = ProviderScope.containerOf(element);
        unawaited(
          container
              .read(authStateRepoProvider.notifier)
              .login('test@example.com', 'password'),
        );
        await tester.pump();

        // Critical assertion: the splash must NOT take over while the
        // login is in-flight. The user stays on LoginPage with its inline
        // spinner instead. This is the regression test for the
        // copyWithPrevious(state) change in AuthStateRepo.login().
        expect(find.byKey(const Key('auth-bootstrap-splash')), findsNothing);
        expect(find.byType(LoginPage), findsOneWidget);

        // Resolve so the test does not leave a dangling completer, and
        // confirm the auth state itself ended up authenticated.
        loginPending.complete(Success(FakeData.user()));
        await tester.pumpAndSettle();
        final finalState = container.read(authStateRepoProvider);
        expect(finalState.hasValue, isTrue);
        expect(finalState.requireValue.isAuthenticated, isTrue);
      },
    );
  });
}
