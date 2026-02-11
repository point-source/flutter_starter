# ADR 006: slang for Internationalization

## Status

Accepted

## Context

The application needs internationalization (i18n) support with:

- Type-safe access to translation strings (no stringly-typed keys).
- Pluralization and interpolation support.
- Feature-scoped organization so translations scale with the codebase.
- A developer-friendly JSON format for translation files.

Alternatives considered:

- **flutter_localizations + ARB files**: The official Flutter approach. ARB files are verbose and unfamiliar to most translators. Requires manual setup of `LocalizationsDelegate` and generated `AppLocalizations` class. No built-in feature scoping.
- **easy_localization**: Popular third-party library with JSON/YAML support. Runtime key resolution (stringly-typed) with no compile-time safety for missing keys.
- **intl + intl_utils**: Powerful pluralization but complex setup, ARB-based, and lacks type-safe code generation.

## Decision

Use **slang** with **slang_flutter** for internationalization.

Configuration in `slang.yaml`:

- Base locale is `en` with `base_locale` fallback strategy.
- Translation files live in `lib/core/l10n/` using the `.i18n.json` extension.
- Output is generated to `lib/gen/strings.g.dart`.
- Dart string interpolation syntax is used (`${paramName}`).
- Keys use `camelCase` to match Dart naming conventions.

Feature scoping strategy: Rather than separate slang configs per feature, all translations use **namespaced keys** within the core translation files (e.g., `auth.loginButton`, `profile.editTitle`). slang generates a single `Translations` class with nested accessor objects. This keeps code generation simple while maintaining logical organization.

## Consequences

### Positive

- **Type-safe access**: `t.auth.loginButton` is a compile-time checked accessor with IDE autocomplete.
- **JSON format**: Familiar to translators and easy to diff in version control.
- **Namespaced organization**: Feature-scoped keys within a single file set keep translations organized without multi-package complexity.
- **Built-in pluralization**: `cardinal` auto-pluralization handles count-based strings natively.
- **Interpolation**: Dart-native `${param}` syntax in translation values generates typed parameters.

### Negative

- **Single generated file**: All translations compile into one `strings.g.dart` file, which grows with the application.
- **Less granular than per-feature configs**: All languages must include all namespaces; you cannot lazily load translations per feature.
- **Smaller community**: slang is less widely adopted than the official ARB-based approach or easy_localization.

### Neutral

- Adding a new locale requires creating a corresponding `strings_<locale>.i18n.json` file and running `build_runner`.
- The `slang.yaml` configuration file lives at the project root alongside `pubspec.yaml`.
