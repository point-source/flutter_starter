/// Application bootstrap and initialization.
///
/// Handles all async setup that must complete before the app renders:
/// SharedPreferences initialization, Sentry configuration, global error
/// handlers, and the root ProviderScope setup.
///
/// Call [bootstrap] from `main()`:
/// ```dart
/// void main() => bootstrap();
/// ```
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/app.dart';
import 'package:flutter_starter/core/env/app_environment.dart';
import 'package:flutter_starter/core/storage/shared_prefs_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initialize the application and run it.
///
/// Performs the following steps in order:
/// 1. Ensure Flutter bindings are initialized
/// 2. Initialize SharedPreferences (async)
/// 3. Log environment configuration warnings
/// 4. Set up global error handlers
/// 5. Initialize Sentry (staging/production only)
/// 6. Run the app inside a ProviderScope with overrides
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences before runApp
  final sharedPreferences = await SharedPreferences.getInstance();

  // Log any environment configuration issues
  final envWarning = AppEnvironment.configurationWarning;
  if (envWarning != null) {
    debugPrint('⚠️ $envWarning');
  }
  debugPrint('🌍 Environment: ${AppEnvironment.current.displayName}');

  // Set up global error handlers
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (AppEnvironment.current.sentryEnabled) {
      Sentry.captureException(
        details.exception,
        stackTrace: details.stack,
      );
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (AppEnvironment.current.sentryEnabled) {
      Sentry.captureException(error, stackTrace: stack);
    }
    return true;
  };

  // Build the app with provider overrides
  final app = ProviderScope(
    overrides: [
      sharedPrefsProvider.overrideWithValue(sharedPreferences),
    ],
    child: const App(),
  );

  // Initialize Sentry and run
  if (AppEnvironment.current.sentryEnabled) {
    final dsn = AppEnvironment.current.sentryDsn;
    if (dsn != null) {
      await SentryFlutter.init(
        (options) {
          options
            ..dsn = dsn
            ..tracesSampleRate = AppEnvironment.current.sentrySampleRate
            ..environment = AppEnvironment.current.name;
        },
        appRunner: () => runApp(app),
      );
      return;
    }
  }

  runApp(app);
}
