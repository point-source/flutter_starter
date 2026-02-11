// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier that manages the current [Locale].
///
/// Persists the selected locale code to [SharedPreferences] and
/// restores it on app startup. Returns `null` to use the system
/// locale by default.

@ProviderFor(LocaleViewModel)
final localeViewModelProvider = LocaleViewModelProvider._();

/// Notifier that manages the current [Locale].
///
/// Persists the selected locale code to [SharedPreferences] and
/// restores it on app startup. Returns `null` to use the system
/// locale by default.
final class LocaleViewModelProvider
    extends $NotifierProvider<LocaleViewModel, Locale?> {
  /// Notifier that manages the current [Locale].
  ///
  /// Persists the selected locale code to [SharedPreferences] and
  /// restores it on app startup. Returns `null` to use the system
  /// locale by default.
  LocaleViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeViewModelHash();

  @$internal
  @override
  LocaleViewModel create() => LocaleViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$localeViewModelHash() => r'60390e3c9ea457d1ea52c89bb5cab4a3d1532ee3';

/// Notifier that manages the current [Locale].
///
/// Persists the selected locale code to [SharedPreferences] and
/// restores it on app startup. Returns `null` to use the system
/// locale by default.

abstract class _$LocaleViewModel extends $Notifier<Locale?> {
  Locale? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Locale?, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Locale?, Locale?>,
              Locale?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
