// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create a [FlutterSecureStorage] instance for dependency injection.
///
/// Returns a const instance with default platform options.  Override this
/// provider in tests to supply a mock or in-memory implementation.

@ProviderFor(secureStorage)
final secureStorageProvider = SecureStorageProvider._();

/// Create a [FlutterSecureStorage] instance for dependency injection.
///
/// Returns a const instance with default platform options.  Override this
/// provider in tests to supply a mock or in-memory implementation.

final class SecureStorageProvider
    extends
        $FunctionalProvider<
          FlutterSecureStorage,
          FlutterSecureStorage,
          FlutterSecureStorage
        >
    with $Provider<FlutterSecureStorage> {
  /// Create a [FlutterSecureStorage] instance for dependency injection.
  ///
  /// Returns a const instance with default platform options.  Override this
  /// provider in tests to supply a mock or in-memory implementation.
  SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'812bdf737c2086561e3f517022184c0fee90d11f';
