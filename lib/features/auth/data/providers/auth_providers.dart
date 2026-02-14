/// Auth infrastructure providers and the reactive auth state notifier.
///
/// This file is the **public API** for authentication state. External
/// consumers (route guards, other features, [App] widget) import from
/// here — never from `ui/view_models/`.
///
/// Providers:
/// - [authServiceProvider] — retrofit [AuthService]
/// - [authRepositoryProvider] — [IAuthRepository] implementation
/// - [authStateRepoProvider] — reactive [AuthState] with mutations
/// - [isAuthenticatedProvider] — simple boolean for guards
/// - [authStateListenableProvider] — [Listenable] for router reevaluation
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_starter/core/env/app_environment.dart';
import 'package:flutter_starter/core/network/dio_provider.dart';
import 'package:flutter_starter/core/storage/token_storage.dart';
import 'package:flutter_starter/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_starter/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:flutter_starter/features/auth/data/services/auth_service.dart';
import 'package:flutter_starter/features/auth/domain/entities/auth_state.dart';
import 'package:flutter_starter/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

/// Create an [AuthService] backed by the application's [Dio] instance.
@riverpod
AuthService authService(Ref ref) => .new(ref.read(dioProvider));

/// Create an [IAuthRepository] wired to the auth service and token storage.
///
/// When `AUTH_BYPASS=mock` is set, returns a [MockAuthRepository] that
/// provides a fake user with no network calls.
@riverpod
IAuthRepository authRepository(Ref ref) => switch (AppEnvironment.authBypass) {
  'mock' => const MockAuthRepository(),
  _ => AuthRepository(
    ref.read(authServiceProvider),
    ref.read(tokenStorageProvider),
  ),
};

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
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.login(email, password);

    state = result.when(
      success: (user) => AsyncData(AuthState.authenticated(user)),
      failure: (failure) => AsyncError(failure, failure.stackTrace ?? .current),
    );
  }

  /// Create a new account with [email], [password], and [name].
  ///
  /// Sets state to loading, then either authenticated or error.
  Future<void> register({
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
