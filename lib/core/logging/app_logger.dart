/// Define the application logging interface and a console-based implementation.
///
/// All application code should depend on [IAppLogger] rather than calling
/// `print` or `dart:developer` directly.  This abstraction allows swapping
/// the underlying transport (console, Sentry, file, etc.) without modifying
/// call sites.
library;

import 'dart:developer' as developer;

/// Declare the contract for structured application logging.
///
/// Each severity level accepts a human-readable [message], an optional
/// structured [data] map for contextual key-value pairs, and an optional
/// [tag] to identify the subsystem that produced the log entry.
abstract class IAppLogger {
  /// Log a debug-level message for development diagnostics.
  ///
  /// Use for granular tracing that should never appear in production
  /// transports.
  void debug(
    String message, {
    Map<String, dynamic>? data,
    String? tag,
  });

  /// Log an informational message about normal application behaviour.
  ///
  /// Use for milestones such as successful initialisation, navigation
  /// events, or feature-flag evaluations.
  void info(
    String message, {
    Map<String, dynamic>? data,
    String? tag,
  });

  /// Log a warning about a recoverable but unexpected condition.
  ///
  /// Use when the application can continue but the situation warrants
  /// attention (e.g. deprecated API usage, missing optional config).
  void warning(
    String message, {
    Map<String, dynamic>? data,
    String? tag,
  });

  /// Log an error that affected a single operation but did not crash the app.
  ///
  /// [error] and [stackTrace] capture the originating exception context so
  /// that error-tracking services can group and symbolicate reports.
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
    String? tag,
  });

  /// Log a fatal error indicating an unrecoverable application state.
  ///
  /// [error] and [stackTrace] capture the originating exception context.
  /// Fatal entries typically trigger immediate crash reports.
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
    String? tag,
  });
}

/// Implement [IAppLogger] by writing structured entries to the Dart developer
/// console.
///
/// Each log line is prefixed with a severity label such as `[DEBUG]` or
/// `[ERROR]` and optionally includes a formatted [data] map.  This
/// implementation is intended for local development where logs are read in
/// an IDE or terminal.
class ConsoleLogger implements IAppLogger {
  /// Create a [ConsoleLogger].
  const ConsoleLogger();

  @override
  void debug(
    String message, {
    Map<String, dynamic>? data,
    String? tag,
  }) {
    _log('[DEBUG]', message, tag: tag, data: data);
  }

  @override
  void info(
    String message, {
    Map<String, dynamic>? data,
    String? tag,
  }) {
    _log('[INFO]', message, tag: tag, data: data);
  }

  @override
  void warning(
    String message, {
    Map<String, dynamic>? data,
    String? tag,
  }) {
    _log('[WARN]', message, tag: tag, data: data);
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
    String? tag,
  }) {
    _log(
      '[ERROR]',
      message,
      tag: tag,
      data: data,
      error: error,
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
    _log(
      '[FATAL]',
      message,
      tag: tag,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _log(
    String level,
    String message, {
    String? tag,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer('$level $message');

    if (data != null && data.isNotEmpty) {
      buffer.write(' | data: $data');
    }

    if (error != null) {
      buffer.write(' | error: $error');
    }

    developer.log(
      buffer.toString(),
      name: tag ?? 'App',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
