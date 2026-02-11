// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_prefs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create a [SharedPreferences] instance for dependency injection.
///
/// This provider is intentionally left unimplemented.  Override it in the
/// root [ProviderScope] with a pre-initialised [SharedPreferences] instance
/// that was resolved during application bootstrap.

@ProviderFor(sharedPrefs)
final sharedPrefsProvider = SharedPrefsProvider._();

/// Create a [SharedPreferences] instance for dependency injection.
///
/// This provider is intentionally left unimplemented.  Override it in the
/// root [ProviderScope] with a pre-initialised [SharedPreferences] instance
/// that was resolved during application bootstrap.

final class SharedPrefsProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// Create a [SharedPreferences] instance for dependency injection.
  ///
  /// This provider is intentionally left unimplemented.  Override it in the
  /// root [ProviderScope] with a pre-initialised [SharedPreferences] instance
  /// that was resolved during application bootstrap.
  SharedPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPrefsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPrefsHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPrefs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPrefsHash() => r'481da9d96e98738ab657e43e60befff2fcf71afe';
