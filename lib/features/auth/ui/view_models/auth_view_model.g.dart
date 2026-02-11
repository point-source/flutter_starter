// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create an [AuthService] backed by the application's [Dio] instance.

@ProviderFor(authService)
final authServiceProvider = AuthServiceProvider._();

/// Create an [AuthService] backed by the application's [Dio] instance.

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  /// Create an [AuthService] backed by the application's [Dio] instance.
  AuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<AuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthService>(value),
    );
  }
}

String _$authServiceHash() => r'e908b5fe8a16cd1a87875742b53dd198f462feb8';

/// Create an [IAuthRepository] wired to the auth service and token storage.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Create an [IAuthRepository] wired to the auth service and token storage.

final class AuthRepositoryProvider
    extends
        $FunctionalProvider<IAuthRepository, IAuthRepository, IAuthRepository>
    with $Provider<IAuthRepository> {
  /// Create an [IAuthRepository] wired to the auth service and token storage.
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

String _$authRepositoryHash() => r'6b86db1c3482b8fefeb2063c787fb3eb6ff8c306';

/// Notifier that manages the authentication lifecycle.
///
/// The [build] method checks for an existing session on startup.
/// [login], [register], and [logout] mutate the state and delegate
/// to [IAuthRepository].

@ProviderFor(AuthViewModel)
final authViewModelProvider = AuthViewModelProvider._();

/// Notifier that manages the authentication lifecycle.
///
/// The [build] method checks for an existing session on startup.
/// [login], [register], and [logout] mutate the state and delegate
/// to [IAuthRepository].
final class AuthViewModelProvider
    extends $AsyncNotifierProvider<AuthViewModel, AuthState> {
  /// Notifier that manages the authentication lifecycle.
  ///
  /// The [build] method checks for an existing session on startup.
  /// [login], [register], and [logout] mutate the state and delegate
  /// to [IAuthRepository].
  AuthViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authViewModelHash();

  @$internal
  @override
  AuthViewModel create() => AuthViewModel();
}

String _$authViewModelHash() => r'0709ad21c0556bfe5f985578e3ea361847b64764';

/// Notifier that manages the authentication lifecycle.
///
/// The [build] method checks for an existing session on startup.
/// [login], [register], and [logout] mutate the state and delegate
/// to [IAuthRepository].

abstract class _$AuthViewModel extends $AsyncNotifier<AuthState> {
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

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Expose whether the user is authenticated as a simple boolean.
///
/// Consumed by [AuthGuard] and other components that need a synchronous
/// check without caring about the full [AuthState].

final class AuthStateProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Expose whether the user is authenticated as a simple boolean.
  ///
  /// Consumed by [AuthGuard] and other components that need a synchronous
  /// check without caring about the full [AuthState].
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return authState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$authStateHash() => r'eb94a852278acb1bcfccc0543c76917903435085';
