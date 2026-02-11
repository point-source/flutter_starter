/// Provide a Riverpod-managed [IAppLogger] instance scoped to the current
/// environment.
///
/// In development the provider returns a [ConsoleLogger] for local output;
/// in staging and production it returns a [SentryReporter] that forwards
/// events to Sentry.  All application code should depend on this provider
/// rather than constructing loggers directly.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/env/app_environment.dart';
import 'package:flutter_starter/core/logging/app_logger.dart';
import 'package:flutter_starter/core/logging/sentry_reporter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger_provider.g.dart';

/// Create an [IAppLogger] appropriate for the current [AppEnvironment].
///
/// Returns [ConsoleLogger] in development and [SentryReporter] otherwise.
/// Override this provider in tests to capture log output without side effects.
@Riverpod(keepAlive: true)
IAppLogger logger(Ref ref) {
  if (AppEnvironment.isDevelopment) {
    return const ConsoleLogger();
  }
  return const SentryReporter();
}
