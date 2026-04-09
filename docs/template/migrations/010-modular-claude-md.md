# Migration: 010 -- Modular CLAUDE.md via @import

## Summary

Splits the monolithic `CLAUDE.md` into three files so template-maintained and
project-maintained AI agent context never conflict during template sync:

- **`CLAUDE.md`** (root) -- thin shell: project overview + `@import`
  directives. Project-owned, mostly stable.
- **`docs/template/CLAUDE.md`** -- tech stack, architecture, conventions, and
  commands. Template-owned; synced from the template.
- **`docs/project/CLAUDE.md`** -- placeholder for project-specific business
  rules, backend guidance, and team preferences. Project-owned; never
  touched by template syncs.

Claude Code inlines the imports when reading `CLAUDE.md`, so agents still see
a single coherent document. Template updates to AI agent context now flow into
`docs/template/CLAUDE.md` only, leaving project customizations untouched.

## Risk Level

**Low-Medium** -- if you added project-specific content to the old root
`CLAUDE.md`, you need to move it to `docs/project/CLAUDE.md`. Otherwise
this is a structural change with no behavioral impact.

## Files Added

```
docs/template/CLAUDE.md            # Template-maintained AI agent context
docs/project/CLAUDE.md             # Project-maintained AI agent context (placeholder)
docs/template/migrations/010-modular-claude-md.md  # This file
```

## Files Modified

```
CLAUDE.md                                              # Rewritten as a thin shell with @imports
docs/template/TEMPLATE_SYNC.md                         # Documents the new split and merge guidance
docs/template/architecture-rules/12-documentation.md   # Describes the modular CLAUDE.md structure
```

## Breaking Changes

If you customized the root `CLAUDE.md` in your project (e.g., added
business-domain conventions, backend guidance, custom commands), those
customizations need to move to `docs/project/CLAUDE.md`. The new root
`CLAUDE.md` is a thin shell and any content beyond the Project Overview
section will be overwritten by future template syncs.

## Migration Steps

1. Fetch and merge the template update:
   ```bash
   git fetch template
   git merge template/main
   ```

2. If you had customizations in the old `CLAUDE.md`, compare your pre-merge
   version against the new root `CLAUDE.md`:
   ```bash
   git show HEAD~1:CLAUDE.md > /tmp/old-claude.md
   diff /tmp/old-claude.md CLAUDE.md
   ```

3. Move any project-specific content (sections you added or modified) from
   the old `CLAUDE.md` into `docs/project/CLAUDE.md`. The template sections
   (Tech Stack, Architecture, Key Conventions, Common Commands, Error
   Handling Flow, Adding a New Feature, Commit Style, Detailed Documentation)
   belong in `docs/template/CLAUDE.md` and should not be duplicated.

4. Customize the Project Overview section in the root `CLAUDE.md` to describe
   your app (replace the template's description).

5. Verify Claude Code still loads the full context:
   ```bash
   # Open your project in Claude Code and run:
   /memory
   # Confirm CLAUDE.md, docs/template/CLAUDE.md, and docs/project/CLAUDE.md
   # all appear in the loaded context.
   ```

## Expected Conflicts

| File | Resolution |
|---|---|
| `CLAUDE.md` | Accept the template's new shell structure; move any customizations to `docs/project/CLAUDE.md` |
| `docs/template/TEMPLATE_SYNC.md` | Accept template version |
| `docs/template/architecture-rules/12-documentation.md` | Accept template version |

If your old `CLAUDE.md` had significant project-specific content, expect a
conflict on the root file. Do not try to merge line-by-line -- instead:

1. Accept the template's new thin shell.
2. Extract your customizations from the `HEAD~1:CLAUDE.md` version (step 2 above).
3. Paste them into `docs/project/CLAUDE.md`.

## Can Skip?

**Yes** -- the monolithic approach still works. However, skipping means future
template updates to `CLAUDE.md` will continue to conflict with any project
customizations. Adopting the modular structure once eliminates this friction
permanently.

## AI Agent Compatibility Note

Claude Code fully supports `@path/to/file` imports in `CLAUDE.md` -- the
imported content is inlined when the agent reads the file. Other AI agents
(Cursor, Copilot, etc.) may not support the import syntax. If your team uses
multiple agents:

- **Claude Code only**: No action needed; imports work transparently.
- **Mixed agents**: Test that your other agents see the full context. If they
  don't honor `@import`, consider either (a) duplicating the most critical
  guidance into the root `CLAUDE.md`, or (b) skipping this migration and
  keeping a monolithic `CLAUDE.md` (accept the merge-conflict trade-off).
