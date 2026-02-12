/// Custom [ThemeExtension] for semantic colors not covered by Material 3.
///
/// Material 3's color scheme handles primary, secondary, tertiary, and error.
/// This extension adds semantic colors for success, warning, and info states
/// that are commonly needed in business applications.
///
/// Access via `Theme.of(context).extension<SemanticColors>()`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_starter/core/theme/color_palette.dart';

/// Semantic colors for success, warning, and info states.
///
/// These colors automatically adapt to light/dark themes when configured
/// in [AppTheme]. Access them with:
/// ```dart
/// final semanticColors = Theme.of(context).extension<SemanticColors>()!;
/// Icon(Icons.check, color: semanticColors.success);
/// ```
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  /// Creates a [SemanticColors] theme extension.
  const SemanticColors({
    required this.success,
    required this.successForeground,
    required this.warning,
    required this.warningForeground,
    required this.info,
    required this.infoForeground,
  });

  /// Light theme semantic colors.
  static const SemanticColors light = SemanticColors(
    success: ColorPalette.success,
    successForeground: Colors.white,
    warning: ColorPalette.warning,
    warningForeground: Colors.black,
    info: ColorPalette.info,
    infoForeground: Colors.white,
  );

  /// Dark theme semantic colors.
  static const SemanticColors dark = SemanticColors(
    success: Color(0xFF66BB6A),
    successForeground: Colors.black,
    warning: Color(0xFFFFEE58),
    warningForeground: Colors.black,
    info: Color(0xFF4FC3F7),
    infoForeground: Colors.black,
  );

  /// Color for success states (completed, saved, approved).
  final Color success;

  /// Foreground color for content displayed on [success] backgrounds.
  final Color successForeground;

  /// Color for warning states (caution, pending, expiring).
  final Color warning;

  /// Foreground color for content displayed on [warning] backgrounds.
  final Color warningForeground;

  /// Color for informational states (tips, notices, updates).
  final Color info;

  /// Foreground color for content displayed on [info] backgrounds.
  final Color infoForeground;

  @override
  SemanticColors copyWith({
    Color? success,
    Color? successForeground,
    Color? warning,
    Color? warningForeground,
    Color? info,
    Color? infoForeground,
  }) => .new(
    success: success ?? this.success,
    successForeground: successForeground ?? this.successForeground,
    warning: warning ?? this.warning,
    warningForeground: warningForeground ?? this.warningForeground,
    info: info ?? this.info,
    infoForeground: infoForeground ?? this.infoForeground,
  );

  @override
  SemanticColors lerp(covariant SemanticColors? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      successForeground: Color.lerp(
        successForeground,
        other.successForeground,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningForeground: Color.lerp(
        warningForeground,
        other.warningForeground,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoForeground: Color.lerp(infoForeground, other.infoForeground, t)!,
    );
  }
}
