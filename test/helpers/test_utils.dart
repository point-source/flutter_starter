/// Shared test utilities for creating Riverpod containers.
///
/// Provides a [createContainer] helper that automatically disposes
/// the container when the current test completes, preventing resource
/// leaks across tests.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Create a [ProviderContainer] with optional [overrides] for testing.
///
/// The container is automatically disposed when the test completes.
ProviderContainer createContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}
