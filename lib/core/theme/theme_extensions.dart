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
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
  });

  /// Light theme semantic colors.
  static const SemanticColors light = SemanticColors(
    success: ColorPalette.success,
    onSuccess: Colors.white,
    warning: ColorPalette.warning,
    onWarning: Colors.black,
    info: ColorPalette.info,
    onInfo: Colors.white,
  );

  /// Dark theme semantic colors.
  static const SemanticColors dark = SemanticColors(
    success: Color(0xFF66BB6A),
    onSuccess: Colors.black,
    warning: Color(0xFFFFEE58),
    onWarning: Colors.black,
    info: Color(0xFF4FC3F7),
    onInfo: Colors.black,
  );

  /// Color for success states (completed, saved, approved).
  final Color success;

  /// Foreground color for content displayed on [success] backgrounds.
  final Color onSuccess;

  /// Color for warning states (caution, pending, expiring).
  final Color warning;

  /// Foreground color for content displayed on [warning] backgrounds.
  final Color onWarning;

  /// Color for informational states (tips, notices, updates).
  final Color info;

  /// Foreground color for content displayed on [info] backgrounds.
  final Color onInfo;

  @override
  SemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
  }) =>
      SemanticColors(
        success: success ?? this.success,
        onSuccess: onSuccess ?? this.onSuccess,
        warning: warning ?? this.warning,
        onWarning: onWarning ?? this.onWarning,
        info: info ?? this.info,
        onInfo: onInfo ?? this.onInfo,
      );

  @override
  SemanticColors lerp(covariant SemanticColors? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
    );
  }
}
