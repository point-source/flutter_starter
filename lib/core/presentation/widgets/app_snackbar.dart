/// Provide convenience methods for displaying themed snack bars.
///
/// Uses the [SemanticColors] theme extension to apply appropriate
/// background and foreground colors for error, success, and info states.
library;

import 'package:flutter/material.dart';

import 'package:flutter_starter/core/theme/theme_extensions.dart';

/// Display themed snack bars for error, success, and informational messages.
///
/// All methods are static and require a [BuildContext] that has access
/// to a [ScaffoldMessenger] ancestor and a [SemanticColors] theme
/// extension.
///
/// ```dart
/// AppSnackbar.showError(context, 'Something went wrong');
/// AppSnackbar.showSuccess(context, 'Profile saved');
/// AppSnackbar.showInfo(context, 'New version available');
/// ```
abstract final class AppSnackbar {
  /// Show an error snack bar with the given [message].
  ///
  /// Uses [SemanticColors] error color from the current theme. Falls
  /// back to [ColorScheme.error] if the extension is not registered.
  static void showError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
      context,
      message: message,
      backgroundColor: colorScheme.error,
      foregroundColor: colorScheme.onError,
      icon: Icons.error_outline,
    );
  }

  /// Show a success snack bar with the given [message].
  ///
  /// Uses [SemanticColors.success] from the theme extension.
  static void showSuccess(BuildContext context, String message) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    _show(
      context,
      message: message,
      backgroundColor: semanticColors.success,
      foregroundColor: semanticColors.onSuccess,
      icon: Icons.check_circle_outline,
    );
  }

  /// Show an informational snack bar with the given [message].
  ///
  /// Uses [SemanticColors.info] from the theme extension.
  static void showInfo(BuildContext context, String message) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    _show(
      context,
      message: message,
      backgroundColor: semanticColors.info,
      foregroundColor: semanticColors.onInfo,
      icon: Icons.info_outline,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Color foregroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(icon, color: foregroundColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: foregroundColor),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
