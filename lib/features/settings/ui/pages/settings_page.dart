/// Display application settings for theme and language preferences.
///
/// Demonstrates the local-only persistence pattern: preference providers
/// read from and write to [SharedPreferences] without any API calls.
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/features/auth/data/providers/auth_providers.dart';
import 'package:flutter_starter/features/settings/data/providers/locale_preference.dart';
import 'package:flutter_starter/features/settings/data/providers/theme_preference.dart';
import 'package:flutter_starter/gen/strings.g.dart';

/// The settings page for configuring theme and language.
@RoutePage()
class SettingsPage extends ConsumerWidget {
  /// Create a [SettingsPage].
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themePreferenceProvider);
    final currentLocale = ref.watch(localePreferenceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.settings.title)),
      body: ListView(
        children: [
          // ── Theme ────────────────────────────────────────────
          Padding(
            padding: const .fromLTRB(16, 16, 16, 8),
            child: Text(
              t.settings.theme,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          RadioGroup<ThemeMode>(
            groupValue: currentTheme,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themePreferenceProvider.notifier).setThemeMode(mode);
              }
            },
            child: Column(
              children: [
                RadioListTile(
                  title: Text(t.settings.themeSystem),
                  value: ThemeMode.system,
                ),
                RadioListTile(
                  title: Text(t.settings.themeLight),
                  value: ThemeMode.light,
                ),
                RadioListTile(
                  title: Text(t.settings.themeDark),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),

          const Divider(),

          // ── Language ─────────────────────────────────────────
          Padding(
            padding: const .fromLTRB(16, 16, 16, 8),
            child: Text(
              t.settings.language,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          RadioGroup<String>(
            groupValue: currentLocale?.languageCode ?? '',
            onChanged: (code) {
              final locale = (code == null || code.isEmpty)
                  ? null
                  : Locale(code);
              ref.read(localePreferenceProvider.notifier).setLocale(locale);
            },
            child: Column(
              children: [
                RadioListTile(title: Text(t.settings.localeSystem), value: ''),
                RadioListTile(
                  title: Text(t.settings.localeEnglish),
                  value: 'en',
                ),
                RadioListTile(
                  title: Text(t.settings.localeSpanish),
                  value: 'es',
                ),
              ],
            ),
          ),

          const Divider(),

          // ── Logout ───────────────────────────────────────────
          Padding(
            padding: const .all(16),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: Text(t.auth.logout),
              onPressed: () {
                ref.read(authStateRepoProvider.notifier).logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}
