---
DATE: 2025-10-07
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Supabase Branch Promotion Strategy
VERSION: v0.11.1
---

# Supabase Branch Promotion Strategy

## Current Architecture (Now Understood Correctly!)

**Project**: THE HOLE TRUTH PROJECT (ctxhmgmeflnemjfzyabr)
**Type**: Paid Pro Project

**Branches within this project**:
1. **main** (ctxhmgmeflnemjfzyabr)
   - DEFAULT: true
   - STATUS: MIGRATIONS_FAILED ❌
   - Created: 2025-09-08
   - Broken/corrupted data

2. **Development** (befpnwcokngtrljxskfz)
   - DEFAULT: false
   - STATUS: FUNCTIONS_DEPLOYED ✅
   - Created: 2025-10-06
   - **Has all 52 jurisdictions, 365 exemptions - PRODUCTION READY**

## The Goal

Make the Development branch (befpnwcokngtrljxskfz) the production branch and get rid of the broken main branch.

## Solution Options

### Option 1: Delete Main Branch, Keep Development (RECOMMENDED)

**Steps**:
```bash
# 1. Delete the broken main branch
npx supabase branches delete main --project-ref ctxhmgmeflnemjfzyabr

# 2. Rename Development branch to Production
npx supabase branches update Development \
  --name Production \
  --project-ref ctxhmgmeflnemjfzyabr

# 3. Update local link if needed
echo "befpnwcokngtrljxskfz" > supabase/.temp/project-ref
```

**Result**:
- ✅ Broken branch gone
- ✅ Development branch renamed to "Production"
- ✅ All data preserved (befpnwcokngtrljxskfz)
- ✅ Clean production environment

**Pros**:
- Simple and clean
- Removes the broken branch
- Development branch IS production

**Cons**:
- Development branch won't be marked as "DEFAULT" (still a preview branch technically)
- But this doesn't matter - it functions as production!

### Option 2: Just Use Development as Production (EASIEST)

**Do nothing with CLI, just**:

1. **In Supabase Dashboard**:
   - Go to https://supabase.com/dashboard/project/ctxhmgmeflnemjfzyabr
   - Navigate to Branches
   - Pause or delete the main branch
   - Keep using Development branch

2. **Update all environment variables** to point to Development:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=https://befpnwcokngtrljxskfz.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=<development_anon_key>
   ```

3. **Document** that Development IS your production

**Pros**:
- Zero risk
- No commands to run
- Already working
- Can delete main branch later if needed

**Cons**:
- Name says "Development" but it's actually production (documentation issue only)

### Option 3: Disable/Re-enable Branching (COMPLEX, NOT RECOMMENDED)

According to Supabase docs: "The only way to change [the production branch] is to disable and re-enable branching."

**Steps**:
1. Disable branching in Project Settings
2. Export data from Development branch
3. Re-enable branching with different default branch
4. Import data back

**Pros**:
- "Proper" production branch setup

**Cons**:
- ❌ Complex multi-step process
- ❌ Risk of data loss
- ❌ Downtime during migration
- ❌ Not worth it - Development branch works fine!

## Recommended Execution Plan

### Step 1: Verify Development Branch is Production-Ready

```bash
# Check current state
npx supabase branches list --project-ref ctxhmgmeflnemjfzyabr

# Verify data in Development branch
npx supabase link --project-ref befpnwcokngtrljxskfz
node dev/scripts/verify-schema.js
```

**Expected output**:
- 52 jurisdictions
- 365 exemptions
- All 10 tables + 1 view
- All migrations applied

### Step 2: Pause or Delete Main Branch

**Via CLI**:
```bash
# Option A: Pause main branch (can unpause later)
npx supabase branches pause main --project-ref ctxhmgmeflnemjfzyabr

# Option B: Delete main branch (permanent)
npx supabase branches delete main --project-ref ctxhmgmeflnemjfzyabr --yes
```

**Via Dashboard** (easier):
1. Go to https://supabase.com/dashboard/project/ctxhmgmeflnemjfzyabr/branches
2. Find "main" branch
3. Click menu → Pause or Delete

### Step 3: Rename Development to Production (Optional)

```bash
npx supabase branches update Development \
  --name Production \
  --project-ref ctxhmgmeflnemjfzyabr
```

This is cosmetic - makes it clear that Development IS production.

### Step 4: Update All Documentation

**Files to update**:
- `.env.production` (already done ✅)
- `README.md` (already done ✅)
- `CLAUDE.md` (already done ✅)
- `VERSION.md` (already done ✅)

All documentation already points to befpnwcokngtrljxskfz as production!

### Step 5: Verify Everything Works

```bash
# Test API access
curl "https://befpnwcokngtrljxskfz.supabase.co/rest/v1/jurisdictions?select=count" \
  -H "apikey: <ANON_KEY>" \
  -H "Authorization: Bearer <ANON_KEY>"

# Should return: {"count":52}
```

## What About GitHub?

**GitHub is independent** - we still need to commit and push our v0.11.1 work:

```bash
# 1. Commit all local changes
git add .
git commit -m "feat: Complete v0.11.1 Supabase Integration [...]"

# 2. Push to GitHub
git push origin main --force  # Replace old main branch
```

This is separate from Supabase branches!

## Final State

After execution:

**Supabase**:
- Project: THE HOLE TRUTH PROJECT (ctxhmgmeflnemjfzyabr)
  - ~~main branch~~ (deleted/paused)
  - **Production branch** (befpnwcokngtrljxskfz) ✅
    - 52 jurisdictions
    - 365 exemptions
    - 10 tables + 1 view
    - All migrations applied

**GitHub**:
- Repository: us-transparency-laws-database
  - **main branch** ✅
    - All v0.11.1 work
    - Supabase migrations
    - Documentation
    - Import scripts

**Environment Variables** (already configured ✅):
```env
NEXT_PUBLIC_SUPABASE_URL=https://befpnwcokngtrljxskfz.supabase.co
```

## Cost Savings

**Current**:
- Main branch: Active but broken (costing money)
- Development branch: Active and working (costing money)
- **Total**: Paying for 2 branches

**After deletion**:
- Production branch only: (befpnwcokngtrljxskfz)
- **Total**: Paying for 1 branch
- **Savings**: ~50% reduction in Supabase costs!

## Summary

**Recommended approach**: Option 2 (Use Development as Production)

**Why**:
1. ✅ Simplest (no complex commands)
2. ✅ Safest (no data migration)
3. ✅ Already working (Development IS production-ready)
4. ✅ Cost savings (pause/delete main branch)
5. ✅ Clear documentation (all docs point to befpnwcokngtrljxskfz)

**What to do**:
1. Pause or delete main branch (via Dashboard or CLI)
2. Keep using Development branch as production
3. Commit and push v0.11.1 work to GitHub
4. Done!

---

**Ready to execute?** Just say the word and I'll:
1. Help you pause/delete the main branch
2. Commit all v0.11.1 work
3. Push to GitHub
4. Verify everything works
