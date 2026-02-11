/// Root application widget.
///
/// Configures [MaterialApp.router] with auto_route navigation,
/// FlexColorScheme theming, and slang localization. Reads theme
/// and locale preferences from Riverpod providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/routing/app_router.dart';
import 'package:flutter_starter/core/theme/app_theme.dart';
import 'package:flutter_starter/features/settings/ui/view_models/theme_view_model.dart';

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
    final themeMode = ref.watch(themeViewModelProvider);
    final appRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Flutter Starter',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter.config(),
      debugShowCheckedModeBanner: false,
    );
  }
}
