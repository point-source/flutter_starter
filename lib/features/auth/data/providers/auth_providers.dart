/// Auth infrastructure providers and the reactive auth state notifier.
///
/// This file is the **public API** for authentication state. External
/// consumers (route guards, other features, [App] widget) import from
/// here — never from `ui/view_models/`.
///
/// Providers:
/// - [authRepositoryProvider] — [IAuthRepository] implementation
/// - [authStateRepoProvider] — reactive [AuthState] with mutations
/// - [isAuthenticatedProvider] — simple boolean for guards
/// - [authStateListenableProvider] — [Listenable] for router reevaluation
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_starter/core/env/app_environment.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:flutter_starter/features/auth/domain/entities/auth_state.dart';
import 'package:flutter_starter/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

/// Provide the [IAuthRepository] implementation.
///
/// Returns [MockAuthRepository] when `BACKEND=mock` (the default).
/// When `BACKEND=real`, replace the [UnimplementedError] with your own
/// [IAuthRepository] backed by Supabase, Firebase, Dio, etc.
@riverpod
IAuthRepository authRepository(Ref ref) {
  if (AppEnvironment.backendMode == BackendMode.mock) {
    return const MockAuthRepository();
  }
  // TODO: Replace with your backend implementation.
  throw UnimplementedError(
    'BACKEND is set to "real" but no auth backend is configured. '
    'Implement IAuthRepository and return it here.',
  );
}

// ---------------------------------------------------------------------------
// Auth state notifier (the public API for auth state)
// ---------------------------------------------------------------------------

/// Notifier that owns the reactive [AuthState] for the entire app.
///
/// This is the single source of truth for authentication state. External
/// consumers (guards, other features) watch this provider. Auth UI pages
/// also use it directly for mutations and loading/error states.
@Riverpod(keepAlive: true)
class AuthStateRepo extends _$AuthStateRepo {
  @override
  Future<AuthState> build() async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.getCurrentUser();

    return result.when(
      success: (user) {
        if (user != null) {
          return AuthState.authenticated(user);
        }
        return AuthState.unauthenticated();
      },
      failure: (_) => AuthState.unauthenticated(),
    );
  }

  /// Authenticate with [email] and [password].
  ///
  /// Sets state to loading, then either authenticated or error.
  /// Returns a [Result] so callers can react to success or failure.
  Future<Result<void>> login(String email, String password) async {
    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.login(email, password);

    state = result.when(
      success: (user) => AsyncData(AuthState.authenticated(user)),
      failure: (failure) => AsyncError(failure, failure.stackTrace ?? .current),
    );

    // ignore: no-empty-block
    return result.map((_) {});
  }

  /// Create a new account with [email], [password], and [name].
  ///
  /// Sets state to loading, then either authenticated or error.
  /// Returns a [Result] so callers can react to success or failure.
  Future<Result<void>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.register(
      email: email,
      password: password,
      name: name,
    );

    state = result.when(
      success: (user) => AsyncData(AuthState.authenticated(user)),
      failure: (failure) => AsyncError(failure, failure.stackTrace ?? .current),
    );

    // ignore: no-empty-block
    return result.map((_) {});
  }

  /// End the current session and return to the unauthenticated state.
  Future<void> logout() async {
    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = AsyncData(AuthState.unauthenticated());
  }
}

// ---------------------------------------------------------------------------
// Derived providers
// ---------------------------------------------------------------------------

/// Expose whether the user is authenticated as a simple boolean.
///
/// Consumed by [AuthGuard] and other components that need a synchronous
/// check without caring about the full [AuthState].
@riverpod
bool isAuthenticated(Ref ref) {
  final authAsync = ref.watch(authStateRepoProvider);
  return authAsync.whenOrNull(data: (state) => state.isAuthenticated) ?? false;
}

/// A [Listenable] that fires whenever [isAuthenticatedProvider] changes.
///
/// Pass this to [RootStackRouter.config]'s `reevaluateListenable` so that
/// route guards (e.g. [AuthGuard]) are automatically re-evaluated on
/// login, logout, token expiry, or server-side session revocation.
@Riverpod(keepAlive: true)
AuthStateListenable authStateListenable(Ref ref) {
  final notifier = AuthStateListenable();
  ref
    ..listen(isAuthenticatedProvider, (_, _) => notifier.notify())
    ..onDispose(notifier.dispose);
  return notifier;
}

/// A [ChangeNotifier] that exposes a public [notify] method.
class AuthStateListenable extends ChangeNotifier {
  /// Notify listeners that the auth state has changed.
  void notify() => notifyListeners();
}
