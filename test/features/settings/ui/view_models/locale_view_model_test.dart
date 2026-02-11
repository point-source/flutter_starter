/// Tests for [LocaleViewModel].
///
/// Uses a [ProviderContainer] with a mocked [SharedPreferences] instance
/// to verify that the view model correctly loads and persists the selected
/// [Locale].
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_starter/core/storage/shared_prefs_provider.dart';
import 'package:flutter_starter/features/settings/ui/view_models/locale_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_utils.dart';

void main() {
  /// Tests for the initial [build] method.
  group('build', () {
    /// Returns null when no persisted locale exists (system default).
    test('returns null when no persisted locale', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = createContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );

      final locale = container.read(localeViewModelProvider);

      expect(locale, isNull);
    });

    /// Returns the persisted locale when a valid value exists.
    test('returns persisted locale', () async {
      SharedPreferences.setMockInitialValues({'locale': 'es'});
      final prefs = await SharedPreferences.getInstance();

      final container = createContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );

      final locale = container.read(localeViewModelProvider);

      expect(locale, isNotNull);
      expect(locale!.languageCode, 'es');
    });
  });

  /// Tests for [LocaleViewModel.setLocale].
  group('setLocale', () {
    /// Updates state and persists locale code.
    test('updates state and persists locale code', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = createContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );

      container.read(localeViewModelProvider.notifier).setLocale(const Locale('fr'));

      final locale = container.read(localeViewModelProvider);
      expect(locale, isNotNull);
      expect(locale!.languageCode, 'fr');

      final persistedCode = prefs.getString('locale');
      expect(persistedCode, 'fr');
    });

    /// Setting null removes the persisted value.
    test('setting null removes persisted value', () async {
      SharedPreferences.setMockInitialValues({'locale': 'es'});
      final prefs = await SharedPreferences.getInstance();

      final container = createContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );

      container.read(localeViewModelProvider.notifier).setLocale(null);

      final locale = container.read(localeViewModelProvider);
      expect(locale, isNull);

      final persistedCode = prefs.getString('locale');
      expect(persistedCode, isNull);
    });
  });
}
