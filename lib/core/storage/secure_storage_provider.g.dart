// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$secureStorageHash() => r'1803ee54eebc4038de1cd19ff9f0850676721a7f';

/// Create a [FlutterSecureStorage] instance for dependency injection.
///
/// Returns a const instance with default platform options.  Override this
/// provider in tests to supply a mock or in-memory implementation.
///
/// Copied from [secureStorage].
@ProviderFor(secureStorage)
final secureStorageProvider = Provider<FlutterSecureStorage>.internal(
  secureStorage,
  name: r'secureStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecureStorageRef = ProviderRef<FlutterSecureStorage>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
