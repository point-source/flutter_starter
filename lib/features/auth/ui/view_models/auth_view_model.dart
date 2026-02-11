/// Manage authentication state and expose auth operations to the UI.
///
/// Provides the [AuthViewModel] notifier and several companion providers:
/// - [authServiceProvider] -- the retrofit [AuthService]
/// - [authRepositoryProvider] -- the [IAuthRepository] implementation
/// - [authStateProvider] -- a simple boolean indicating whether the user
///   is authenticated, consumed by [AuthGuard]
///
/// The view model wraps [IAuthRepository] calls in [AsyncValue] so that
/// the UI can react to loading, data, and error states declaratively.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/network/dio_provider.dart';
import 'package:flutter_starter/core/storage/token_storage.dart';
import 'package:flutter_starter/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_starter/features/auth/data/services/auth_service.dart';
import 'package:flutter_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_starter/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

/// Represent the current authentication state.
///
/// Use the named factories to create the appropriate variant and read
/// [isAuthenticated] / [user] to inspect the state without pattern matching.
class AuthState {
  const AuthState._({required this.isAuthenticated, this.user});

  /// No authentication check has been performed yet.
  factory AuthState.initial() => const AuthState._(isAuthenticated: false);

  /// The user is authenticated and their profile is available.
  factory AuthState.authenticated(User user) =>
      AuthState._(user: user, isAuthenticated: true);

  /// The user is not authenticated (logged out or session invalid).
  factory AuthState.unauthenticated() =>
      const AuthState._(isAuthenticated: false);

  /// Whether the user is currently authenticated.
  final bool isAuthenticated;

  /// The authenticated user's profile, or `null` if unauthenticated.
  final User? user;
}

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

/// Create an [AuthService] backed by the application's [Dio] instance.
@riverpod
AuthService authService(Ref ref) => AuthService(ref.read(dioProvider));

/// Create an [IAuthRepository] wired to the auth service and token storage.
@riverpod
IAuthRepository authRepository(Ref ref) => AuthRepository(
  ref.read(authServiceProvider),
  ref.read(tokenStorageProvider),
);

// ---------------------------------------------------------------------------
// Auth view model
// ---------------------------------------------------------------------------

/// Notifier that manages the authentication lifecycle.
///
/// The [build] method checks for an existing session on startup.
/// [login], [register], and [logout] mutate the state and delegate
/// to [IAuthRepository].
@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
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
      failure: (failure) => AsyncError(failure, StackTrace.current),
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
      failure: (failure) => AsyncError(failure, StackTrace.current),
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
// Derived provider
// ---------------------------------------------------------------------------

/// Expose whether the user is authenticated as a simple boolean.
///
/// Consumed by [AuthGuard] and other components that need a synchronous
/// check without caring about the full [AuthState].
@riverpod
bool authState(Ref ref) {
  final viewModel = ref.watch(authViewModelProvider);
  return viewModel.whenOrNull(data: (state) => state.isAuthenticated) ?? false;
}
