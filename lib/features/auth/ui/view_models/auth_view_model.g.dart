// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServiceHash() => r'e908b5fe8a16cd1a87875742b53dd198f462feb8';

/// Create an [AuthService] backed by the application's [Dio] instance.
///
/// Copied from [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
String _$authRepositoryHash() => r'6b86db1c3482b8fefeb2063c787fb3eb6ff8c306';

/// Create an [IAuthRepository] wired to the auth service and token storage.
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<IAuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<IAuthRepository>;
String _$authStateHash() => r'eb94a852278acb1bcfccc0543c76917903435085';

/// Expose whether the user is authenticated as a simple boolean.
///
/// Consumed by [AuthGuard] and other components that need a synchronous
/// check without caring about the full [AuthState].
///
/// Copied from [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeProvider<bool>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeProviderRef<bool>;
String _$authViewModelHash() => r'0709ad21c0556bfe5f985578e3ea361847b64764';

/// Notifier that manages the authentication lifecycle.
///
/// The [build] method checks for an existing session on startup.
/// [login], [register], and [logout] mutate the state and delegate
/// to [IAuthRepository].
///
/// Copied from [AuthViewModel].
@ProviderFor(AuthViewModel)
final authViewModelProvider =
    AsyncNotifierProvider<AuthViewModel, AuthState>.internal(
      AuthViewModel.new,
      name: r'authViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthViewModel = AsyncNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
