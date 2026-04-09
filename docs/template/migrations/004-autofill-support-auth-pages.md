# Migration: 004 -- Autofill support for auth pages

## Summary

Wrapped login and register forms in `AutofillGroup` and added `TextInput.finishAutofillContext()` on successful authentication. This enables password manager autofill on iOS and Android.

## Risk Level

**Low**

- No API changes. Only modifies internal widget structure of two pages.

## Files Added

_None._

## Files Modified

```
lib/features/auth/ui/pages/login_page.dart     # Wrapped Form in AutofillGroup, added finishAutofillContext
lib/features/auth/ui/pages/register_page.dart   # Wrapped Form in AutofillGroup, added finishAutofillContext
```

## Breaking Changes

_None._

## Migration Steps

1. Fetch and merge the template update:
   ```bash
   git fetch template
   git merge template/main
   ```
2. If you have customized the login or register pages, resolve any conflicts by keeping your customizations inside the new `AutofillGroup` wrapper.
3. Run `flutter test` and fix any failures.

## Expected Conflicts

| File | Resolution |
|---|---|
| `lib/features/auth/ui/pages/login_page.dart` | If customized, keep your field/button changes inside the `AutofillGroup > Form` wrapper |
| `lib/features/auth/ui/pages/register_page.dart` | Same as above |

## Can Skip?

**Yes** -- this adds autofill support only. No later releases depend on it.
