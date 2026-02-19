# Migration: v1.1.0 -- Test file Stop hook & architecture import lint

## Summary

Adds a Claude Code Stop hook that blocks when modified `lib/` files are missing corresponding test files, and introduces the `import_rules` analyzer plugin to enforce architecture layer boundaries (UI, domain, data) at `dart analyze` time.

## Risk Level

**Low**

New hook script, new dev dependency, and new analyzer plugin config. No changes to existing APIs, runtime behavior, or application code.

## Files Added

```
.claude/hooks/check-test-files.sh     # Stop hook: blocks if test files are missing for modified lib/ files
```

## Files Modified

```
.claude/settings.json                 # Added check-test-files.sh to Stop hooks array
pubspec.yaml                          # Added import_rules dev dependency
analysis_options.yaml                 # Added import_rules plugin + architecture layer rules
```

## Breaking Changes

None.

## Migration Steps

1. Fetch and merge the template update:
   ```bash
   git fetch template
   git merge template/main
   ```
2. Resolve conflicts in `pubspec.yaml` (keep your app name/version, accept new `import_rules` dev dependency)
3. Resolve conflicts in `analysis_options.yaml` (accept new `plugins:` block and `import_rules:` section at the bottom)
4. Run `flutter pub get`
5. Run `dart analyze` to confirm no architecture violations exist in your codebase
6. If violations are found, either fix the imports or adjust the rules in `import_rules:` to match your project's conventions

## Expected Conflicts

| File | Resolution |
|---|---|
| `pubspec.yaml` | Keep your app name/version, accept `import_rules` dev dependency |
| `analysis_options.yaml` | Accept the new `plugins:` block at the top and `import_rules:` section at the bottom; keep any custom lint rules you've added |
| `.claude/settings.json` | Accept the new hook entry; keep any custom hooks you've added |

## Can Skip?

**Yes** -- this release only adds developer tooling (a Claude Code hook and lint rules). No runtime code changes. You can skip it and pick up the changes in a later sync. However, adopting it early helps catch architecture violations and missing tests sooner.
