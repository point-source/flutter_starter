// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create an [ITokenStorage] backed by [FlutterSecureStorage].
///
/// Reads the [secureStorageProvider] to obtain the storage instance and
/// returns a [SecureTokenStorage] wrapping it.  Override this provider in
/// tests to supply a fake or in-memory token store.

@ProviderFor(tokenStorage)
final tokenStorageProvider = TokenStorageProvider._();

/// Create an [ITokenStorage] backed by [FlutterSecureStorage].
///
/// Reads the [secureStorageProvider] to obtain the storage instance and
/// returns a [SecureTokenStorage] wrapping it.  Override this provider in
/// tests to supply a fake or in-memory token store.

final class TokenStorageProvider
    extends $FunctionalProvider<ITokenStorage, ITokenStorage, ITokenStorage>
    with $Provider<ITokenStorage> {
  /// Create an [ITokenStorage] backed by [FlutterSecureStorage].
  ///
  /// Reads the [secureStorageProvider] to obtain the storage instance and
  /// returns a [SecureTokenStorage] wrapping it.  Override this provider in
  /// tests to supply a fake or in-memory token store.
  TokenStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStorageHash();

  @$internal
  @override
  $ProviderElement<ITokenStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ITokenStorage create(Ref ref) {
    return tokenStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ITokenStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ITokenStorage>(value),
    );
  }
}

String _$tokenStorageHash() => r'f71779655d6abbb5f145860e685b61f7d77c78bf';
