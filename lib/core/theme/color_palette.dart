/// Application color palette constants.
///
/// Defines the brand colors used throughout the app. These feed into
/// [FlexColorScheme] to generate the full Material 3 color scheme.
///
/// To change the app's color identity, update the primary and secondary
/// seed colors here. FlexColorScheme will derive all surface, container,
/// and on-color variants automatically.
library;

import 'package:flutter/material.dart';

/// Brand and semantic color constants for the application.
///
/// These are seed colors — FlexColorScheme uses them to generate
/// a complete Material 3 color scheme with proper contrast ratios.
abstract final class ColorPalette {
  /// Primary brand color — used for key components and actions.
  static const Color primary = Color(0xFF6750A4);

  /// Secondary brand color — used for less prominent components.
  static const Color secondary = Color(0xFF625B71);

  /// Tertiary accent color — used for contrasting accents.
  static const Color tertiary = Color(0xFF7D5260);

  /// Error color — used for error states and destructive actions.
  static const Color error = Color(0xFFB3261E);

  // ---------------------------------------------------------------------------
  // Semantic colors (used in ThemeExtensions)
  // ---------------------------------------------------------------------------

  /// Color indicating a successful operation.
  static const Color success = Color(0xFF2E7D32);

  /// Color indicating a warning or caution state.
  static const Color warning = Color(0xFFF57F17);

  /// Color indicating informational content.
  static const Color info = Color(0xFF0277BD);
}
