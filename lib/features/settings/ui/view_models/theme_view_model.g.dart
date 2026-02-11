// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeViewModelHash() => r'749c09ffa5e37c5cb7e47578f821b3ed8eed2fec';

/// Notifier that manages the current [ThemeMode].
///
/// Persists the selected theme to [SharedPreferences] and restores
/// it on app startup. The [App] widget watches this provider to
/// apply the correct theme.
///
/// Copied from [ThemeViewModel].
@ProviderFor(ThemeViewModel)
final themeViewModelProvider =
    NotifierProvider<ThemeViewModel, ThemeMode>.internal(
      ThemeViewModel.new,
      name: r'themeViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themeViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemeViewModel = Notifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
