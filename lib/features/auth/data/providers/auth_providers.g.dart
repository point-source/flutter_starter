// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provide the [IAuthRepository] implementation.
///
/// Returns [MockAuthRepository] when `BACKEND=mock` (the default).
/// When `BACKEND=real`, replace the [UnimplementedError] with your own
/// [IAuthRepository] backed by Supabase, Firebase, Dio, etc.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Provide the [IAuthRepository] implementation.
///
/// Returns [MockAuthRepository] when `BACKEND=mock` (the default).
/// When `BACKEND=real`, replace the [UnimplementedError] with your own
/// [IAuthRepository] backed by Supabase, Firebase, Dio, etc.

final class AuthRepositoryProvider
    extends
        $FunctionalProvider<IAuthRepository, IAuthRepository, IAuthRepository>
    with $Provider<IAuthRepository> {
  /// Provide the [IAuthRepository] implementation.
  ///
  /// Returns [MockAuthRepository] when `BACKEND=mock` (the default).
  /// When `BACKEND=real`, replace the [UnimplementedError] with your own
  /// [IAuthRepository] backed by Supabase, Firebase, Dio, etc.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<IAuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IAuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IAuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'63f44367d6f0d68567bc2abc5dce1f72a7650822';

/// Notifier that owns the reactive [AuthState] for the entire app.
///
/// This is the single source of truth for authentication state. External
/// consumers (guards, other features) watch this provider. Auth UI pages
/// also use it directly for mutations and loading/error states.

@ProviderFor(AuthStateRepo)
final authStateRepoProvider = AuthStateRepoProvider._();

/// Notifier that owns the reactive [AuthState] for the entire app.
///
/// This is the single source of truth for authentication state. External
/// consumers (guards, other features) watch this provider. Auth UI pages
/// also use it directly for mutations and loading/error states.
final class AuthStateRepoProvider
    extends $AsyncNotifierProvider<AuthStateRepo, AuthState> {
  /// Notifier that owns the reactive [AuthState] for the entire app.
  ///
  /// This is the single source of truth for authentication state. External
  /// consumers (guards, other features) watch this provider. Auth UI pages
  /// also use it directly for mutations and loading/error states.
  AuthStateRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateRepoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateRepoHash();

  @$internal
  @override
  AuthStateRepo create() => AuthStateRepo();
}

String _$authStateRepoHash() => r'20dd8a7bf0d099d641d9a8e3a5f551492f6f3341';

/// Notifier that owns the reactive [AuthState] for the entire app.
///
/// This is the single source of truth for authentication state. External
/// consumers (guards, other features) watch this provider. Auth UI pages
/// also use it directly for mutations and loading/error states.

abstract class _$AuthStateRepo extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthState>, AuthState>,
              AsyncValue<AuthState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Expose whether the user is authenticated as a simple boolean.
///
/// Consumed by [AuthGuard] and other components that need a synchronous
/// check without caring about the full [AuthState].

@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = IsAuthenticatedProvider._();

/// Expose whether the user is authenticated as a simple boolean.
///
/// Consumed by [AuthGuard] and other components that need a synchronous
/// check without caring about the full [AuthState].

final class IsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Expose whether the user is authenticated as a simple boolean.
  ///
  /// Consumed by [AuthGuard] and other components that need a synchronous
  /// check without caring about the full [AuthState].
  IsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthenticatedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'2bef2f42d6a6ee87112c5ddf74f60a9aaba8d47a';

/// A [Listenable] that fires whenever [isAuthenticatedProvider] changes.
///
/// Pass this to [RootStackRouter.config]'s `reevaluateListenable` so that
/// route guards (e.g. [AuthGuard]) are automatically re-evaluated on
/// login, logout, token expiry, or server-side session revocation.

@ProviderFor(authStateListenable)
final authStateListenableProvider = AuthStateListenableProvider._();

/// A [Listenable] that fires whenever [isAuthenticatedProvider] changes.
///
/// Pass this to [RootStackRouter.config]'s `reevaluateListenable` so that
/// route guards (e.g. [AuthGuard]) are automatically re-evaluated on
/// login, logout, token expiry, or server-side session revocation.

final class AuthStateListenableProvider
    extends
        $FunctionalProvider<
          AuthStateListenable,
          AuthStateListenable,
          AuthStateListenable
        >
    with $Provider<AuthStateListenable> {
  /// A [Listenable] that fires whenever [isAuthenticatedProvider] changes.
  ///
  /// Pass this to [RootStackRouter.config]'s `reevaluateListenable` so that
  /// route guards (e.g. [AuthGuard]) are automatically re-evaluated on
  /// login, logout, token expiry, or server-side session revocation.
  AuthStateListenableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateListenableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateListenableHash();

  @$internal
  @override
  $ProviderElement<AuthStateListenable> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthStateListenable create(Ref ref) {
    return authStateListenable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthStateListenable value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthStateListenable>(value),
    );
  }
}

String _$authStateListenableHash() =>
    r'fb80a3172f7f160b06495f77e9841c5262415515';
