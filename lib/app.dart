/// Root application widget.
///
/// Configures [MaterialApp.router] with auto_route navigation,
/// FlexColorScheme theming, and slang localization. Reads theme
/// and locale preferences from Riverpod providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/routing/app_router.dart';
import 'package:flutter_starter/core/theme/app_theme.dart';
import 'package:flutter_starter/features/auth/data/providers/auth_providers.dart';
import 'package:flutter_starter/features/settings/data/providers/locale_preference.dart';
import 'package:flutter_starter/features/settings/data/providers/theme_preference.dart';
import 'package:flutter_starter/gen/strings.g.dart';

/// The root widget of the application.
///
/// Wraps [MaterialApp.router] with the auto_route configuration and
/// watches the theme mode provider to reactively switch between light,
/// dark, and system themes.
class App extends ConsumerWidget {
  /// Creates the root [App] widget.
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themePreferenceProvider);
    final locale = ref.watch(localePreferenceProvider);
    final appRouter = ref.watch(appRouterProvider);

    if (locale == null) {
      LocaleSettings.useDeviceLocaleSync();
    } else {
      LocaleSettings.setLocaleSync(
        AppLocaleUtils.parseLocaleParts(
          languageCode: locale.languageCode,
          scriptCode: locale.scriptCode,
          countryCode: locale.countryCode,
        ),
      );
    }

    return MaterialApp.router(
      title: 'Flutter Starter',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter.config(
        reevaluateListenable: ref.watch(authStateListenableProvider),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
