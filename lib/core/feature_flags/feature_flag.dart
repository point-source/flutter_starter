/// Define the available feature flags for the application.
///
/// Feature flags allow enabling or disabling functionality at runtime
/// without redeploying. Flags can be toggled via SharedPreferences
/// for local overrides, or eventually backed by a remote service.
library;

/// Enumerate all feature flags available in the application.
///
/// Add new flags here as the application grows. Each flag defaults to
/// disabled unless explicitly enabled via [FeatureFlagNotifier].
///
/// ```dart
/// if (ref.watch(featureFlagProvider(FeatureFlag.darkMode))) {
///   // Show dark mode toggle
/// }
/// ```
enum FeatureFlag {
  /// Enable experimental dark mode support.
  darkMode('dark_mode'),

  /// Enable the new dashboard layout.
  newDashboard('new_dashboard'),

  /// Enable profile avatar upload.
  avatarUpload('avatar_upload');

  const FeatureFlag(this.key);

  /// The storage key used for persisting this flag's state.
  final String key;
}
