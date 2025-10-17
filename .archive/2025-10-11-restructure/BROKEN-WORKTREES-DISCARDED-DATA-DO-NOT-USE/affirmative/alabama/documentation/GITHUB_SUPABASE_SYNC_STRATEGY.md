---
DATE: 2025-10-07
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: GitHub-Supabase Sync Strategy
VERSION: v0.11.1
---

# GitHub-Supabase Sync Strategy

## CRITICAL DISCOVERY: GitHub Integration is ENABLED

Based on the Supabase dashboard screenshot, here's what's actually configured:

**GitHub Integration Settings**:
```
✅ Connected repository: The-HOLE-Foundation/us-transparency-laws-database
✅ Supabase directory: .
✅ Deploy to production: ON
✅ Production branch name: Main
✅ Automatic branching: OFF (good - prevents auto-creating preview branches)
```

**What this means**:
- When you push to GitHub `main` branch → Supabase deploys to production (main branch)
- Migrations in `supabase/migrations/` get automatically applied
- This is why the main branch has "MIGRATIONS_FAILED" status - it tried to run migrations from GitHub!

## Current State

**GitHub**:
- `main` branch: Has old/incomplete v0.11.1 work
- `Development` branch: Has v0.11.0 JSON data

**Supabase** (Project: THE HOLE TRUTH PROJECT - ctxhmgmeflnemjfzyabr):
- `main` branch: MIGRATIONS_FAILED (was synced with GitHub main - broken)
- `Development` branch: FUNCTIONS_DEPLOYED ✅ (has all 52 jurisdictions - working)

**Local machine**:
- On `main` branch with uncommitted v0.11.1 work
- All migrations, scripts, documentation complete

## The Problem

If we force push to GitHub `main`:
1. GitHub integration will detect the push
2. Supabase will try to apply migrations to production (main branch)
3. Production branch is already broken (MIGRATIONS_FAILED)
4. This could make it worse OR might fix it (risky!)

## Safe Strategy: Change Production Branch Mapping

### Option 1: Point Supabase Production to Development Branch (RECOMMENDED)

**Step 1: Change Supabase Production Branch Name**

In Supabase Dashboard:
1. Go to Project Settings → Integrations → GitHub Integration
2. Change "Production branch name" from `Main` to `Development`
3. Click "Save changes"

**Result**:
- Supabase production now syncs with GitHub `Development` branch
- GitHub `main` branch no longer triggers production deployments
- Safe to update GitHub main without affecting working Supabase

**Step 2: Push v0.11.1 Work to GitHub Development Branch**

```bash
# Commit all local work
git add .
git commit -m "feat: Complete v0.11.1 Supabase Integration [...]"

# Push to Development branch (becomes new production)
git push origin main:Development --force

# This pushes local main to GitHub Development branch
# Supabase will sync and deploy to Development branch (which already has the data!)
```

**Step 3: Optionally Clean Up GitHub Main**

```bash
# Later, update GitHub main if needed
git push origin main --force
```

### Option 2: Disable GitHub Integration Temporarily

**Step 1: Disable Integration**

In Supabase Dashboard:
1. Go to Project Settings → Integrations
2. Click "Disable integration"

**Step 2: Force Push to GitHub**

```bash
git add .
git commit -m "feat: Complete v0.11.1 Supabase Integration [...]"
git push origin main --force
```

**Step 3: Re-enable Integration with Development as Production**

1. Re-enable GitHub integration
2. Set "Production branch name" to `Development`
3. Supabase Development branch already has everything - no changes

### Option 3: Work with GitHub as-is (SAFEST)

**Don't change GitHub or Supabase settings**:

1. Keep Supabase Development branch as working production
2. Update documentation to point to Development branch URL
3. Commit v0.11.1 work to a new branch on GitHub
4. Don't touch GitHub main or Supabase settings

```bash
# Push to a new branch
git checkout -b v0.11.1-complete
git add .
git commit -m "feat: Complete v0.11.1 Supabase Integration [...]"
git push origin v0.11.1-complete
```

**Pros**:
- ✅ Zero risk
- ✅ No configuration changes
- ✅ Supabase Development branch keeps working

**Cons**:
- GitHub main branch stays outdated (but doesn't matter - nobody uses it)

## Recommended Execution Plan

### Phase 1: Change Supabase Production Branch Mapping

1. **Go to Supabase Dashboard**:
   https://supabase.com/dashboard/project/ctxhmgmeflnemjfzyabr/settings/integrations

2. **Find GitHub Integration section**

3. **Change "Production branch name"**:
   - From: `Main`
   - To: `Development`

4. **Click "Save changes"**

**Why this works**:
- Supabase Development branch (befpnwcokngtrljxskfz) already has all data
- GitHub Development branch exists (from earlier commits)
- They'll stay in sync
- GitHub main becomes irrelevant

### Phase 2: Commit and Push v0.11.1 Work

**Option A: Push to GitHub Development** (if you changed Supabase setting):
```bash
# Commit everything
git add .
git commit -m "feat: Complete v0.11.1 Supabase Integration

✅ Supabase PostgreSQL Deployment
- 10 core tables + 1 view
- 52 jurisdictions imported
- 365 exemptions with jurisdiction context
- Zero data loss

✅ Production Infrastructure
- TypeScript types
- Import scripts
- Documentation
- Platform configs

🎯 Production: befpnwcokngtrljxskfz.supabase.co

🤖 Generated with Claude Code (https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to Development branch
git push origin main:Development --force
```

**Option B: Push to new branch** (safest):
```bash
git checkout -b v0.11.1-production
git add .
git commit -m "[same commit message as above]"
git push origin v0.11.1-production
```

### Phase 3: Clean Up Supabase Main Branch (Optional)

```bash
# Delete the broken main branch
npx supabase branches delete main --project-ref ctxhmgmeflnemjfzyabr --yes
```

This saves costs and removes confusion.

### Phase 4: Verify Everything Works

```bash
# Check Supabase still working
node dev/scripts/verify-schema.js

# Check GitHub updated
# Visit: https://github.com/The-HOLE-Foundation/us-transparency-laws-database

# Check integration status
# Visit: https://supabase.com/dashboard/project/ctxhmgmeflnemjfzyabr/settings/integrations
```

## What NOT to Do

❌ **Don't force push to GitHub main without changing Supabase production branch**
- Will trigger deployment to broken Supabase main branch
- Risky and unpredictable

❌ **Don't delete Supabase Development branch**
- It has all your data!
- This is your working production

❌ **Don't disable GitHub integration and forget to re-enable**
- Loses automatic deployment benefits
- Manual migrations become necessary

## Final Architecture

**After completing this strategy**:

**Supabase**:
- Project: THE HOLE TRUTH PROJECT (ctxhmgmeflnemjfzyabr)
  - ~~main branch~~ (deleted - was broken)
  - **Production/Development branch** (befpnwcokngtrljxskfz) ✅
    - Synced with GitHub Development branch
    - Has all 52 jurisdictions
    - Production-ready

**GitHub**:
- Repository: us-transparency-laws-database
  - `main` branch: Can be updated or ignored
  - `Development` branch: Syncs with Supabase production ✅
  - `v0.11.1-production` branch: Has all current work

**GitHub Integration**:
- ✅ Connected
- ✅ Deploy to production: ON
- ✅ Production branch name: **Development**
- ✅ Syncs GitHub Development → Supabase Production

## Summary

**Key Insight**: GitHub integration is enabled and watches specific branch names!

**Safe approach**:
1. Change Supabase "Production branch name" to `Development`
2. Push v0.11.1 work to GitHub Development branch
3. Supabase automatically syncs (but Development branch already has everything!)
4. Optionally delete broken Supabase main branch

**Result**:
- ✅ No risk to working data
- ✅ GitHub and Supabase in sync
- ✅ Clear production environment
- ✅ Automatic deployments working

---

**Ready to proceed?** I can walk you through changing the Supabase production branch setting in the dashboard.
