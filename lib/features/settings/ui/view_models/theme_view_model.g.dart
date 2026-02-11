// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier that manages the current [ThemeMode].
///
/// Persists the selected theme to [SharedPreferences] and restores
/// it on app startup. The [App] widget watches this provider to
/// apply the correct theme.

@ProviderFor(ThemeViewModel)
final themeViewModelProvider = ThemeViewModelProvider._();

/// Notifier that manages the current [ThemeMode].
///
/// Persists the selected theme to [SharedPreferences] and restores
/// it on app startup. The [App] widget watches this provider to
/// apply the correct theme.
final class ThemeViewModelProvider
    extends $NotifierProvider<ThemeViewModel, ThemeMode> {
  /// Notifier that manages the current [ThemeMode].
  ///
  /// Persists the selected theme to [SharedPreferences] and restores
  /// it on app startup. The [App] widget watches this provider to
  /// apply the correct theme.
  ThemeViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeViewModelHash();

  @$internal
  @override
  ThemeViewModel create() => ThemeViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeViewModelHash() => r'749c09ffa5e37c5cb7e47578f821b3ed8eed2fec';

/// Notifier that manages the current [ThemeMode].
///
/// Persists the selected theme to [SharedPreferences] and restores
/// it on app startup. The [App] widget watches this provider to
/// apply the correct theme.

abstract class _$ThemeViewModel extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
