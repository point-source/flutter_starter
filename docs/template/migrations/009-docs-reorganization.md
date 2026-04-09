# Migration: 009 -- Documentation reorganization

## Summary

Separates template-owned docs from project-owned docs to eliminate confusion in
derived projects. All template-maintained documentation now lives under
`docs/template/`. The `project-decisions/` directory moves under a broader
`docs/project/` directory where derived projects can keep all their
project-specific documentation.

## Risk Level

**Low** -- file moves and reference updates only. No code changes, no
dependency changes, no behavior changes.

## Files Added

```
docs/template/                     # New parent for all template docs
docs/project/                      # New parent for all project docs
docs/project/README.md             # Guide for project-specific documentation
docs/template/migrations/009-docs-reorganization.md  # This file
```

## Files Moved

```
docs/ARCHITECTURE.md               → docs/template/ARCHITECTURE.md
docs/FASTLANE.md                   → docs/template/FASTLANE.md
docs/ROADMAP.md                    → docs/template/ROADMAP.md
docs/TEMPLATE_SYNC.md              → docs/template/TEMPLATE_SYNC.md
docs/WEB_DEPLOYMENT.md             → docs/template/WEB_DEPLOYMENT.md
docs/adrs/                         → docs/template/adrs/
docs/architecture-rules/           → docs/template/architecture-rules/
docs/migrations/                   → docs/template/migrations/
docs/proposals/                    → docs/template/proposals/
docs/project-decisions/            → docs/project/decisions/
```

## Files Modified

```
CLAUDE.md                                              # Updated doc path references
README.md                                              # Updated doc links and section headings
improvement.md                                         # Updated architecture-rules paths
meta.md                                                # Updated docs tree and path references
docs/template/ARCHITECTURE.md                          # Updated project-decisions link
docs/template/TEMPLATE_SYNC.md                         # Updated ownership lists and paths
docs/template/ROADMAP.md                               # Added template banner, updated display paths
docs/template/proposals/README.md                      # Added template banner
docs/template/architecture-rules/01-project-structure.md  # Updated docs tree
docs/template/architecture-rules/12-documentation.md   # Updated cross-boundary links and display paths
docs/template/migrations/_TEMPLATE.md                  # Updated example paths
docs/project/decisions/README.md                       # Updated cross-boundary link to template adrs
.claude/hooks/check-migration-doc.sh                   # Updated path patterns
.claude/hooks/suggest-project-decision.sh              # Updated path patterns
ios/fastlane/.env.default                              # Updated FASTLANE.md path
android/fastlane/.env.default                          # Updated FASTLANE.md path
ios/fastlane/Fastfile                                  # Updated FASTLANE.md path
android/fastlane/Fastfile                              # Updated FASTLANE.md path
scripts/preflight.sh                                   # Updated FASTLANE.md path
```

## Breaking Changes

If your project has:
- Scripts or CI that reference `docs/project-decisions/` -- update to
  `docs/project/decisions/`
- Links to `docs/ROADMAP.md` or `docs/proposals/` -- update to
  `docs/template/ROADMAP.md` or `docs/template/proposals/`
- Links to `docs/ARCHITECTURE.md`, `docs/adrs/`, `docs/architecture-rules/`,
  `docs/migrations/`, `docs/TEMPLATE_SYNC.md`, `docs/WEB_DEPLOYMENT.md`, or
  `docs/FASTLANE.md` -- prefix with `docs/template/`

## Migration Steps

1. Fetch and merge the template update:
   ```bash
   git fetch template
   git merge template/main
   ```

2. If you have project-specific ADRs in `docs/project-decisions/`, move them
   to `docs/project/decisions/`:
   ```bash
   mv docs/project-decisions/*.md docs/project/decisions/
   rmdir docs/project-decisions
   ```
   (The merge should handle this automatically via rename detection, but
   verify your files ended up in the right place.)

3. If you added your own items to `docs/ROADMAP.md` or files to
   `docs/proposals/`, move them to `docs/project/` instead -- those were
   template-owned docs. Consider creating your own `docs/project/roadmap.md`.

4. Search your codebase for any hardcoded references to the old paths:
   ```bash
   grep -r 'docs/project-decisions\|docs/ROADMAP\|docs/proposals/\|docs/ARCHITECTURE\|docs/adrs/\|docs/architecture-rules/\|docs/migrations/\|docs/TEMPLATE_SYNC\|docs/WEB_DEPLOYMENT\|docs/FASTLANE' .
   ```

5. Update any matches found in step 4 to use the new `docs/template/` or
   `docs/project/` paths.

## Expected Conflicts

| File | Resolution |
|---|---|
| `CLAUDE.md` | Accept template's updated paths in the Detailed Documentation section, keep your customizations elsewhere |
| `README.md` | Accept template's updated Documentation section, keep your customizations |
| `docs/project-decisions/README.md` | Accept the move to `docs/project/decisions/README.md` |
| `.claude/hooks/suggest-project-decision.sh` | Accept template version (path updates only) |
| `.claude/hooks/check-migration-doc.sh` | Accept template version (path updates only) |

If you added your own roadmap items to `docs/ROADMAP.md`, they will conflict.
Move your items to a new `docs/project/roadmap.md` and accept the template's
version of `docs/template/ROADMAP.md`.

## Can Skip?

**Yes** -- this is a documentation-only reorganization. No code changes.
However, skipping will mean the old confusing structure remains, and future
template updates will reference the new paths.
