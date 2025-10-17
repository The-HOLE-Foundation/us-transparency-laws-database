# ⚠️ BROKEN WORKTREES - DO NOT USE ⚠️

**Status**: ARCHIVED - BROKEN - DISCARDED
**Date Archived**: 2025-10-11
**Date Labeled**: 2025-10-16

## What This Contains

This directory contains 52 **BROKEN** git worktrees that were created during the v0.12 affirmative rights collection effort. Each subdirectory is a FULL COPY of the repository (89MB × 52 = 4.5GB total).

## Why These Are Broken

- Git worktree metadata was deleted/corrupted
- Worktrees point to non-existent git references
- These are NOT valid working directories
- The data extracted from these worktrees has already been preserved in `data/jurisdictions/`

## Why This Was Archived

During the 2025-10-11 restructure, someone archived the entire `worktrees/affirmative/` directory instead of just archiving the extraction scripts or valuable data. This created a 4.5GB archive of broken git working directories.

## What You Should Use Instead

- **Current Data**: `data/jurisdictions/*/rights.json` (the extracted rights data)
- **Current Workflow**: Use the main branch or create new temporary worktrees as needed
- **Templates**: `templates/` directory for affirmative rights templates

## Safe to Delete?

**YES** - This entire directory can be safely deleted without losing any valuable data. The rights data extracted from these worktrees is already preserved in the main repository.

## Structural Health Check (2025-10-16)

✅ Main repository structure: HEALTHY
✅ Git worktree system: CLEAN (no active worktrees, all metadata pruned)
✅ Data integrity: INTACT (rights data preserved in data/jurisdictions/)
⚠️ This archived directory: BROKEN but harmless (safe to delete)

---

**Recommendation**: Delete this entire directory to free up 4.5GB of disk space.

```bash
rm -rf /Volumes/HOLE-RAID-DRIVE/HOLE/Github/us-transparency-laws-database/.archive/2025-10-11-restructure/BROKEN-WORKTREES-DISCARDED-DATA-DO-NOT-USE
```
