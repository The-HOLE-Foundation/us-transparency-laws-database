---
DATE: 2025-10-11
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Repository Organization and Cleanup
VERSION: Quick Start Guide
---

# REPOSITORY CLEANUP - QUICK START GUIDE

## The Problem

**Repository is 4.7 GB** (should be ~200 MB)
- 4.5 GB of bloated worktrees (52 × 89 MB each)
- 5,212 node_modules files tracked in git
- 16,460+ duplicate documentation files

## The Solution (5 Phases)

Execute these scripts **in order**:

```bash
# 1. Fix .gitignore (2 min)
chmod +x cleanup-phase1-gitignore.sh
./cleanup-phase1-gitignore.sh

# 2. Stop tracking node_modules (5 min)
chmod +x cleanup-phase2-stop-tracking.sh
./cleanup-phase2-stop-tracking.sh

# 3. Consolidate rights data (5 min)
chmod +x cleanup-phase3-consolidate-data.sh
./cleanup-phase3-consolidate-data.sh

# 4. Clean worktrees (10 min)
chmod +x cleanup-phase4-clean-worktrees.sh
./cleanup-phase4-clean-worktrees.sh

# 5. Archive old docs (5 min)
chmod +x cleanup-phase5-archive-docs.sh
./cleanup-phase5-archive-docs.sh

# Verify results
./check-repository-health.sh
```

**Total time**: ~30 minutes
**Space saved**: ~4.5 GB (96% reduction)

## Before You Start

### Prerequisites

1. **Backup the repository**
   ```bash
   cd /Volumes/HOLE-RAID-DRIVE/HOLE/Github/
   tar -czf us-transparency-laws-database-backup-$(date +%Y%m%d).tar.gz us-transparency-laws-database/
   ```

2. **Check current status**
   ```bash
   chmod +x check-repository-health.sh
   ./check-repository-health.sh
   ```

3. **Ensure clean working tree**
   ```bash
   git status
   # Should show: "nothing to commit, working tree clean"
   # If not, commit or stash changes first
   ```

### Safety Features

Each script:
- ✅ Creates git checkpoints (tagged commits)
- ✅ Can be rolled back with `git reset --hard [tag]`
- ✅ Moves files (doesn't delete)
- ✅ Validates operations before proceeding

## What Each Phase Does

### Phase 1: Fix .gitignore
- Adds node_modules/ and other exclusions
- **Reversible**: Just restore .gitignore.backup
- **Risk**: None
- **Time**: 2 minutes

### Phase 2: Stop Tracking node_modules
- Removes 5,212 files from git index
- Keeps node_modules in git history
- Local node_modules/ untouched
- **Reversible**: `git reset --hard cleanup-checkpoint-YYYYMMDD-HHMM`
- **Risk**: Low
- **Time**: 5 minutes

### Phase 3: Consolidate Rights Data
- Copies 42+ rights files to main repo
- Original files untouched
- Creates inventory report
- **Reversible**: Just delete the consolidated folder
- **Risk**: None (creates copies)
- **Time**: 5 minutes

### Phase 4: Clean Worktrees
- Tests on one worktree first
- Removes node_modules, docs, configs from worktrees
- Keeps only jurisdiction-specific rights files
- **Reversible**: `git reset --hard cleanup-checkpoint-worktrees-YYYYMMDD-HHMM`
- **Risk**: Medium (deletes files, but data backed up in phase 3)
- **Time**: 10 minutes

### Phase 5: Archive Documentation
- Moves old docs to .archive/2025-10-11-cleanup/
- Organizes technical docs in documentation/
- Creates inventory
- **Reversible**: Just move files back
- **Risk**: None (moves, doesn't delete)
- **Time**: 5 minutes

## Expected Results

### Before Cleanup
```
Repository Size:        4.7 GB
Worktrees:              4.5 GB (89 MB each × 52)
Git tracked files:      5,987 files
node_modules in git:    5,212 files
Markdown files:         16,461 files
Worktree contents:      Everything (full repo copies)
```

### After Cleanup
```
Repository Size:        ~200 MB
Worktrees:              ~52 MB (1 MB each × 52)
Git tracked files:      ~775 files
node_modules in git:    0 files
Markdown files:         ~30 files
Worktree contents:      Only jurisdiction-specific data
```

### Space Savings
- **Total**: 4.5 GB saved (96% reduction)
- **Worktrees**: 4.45 GB saved (99% reduction)
- **Git tracking**: 5,212 files removed

## Troubleshooting

### If Something Goes Wrong

**General rollback**:
```bash
# List available checkpoints
git tag | grep cleanup-checkpoint

# Rollback to specific checkpoint
git reset --hard cleanup-checkpoint-YYYYMMDD-HHMM

# Remove checkpoint tags (after successful cleanup)
git tag -d cleanup-checkpoint-YYYYMMDD-HHMM
```

**Restore from backup**:
```bash
cd /Volumes/HOLE-RAID-DRIVE/HOLE/Github/
rm -rf us-transparency-laws-database/
tar -xzf us-transparency-laws-database-backup-YYYYMMDD.tar.gz
```

### Common Issues

**Issue**: "worktree not working after cleanup"
```bash
# Check worktree status
cd worktrees/affirmative/alabama
git status
git worktree repair
```

**Issue**: "can't find rights data"
```bash
# Check consolidated location
ls -lh data/v0.12/affirmative-rights-consolidated/
cat data/v0.12/affirmative-rights-consolidated/INVENTORY.md
```

**Issue**: "node_modules still showing in git status"
```bash
# Verify .gitignore
grep node_modules .gitignore

# If missing, re-run phase 1
./cleanup-phase1-gitignore.sh
```

## Verification Checklist

After completing all phases:

- [ ] Repository size < 500 MB
- [ ] Worktrees size < 100 MB
- [ ] node_modules not in git status
- [ ] All 42+ rights files in data/v0.12/affirmative-rights-consolidated/
- [ ] Worktrees still functional (git status works)
- [ ] Documentation organized (old docs in .archive/)
- [ ] check-repository-health.sh shows no critical issues

## Next Steps

After successful cleanup:

1. **Commit the cleanup**
   ```bash
   git add -A
   git commit -m "Major cleanup: Fix bloated worktrees and consolidate data

   - Fixed .gitignore to exclude node_modules
   - Stopped tracking 5,212 dependency files
   - Consolidated 42+ affirmative rights files
   - Cleaned worktrees (4.5 GB → 52 MB)
   - Archived obsolete documentation

   See: REPOSITORY_BLOAT_ANALYSIS.md
   Saved: 4.5 GB (96% reduction)"
   ```

2. **Push to remote** (if desired)
   ```bash
   git push origin v0.12-affirmative-rights-collection
   ```

3. **Update team** about new structure
   - Worktrees now lean (jurisdiction data only)
   - All rights data consolidated in main repo
   - node_modules no longer tracked

4. **Delete backup** (after verifying everything works)
   ```bash
   # Wait a few days, then:
   rm /Volumes/HOLE-RAID-DRIVE/HOLE/Github/us-transparency-laws-database-backup-*.tar.gz
   ```

## Prevention (Going Forward)

To prevent recurrence:

1. **Never commit node_modules**
   - Always check: `git status` before committing
   - If you see node_modules, something is wrong

2. **Keep worktrees lean**
   - Only edit jurisdiction-specific files in worktrees
   - All other work in main repo

3. **Archive session docs regularly**
   - Use session end protocol
   - Move old summaries to .archive/YYYY-MM-DD/

4. **Run health checks monthly**
   ```bash
   ./check-repository-health.sh
   ```

## Help & Support

**Full documentation**: See `REPOSITORY_BLOAT_ANALYSIS.md`

**Questions?**
- Review the comprehensive analysis report
- Check troubleshooting section above
- Restore from backup if needed

---

**Created**: 2025-10-11
**Status**: Ready for execution
**Estimated cleanup time**: 30 minutes
**Expected space savings**: 4.5 GB (96%)
