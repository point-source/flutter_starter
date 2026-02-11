// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_flag_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$featureFlagHash() => r'00ac345661430a91c15265dca2da65b36cc772d1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Check whether a specific [FeatureFlag] is currently enabled.
///
/// This is a convenience provider that watches the full flag map and
/// extracts the value for a single flag.
///
/// ```dart
/// final isDarkMode = ref.watch(featureFlagProvider(FeatureFlag.darkMode));
/// ```
///
/// Copied from [featureFlag].
@ProviderFor(featureFlag)
const featureFlagProvider = FeatureFlagFamily();

/// Check whether a specific [FeatureFlag] is currently enabled.
///
/// This is a convenience provider that watches the full flag map and
/// extracts the value for a single flag.
///
/// ```dart
/// final isDarkMode = ref.watch(featureFlagProvider(FeatureFlag.darkMode));
/// ```
///
/// Copied from [featureFlag].
class FeatureFlagFamily extends Family<bool> {
  /// Check whether a specific [FeatureFlag] is currently enabled.
  ///
  /// This is a convenience provider that watches the full flag map and
  /// extracts the value for a single flag.
  ///
  /// ```dart
  /// final isDarkMode = ref.watch(featureFlagProvider(FeatureFlag.darkMode));
  /// ```
  ///
  /// Copied from [featureFlag].
  const FeatureFlagFamily();

  /// Check whether a specific [FeatureFlag] is currently enabled.
  ///
  /// This is a convenience provider that watches the full flag map and
  /// extracts the value for a single flag.
  ///
  /// ```dart
  /// final isDarkMode = ref.watch(featureFlagProvider(FeatureFlag.darkMode));
  /// ```
  ///
  /// Copied from [featureFlag].
  FeatureFlagProvider call(FeatureFlag flag) {
    return FeatureFlagProvider(flag);
  }

  @override
  FeatureFlagProvider getProviderOverride(
    covariant FeatureFlagProvider provider,
  ) {
    return call(provider.flag);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'featureFlagProvider';
}

/// Check whether a specific [FeatureFlag] is currently enabled.
///
/// This is a convenience provider that watches the full flag map and
/// extracts the value for a single flag.
///
/// ```dart
/// final isDarkMode = ref.watch(featureFlagProvider(FeatureFlag.darkMode));
/// ```
///
/// Copied from [featureFlag].
class FeatureFlagProvider extends AutoDisposeProvider<bool> {
  /// Check whether a specific [FeatureFlag] is currently enabled.
  ///
  /// This is a convenience provider that watches the full flag map and
  /// extracts the value for a single flag.
  ///
  /// ```dart
  /// final isDarkMode = ref.watch(featureFlagProvider(FeatureFlag.darkMode));
  /// ```
  ///
  /// Copied from [featureFlag].
  FeatureFlagProvider(FeatureFlag flag)
    : this._internal(
        (ref) => featureFlag(ref as FeatureFlagRef, flag),
        from: featureFlagProvider,
        name: r'featureFlagProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$featureFlagHash,
        dependencies: FeatureFlagFamily._dependencies,
        allTransitiveDependencies: FeatureFlagFamily._allTransitiveDependencies,
        flag: flag,
      );

  FeatureFlagProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.flag,
  }) : super.internal();

  final FeatureFlag flag;

  @override
  Override overrideWith(bool Function(FeatureFlagRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: FeatureFlagProvider._internal(
        (ref) => create(ref as FeatureFlagRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        flag: flag,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _FeatureFlagProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeatureFlagProvider && other.flag == flag;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, flag.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeatureFlagRef on AutoDisposeProviderRef<bool> {
  /// The parameter `flag` of this provider.
  FeatureFlag get flag;
}

class _FeatureFlagProviderElement extends AutoDisposeProviderElement<bool>
    with FeatureFlagRef {
  _FeatureFlagProviderElement(super.provider);

  @override
  FeatureFlag get flag => (origin as FeatureFlagProvider).flag;
}

String _$featureFlagNotifierHash() =>
    r'a1abf301b5b2dc96deb66837e921933090745ed5';

/// Manage the enabled/disabled state of all [FeatureFlag]s.
///
/// State is a [Map] from [FeatureFlag] to [bool]. Changes are persisted
/// to [SharedPreferences] so they survive app restarts.
///
/// ```dart
/// // Read a flag
/// final enabled = ref.watch(featureFlagProvider(FeatureFlag.darkMode));
///
/// // Toggle a flag
/// ref.read(featureFlagNotifierProvider.notifier).toggle(FeatureFlag.darkMode);
/// ```
///
/// Copied from [FeatureFlagNotifier].
@ProviderFor(FeatureFlagNotifier)
final featureFlagNotifierProvider =
    NotifierProvider<FeatureFlagNotifier, Map<FeatureFlag, bool>>.internal(
      FeatureFlagNotifier.new,
      name: r'featureFlagNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$featureFlagNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FeatureFlagNotifier = Notifier<Map<FeatureFlag, bool>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
