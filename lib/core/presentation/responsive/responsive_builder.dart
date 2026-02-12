/// Build different widget trees based on the current viewport width.
///
/// Wraps [LayoutBuilder] to select the appropriate builder function
/// for each [AppBreakpoint]. Larger breakpoints fall back to the next
/// smaller builder when not explicitly provided.
library;

import 'package:flutter/material.dart';

import 'package:flutter_starter/core/presentation/responsive/breakpoints.dart';

/// Select a builder function based on the current [AppBreakpoint].
///
/// The [compact] builder is required. All other builders are optional and
/// fall back to the next smaller breakpoint when omitted:
///
/// - [large] falls back to [expanded]
/// - [expanded] falls back to [medium]
/// - [medium] falls back to [compact]
///
/// ```dart
/// ResponsiveBuilder(
///   compact: (context) => MobileLayout(),
///   expanded: (context) => DesktopLayout(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  /// Create a [ResponsiveBuilder] with the required [compact] builder
  /// and optional larger-breakpoint builders.
  const ResponsiveBuilder({
    required this.compactBuilder,
    this.mediumBuilder,
    this.expandedBuilder,
    this.largeBuilder,
    super.key,
  });

  /// Builder for compact (phone) layouts. Always required.
  final Widget Function(BuildContext context) compactBuilder;

  /// Builder for medium (small tablet) layouts.
  ///
  /// Falls back to [compactBuilder] when not provided.
  final Widget Function(BuildContext context)? mediumBuilder;

  /// Builder for expanded (tablet / small desktop) layouts.
  ///
  /// Falls back to [mediumBuilder] when not provided.
  final Widget Function(BuildContext context)? expandedBuilder;

  /// Builder for large (wide desktop) layouts.
  ///
  /// Falls back to [expandedBuilder] when not provided.
  final Widget Function(BuildContext context)? largeBuilder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final breakpoint = AppBreakpoint.fromWidth(constraints.maxWidth);

      return switch (breakpoint) {
        .compact => compactBuilder(context),
        .medium => (mediumBuilder ?? compactBuilder)(context),
        .expanded => (expandedBuilder ?? mediumBuilder ?? compactBuilder)(
          context,
        ),
        .large =>
          (largeBuilder ?? expandedBuilder ?? mediumBuilder ?? compactBuilder)(
            context,
          ),
      };
    },
  );
}
