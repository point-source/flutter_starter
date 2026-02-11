// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_prefs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPrefsHash() => r'481da9d96e98738ab657e43e60befff2fcf71afe';

/// Create a [SharedPreferences] instance for dependency injection.
///
/// This provider is intentionally left unimplemented.  Override it in the
/// root [ProviderScope] with a pre-initialised [SharedPreferences] instance
/// that was resolved during application bootstrap.
///
/// Copied from [sharedPrefs].
@ProviderFor(sharedPrefs)
final sharedPrefsProvider = Provider<SharedPreferences>.internal(
  sharedPrefs,
  name: r'sharedPrefsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPrefsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPrefsRef = ProviderRef<SharedPreferences>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
