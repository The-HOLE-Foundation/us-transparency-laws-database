---
DATE: 2025-10-08
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Git Worktree Workflow for Parallel Agent Work
VERSION: v0.12
---

# Git Worktree Workflow for Parallel Agent Work

## Purpose

This workflow enables multiple Claude Code agents (or human collaborators) to work on different jurisdictions simultaneously without conflicts, using git worktrees for complete isolation.

## Why Worktrees?

**Problem**: Working on multiple jurisdictions in the same directory causes:
- File conflicts when agents modify same files
- Confusion about which jurisdiction is being worked on
- Risk of cross-contamination between verification tasks
- Difficulty tracking progress per jurisdiction

**Solution**: Git worktrees create isolated working directories, each with:
- Separate branch for changes
- Independent file system state
- No risk of conflicts
- Clear jurisdiction assignment

## Directory Structure

```
us-transparency-laws-database/              # Main worktree (main branch)
├── worktrees/
│   ├── affirmative/                        # Affirmative rights verification
│   │   ├── federal/                        # Federal jurisdiction worktree
│   │   ├── california/                     # California worktree
│   │   ├── texas/                          # Texas worktree
│   │   ├── florida/                        # Florida worktree
│   │   └── ...                             # Additional state worktrees
│   ├── exemptions/                         # Future: exemptions verification
│   └── agencies/                           # Future: agency data collection
```

## Current Worktrees

Created worktrees for priority jurisdictions:

```bash
# List all worktrees
git worktree list

# Expected output:
# /path/to/main                                    [main]
# /path/to/worktrees/affirmative/federal          [verification/federal-affirmative]
# /path/to/worktrees/affirmative/california       [verification/california-affirmative]
# /path/to/worktrees/affirmative/texas            [verification/texas-affirmative]
# /path/to/worktrees/affirmative/florida          [verification/florida-affirmative]
```

## How to Use Worktrees

### For Agents

**Starting Work on a Jurisdiction**:
```bash
# 1. Navigate to the jurisdiction's worktree
cd worktrees/affirmative/federal

# 2. Verify you're on the right branch
git branch --show-current
# Should show: verification/federal-affirmative

# 3. Do your work (edit files, run scripts, verify data)
# All changes are isolated to this worktree

# 4. Commit your changes
git add data/v0.12/rights/federal-rights.json
git commit -m "feat: Complete federal affirmative rights verification"

# 5. When done, return to main worktree
cd ../../../
```

**Creating a New Jurisdiction Worktree**:
```bash
# From main worktree directory
git worktree add worktrees/affirmative/illinois -b verification/illinois-affirmative
```

**Merging Completed Work**:
```bash
# From main worktree
git checkout main
git merge verification/federal-affirmative
git push origin main

# Optional: Remove the worktree if done
git worktree remove worktrees/affirmative/federal
git branch -d verification/federal-affirmative
```

### For Parallel Agent Coordination

**Scenario**: 4 Claude Code agents working simultaneously

**Agent 1 (Federal)**:
```bash
cd worktrees/affirmative/federal
# Work on federal rights verification
```

**Agent 2 (California)**:
```bash
cd worktrees/affirmative/california
# Work on California rights verification
```

**Agent 3 (Texas)**:
```bash
cd worktrees/affirmative/texas
# Work on Texas rights verification
```

**Agent 4 (Florida)**:
```bash
cd worktrees/affirmative/florida
# Work on Florida rights verification
```

**Zero Conflicts**: Each agent works in complete isolation until ready to merge.

## Workflow Integration with v0.12

### Affirmative Rights Collection (Current Focus)

Each jurisdiction follows this workflow:

1. **Agent Assignment**: Agent claims a jurisdiction worktree
2. **Research Phase**: Agent researches official statutes in isolation
3. **Data Creation**: Agent creates/updates `data/v0.12/rights/{jurisdiction}-rights.json`
4. **Validation**: Agent runs validation scripts within worktree
5. **Commit**: Agent commits verified data to jurisdiction branch
6. **Review**: Coordinator reviews changes in worktree
7. **Merge**: Coordinator merges to main when verified
8. **Cleanup**: Worktree removed or kept for future updates

### Branch Naming Convention

Format: `verification/{jurisdiction}-{data-type}`

Examples:
- `verification/federal-affirmative`
- `verification/california-affirmative`
- `verification/texas-exemptions` (future)
- `verification/illinois-agencies` (future)

## Commands Reference

### Creating Worktrees
```bash
# Single worktree
git worktree add worktrees/affirmative/{jurisdiction} -b verification/{jurisdiction}-affirmative

# Multiple worktrees at once
git worktree add worktrees/affirmative/jurisdiction1 -b verification/jurisdiction1-affirmative && \
git worktree add worktrees/affirmative/jurisdiction2 -b verification/jurisdiction2-affirmative
```

### Managing Worktrees
```bash
# List all worktrees
git worktree list

# Remove a worktree (after merging)
git worktree remove worktrees/affirmative/{jurisdiction}

# Prune stale worktrees
git worktree prune

# Check which branch is checked out in each worktree
git worktree list
```

### Working in Worktrees
```bash
# Navigate to worktree
cd worktrees/affirmative/{jurisdiction}

# Check status (only shows changes in this worktree)
git status

# Commit changes (stays in jurisdiction branch)
git add .
git commit -m "feat: Add {jurisdiction} affirmative rights"

# Push branch to remote (optional, for backup)
git push -u origin verification/{jurisdiction}-affirmative
```

### Merging Work
```bash
# From main worktree
git checkout main

# Merge jurisdiction work
git merge verification/{jurisdiction}-affirmative

# Delete branch after merge (optional)
git branch -d verification/{jurisdiction}-affirmative

# Remove worktree after merge (optional)
git worktree remove worktrees/affirmative/{jurisdiction}
```

## Best Practices

### DO:
- ✅ Assign one jurisdiction per agent
- ✅ Commit frequently within worktree
- ✅ Run validation scripts before merging
- ✅ Keep worktrees for jurisdictions needing updates
- ✅ Document which agent is working on which worktree

### DON'T:
- ❌ Work on multiple jurisdictions in same worktree
- ❌ Delete worktree before merging changes
- ❌ Mix different data types in same branch (keep affirmative rights separate from exemptions)
- ❌ Modify files in main worktree while agents work in other worktrees (causes confusion)

## Troubleshooting

### "worktree already exists"
```bash
# List existing worktrees
git worktree list

# Remove old worktree if no longer needed
git worktree remove worktrees/affirmative/{jurisdiction}
```

### "branch already exists"
```bash
# List all branches
git branch -a

# Delete branch if no longer needed
git branch -d verification/{jurisdiction}-affirmative

# Or force delete if not merged
git branch -D verification/{jurisdiction}-affirmative
```

### "Cannot remove working tree"
```bash
# Make sure no processes are using the worktree directory
# Navigate out of the worktree
cd /path/to/main

# Try removing again
git worktree remove worktrees/affirmative/{jurisdiction}
```

### Checking Worktree Status
```bash
# Show which worktrees exist and their branches
git worktree list

# Show commits in a worktree branch that aren't in main
git log main..verification/{jurisdiction}-affirmative

# See what files changed in a worktree
cd worktrees/affirmative/{jurisdiction}
git status
git diff
```

## Integration with Claude Code

### Agent Instructions

When assigning work to a Claude Code agent, provide:

```
You will be working on {jurisdiction} affirmative rights verification.

Setup:
1. Navigate to: worktrees/affirmative/{jurisdiction}
2. Verify branch: git branch --show-current
   (should show: verification/{jurisdiction}-affirmative)
3. All your work should happen in this directory

Your task:
[specific task details]

When complete:
1. Commit changes: git add . && git commit -m "feat: ..."
2. Report completion
3. Stay in worktree for review
```

### Coordinator Workflow

```bash
# 1. Check all active worktrees
git worktree list

# 2. Review agent work
cd worktrees/affirmative/{jurisdiction}
git log
git diff main

# 3. If approved, merge to main
cd ../../../
git checkout main
git merge verification/{jurisdiction}-affirmative

# 4. Optionally clean up
git worktree remove worktrees/affirmative/{jurisdiction}
git branch -d verification/{jurisdiction}-affirmative
```

## Future Enhancements

### Additional Worktree Categories
- `worktrees/exemptions/{jurisdiction}` - Exemptions verification work
- `worktrees/agencies/{jurisdiction}` - Agency data collection
- `worktrees/testing/{jurisdiction}` - Testing and validation
- `worktrees/updates/{jurisdiction}` - Statute updates and amendments

### Automation Opportunities
- Script to create all 52 jurisdiction worktrees at once
- Automated assignment of jurisdictions to agents
- Status dashboard showing which worktrees are active
- Automated merge when validation passes

## Status Tracking

Use this template to track worktree assignments:

| Jurisdiction | Worktree Path | Branch | Agent | Status | Last Updated |
|--------------|---------------|--------|-------|--------|--------------|
| Federal | worktrees/affirmative/federal | verification/federal-affirmative | Agent 1 | Active | 2025-10-08 |
| California | worktrees/affirmative/california | verification/california-affirmative | Agent 2 | Active | 2025-10-08 |
| Texas | worktrees/affirmative/texas | verification/texas-affirmative | Agent 3 | Active | 2025-10-08 |
| Florida | worktrees/affirmative/florida | verification/florida-affirmative | Agent 4 | Active | 2025-10-08 |

## Resources

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Parallel Development Patterns](https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging)
- Project-specific workflow: `workflows/v0.12-AFFIRMATIVE_RIGHTS_WORKFLOW.md`
