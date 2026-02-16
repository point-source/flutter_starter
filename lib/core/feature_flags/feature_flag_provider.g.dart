// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_flag_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manage the enabled/disabled state of all [FeatureFlag]s.
///
/// State is a [Map] from [FeatureFlag] to [bool]. Changes are persisted
/// to [SharedPreferences] so they survive app restarts.
///
/// ```dart
/// // Read a flag
/// final enabled = ref.watch(isFeatureFlagEnabledProvider(FeatureFlag.darkMode));
///
/// // Toggle a flag
/// ref.read(featureFlagProvider.notifier).toggle(FeatureFlag.darkMode);
/// ```

@ProviderFor(FeatureFlagNotifier)
final featureFlagProvider = FeatureFlagNotifierProvider._();

/// Manage the enabled/disabled state of all [FeatureFlag]s.
///
/// State is a [Map] from [FeatureFlag] to [bool]. Changes are persisted
/// to [SharedPreferences] so they survive app restarts.
///
/// ```dart
/// // Read a flag
/// final enabled = ref.watch(isFeatureFlagEnabledProvider(FeatureFlag.darkMode));
///
/// // Toggle a flag
/// ref.read(featureFlagProvider.notifier).toggle(FeatureFlag.darkMode);
/// ```
final class FeatureFlagNotifierProvider
    extends $NotifierProvider<FeatureFlagNotifier, Map<FeatureFlag, bool>> {
  /// Manage the enabled/disabled state of all [FeatureFlag]s.
  ///
  /// State is a [Map] from [FeatureFlag] to [bool]. Changes are persisted
  /// to [SharedPreferences] so they survive app restarts.
  ///
  /// ```dart
  /// // Read a flag
  /// final enabled = ref.watch(isFeatureFlagEnabledProvider(FeatureFlag.darkMode));
  ///
  /// // Toggle a flag
  /// ref.read(featureFlagProvider.notifier).toggle(FeatureFlag.darkMode);
  /// ```
  FeatureFlagNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featureFlagProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featureFlagNotifierHash();

  @$internal
  @override
  FeatureFlagNotifier create() => FeatureFlagNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<FeatureFlag, bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<FeatureFlag, bool>>(value),
    );
  }
}

String _$featureFlagNotifierHash() =>
    r'73ab43df988cda172a933ffaf4770296b051a1ef';

/// Manage the enabled/disabled state of all [FeatureFlag]s.
///
/// State is a [Map] from [FeatureFlag] to [bool]. Changes are persisted
/// to [SharedPreferences] so they survive app restarts.
///
/// ```dart
/// // Read a flag
/// final enabled = ref.watch(isFeatureFlagEnabledProvider(FeatureFlag.darkMode));
///
/// // Toggle a flag
/// ref.read(featureFlagProvider.notifier).toggle(FeatureFlag.darkMode);
/// ```

abstract class _$FeatureFlagNotifier extends $Notifier<Map<FeatureFlag, bool>> {
  Map<FeatureFlag, bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Map<FeatureFlag, bool>, Map<FeatureFlag, bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<FeatureFlag, bool>, Map<FeatureFlag, bool>>,
              Map<FeatureFlag, bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Check whether a specific [FeatureFlag] is currently enabled.
///
/// This is a convenience provider that watches the full flag map and
/// extracts the value for a single flag.
///
/// ```dart
/// final isDarkMode = ref.watch(isFeatureFlagEnabledProvider(FeatureFlag.darkMode));
/// ```

@ProviderFor(isFeatureFlagEnabled)
final isFeatureFlagEnabledProvider = IsFeatureFlagEnabledFamily._();

/// Check whether a specific [FeatureFlag] is currently enabled.
///
/// This is a convenience provider that watches the full flag map and
/// extracts the value for a single flag.
///
/// ```dart
/// final isDarkMode = ref.watch(isFeatureFlagEnabledProvider(FeatureFlag.darkMode));
/// ```

final class IsFeatureFlagEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Check whether a specific [FeatureFlag] is currently enabled.
  ///
  /// This is a convenience provider that watches the full flag map and
  /// extracts the value for a single flag.
  ///
  /// ```dart
  /// final isDarkMode = ref.watch(isFeatureFlagEnabledProvider(FeatureFlag.darkMode));
  /// ```
  IsFeatureFlagEnabledProvider._({
    required IsFeatureFlagEnabledFamily super.from,
    required FeatureFlag super.argument,
  }) : super(
         retry: null,
         name: r'isFeatureFlagEnabledProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isFeatureFlagEnabledHash();

  @override
  String toString() {
    return r'isFeatureFlagEnabledProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as FeatureFlag;
    return isFeatureFlagEnabled(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsFeatureFlagEnabledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isFeatureFlagEnabledHash() =>
    r'08f33ec6b71b83bbebc9f1540fad0373cb0dc71c';

/// Check whether a specific [FeatureFlag] is currently enabled.
///
/// This is a convenience provider that watches the full flag map and
/// extracts the value for a single flag.
///
/// ```dart
/// final isDarkMode = ref.watch(isFeatureFlagEnabledProvider(FeatureFlag.darkMode));
/// ```

final class IsFeatureFlagEnabledFamily extends $Family
    with $FunctionalFamilyOverride<bool, FeatureFlag> {
  IsFeatureFlagEnabledFamily._()
    : super(
        retry: null,
        name: r'isFeatureFlagEnabledProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Check whether a specific [FeatureFlag] is currently enabled.
  ///
  /// This is a convenience provider that watches the full flag map and
  /// extracts the value for a single flag.
  ///
  /// ```dart
  /// final isDarkMode = ref.watch(isFeatureFlagEnabledProvider(FeatureFlag.darkMode));
  /// ```

  IsFeatureFlagEnabledProvider call(FeatureFlag flag) =>
      IsFeatureFlagEnabledProvider._(argument: flag, from: this);

  @override
  String toString() => r'isFeatureFlagEnabledProvider';
}
