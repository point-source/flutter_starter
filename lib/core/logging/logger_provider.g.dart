// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loggerHash() => r'6d3754f8937a06f875ba3143a0a676cdd8543f99';

/// Create an [IAppLogger] appropriate for the current [AppEnvironment].
///
/// Returns [ConsoleLogger] in development and [SentryReporter] otherwise.
/// Override this provider in tests to capture log output without side effects.
///
/// Copied from [logger].
@ProviderFor(logger)
final loggerProvider = Provider<IAppLogger>.internal(
  logger,
  name: r'loggerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoggerRef = ProviderRef<IAppLogger>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
