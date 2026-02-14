/// Tests for [ThemePreference].
///
/// Uses a [ProviderContainer] with a mocked [SharedPreferences] instance
/// to verify that the preference provider correctly loads and persists the
/// selected [ThemeMode].
library;

import 'package:flutter/material.dart';
import 'package:flutter_starter/core/storage/shared_prefs_provider.dart';
import 'package:flutter_starter/features/settings/data/providers/theme_preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_utils.dart';

void main() {
  /// Tests for the initial [build] method.
  group('build', () {
    /// Returns ThemeMode.system when no persisted value exists.
    test('returns ThemeMode.system when no persisted value', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = createContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );

      final themeMode = container.read(themePreferenceProvider);

      expect(themeMode, ThemeMode.system);
    });

    /// Returns the persisted theme mode when a valid value exists.
    test('returns persisted theme mode', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 1});
      final prefs = await SharedPreferences.getInstance();

      final container = createContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );

      final themeMode = container.read(themePreferenceProvider);

      expect(themeMode, ThemeMode.light);
    });

    /// Clamps invalid index to valid range.
    test('clamps invalid index to valid range', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 999});
      final prefs = await SharedPreferences.getInstance();

      final container = createContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );

      final themeMode = container.read(themePreferenceProvider);

      expect(themeMode, ThemeMode.dark);
    });
  });

  /// Tests for [ThemePreference.setThemeMode].
  group('setThemeMode', () {
    /// Updates state and persists to SharedPreferences.
    test('updates state and persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = createContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );

      container.read(themePreferenceProvider.notifier).setThemeMode(.dark);

      final themeMode = container.read(themePreferenceProvider);
      expect(themeMode, ThemeMode.dark);

      final persistedIndex = prefs.getInt('theme_mode');
      expect(persistedIndex, ThemeMode.dark.index);
    });
  });
}
