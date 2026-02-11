/// Tests for [AuthGuard].
///
/// Uses mocked [NavigationResolver] and [StackRouter] to verify that the
/// guard correctly allows or blocks navigation based on [authStateProvider].
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/routing/app_router.dart';
import 'package:flutter_starter/core/routing/guards/auth_guard.dart';
import 'package:flutter_starter/features/auth/ui/view_models/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_utils.dart';

/// Mock [NavigationResolver] for testing guard behavior.
class MockNavigationResolver extends Mock implements NavigationResolver {}

/// Mock [StackRouter] for testing guard behavior.
class MockStackRouter extends Mock implements StackRouter {}

void main() {
  late MockNavigationResolver mockResolver;
  late MockStackRouter mockRouter;

  setUpAll(() {
    // Register fallback value for LoginRoute.
    registerFallbackValue(const LoginRoute());
  });

  setUp(() {
    mockResolver = MockNavigationResolver();
    mockRouter = MockStackRouter();

    // Stub void methods.
    when(() => mockResolver.next(any())).thenReturn(null);
    when(() => mockResolver.redirectUntil(any())).thenReturn(null);
  });

  /// Tests for [AuthGuard.onNavigation].
  group('onNavigation', () {
    /// Allows navigation when the user is authenticated.
    test('allows navigation when authenticated', () {
      final container = createContainer(
        overrides: [authStateProvider.overrideWithValue(true)],
      );

      late AuthGuard guard;
      final testProvider = Provider<void>((ref) {
        guard = AuthGuard(ref);
      });
      container.read(testProvider);

      guard.onNavigation(mockResolver, mockRouter);

      verify(() => mockResolver.next()).called(1);
      verifyNever(() => mockResolver.redirectUntil(any()));
    });

    /// Redirects to [LoginRoute] when the user is not authenticated.
    test('redirects to LoginRoute when not authenticated', () {
      final container = createContainer(
        overrides: [authStateProvider.overrideWithValue(false)],
      );

      late AuthGuard guard;
      final testProvider = Provider<void>((ref) {
        guard = AuthGuard(ref);
      });
      container.read(testProvider);

      guard.onNavigation(mockResolver, mockRouter);

      verifyNever(() => mockResolver.next());
      verify(() => mockResolver.redirectUntil(const LoginRoute())).called(1);
    });
  });
}
