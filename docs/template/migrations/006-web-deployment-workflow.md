# Migration: 006 -- Web deployment workflow

## Summary

Adds an optional GitHub Actions workflow for deploying the Flutter web build to
a static hosting provider. Cloudflare Pages is the first supported provider.
The workflow is provider-extensible -- adding Vercel, Netlify, or Firebase
Hosting later requires only a new choice option and a conditional deploy step.

## Risk Level

**Low**

- New files only, no changes to existing APIs, dependencies, or patterns.
- The workflow has no effect unless Cloudflare secrets/variables are configured.

## Files Added

```
.github/workflows/deploy-web.yml    # Manual web deployment workflow
docs/WEB_DEPLOYMENT.md              # Setup guide for web deployment
```

## Files Modified

```
CLAUDE.md                            # Added web build commands and doc link
```

## Breaking Changes

_None._

## Migration Steps

1. Fetch and merge the template update:
   ```bash
   git fetch template
   git merge template/main
   ```
2. If you want web deployment, follow the setup guide in `docs/WEB_DEPLOYMENT.md`
   to configure your hosting provider's secrets and variables in GitHub.
3. No code changes required.

## Expected Conflicts

| File | Resolution |
|---|---|
| `CLAUDE.md` | Accept template additions (web build commands in Common Commands, doc link in Detailed Documentation), keep your customizations |

## Can Skip?

**Yes** -- this adds optional web deployment only. No other changes depend on it.
