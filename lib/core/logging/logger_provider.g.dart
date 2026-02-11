// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create an [IAppLogger] appropriate for the current [AppEnvironment].
///
/// Returns [ConsoleLogger] in development and [SentryReporter] otherwise.
/// Override this provider in tests to capture log output without side effects.

@ProviderFor(logger)
final loggerProvider = LoggerProvider._();

/// Create an [IAppLogger] appropriate for the current [AppEnvironment].
///
/// Returns [ConsoleLogger] in development and [SentryReporter] otherwise.
/// Override this provider in tests to capture log output without side effects.

final class LoggerProvider
    extends $FunctionalProvider<IAppLogger, IAppLogger, IAppLogger>
    with $Provider<IAppLogger> {
  /// Create an [IAppLogger] appropriate for the current [AppEnvironment].
  ///
  /// Returns [ConsoleLogger] in development and [SentryReporter] otherwise.
  /// Override this provider in tests to capture log output without side effects.
  LoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggerHash();

  @$internal
  @override
  $ProviderElement<IAppLogger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IAppLogger create(Ref ref) {
    return logger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IAppLogger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IAppLogger>(value),
    );
  }
}

String _$loggerHash() => r'409586a8e73b951593f86e49a8fcfc6ee455c912';
