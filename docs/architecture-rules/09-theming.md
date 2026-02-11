# Architecture Rule 09: Theming

## Overview

Theming uses **FlexColorScheme** for Material 3 compliant light and dark themes. Custom semantic colors are provided via a `ThemeExtension`. Theme mode (light/dark/system) is managed by a Riverpod notifier and persisted to SharedPreferences.

## Theme Configuration

Light and dark themes are defined in `core/theme/app_theme.dart`:

```dart
abstract final class AppTheme {
  static ThemeData get light => FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: ColorPalette.primary,
      secondary: ColorPalette.secondary,
      tertiary: ColorPalette.tertiary,
      error: ColorPalette.error,
    ),
    useMaterial3: true,
    useMaterial3ErrorColors: true,
    extensions: const <ThemeExtension<dynamic>>[
      SemanticColors.light,
    ],
  );

  static ThemeData get dark => FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: ColorPalette.primary,
      secondary: ColorPalette.secondary,
      tertiary: ColorPalette.tertiary,
      error: ColorPalette.error,
    ),
    useMaterial3: true,
    useMaterial3ErrorColors: true,
    extensions: const <ThemeExtension<dynamic>>[
      SemanticColors.dark,
    ],
  );
}
```

## Color Palette

Brand colors are defined as constants in `core/theme/color_palette.dart`:

```dart
abstract final class ColorPalette {
  static const Color primary = Color(0xFF6750A4);
  static const Color secondary = Color(0xFF625B71);
  static const Color tertiary = Color(0xFF7D5260);
  static const Color error = Color(0xFFB3261E);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);
}
```

## Semantic Colors (ThemeExtension)

Material 3 provides primary, secondary, tertiary, and error colors. For business applications, additional semantic colors are needed:

```dart
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
  });

  static const SemanticColors light = SemanticColors(
    success: ColorPalette.success,
    onSuccess: Colors.white,
    warning: ColorPalette.warning,
    onWarning: Colors.black,
    info: ColorPalette.info,
    onInfo: Colors.white,
  );

  static const SemanticColors dark = SemanticColors(/* dark variants */);

  // ... fields, copyWith, lerp
}
```

### Accessing Semantic Colors

```dart
Widget build(BuildContext context) {
  final semanticColors = Theme.of(context).extension<SemanticColors>()!;

  return Icon(
    Icons.check_circle,
    color: semanticColors.success,
  );
}
```

## Theme Mode Management

The `ThemeViewModel` persists the user's theme preference:

```dart
@riverpod
class ThemeViewModel extends _$ThemeViewModel {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPrefsProvider);
    final stored = prefs.getString('theme_mode');
    return ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    ref.read(sharedPrefsProvider).setString('theme_mode', mode.name);
  }
}
```

### Wiring in App Widget

```dart
class App extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeViewModelProvider);

    return MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: ref.watch(appRouterProvider).config(),
    );
  }
}
```

## DO

- Use `FlexThemeData.light()` and `FlexThemeData.dark()` for theme generation.
- Define brand colors in `ColorPalette` as `static const`.
- Use `ThemeExtension` for semantic colors beyond Material 3's built-in set.
- Access colors via `Theme.of(context)` and `Theme.of(context).extension<SemanticColors>()`.
- Persist theme mode choice to SharedPreferences.
- Always set `useMaterial3: true`.

## DO NOT

- Do not hardcode color values in widgets -- use `Theme.of(context).colorScheme` or `SemanticColors`.
- Do not create multiple theme configurations -- use `AppTheme.light` and `AppTheme.dark` exclusively.
- Do not use `Color(0xFF...)` literals in widget code -- reference `ColorPalette` or theme properties.
- Do not forget to add theme extensions to both light and dark themes.
- Do not use `primaryColor`, `accentColor`, or other deprecated theme properties.
