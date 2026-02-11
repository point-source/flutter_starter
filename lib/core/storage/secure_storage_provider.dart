/// Provide a Riverpod-managed [FlutterSecureStorage] instance.
///
/// Unlike [SharedPreferences], [FlutterSecureStorage] does not require
/// asynchronous initialisation, so the provider can return a const instance
/// directly.  All secure-storage consumers should depend on this provider
/// rather than constructing their own instance, ensuring a single
/// configuration point and straightforward test overrides.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_provider.g.dart';

/// Create a [FlutterSecureStorage] instance for dependency injection.
///
/// Returns a const instance with default platform options.  Override this
/// provider in tests to supply a mock or in-memory implementation.
@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) => const FlutterSecureStorage();
