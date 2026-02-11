/// Application entry point.
///
/// Delegates all initialization to [bootstrap], which handles async setup
/// (SharedPreferences, Sentry, error handlers) before running the app.
///
/// The environment is determined by compile-time constants:
/// ```bash
/// flutter run --dart-define-from-file=config/development.json
/// flutter run --dart-define-from-file=config/staging.json
/// flutter build apk --release --dart-define-from-file=config/production.json
/// ```
library;

import 'package:flutter_starter/bootstrap.dart';

/// Launch the application.
void main() => bootstrap();
