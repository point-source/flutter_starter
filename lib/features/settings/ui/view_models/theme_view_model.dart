/// Manage the application's theme mode with persistence.
///
/// Reads and writes the selected [ThemeMode] to [SharedPreferences]
/// so the user's preference survives app restarts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_starter/core/storage/shared_prefs_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_view_model.g.dart';

/// Key used to persist the theme mode index in [SharedPreferences].
const _kThemeModeKey = 'theme_mode';

/// Notifier that manages the current [ThemeMode].
///
/// Persists the selected theme to [SharedPreferences] and restores
/// it on app startup. The [App] widget watches this provider to
/// apply the correct theme.
@Riverpod(keepAlive: true)
class ThemeViewModel extends _$ThemeViewModel {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPrefsProvider);
    final index = prefs.getInt(_kThemeModeKey) ?? 0;
    final safeIndex = index.clamp(0, ThemeMode.values.length - 1);
    // ignore: avoid-unsafe-collection-methods
    return .values.elementAt(safeIndex);
  }

  /// Set the theme mode and persist it to local storage.
  void setThemeMode(ThemeMode mode) {
    state = mode;
    ref.read(sharedPrefsProvider).setInt(_kThemeModeKey, mode.index);
  }
}
