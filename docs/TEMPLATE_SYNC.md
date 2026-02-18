# Template Synchronization Guide

This document explains how to keep projects derived from `flutter_starter` in sync with template updates.

## Initial Setup: Creating a New Project

### Option 1: Use Template + Add Remote (Recommended)

```bash
# Create new repo from template on GitHub (via "Use this template" button)
# OR clone and create new repo
git clone https://github.com/PointSource/flutter_starter.git my-new-app
cd my-new-app
rm -rf .git
git init
git add .
git commit -m "Initial commit from flutter_starter template"

# Add template as a remote
git remote add template https://github.com/PointSource/flutter_starter.git
git fetch template

# Add your project's origin
git remote add origin https://github.com/YourOrg/my-new-app.git
git push -u origin main
```

### Option 2: Fork (Alternative)

Forking creates a permanent connection to the upstream repository, which is useful if you plan to contribute back to the template. However, for most app projects:

**DON'T fork if:**
- You're building a unique product (not contributing back)
- You want a clean commit history without template noise
- Your project will diverge significantly from the template

**DO fork if:**
- You plan to contribute improvements back to the template
- You want GitHub's built-in fork sync UI
- Multiple teams will share a customized template variant

**For most apps, use Option 1 (template + remote) instead of forking.**

## Syncing Template Updates

### 1. Check for Updates

```bash
# Fetch latest template changes
git fetch template

# Review what changed
git log HEAD..template/main --oneline

# See detailed diff
git diff HEAD..template/main
```

### 2. Review the Migration Guide

Check `docs/migrations/` in the template repo for migration files covering the versions you're jumping between. Each migration file describes:
- Breaking changes and required code modifications
- New and modified files
- Step-by-step migration instructions
- Expected merge conflicts and how to resolve them

### 3. Merge Updates

```bash
# Merge all changes (may require conflict resolution)
git merge template/main

# OR cherry-pick specific commits
git cherry-pick <commit-hash>

# OR merge specific files/directories
git checkout template/main -- lib/core/error/
git checkout template/main -- docs/
```

### 4. Post-Merge Steps

After merging template changes:

```bash
# Update dependencies
flutter pub get

# Regenerate code
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Verify the app runs
flutter run --dart-define-from-file=config/development.json
```

### 5. Resolve Conflicts

Common conflict scenarios:

- **`pubspec.yaml`**: Manually merge dependencies, keep your app's name/version
- **`lib/core/routing/app_router.dart`**: Keep your routes, adopt new route patterns
- **`lib/main.dart`**: Keep your customizations, adopt new bootstrap patterns
- **Generated files**: Delete and regenerate with `build_runner`

## Template-Owned vs Project-Owned Files

### Template-Owned (Safe to Sync)

These files should generally be synced from the template:

```
lib/core/                          # Shared infrastructure
  ├── env/                         # Environment configuration
  ├── error/                       # Result<T>, Failure
  ├── network/                     # Dio setup, interceptors
  ├── storage/                     # Storage providers
  ├── routing/                     # Router setup (merge routes carefully)
  ├── theme/                       # FlexColorScheme themes
  ├── logging/                     # Logging infrastructure
  ├── feature_flags/               # Feature flag system
  ├── presentation/                # Shared widgets (AdaptiveScaffold, etc.)
  └── utils/                       # Utility functions

lib/bootstrap.dart                 # App initialization (merge carefully)

docs/                              # Architecture documentation
  ├── ARCHITECTURE.md
  ├── TEMPLATE_SYNC.md
  ├── adrs/
  ├── architecture-rules/
  └── migrations/

analysis_options.yaml              # Linting rules
CLAUDE.md                          # AI agent context (merge tech stack updates)
```

### Project-Owned (Never Auto-Sync)

These files contain your app-specific logic and should NOT be overwritten:

```
lib/features/                      # Your business features
  └── <your-features>/

lib/main.dart                      # May have app-specific customizations
lib/app.dart                       # May have app-specific customizations

config/                            # Your environment configs
  ├── development.json
  ├── staging.json
  └── production.json

pubspec.yaml                       # Your dependencies (merge carefully)
pubspec.lock                       # Generated from your dependencies

docs/project-decisions/            # Your app-specific ADRs

README.md                          # Your project README (replace template's)

test/                              # Your tests
```

### Merge Carefully (Project-Specific Customizations)

```
lib/core/routing/app_router.dart   # Template patterns + your routes
lib/core/l10n/                     # Core strings, but you may add your own
```

## Update Checklist

When syncing template updates, follow this checklist:

- [ ] **Backup**: Create a branch: `git checkout -b template-update-$(date +%Y%m%d)`
- [ ] **Fetch**: `git fetch template`
- [ ] **Review**: Read `docs/migrations/` guides covering your version range
- [ ] **Merge**: `git merge template/main` (or cherry-pick specific commits)
- [ ] **Resolve**: Fix merge conflicts, preferring template for core/, your code for features/
- [ ] **Dependencies**: `flutter pub get`
- [ ] **Regenerate**: `dart run build_runner build --delete-conflicting-outputs`
- [ ] **Test**: `flutter test`
- [ ] **Run**: `flutter run --dart-define-from-file=config/development.json`
- [ ] **Commit**: `git commit -m "Merge template updates from v{version}"`
- [ ] **PR**: Open PR to main branch for team review

## Best Practices

1. **Sync regularly**: Pull template updates monthly or quarterly, not annually
2. **Don't modify template-owned files**: Extend instead (e.g., add interceptors, don't rewrite the Dio provider)
3. **Follow template patterns**: When adding features, follow `lib/features/auth/` structure
4. **Use `docs/project-decisions/`** for app-specific ADRs instead of adding to `docs/adrs/` (which is template-owned)
5. **Document deviations**: If you must deviate from the template, record a project ADR explaining why
6. **Contribute back**: If you fix bugs or improve core infrastructure, consider PRing back to the template

## Troubleshooting

### "I have too many conflicts"

You may have modified template-owned files. Options:
1. Revert your changes to core/, reapply your customizations as extensions
2. Accept template version, reapply your changes manually
3. Skip this update, wait for the next version

### "Generated files have conflicts"

```bash
# Delete generated files
find lib -name "*.g.dart" -delete
find lib -name "*.gr.dart" -delete
find lib -name "*.mapper.dart" -delete

# Complete the merge
git add .
git commit

# Regenerate
dart run build_runner build --delete-conflicting-outputs
```

### "My app broke after merging"

```bash
# Revert the merge
git reset --hard HEAD~1

# Try cherry-picking specific commits instead
git cherry-pick <safe-commit-hash>
```

## Release Versioning

The template uses semantic versioning:

- **Major (v2.0.0)**: Breaking changes, requires migration
- **Minor (v1.1.0)**: New features, backward compatible
- **Patch (v1.0.1)**: Bug fixes, safe to merge

Check GitHub releases for migration guides when major versions change.
