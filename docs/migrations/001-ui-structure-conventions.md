# Migration: 001 -- UI Structure Conventions

## Summary

Codifies three UI conventions into project documentation: pages as layout
orchestrators, thumb-accessible input placement in compact portrait, and
mock-first backend strategy for UI work. No code changes -- documentation only.

## Risk Level

**Low** -- documentation additions only, no changes to existing APIs or code.

## Files Added

```
(none)
```

## Files Modified

```
CLAUDE.md                                          # Added "UI Structure" subsection under Key Conventions
docs/adrs/008-mvvm-with-clean-architecture.md      # Added layout-orchestrator rule to Key Rules
docs/architecture-rules/02-layer-responsibilities.md # Added layout-orchestrator and input-placement rules
```

## Breaking Changes

None.

## Migration Steps

1. Merge the template update:
   ```bash
   git fetch template
   git merge template/main
   ```
2. Review the new UI conventions in the modified files and align any existing
   pages that embed complex UI logic inline rather than extracting widgets.

## Expected Conflicts

| File | Resolution |
|---|---|
| `CLAUDE.md` | Keep your project-specific customizations, accept the new UI Structure section |
| `docs/adrs/008-mvvm-with-clean-architecture.md` | Accept template changes if you haven't modified this ADR |
| `docs/architecture-rules/02-layer-responsibilities.md` | Accept template changes, re-apply any custom rules |

## Can Skip?

**Yes** -- this release only adds documentation conventions. No code depends on
it. You can adopt these guidelines at your own pace.
