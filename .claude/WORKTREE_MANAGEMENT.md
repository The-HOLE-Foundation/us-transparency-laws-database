---
DATE: 2025-10-08
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Worktree Management Strategy
VERSION: v0.12
---

# Worktree Management Strategy

## The Right Number of Worktrees

**Industry Standard: Create On-Demand, Not Pre-emptively**

### Current Setup
- ✅ 4 worktrees created (federal, california, texas, florida)
- ✅ Ideal for parallel work by 4 agents simultaneously
- ✅ Manageable disk space and cognitive overhead

### Maximum Recommended: 6 Active Worktrees

**Why Not All 52?**
- Disk space: ~500MB × 52 = 26GB of duplicate data
- Confusion: Too many directories to track
- Sync issues: Idle worktrees get out of date
- Industry practice: Create → Work → Merge → Delete → Repeat

## Lifecycle Management

### Phase 1: Create (When Starting Work)
```bash
git worktree add worktrees/affirmative/{jurisdiction} -b verification/{jurisdiction}-affirmative
cd worktrees/affirmative/{jurisdiction}
```

### Phase 2: Work (Active Development)
```bash
# Agent works in isolated worktree
# Makes commits as progress happens
git add data/v0.12/rights/{jurisdiction}-rights.json
git commit -m "feat: Add {jurisdiction} affirmative rights"
```

### Phase 3: Complete (Merge to Main)
```bash
cd /path/to/main
git merge verification/{jurisdiction}-affirmative
```

### Phase 4: Cleanup (Remove Worktree)
```bash
git worktree remove worktrees/affirmative/{jurisdiction}
git branch -d verification/{jurisdiction}-affirmative
```

### Phase 5: Next (Create New Worktree)
```bash
git worktree add worktrees/affirmative/{next-jurisdiction} -b verification/{next-jurisdiction}-affirmative
```

## Parallel Work Pattern (4-6 Agents)

### Example: 4 Agents, 52 Jurisdictions

**Round 1** (Worktrees 1-4):
- Agent 1: Federal → Complete → Merge → Delete
- Agent 2: California → Complete → Merge → Delete
- Agent 3: Texas → Complete → Merge → Delete
- Agent 4: Florida → Complete → Merge → Delete

**Round 2** (Worktrees 5-8):
- Agent 1: Illinois → Complete → Merge → Delete
- Agent 2: New York → Complete → Merge → Delete
- Agent 3: Pennsylvania → Complete → Merge → Delete
- Agent 4: Ohio → Complete → Merge → Delete

**Continue until all 52 complete...**

## Automation Script

Create a helper script to manage the cycle:

```bash
#!/bin/bash
# worktree-cycle.sh - Manage worktree lifecycle

JURISDICTION=$1
ACTION=$2

case $ACTION in
  create)
    git worktree add worktrees/affirmative/$JURISDICTION -b verification/$JURISDICTION-affirmative
    echo "✅ Created worktree for $JURISDICTION"
    ;;

  merge)
    git merge verification/$JURISDICTION-affirmative
    echo "✅ Merged $JURISDICTION to main"
    ;;

  cleanup)
    git worktree remove worktrees/affirmative/$JURISDICTION
    git branch -d verification/$JURISDICTION-affirmative
    echo "✅ Cleaned up $JURISDICTION worktree"
    ;;

  cycle)
    # Complete cycle: merge + cleanup + create next
    git merge verification/$JURISDICTION-affirmative
    git worktree remove worktrees/affirmative/$JURISDICTION
    git branch -d verification/$JURISDICTION-affirmative
    echo "✅ Cycled $JURISDICTION worktree"
    ;;

  *)
    echo "Usage: ./worktree-cycle.sh {jurisdiction} {create|merge|cleanup|cycle}"
    exit 1
    ;;
esac
```

## Tracking Active Worktrees

Use this table to track which worktrees are currently active:

| Slot | Jurisdiction | Branch | Agent | Status | Started | Notes |
|------|--------------|--------|-------|--------|---------|-------|
| 1 | federal | verification/federal-affirmative | Agent 1 | Active | 2025-10-08 | Priority 1 |
| 2 | california | verification/california-affirmative | Agent 2 | Active | 2025-10-08 | Priority 1 |
| 3 | texas | verification/texas-affirmative | Agent 3 | Active | 2025-10-08 | Priority 1 |
| 4 | florida | verification/florida-affirmative | Agent 4 | Active | 2025-10-08 | Priority 1 |

## When to Create New Worktrees

**Create a new worktree when:**
- ✅ An agent is ready to start work on a new jurisdiction
- ✅ Previous jurisdiction has been merged and cleaned up
- ✅ You have fewer than 6 active worktrees

**Don't create worktrees for:**
- ❌ "Just in case" or pre-emptive planning
- ❌ Jurisdictions not yet assigned to an agent
- ❌ When you already have 6+ active worktrees

## Quick Reference Commands

```bash
# See all active worktrees
git worktree list

# Create new worktree
git worktree add worktrees/affirmative/{jurisdiction} -b verification/{jurisdiction}-affirmative

# Merge completed work
git merge verification/{jurisdiction}-affirmative

# Remove worktree
git worktree remove worktrees/affirmative/{jurisdiction}

# Delete branch
git branch -d verification/{jurisdiction}-affirmative

# Full cycle (from main worktree)
git merge verification/{jurisdiction}-affirmative && \
git worktree remove worktrees/affirmative/{jurisdiction} && \
git branch -d verification/{jurisdiction}-affirmative
```

## Best Practices Summary

1. **Create on-demand**: Only when starting active work
2. **Keep 4-6 max**: More becomes unmanageable
3. **Merge quickly**: Don't let branches sit idle
4. **Clean up promptly**: Delete after merging
5. **Track status**: Know which worktrees are active
6. **Cycle efficiently**: Merge → Delete → Create next

## Current Status

**Active Worktrees: 4**
- ✅ federal (verification/federal-affirmative)
- ✅ california (verification/california-affirmative)
- ✅ texas (verification/texas-affirmative)
- ✅ florida (verification/florida-affirmative)

**Next Actions:**
1. Assign these 4 worktrees to agents
2. Complete verification work
3. Merge to main
4. Clean up worktrees
5. Create next batch (4 more jurisdictions)
