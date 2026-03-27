# Migration: 005 -- Localization infrastructure and Spanish locale

## Summary

Wires up slang's `TranslationProvider` and Flutter's built-in localization
delegates so the app can switch locales at runtime. Adds a Spanish (es)
translation and a `localePreferenceProvider` that persists the user's choice.
Generated slang output in `lib/core/l10n/` is now gitignored (output moved to
`lib/gen/`).

## Risk Level

**Medium**

- Modifies `app.dart` and `bootstrap.dart`, which most downstream apps have
  customized.
- Moves generated translation files out of version control, which may confuse
  merges if the old files were committed downstream.

## Files Added

```
lib/core/l10n/es.i18n.json       # Spanish translation source strings
lib/gen/strings_es.g.dart         # Generated Spanish translations (committed for now)
```

## Files Modified

```
lib/app.dart                      # Added locale provider, LocaleSettings, localizationsDelegates
lib/bootstrap.dart                # Wrapped App in TranslationProvider
lib/gen/strings.g.dart            # Updated with Spanish locale enum + loader
.gitignore                        # Added lib/core/l10n/*.g.dart
build.yaml                        # Added lib/features/**/data/services/** to retrofit generator
pubspec.lock                      # Transitive dependency updates (matcher, test, test_api)
README.md                         # Fixed license badge, network/ → http/ directory name
```

## Files Removed

```
lib/core/l10n/strings.g.dart      # Moved to .gitignore (regenerated into lib/gen/)
lib/core/l10n/strings_en.g.dart   # Moved to .gitignore (regenerated into lib/gen/)
```

## Breaking Changes

_None._ Existing English-only behavior is preserved when no locale preference
is set (the app follows the device locale, falling back to English).

## Migration Steps

1. Fetch and merge the template update:
   ```bash
   git fetch template
   git merge template/main
   ```
2. If you previously committed the generated slang files in `lib/core/l10n/`,
   remove them from tracking after the merge:
   ```bash
   git rm --cached lib/core/l10n/strings.g.dart lib/core/l10n/strings_en.g.dart
   ```
3. Ensure `flutter_localizations` is in your `pubspec.yaml` dependencies:
   ```yaml
   dependencies:
     flutter_localizations:
       sdk: flutter
   ```
4. Run `flutter pub get`
5. Run `dart run build_runner build --delete-conflicting-outputs`
6. Run `dart run slang` to regenerate translations
7. Run `flutter test` and fix any failures

## Expected Conflicts

| File | Resolution |
|---|---|
| `lib/app.dart` | Keep your customizations (extra routes, theme tweaks), adopt the new `locale`, `supportedLocales`, `localizationsDelegates`, and `LocaleSettings` block |
| `lib/bootstrap.dart` | Accept the `TranslationProvider` wrapper around `App()`, keep any other overrides you added |
| `pubspec.lock` | Re-run `flutter pub get` after resolving `pubspec.yaml` |

## Can Skip?

**Yes** -- this adds localization support only. No later releases depend on it.
If you skip, the app continues to work in English without locale switching.
