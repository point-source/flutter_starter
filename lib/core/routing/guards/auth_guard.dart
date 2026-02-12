/// Route guard that restricts navigation to authenticated users.
///
/// Reads the current authentication state from [authStateProvider] and
/// either allows navigation to proceed or redirects to [LoginRoute].
/// Attach this guard to any route or route group that requires the user
/// to be logged in.
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_starter/core/env/app_environment.dart';
import 'package:flutter_starter/core/routing/app_router.dart';
import 'package:flutter_starter/features/auth/ui/view_models/auth_view_model.dart';

/// Guard that checks authentication before allowing route navigation.
///
/// Pass a Riverpod [Ref] to the constructor so the guard can read
/// [authStateProvider] synchronously during the navigation lifecycle.
///
/// ```dart
/// AutoRoute(
///   page: ProtectedRoute.page,
///   guards: [AuthGuard(ref)],
/// )
/// ```
class AuthGuard extends AutoRouteGuard {
  /// Create an [AuthGuard] backed by the given Riverpod [ref].
  const AuthGuard(this._ref);

  final Ref _ref;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (AppEnvironment.authBypass == 'mock') {
      resolver.next();
      return;
    }

    final isAuthenticated = _ref.read(authStateProvider);

    if (isAuthenticated) {
      resolver.next();
    } else {
      resolver.redirectUntil(const LoginRoute());
    }
  }
}
