/// Define responsive layout breakpoints for the application.
///
/// Breakpoints follow Material Design 3 adaptive layout guidelines and
/// determine which navigation pattern ([BottomNavigationBar],
/// [NavigationRail], or [NavigationDrawer]) is displayed.
library;

/// Responsive breakpoints used to select the appropriate layout.
///
/// Each value represents a window-size class with a [maxWidth] upper
/// bound. Use [fromWidth] to determine the active breakpoint for a
/// given viewport width.
///
/// | Breakpoint | Max Width |
/// |------------|-----------|
/// | compact    | 600       |
/// | medium     | 840       |
/// | expanded   | 1200      |
/// | large      | infinity  |
enum AppBreakpoint {
  /// Phone-sized screens (up to 600dp).
  compact(600),

  /// Small tablet or large phone in landscape (up to 840dp).
  medium(840),

  /// Tablet or small desktop (up to 1200dp).
  expanded(1200),

  /// Large desktop or wide display (no upper bound).
  large(double.infinity);

  const AppBreakpoint(this.maxWidth);

  /// The upper width boundary for this breakpoint in logical pixels.
  final double maxWidth;

  /// Determine the [AppBreakpoint] that applies to the given [width].
  ///
  /// Returns the first breakpoint whose [maxWidth] is greater than
  /// or equal to [width].
  static AppBreakpoint fromWidth(double width) {
    if (width < compact.maxWidth) return compact;
    if (width < medium.maxWidth) return medium;
    if (width < expanded.maxWidth) return expanded;
    return large;
  }
}
