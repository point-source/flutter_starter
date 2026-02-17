// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the main [Dio] instance with all interceptors configured.
///
/// This is the Dio instance that all retrofit services should use.
/// It includes auth, refresh, logging, and error interceptors.

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// Provides the main [Dio] instance with all interceptors configured.
///
/// This is the Dio instance that all retrofit services should use.
/// It includes auth, refresh, logging, and error interceptors.

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Provides the main [Dio] instance with all interceptors configured.
  ///
  /// This is the Dio instance that all retrofit services should use.
  /// It includes auth, refresh, logging, and error interceptors.
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'58e6d9f28b07869536e00c0256fd328683819427';
