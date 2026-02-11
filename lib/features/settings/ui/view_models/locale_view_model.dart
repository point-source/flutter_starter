/// Manage the application's locale with persistence.
///
/// Reads and writes the selected locale code to [SharedPreferences]
/// so the user's language preference survives app restarts.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_starter/core/storage/shared_prefs_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_view_model.g.dart';

/// Key used to persist the locale code in [SharedPreferences].
const _kLocaleKey = 'locale';

/// Notifier that manages the current [Locale].
///
/// Persists the selected locale code to [SharedPreferences] and
/// restores it on app startup. Returns `null` to use the system
/// locale by default.
@Riverpod(keepAlive: true)
class LocaleViewModel extends _$LocaleViewModel {
  @override
  Locale? build() {
    final prefs = ref.read(sharedPrefsProvider);
    final code = prefs.getString(_kLocaleKey);
    if (code == null) return null;
    return Locale(code);
  }

  /// Set the locale and persist it to local storage.
  ///
  /// Pass `null` to revert to the system locale.
  void setLocale(Locale? locale) {
    state = locale;
    final prefs = ref.read(sharedPrefsProvider);
    if (locale == null) {
      prefs.remove(_kLocaleKey);
    } else {
      prefs.setString(_kLocaleKey, locale.languageCode);
    }
  }
}
