/// Application theme configuration using FlexColorScheme.
///
/// Provides light and dark [ThemeData] built with FlexColorScheme for
/// Material 3 compliance. Includes custom [SemanticColors] theme extension
/// for success, warning, and info states.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
/// )
/// ```
library;

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/core/theme/color_palette.dart';
import 'package:flutter_starter/core/theme/theme_extensions.dart';

/// Provides the light and dark [ThemeData] for the application.
///
/// Uses [FlexColorScheme] with custom seed colors from [ColorPalette]
/// to generate a complete Material 3 color scheme.
abstract final class AppTheme {
  /// Light theme configuration.
  static ThemeData get light => FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: ColorPalette.primary,
      secondary: ColorPalette.secondary,
      tertiary: ColorPalette.tertiary,
      error: ColorPalette.error,
    ),
    useMaterial3ErrorColors: true,
    extensions: const <ThemeExtension<dynamic>>[SemanticColors.light],
  );

  /// Dark theme configuration.
  static ThemeData get dark => FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: ColorPalette.primary,
      secondary: ColorPalette.secondary,
      tertiary: ColorPalette.tertiary,
      error: ColorPalette.error,
    ),
    useMaterial3ErrorColors: true,
    extensions: const <ThemeExtension<dynamic>>[SemanticColors.dark],
  );
}
