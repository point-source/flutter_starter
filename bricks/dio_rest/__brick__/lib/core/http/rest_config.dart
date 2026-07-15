/// Configuration consumed by the optional REST client.
library;

/// Resolve and validate configuration for the installed REST capability.
abstract final class RestConfig {
  /// REST endpoint supplied through `--dart-define-from-file`.
  static const String _configuredApiUrl = String.fromEnvironment(
    'REST_API_URL',
  );

  /// Return the configured absolute HTTP(S) REST endpoint.
  ///
  /// Throws a [StateError] with setup instructions when the value is absent or
  /// invalid. REST projects should fail before issuing a request rather than
  /// silently talking to a placeholder service.
  static String get apiBaseUrl => validateApiBaseUrl(_configuredApiUrl);

  /// Validate a candidate REST endpoint.
  static String validateApiBaseUrl(String value) {
    final uri = Uri.tryParse(value);
    if (value.trim().isEmpty ||
        uri == null ||
        !uri.isAbsolute ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw StateError(
        'REST_API_URL is required after installing the dio_rest capability. '
        'Set an absolute http(s) URL in config/<environment>.json (copied '
        'from config/examples/) and run with --dart-define-from-file.',
      );
    }
    return value;
  }
}
