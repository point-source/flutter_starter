/// Tests for [AuthGuard].
///
/// Uses mocked [NavigationResolver] and [StackRouter] to verify that the
/// guard correctly allows or blocks navigation based on [isAuthenticatedProvider].
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/routing/app_router.dart';
import 'package:flutter_starter/core/routing/guards/auth_guard.dart';
import 'package:flutter_starter/features/auth/data/providers/auth_providers.dart';
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
    // ignore: no-empty-block
    when(() => mockRouter.replaceAll(any())).thenAnswer((_) async {});
  });

  /// Tests for [AuthGuard.onNavigation].
  group('onNavigation', () {
    /// Allows navigation when the user is authenticated.
    test('allows navigation when authenticated', () {
      final container = createContainer(
        overrides: [isAuthenticatedProvider.overrideWithValue(true)],
      );

      late AuthGuard guard;
      final testProvider = Provider((ref) {
        guard = AuthGuard(ref);
      });
      container.read(testProvider);

      guard.onNavigation(mockResolver, mockRouter);

      verify(() => mockResolver.next()).called(1);
      verifyNever(() => mockRouter.replaceAll(any()));
    });

    /// Redirects to [LoginRoute] when the user is not authenticated.
    test('redirects to LoginRoute when not authenticated', () {
      final container = createContainer(
        overrides: [isAuthenticatedProvider.overrideWithValue(false)],
      );

      late AuthGuard guard;
      final testProvider = Provider((ref) {
        guard = AuthGuard(ref);
      });
      container.read(testProvider);

      guard.onNavigation(mockResolver, mockRouter);

      verify(() => mockResolver.next(false)).called(1);
      verify(() => mockRouter.replaceAll(const [LoginRoute()])).called(1);
    });
  });
}
