/// Application environment configuration.
///
/// Determines the current environment (development, staging, production)
/// based on compile-time constants loaded from JSON config files.
///
/// Usage in build:
/// ```bash
/// # Development (default)
/// flutter run --dart-define-from-file=config/development.json
///
/// # Staging
/// flutter run --dart-define-from-file=config/staging.json
///
/// # Production
/// flutter build apk --release --dart-define-from-file=config/production.json
/// ```
enum AppEnvironment {
  /// Development environment — local development with debug tools.
  development,

  /// Staging environment — pre-production testing.
  staging,

  /// Production environment — live user-facing.
  production;

  /// The raw ENVIRONMENT value from compile-time constants.
  static const String _rawEnvironment = String.fromEnvironment('ENVIRONMENT');

  /// Whether to throw when ENVIRONMENT is invalid. Enable in CI.
  static const bool _strictMode = bool.fromEnvironment('STRICT_ENV');

  /// Returns the current environment based on compile-time constants.
  ///
  /// Defaults to [development] if ENVIRONMENT is not set or unrecognized.
  /// In strict mode (STRICT_ENV=true), throws [StateError] on invalid values.
  static AppEnvironment get current =>
      _resolve(_rawEnvironment, strictMode: _strictMode);

  /// Whether a valid ENVIRONMENT value was explicitly provided.
  static bool get isExplicitlyConfigured => _isConfigured(_rawEnvironment);

  /// Returns a warning message if ENVIRONMENT is misconfigured, null otherwise.
  ///
  /// Useful for startup diagnostics logging.
  static String? get configurationWarning => _validate(_rawEnvironment);

  /// Checks if running in development.
  static bool get isDevelopment => current == AppEnvironment.development;

  /// Checks if running in staging.
  static bool get isStaging => current == AppEnvironment.staging;

  /// Checks if running in production.
  static bool get isProduction => current == AppEnvironment.production;

  // ---------------------------------------------------------------------------
  // Environment-specific configuration
  // ---------------------------------------------------------------------------

  /// Whether Sentry error reporting should be enabled.
  bool get sentryEnabled => this == staging || this == production;

  /// Whether SSL pinning should be enabled.
  ///
  /// Disabled in development to allow proxy-based network inspection.
  bool get sslPinningEnabled => this == staging || this == production;

  /// Sentry DSN loaded from compile-time config.
  ///
  /// Returns `null` in development or when not configured.
  String? get sentryDsn {
    if (this == development) return null;
    const dsn = String.fromEnvironment('SENTRY_DSN');
    return dsn.isEmpty ? null : dsn;
  }

  /// Sentry performance monitoring sample rate.
  ///
  /// Higher in staging for thorough testing, lower in production for
  /// reduced overhead.
  double get sentrySampleRate => switch (this) {
    development => 0.0,
    staging => 1.0,
    production => 0.1,
  };

  /// API base URL for this environment.
  ///
  /// Reads from `API_URL` compile-time constant with sensible fallbacks.
  String get apiBaseUrl {
    const url = String.fromEnvironment('API_URL');
    if (url.isNotEmpty) return url;

    return switch (this) {
      development => 'http://localhost:3000',
      staging => 'https://api-staging.example.com',
      production => 'https://api.example.com',
    };
  }

  /// Display name for this environment (capitalized).
  String get displayName => '${name[0].toUpperCase()}${name.substring(1)}';

  @override
  String toString() => displayName;

  // ---------------------------------------------------------------------------
  // Internal helpers (visible for testing)
  // ---------------------------------------------------------------------------

  /// Resolves the environment from a raw string value.
  static AppEnvironment _resolve(
    String rawEnvironment, {
    required bool strictMode,
  }) {
    if (strictMode && !_isConfigured(rawEnvironment)) {
      throw StateError(
        'STRICT_ENV is enabled but ENVIRONMENT "$rawEnvironment" is invalid. '
        'Valid values: ${values.map((e) => e.name).join(", ")}',
      );
    }
    return _parse(rawEnvironment);
  }

  static bool _isConfigured(String environment) {
    if (environment.isEmpty) return false;
    return values.any((e) => e.name == environment.toLowerCase());
  }

  static AppEnvironment _parse(String environment) {
    if (environment.isEmpty) return AppEnvironment.development;
    return AppEnvironment.values.firstWhere(
      (e) => e.name == environment.toLowerCase(),
      orElse: () => AppEnvironment.development,
    );
  }

  static String? _validate(String environment) {
    if (environment.isEmpty) return null;
    final isValid = values.any((e) => e.name == environment.toLowerCase());
    if (isValid) return null;

    final validValues = values.map((e) => e.name).join(', ');
    return 'Unknown ENVIRONMENT value: "$environment". '
        'Valid values: $validValues. Defaulting to "development".';
  }
}
