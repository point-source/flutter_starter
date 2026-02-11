/// Provide a Riverpod-managed [SharedPreferences] instance.
///
/// Because [SharedPreferences] requires asynchronous initialisation, the
/// provider deliberately throws at runtime.  The application bootstrap must
/// resolve the [SharedPreferences] future **before** `runApp` and supply the
/// concrete instance via a `ProviderScope` override.  This guarantees that
/// every downstream consumer receives a fully-initialised, synchronous
/// reference without awaiting inside widget code.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_prefs_provider.g.dart';

/// Create a [SharedPreferences] instance for dependency injection.
///
/// This provider is intentionally left unimplemented.  Override it in the
/// root [ProviderScope] with a pre-initialised [SharedPreferences] instance
/// that was resolved during application bootstrap.
@Riverpod(keepAlive: true)
SharedPreferences sharedPrefs(Ref ref) {
  throw UnimplementedError(
    'sharedPrefsProvider must be overridden in ProviderScope '
    'with a pre-initialised SharedPreferences instance.',
  );
}
