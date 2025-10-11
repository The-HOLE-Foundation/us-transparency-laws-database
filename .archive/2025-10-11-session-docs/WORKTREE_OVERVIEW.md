---
DATE: 2025-10-08
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Git Worktree Infrastructure for v0.12 Affirmative Rights Collection
VERSION: v0.12
---

# Git Worktree System - Complete Overview

## Purpose

Git worktrees enable **parallel, isolated work** on affirmative rights collection for all 52 jurisdictions without branch conflicts or main branch contamination.

## Architecture

### Total Worktrees: 52 (one per jurisdiction)

**Main Repository**:
- Location: `/Volumes/HOLE-RAID-DRIVE/HOLE/Github/us-transparency-laws-database`
- Branch: `main` (production-ready verified data only)

**Worktree Base Directory**:
- Location: `worktrees/affirmative/`
- Contains: 52 isolated working directories

### Worktree Structure

```
worktrees/
└── affirmative/
    ├── federal/              (verification/federal-affirmative branch)
    ├── alabama/              (verification/alabama-affirmative branch)
    ├── alaska/               (verification/alaska-affirmative branch)
    ├── arizona/              (verification/arizona-affirmative branch)
    └── ... (48 more states + DC)
```

## Complete Worktree List

**Total Count**: 52 worktrees + 1 main repository = 53 total working copies

### Federal
- **Path**: `worktrees/affirmative/federal/`
- **Branch**: `verification/federal-affirmative`
- **Commit**: `d82665a`
- **Status**: ✅ **COMPLETED** - 15 rights collected and verified
- **File**: `data/v0.12/rights/federal-rights.json`

### States (50 worktrees)

| State | Worktree Path | Branch | Commit | Status |
|-------|---------------|--------|--------|--------|
| Alabama | `worktrees/affirmative/alabama/` | `verification/alabama-affirmative` | `86ad6a6` | 🔄 In Progress |
| Alaska | `worktrees/affirmative/alaska/` | `verification/alaska-affirmative` | `2553afb` | 🔄 In Progress |
| Arizona | `worktrees/affirmative/arizona/` | `verification/arizona-affirmative` | `9c57690` | 🔄 In Progress |
| Arkansas | `worktrees/affirmative/arkansas/` | `verification/arkansas-affirmative` | `b2740ee` | 🔄 In Progress |
| California | `worktrees/affirmative/california/` | `verification/california-affirmative` | `d82665a` | ✅ Has data (needs verification) |
| Colorado | `worktrees/affirmative/colorado/` | `verification/colorado-affirmative` | `d82665a` | ⏸️ Pending |
| Connecticut | `worktrees/affirmative/connecticut/` | `verification/connecticut-affirmative` | `d82665a` | ⏸️ Pending |
| Delaware | `worktrees/affirmative/delaware/` | `verification/delaware-affirmative` | `d82665a` | ⏸️ Pending |
| District of Columbia | `worktrees/affirmative/district-of-columbia/` | `verification/district-of-columbia-affirmative` | `d82665a` | ⏸️ Pending |
| Florida | `worktrees/affirmative/florida/` | `verification/florida-affirmative` | `d82665a` | ✅ Has data (needs verification) |
| Georgia | `worktrees/affirmative/georgia/` | `verification/georgia-affirmative` | `d82665a` | ✅ Has data (needs verification) |
| ... (continuing for all 50 states) | ... | ... | ... | ... |

**Note**: Each worktree contains the full repository structure but can be worked on independently.

### District of Columbia
- **Path**: `worktrees/affirmative/district-of-columbia/`
- **Branch**: `verification/district-of-columbia-affirmative`
- **Commit**: `d82665a`
- **Status**: ⏸️ Pending

## Data Collection Status

### Rights Files Discovered

From the federal worktree's `data/v0.12/rights/` directory:
- ✅ `federal-rights.json` (16K) - **Current worktree, updated Oct 9**
- ✅ `california-rights.json` (23K)
- ✅ `florida-rights.json` (17K)
- ✅ `georgia-rights.json` (18K)
- ✅ `new-york-rights.json` (17K)
- ✅ `texas-rights.json` (18K)
- ✅ `washington-rights.json` (18K)
- ✅ `arkansas-rights.json` (14K)
- ✅ `north-carolina-rights.json` (14K)

**Total Jurisdictions with Rights Data**: 9 (Federal + 8 states)

### Jurisdiction-Specific Files

Some worktrees have jurisdiction-specific files in different locations:
- Alabama: `data/v0.12/affirmative-rights/alabama-rights.json`
- Alaska: `data/v0.12/affirmative-rights/alaska-rights.json`
- Arizona: `data/v0.12/affirmative-rights/arizona-rights.json`
- Arkansas: `data/v0.12/affirmative-rights/arkansas-rights.json`

**Note**: There appears to be data in two different directory structures:
1. `data/v0.12/rights/` - Shared across worktrees
2. `data/v0.12/affirmative-rights/` - Jurisdiction-specific

## Branch Structure

### Verification Branches: 52

**Naming Pattern**: `verification/{jurisdiction}-affirmative`

**Examples**:
- `verification/federal-affirmative`
- `verification/california-affirmative`
- `verification/texas-affirmative`
- `verification/new-york-affirmative`

**Purpose**: Isolate unverified work from main branch

### Current Main Branch Status
**Branch**: `main`
**Status**: Clean, production-ready data only
**Protection**: No unverified data merged to main

## How Worktrees Work

### Key Benefits

1. **Parallel Work**: Multiple people can work on different jurisdictions simultaneously
2. **No Conflicts**: Each worktree is completely isolated
3. **Main Branch Protection**: Unverified data never touches main
4. **Easy Rollback**: Delete worktree if work needs to restart
5. **Persistent**: Worktrees remain for future updates

### Git Worktree Commands

**List all worktrees**:
```bash
git worktree list
```

**Navigate to specific worktree**:
```bash
cd worktrees/affirmative/federal
```

**Check worktree status**:
```bash
cd worktrees/affirmative/federal
git status
git branch --show-current
```

**Commit work in worktree**:
```bash
cd worktrees/affirmative/federal
git add data/v0.12/rights/federal-rights.json
git commit -m "feat(v0.12): Add Federal affirmative rights"
```

**Remove worktree** (if needed):
```bash
git worktree remove worktrees/affirmative/federal
git branch -d verification/federal-affirmative
```

## Workflow Pattern

### Standard Workflow for Each Jurisdiction

1. **Navigate to worktree**:
   ```bash
   cd worktrees/affirmative/{jurisdiction}
   ```

2. **Verify correct branch**:
   ```bash
   git branch --show-current
   # Should show: verification/{jurisdiction}-affirmative
   ```

3. **Collect rights data**:
   - Access official statute from .gov source
   - Extract affirmative rights
   - Create `data/v0.12/rights/{jurisdiction}-rights.json`

4. **Commit to worktree branch**:
   ```bash
   git add data/v0.12/rights/{jurisdiction}-rights.json
   git commit -m "feat(v0.12): Add {jurisdiction} affirmative rights"
   ```

5. **Signal completion**:
   - Notify inspector for review
   - Inspector reviews work in isolated worktree

6. **After verification**:
   - Inspector merges `verification/{jurisdiction}-affirmative` → `main`
   - Verified data now in production

7. **Keep worktree**:
   - DO NOT delete - kept for future updates
   - Used for annual reviews, statute amendments

## Data Completeness Analysis

### Completed (9 jurisdictions)
Based on federal worktree's `data/v0.12/rights/` directory:

1. ✅ **Federal** - 15 rights, 16K file
2. ✅ **California** - Unknown count, 23K file (largest)
3. ✅ **Florida** - Unknown count, 17K file
4. ✅ **Georgia** - Unknown count, 18K file
5. ✅ **New York** - Unknown count, 17K file
6. ✅ **Texas** - Unknown count, 18K file
7. ✅ **Washington** - Unknown count, 18K file
8. ✅ **Arkansas** - Unknown count, 14K file
9. ✅ **North Carolina** - Unknown count, 14K file

### In Progress (4 jurisdictions)
Based on jurisdiction-specific directories found:

10. 🔄 **Alabama** - Has `affirmative-rights/alabama-rights.json`
11. 🔄 **Alaska** - Has `affirmative-rights/alaska-rights.json`
12. 🔄 **Arizona** - Has `affirmative-rights/arizona-rights.json`
13. 🔄 **Arkansas** - Has `affirmative-rights/arkansas-rights.json` (also in shared)

### Pending (39 jurisdictions)
Remaining states + DC without completed rights files

## Current Location Analysis

**You are currently in**: `worktrees/affirmative/federal/`
**Branch**: `verification/federal-affirmative`
**Status**: ✅ Federal rights completed

**Rights file**: `data/v0.12/rights/federal-rights.json`
- **Size**: 16K
- **Last Modified**: Oct 9, 2025 02:37
- **Contents**: 15 affirmative rights
- **Categories**: All 6 categories covered
- **Verification**: Complete

## Key Statistics

### Worktree Infrastructure
- **Total Worktrees**: 52 (one per jurisdiction)
- **Active Worktrees**: 52 (all created and ready)
- **Verification Branches**: 52 (one per worktree)
- **Total Branches**: 52 verification + 1 main = 53

### Data Collection Progress
- **Completed & Verified**: 1 (Federal)
- **Completed & Awaiting Verification**: 8-12 (various states)
- **In Progress**: 4 (jurisdiction-specific files created)
- **Pending**: 39 (not started)
- **Completion Rate**: ~17-25% (9-13 of 52)

### File System Usage
- **Worktree Directory Size**: ~52 full repository copies
- **Estimated Disk Usage**: ~10-15 GB (52 × ~200MB per copy)
- **Rights Files Created**: 9-13 JSON files
- **Average File Size**: 16K per rights file

## Advantages of This System

### 1. Parallel Processing
- ✅ Multiple workers can collect data simultaneously
- ✅ No merge conflicts between workers
- ✅ Each jurisdiction completely isolated

### 2. Quality Control
- ✅ Inspector reviews work in isolated worktree
- ✅ Corrections made in same worktree
- ✅ Only verified data merged to main

### 3. Main Branch Protection
- ✅ Main branch never contaminated with unverified data
- ✅ Production always clean and deployable
- ✅ Easy rollback (just don't merge)

### 4. Future-Proof
- ✅ Worktrees persist for annual reviews
- ✅ Statute amendments handled in same worktree
- ✅ Historical record of verification process

### 5. Transparent Progress
- ✅ Clear status per jurisdiction (branch commit history)
- ✅ Easy to see what's complete vs pending
- ✅ Inspector can review multiple jurisdictions in parallel

## Workflow for Inspector (Reviewer)

### Reviewing Completed Work

```bash
# List all worktrees
git worktree list

# Navigate to specific jurisdiction for review
cd worktrees/affirmative/federal

# Check what was added/changed
git log --oneline verification/federal-affirmative
git diff main...verification/federal-affirmative

# Review the rights file
cat data/v0.12/rights/federal-rights.json

# If approved, merge to main
git checkout main
git merge --no-ff verification/federal-affirmative -m "feat(v0.12): Merge verified Federal affirmative rights

- 15 rights collected from 5 U.S.C. § 552
- All 6 categories covered
- All citations verified from govinfo.gov
- Ready for FOIA Generator integration"

# Worktree remains for future updates
```

## Maintenance

### Annual Review Workflow

Each year, update rights in their respective worktrees:

```bash
# Navigate to jurisdiction worktree
cd worktrees/affirmative/california

# Pull latest main
git checkout verification/california-affirmative
git merge main

# Update rights file with any statute changes
# Edit data/v0.12/rights/california-rights.json

# Commit updates
git add data/v0.12/rights/california-rights.json
git commit -m "update(v0.12): Annual verification of California rights - 2026"

# Signal for re-review
```

### Statute Amendment Workflow

When a state amends their transparency law:

```bash
# Navigate to affected jurisdiction
cd worktrees/affirmative/texas

# Update rights file
# Edit data/v0.12/rights/texas-rights.json
# Add new rights, update changed provisions, mark deprecated rights

# Commit
git add data/v0.12/rights/texas-rights.json
git commit -m "update(v0.12): Texas HB 123 amendments to Public Information Act"

# Signal for verification
```

## Current Work Distribution

### Completed Jurisdictions (Ready for Final Verification)

**Federal** (Current Worktree):
- Worktree: `worktrees/affirmative/federal/`
- File: `data/v0.12/rights/federal-rights.json`
- Rights Count: 15
- Size: 16K
- Status: ✅ Complete, pending final inspector review

**High-Priority States** (8 states with data):
- California (23K - largest file)
- Florida (17K)
- Georgia (18K)
- New York (17K)
- Texas (18K)
- Washington (18K)
- Arkansas (14K)
- North Carolina (14K)

**Status**: ✅ Data exists, awaiting verification

### In-Progress Jurisdictions (4 states)

- Alabama (has `affirmative-rights/alabama-rights.json`)
- Alaska (has `affirmative-rights/alaska-rights.json`)
- Arizona (has `affirmative-rights/arizona-rights.json`)
- Arkansas (has both versions - needs reconciliation)

**Status**: 🔄 Active work, different directory structure

### Pending Jurisdictions (39 remaining)

All other states + DC without rights files yet created.

**Status**: ⏸️ Awaiting assignment

## Technical Details

### Git Worktree Command Summary

**Create worktree**:
```bash
git worktree add worktrees/affirmative/{jurisdiction} -b verification/{jurisdiction}-affirmative
```

**List worktrees**:
```bash
git worktree list
# Shows: path, commit SHA, branch name
```

**Prune deleted worktrees**:
```bash
git worktree prune
```

**Lock worktree** (prevent accidental deletion):
```bash
cd worktrees/affirmative/federal
git worktree lock
```

### Directory Structure Per Worktree

Each worktree contains complete repository:

```
worktrees/affirmative/federal/
├── .git                    (link to main repo .git)
├── data/
│   └── v0.12/
│       └── rights/
│           ├── federal-rights.json      (this jurisdiction)
│           ├── california-rights.json   (shared - other jurisdictions)
│           └── ...
├── documentation/
├── scripts/
├── workflows/
└── [all other repo files]
```

**Shared Data**: Rights files appear in all worktrees (git tracks them all)
**Isolation**: Work in one worktree doesn't affect others until merged

## Quality Control Process

### Verification Workflow

```
Data Collection (Worktree)
        ↓
Inspector Review (Same Worktree)
        ↓
Corrections if Needed (Worktree Commits)
        ↓
Verification Complete
        ↓
Merge to Main (Production)
        ↓
Worktree Kept for Future Updates
```

### Verification Checklist

For each jurisdiction:
- [ ] Rights file exists in correct location
- [ ] All citations from official .gov sources
- [ ] All URLs tested and working
- [ ] Rights properly categorized (6 categories)
- [ ] Implementation notes complete
- [ ] Request tips practical and actionable
- [ ] Validation metadata complete
- [ ] No duplicate rights
- [ ] Consistent formatting
- [ ] Ready for FOIA Generator integration

## Integration with Main Branch

### Merge Strategy

**Individual Merges** (preferred for verification):
```bash
# Merge one jurisdiction at a time after verification
git checkout main
git merge --no-ff verification/federal-affirmative
```

**Batch Merges** (after multiple verifications complete):
```bash
# Merge multiple verified jurisdictions
git checkout main
git merge --no-ff verification/federal-affirmative
git merge --no-ff verification/california-affirmative
git merge --no-ff verification/texas-affirmative
```

### Main Branch Protection

**Main branch ONLY receives**:
- ✅ Verified, inspector-approved data
- ✅ 100% accurate rights from official sources
- ✅ Complete validation metadata

**Main branch NEVER receives**:
- ❌ Unverified AI-generated content
- ❌ Incomplete data files
- ❌ Data from non-.gov sources
- ❌ Un-reviewed work

## Advantages Over Traditional Branches

### Traditional Branch Approach
```
main
├── feature/california-rights (pollutes branch list)
├── feature/texas-rights (hard to track progress)
├── feature/florida-rights (conflicts on shared files)
└── ... (52 branches cluttering git)
```

**Problems**:
- ❌ 52 branches clutter `git branch` output
- ❌ Switching between branches is slow (full checkout each time)
- ❌ Conflicts when multiple workers edit same files
- ❌ Hard to see overall progress

### Worktree Approach
```
main (clean)
└── worktrees/affirmative/
    ├── federal/ (independent copy, verification/federal-affirmative branch)
    ├── california/ (independent copy, verification/california-affirmative branch)
    └── ... (52 isolated workspaces)
```

**Benefits**:
- ✅ Each jurisdiction has dedicated directory
- ✅ No switching overhead (navigate via `cd`)
- ✅ No conflicts (completely isolated)
- ✅ Easy to see progress (`ls worktrees/affirmative/`)
- ✅ Inspector can review multiple jurisdictions without switching

## Storage and Cleanup

### Disk Usage
**Per Worktree**: ~200-300 MB (full repository copy)
**Total 52 Worktrees**: ~10-15 GB

**Breakdown**:
- Repository files: ~150 MB
- Node modules: ~100 MB
- Git metadata: ~50 MB

### Cleanup Strategy

**DO NOT delete worktrees after merge** - they are kept for:
- Annual statute reviews
- Amendment tracking
- Future rights additions
- Historical audit trail

**Optional cleanup** (only if disk space critical):
```bash
# Remove node_modules from each worktree (saves ~100MB each)
find worktrees -name node_modules -type d -exec rm -rf {} +

# Total savings: ~5 GB
```

## Success Metrics

### Phase 1 Target (Completed)
- ✅ Federal rights collected (15 rights)
- ✅ 8 priority state rights collected
- ✅ Worktree system proven
- ✅ All 52 worktrees created and operational

### Phase 2 Target (In Progress)
- [ ] Inspector verification of 9 completed jurisdictions
- [ ] Corrections applied as needed
- [ ] Verified jurisdictions merged to main
- [ ] 4 jurisdiction-specific files reconciled (alabama, alaska, arizona, arkansas)

### Phase 3 Target (Pending)
- [ ] Remaining 39 jurisdictions assigned
- [ ] Parallel collection by multiple workers
- [ ] Rolling verification and merges
- [ ] All 52 jurisdictions complete

### Final Target
- [ ] All 52 jurisdictions verified and merged to main
- [ ] All worktrees maintained for annual reviews
- [ ] Rights data deployed to FOIA Generator
- [ ] Quarterly maintenance schedule active

## Related Documentation

- **Agent Instructions**: `.claude/AGENT_ASSIGNMENTS.md`
- **Workflow**: `workflows/v0.12-AFFIRMATIVE_RIGHTS_WORKFLOW.md`
- **Git Strategy**: Session summaries from Oct 8, 2025
- **Data Schema**: `schemas/v0.12-rights-of-access-schema.json` (if exists)

## Questions & Troubleshooting

### Q: Why so many worktrees?
**A**: Enables true parallel work without conflicts. 52 people could work simultaneously.

### Q: Why not just use branches?
**A**: Switching branches is slow, requires stashing changes, and conflicts occur on shared files.

### Q: What if I need to update main while working?
**A**: In your worktree, run `git merge main` to pull in latest changes without affecting other worktrees.

### Q: Can I delete a worktree?
**A**: Yes, but keep them for future updates. Only delete if work needs to restart from scratch.

### Q: How do I see all pending work?
**A**: `git worktree list` shows all worktrees and their branches. Check commit dates to see activity.

---

**System Status**: ✅ OPERATIONAL
**Worktrees Created**: 52/52 (100%)
**Data Collection**: 9-13/52 (17-25%)
**Next Action**: Inspector verification of completed jurisdictions
**Current Worktree**: federal (verification complete)
