// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenStorageHash() => r'e081f1677c04fb0ef2ac0eef21750a2613c897bc';

/// Create an [ITokenStorage] backed by [FlutterSecureStorage].
///
/// Reads the [secureStorageProvider] to obtain the storage instance and
/// returns a [SecureTokenStorage] wrapping it.  Override this provider in
/// tests to supply a fake or in-memory token store.
///
/// Copied from [tokenStorage].
@ProviderFor(tokenStorage)
final tokenStorageProvider = AutoDisposeProvider<ITokenStorage>.internal(
  tokenStorage,
  name: r'tokenStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tokenStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TokenStorageRef = AutoDisposeProviderRef<ITokenStorage>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
