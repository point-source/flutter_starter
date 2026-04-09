# Template Migration Guides

This directory contains structured migration files that help downstream projects merge template updates. Each file covers one tagged template release and describes what changed, what might break, and exactly what to do.

## Who Writes These

Template maintainers write a migration file for each tagged release of `flutter_starter`. Downstream project teams consume them during [template sync](../TEMPLATE_SYNC.md).

## How to Use (Downstream Projects)

When syncing template updates:

1. Identify the versions you're jumping between (e.g., `v1.2.0` to `v1.4.0`)
2. Read every migration file in that range, in order
3. Follow the **Migration Steps** in each file
4. Use the **Expected Conflicts** section to prepare for merge conflicts

## File Format

Each migration file is named `NNN-short-description.md` where `NNN` matches the release version (e.g., `v1.3.0`). See [`_TEMPLATE.md`](_TEMPLATE.md) for the full format.

### Sections

| Section | Purpose |
|---|---|
| **Summary** | What changed, in plain language |
| **Risk Level** | Low / Medium / High -- how disruptive this update is |
| **Files Added** | New files that can be accepted wholesale |
| **Files Modified** | Existing files with template changes to merge |
| **Breaking Changes** | Anything requiring code changes in downstream projects |
| **Migration Steps** | Numbered steps to apply the update |
| **Expected Conflicts** | Files likely to conflict and how to resolve them |
| **Can Skip?** | Whether this update is optional |
