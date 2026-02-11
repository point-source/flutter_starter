// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localeViewModelHash() => r'60390e3c9ea457d1ea52c89bb5cab4a3d1532ee3';

/// Notifier that manages the current [Locale].
///
/// Persists the selected locale code to [SharedPreferences] and
/// restores it on app startup. Returns `null` to use the system
/// locale by default.
///
/// Copied from [LocaleViewModel].
@ProviderFor(LocaleViewModel)
final localeViewModelProvider =
    NotifierProvider<LocaleViewModel, Locale?>.internal(
      LocaleViewModel.new,
      name: r'localeViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localeViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocaleViewModel = Notifier<Locale?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
