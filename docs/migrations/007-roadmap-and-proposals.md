# Migration: 007 -- Roadmap and design proposals

## Summary

Adds a roadmap (`docs/ROADMAP.md`) and design proposals directory
(`docs/proposals/`) for tracking future work and capturing detailed designs
before implementation. The first proposal documents ephemeral preview
environments (Supabase branching + Cloudflare Pages).

## Risk Level

**Low**

- New files only, plus minor additions to CLAUDE.md and README.md documentation
  sections.

## Files Added

```
docs/ROADMAP.md                                        # Index of future work items
docs/proposals/README.md                               # Proposals directory guide and format
docs/proposals/001-ephemeral-preview-environments.md   # First design proposal
```

## Files Modified

```
CLAUDE.md      # Added roadmap and proposals to Detailed Documentation section
README.md      # Added Planning subsection under Documentation
```

## Breaking Changes

_None._

## Migration Steps

1. Fetch and merge the template update:
   ```bash
   git fetch template
   git merge template/main
   ```
2. No code changes required. Review the roadmap and proposals for relevance to
   your project -- you may want to add your own items or remove template items
   that don't apply.

## Expected Conflicts

| File | Resolution |
|---|---|
| `CLAUDE.md` | Accept template additions (two new lines in Detailed Documentation), keep your customizations |
| `README.md` | Accept the new Planning subsection under Documentation, keep your customizations |

## Can Skip?

**Yes** -- this adds documentation only. No code or behavior changes.
