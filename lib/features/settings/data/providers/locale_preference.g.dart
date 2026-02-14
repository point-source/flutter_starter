// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_preference.dart';

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

@ProviderFor(LocalePreference)
final localePreferenceProvider = LocalePreferenceProvider._();

/// Notifier that manages the current [Locale].
///
/// Persists the selected locale code to [SharedPreferences] and
/// restores it on app startup. Returns `null` to use the system
/// locale by default.
final class LocalePreferenceProvider
    extends $NotifierProvider<LocalePreference, Locale?> {
  /// Notifier that manages the current [Locale].
  ///
  /// Persists the selected locale code to [SharedPreferences] and
  /// restores it on app startup. Returns `null` to use the system
  /// locale by default.
  LocalePreferenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localePreferenceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localePreferenceHash();

  @$internal
  @override
  LocalePreference create() => LocalePreference();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$localePreferenceHash() => r'b05a3d1f69040d56ded8301c37b53c216e8b94a7';

/// Notifier that manages the current [Locale].
///
/// Persists the selected locale code to [SharedPreferences] and
/// restores it on app startup. Returns `null` to use the system
/// locale by default.

abstract class _$LocalePreference extends $Notifier<Locale?> {
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
