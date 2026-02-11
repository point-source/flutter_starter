/// Riverpod providers for feature flag management.
///
/// Provides a [FeatureFlagNotifier] that reads and writes flag state to
/// [SharedPreferences], and a convenience provider for checking individual
/// flags by their [FeatureFlag] enum value.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/feature_flags/feature_flag.dart';
import 'package:flutter_starter/core/storage/shared_prefs_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'feature_flag_provider.g.dart';

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
@Riverpod(keepAlive: true)
class FeatureFlagNotifier extends _$FeatureFlagNotifier {
  late SharedPreferences _prefs;

  @override
  Map<FeatureFlag, bool> build() {
    _prefs = ref.read(sharedPrefsProvider);
    return {
      for (final flag in FeatureFlag.values)
        flag: _prefs.getBool(_storageKey(flag)) ?? false,
    };
  }

  /// Enable or disable a specific [flag].
  void setFlag(FeatureFlag flag, {required bool enabled}) {
    state = {...state, flag: enabled};
    _prefs.setBool(_storageKey(flag), enabled);
  }

  /// Toggle the current state of a [flag].
  void toggle(FeatureFlag flag) {
    final current = state[flag] ?? false;
    setFlag(flag, enabled: !current);
  }

  /// Reset all flags to their default (disabled) state.
  void resetAll() {
    state = {for (final flag in FeatureFlag.values) flag: false};
    for (final flag in FeatureFlag.values) {
      _prefs.remove(_storageKey(flag));
    }
  }

  String _storageKey(FeatureFlag flag) => 'feature_flag_${flag.key}';
}

/// Check whether a specific [FeatureFlag] is currently enabled.
///
/// This is a convenience provider that watches the full flag map and
/// extracts the value for a single flag.
///
/// ```dart
/// final isDarkMode = ref.watch(featureFlagProvider(FeatureFlag.darkMode));
/// ```
@riverpod
bool featureFlag(Ref ref, FeatureFlag flag) {
  final flags = ref.watch(featureFlagNotifierProvider);
  return flags[flag] ?? false;
}
