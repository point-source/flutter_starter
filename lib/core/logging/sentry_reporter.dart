/// Implement [IAppLogger] by forwarding events to the Sentry error-tracking
/// service.
///
/// Low-severity messages (debug and info) are recorded as Sentry breadcrumbs
/// so they appear in the trail leading up to an error, without generating
/// standalone events.  Warnings produce Sentry messages, and errors / fatals
/// produce full exception reports with stack traces.
library;

import 'package:flutter_starter/core/logging/app_logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Report application log events to Sentry.
///
/// * **debug / info** -- added as breadcrumbs (no Sentry event).
/// * **warning** -- sent via [Sentry.captureMessage] at
///   [SentryLevel.warning].
/// * **error** -- sent via [Sentry.captureException].
/// * **fatal** -- sent via [Sentry.captureException] at
///   [SentryLevel.fatal].
class SentryReporter implements IAppLogger {
  /// Create a [SentryReporter].
  const SentryReporter();

  // ---------------------------------------------------------------------------
  // Breadcrumb-only levels
  // ---------------------------------------------------------------------------

  @override
  void debug(
    String message, {
    Map<String, dynamic>? data,
    String? tag,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: tag,
        level: SentryLevel.debug,
        data: data,
      ),
    );
  }

  @override
  void info(
    String message, {
    Map<String, dynamic>? data,
    String? tag,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: tag,
        level: SentryLevel.info,
        data: data,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Event-producing levels
  // ---------------------------------------------------------------------------

  @override
  void warning(
    String message, {
    Map<String, dynamic>? data,
    String? tag,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: tag,
        level: SentryLevel.warning,
        data: data,
      ),
    );

    Sentry.captureMessage(
      message,
      level: SentryLevel.warning,
      params: data != null ? [data.toString()] : null,
    );
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
    String? tag,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: tag,
        level: SentryLevel.error,
        data: data,
      ),
    );

    Sentry.captureException(
      error ?? Exception(message),
      stackTrace: stackTrace,
    );
  }

  @override
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
    String? tag,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: tag,
        level: SentryLevel.fatal,
        data: data,
      ),
    );

    Sentry.captureException(
      error ?? Exception(message),
      stackTrace: stackTrace,
    );
  }

  // ---------------------------------------------------------------------------
  // User context
  // ---------------------------------------------------------------------------

  /// Set the Sentry user context for all subsequent events.
  ///
  /// Pass `null` for both [userId] and [email] to clear the user context
  /// (e.g. on logout).
  void setUser(String? userId, String? email) {
    if (userId == null && email == null) {
      Sentry.configureScope((scope) => scope.setUser(null));
      return;
    }

    Sentry.configureScope(
      (scope) => scope.setUser(SentryUser(id: userId, email: email)),
    );
  }
}
