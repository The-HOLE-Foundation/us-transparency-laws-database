---
DATE: 2025-10-08
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Inspector Role - Quality Control Workflow
VERSION: v0.12
---

# Inspector Workflow: Your Role in Quality Control

## Overview

You act as **inspector and correction agent** while Claude Code agents collect data in parallel across all 52 jurisdictions.

**Your Responsibilities:**
- ✅ Review completed work for accuracy
- ✅ Verify citations are from official .gov sources
- ✅ Identify errors and request corrections
- ✅ Approve verified data for merge to main
- ✅ Maintain 100% accuracy standard

## The Parallel Work Model

```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ Agent 1     │  │ Agent 2     │  │ Agent 3     │  │ Agent N     │
│ Federal     │  │ California  │  │ Texas       │  │ Wyoming     │
│ Worktree    │  │ Worktree    │  │ Worktree    │  │ Worktree    │
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                │                │
       └────────────────┴────────────────┴────────────────┘
                              │
                    ┌─────────▼──────────┐
                    │   YOU (Inspector)  │
                    │   Review & Approve │
                    └─────────┬──────────┘
                              │
                    ┌─────────▼──────────┐
                    │   Main Branch      │
                    │   (Verified Data)  │
                    └────────────────────┘
```

## Review Workflow

### Step 1: Agent Signals Completion

Agent will message: "I've completed {jurisdiction} affirmative rights data collection. Ready for review."

### Step 2: Navigate to Jurisdiction Worktree

```bash
cd worktrees/affirmative/{jurisdiction}
```

### Step 3: Review the Data File

```bash
# View the collected rights data
cat data/v0.12/rights/{jurisdiction}-rights.json

# Or open in your editor
code data/v0.12/rights/{jurisdiction}-rights.json
```

### Step 4: Verification Checklist

**Check each item:**

- [ ] **File exists** at correct path: `data/v0.12/rights/{jurisdiction}-rights.json`
- [ ] **JSON is valid** (no syntax errors)
- [ ] **All citations** reference official .gov sources
- [ ] **Statute numbers** match official statutory codes
- [ ] **Categories** match the schema:
  - Proactive Disclosure
  - Enhanced Access Rights
  - Technology Rights
  - Requester-Specific Rights
  - Inspection Rights
  - Timeliness Rights
- [ ] **Descriptions** are clear, accurate, and complete
- [ ] **No AI summarization** used (only official statutory language)
- [ ] **Request tips** are practical and actionable
- [ ] **Metadata** includes verification date and sources

### Step 5A: If Errors Found

**Update tracking:**
```bash
# Edit .claude/JURISDICTION_TRACKING.md
# Change jurisdiction status to: ⚠️ Needs Correction
# Add note describing what needs fixing
```

**Notify agent with specific corrections:**
```
I've reviewed {jurisdiction}. Please make the following corrections:

1. [Specific issue #1 with exact location]
2. [Specific issue #2 with exact location]
3. [etc.]

The worktree is still at: worktrees/affirmative/{jurisdiction}
Please make corrections and let me know when ready for re-review.
```

**Agent makes corrections in same worktree, signals completion again, you review again.**

### Step 5B: If Approved

**Update tracking:**
```bash
# Edit .claude/JURISDICTION_TRACKING.md
# Change jurisdiction status to: ✅ Complete
# Add completion date
```

**Merge to main:**
```bash
# Return to main worktree
cd /Volumes/HOLE-RAID-DRIVE/HOLE/Github/us-transparency-laws-database

# Ensure you're on main branch
git branch --show-current  # Should show: main

# Merge the verified jurisdiction data
git merge verification/{jurisdiction}-affirmative

# Commit message will be auto-generated or you can customize:
git commit -m "feat(v0.12): Add verified {jurisdiction} affirmative rights

- All citations verified from official .gov sources
- {X} rights of access documented
- Categories: [list main categories]
- Reviewed and approved: [date]

🤖 Generated with Claude Code (https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Keep the worktree** (don't delete) - it will be useful for future statute updates.

## Common Issues to Watch For

### ❌ Citation Errors
- **Problem**: Citation references unofficial source (blog, wiki, AI summary)
- **Correction**: "Citation for {specific right} must reference official statute at {official .gov URL}"

### ❌ Category Mismatch
- **Problem**: Right placed in wrong category
- **Correction**: "'{right description}' should be in 'Technology Rights' not 'Enhanced Access Rights'"

### ❌ Unclear Description
- **Problem**: Description is vague or uses AI-generated language
- **Correction**: "Description must use exact statutory language. Replace with verbatim quote from {statute citation}"

### ❌ Missing Implementation Notes
- **Problem**: Complex right lacks guidance on how to invoke it
- **Correction**: "Add implementation_notes explaining how to assert this right in a FOIA request"

### ❌ Invalid JSON
- **Problem**: Syntax error (missing comma, unclosed bracket, etc.)
- **Correction**: "JSON syntax error at line {X}. Missing comma after {field name}"

## Tracking Progress

Update `.claude/JURISDICTION_TRACKING.md` after each review:

**Status Changes:**
- 🔴 Not Started → 🟡 In Progress (when agent starts)
- 🟡 In Progress → 🔵 In Review (when agent signals completion)
- 🔵 In Review → ⚠️ Needs Correction (if errors found)
- ⚠️ Needs Correction → 🔵 In Review (when agent re-submits)
- 🔵 In Review → ✅ Complete (when approved and merged)

**Update the progress counters:**
```markdown
- **Not Started:** 45/52
- **In Progress:** 5/52
- **In Review:** 2/52
- **Needs Correction:** 0/52
- **Complete:** 0/52
```

## Handling Multiple Agents

**Scenario:** 4 agents working simultaneously

**Your Review Queue:**
1. Federal (Agent 1) - submitted first
2. California (Agent 2) - submitted second
3. Texas (Agent 3) - submitted third
4. Florida (Agent 4) - submitted fourth

**Review in order received or by priority:**
- Priority 1: Federal (needed for examples)
- Priority 2: Large states (CA, TX, FL, NY)
- Priority 3: All others

**Parallel review possible:**
- You can review multiple jurisdictions simultaneously
- Each worktree is independent
- Open multiple terminal windows/tabs

## Quality Standards (100% Accuracy Required)

This database is **ground truth for AI training**. Errors are unacceptable.

### Acceptable Sources ONLY:
✅ Official state legislature websites
✅ Official statutory code databases (.gov)
✅ Official AG guidance documents (.gov)
✅ Official agency FOIA pages (.gov)

### PROHIBITED Sources:
❌ Perplexity AI or any AI summarization
❌ Wikipedia or collaborative wikis
❌ Legal blogs or commentary
❌ Third-party summaries
❌ News articles

**If in doubt about a citation → REJECT and request correction.**

## Emergency Stop

If you notice **systemic issues** (multiple jurisdictions with same type of error):

1. **PAUSE all agent work** immediately
2. **Document the pattern** you've discovered
3. **Update agent instructions** to prevent issue
4. **Request re-review** of all affected jurisdictions
5. **Resume** once pattern is corrected

## Completion

When all 52 jurisdictions are ✅ Complete:

1. All worktrees merged to main
2. Update `.claude/JURISDICTION_TRACKING.md` with final status
3. Tag release: `git tag v0.12.0-affirmative-rights`
4. Push to remote: `git push origin main --tags`
5. Celebrate! 🎉

## Quick Reference

**Review a jurisdiction:**
```bash
cd worktrees/affirmative/{jurisdiction}
cat data/v0.12/rights/{jurisdiction}-rights.json
```

**Approve and merge:**
```bash
cd /path/to/main
git merge verification/{jurisdiction}-affirmative
```

**Track progress:**
```bash
code .claude/JURISDICTION_TRACKING.md
```

**View all active work:**
```bash
git worktree list
```

**DO NOT delete worktrees** - keep for future updates!
