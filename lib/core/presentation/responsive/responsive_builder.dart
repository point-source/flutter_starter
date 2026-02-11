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
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    super.key,
  });

  /// Builder for compact (phone) layouts. Always required.
  final Widget Function(BuildContext context) compact;

  /// Builder for medium (small tablet) layouts.
  ///
  /// Falls back to [compact] when not provided.
  final Widget Function(BuildContext context)? medium;

  /// Builder for expanded (tablet / small desktop) layouts.
  ///
  /// Falls back to [medium] when not provided.
  final Widget Function(BuildContext context)? expanded;

  /// Builder for large (wide desktop) layouts.
  ///
  /// Falls back to [expanded] when not provided.
  final Widget Function(BuildContext context)? large;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = AppBreakpoint.fromWidth(constraints.maxWidth);

        return switch (breakpoint) {
          AppBreakpoint.compact => compact(context),
          AppBreakpoint.medium => (medium ?? compact)(context),
          AppBreakpoint.expanded =>
            (expanded ?? medium ?? compact)(context),
          AppBreakpoint.large =>
            (large ?? expanded ?? medium ?? compact)(context),
        };
      },
    );
  }
}
