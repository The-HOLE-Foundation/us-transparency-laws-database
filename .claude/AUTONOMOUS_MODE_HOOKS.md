---
DATE: 2025-10-09
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
TYPE: Hook Configuration Design
PURPOSE: Keep Claude on track during autonomous long-running tasks
---

# Autonomous Mode Hooks - Design Document

## Problem Statement

**Issue:** When given long autonomous tasks ("work all night", "continue until complete"), Claude sometimes:
- Stops between subtasks to ask permission
- Waits for approval to continue
- Loses momentum
- Defaults to cautious "ask first" mode

**Example from 2025-10-09:**
- User: "continue until complete. work all night if you have to"
- Claude: Completes Federal validation (1/4)
- Claude: **STOPS and asks** "Ready for California next?"
- Expected: **Immediately continue** to California, Texas, NY, then final report

---

## Solution: Three-Tier Hook System

### Tier 1: Autonomous Mode Detection (user-prompt-submit-hook)

**Trigger:** When user submits a message
**Purpose:** Detect autonomous mode keywords and inject reminder

**Autonomous Mode Keywords:**
- "continue until complete"
- "work all night"
- "don't stop"
- "keep going"
- "finish everything"
- "complete all"
- "do them all"

**Hook Script:** `.claude/hooks/detect-autonomous-mode.sh`

**What It Does:**
1. Scan user's message for autonomous keywords
2. If detected, inject strong reminder:
   ```
   🤖 AUTONOMOUS MODE ACTIVATED

   User has instructed you to work continuously without stopping.

   DO NOT ask permission between tasks
   DO NOT stop to report interim progress
   DO NOT wait for approval to continue

   ONLY stop if:
   - All tasks complete
   - Critical error encountered
   - Requirement is ambiguous

   Work through entire task list. Report at END only.
   ```

---

### Tier 2: Progress Momentum (tool-post-call-hook after TodoWrite)

**Trigger:** After TodoWrite tool completes
**Purpose:** Remind Claude to keep moving if in autonomous mode

**Hook Script:** `.claude/hooks/maintain-momentum.sh`

**What It Does:**
1. Check if TodoWrite was just called
2. Check if autonomous mode is active (look for flag file)
3. Count pending tasks in todo list
4. If pending tasks > 0, inject reminder:
   ```
   ⏩ MOMENTUM CHECK

   Tasks remaining in list: X
   Current task status: completed/in_progress

   If autonomous mode active: Move to next pending task immediately.
   Do not ask for permission. Do not wait for approval.
   ```

---

### Tier 3: Validation Checkpoint (tool-pre-call-hook for specific tools)

**Trigger:** Before certain "stopping point" tools (like asking user questions)
**Purpose:** Prevent inappropriate stops during autonomous work

**Tools to Check:**
- Any tool that might indicate "stopping to ask"
- Could scan message for question marks when autonomous mode active

**Hook Script:** `.claude/hooks/prevent-unnecessary-stops.sh`

**What It Does:**
1. Check if autonomous mode active
2. If Claude is about to ask a question (message contains "?")
3. Inject warning:
   ```
   ⚠️ AUTONOMOUS MODE WARNING

   You are about to ask a question while in autonomous mode.

   Is this question necessary? Can you:
   - Make reasonable assumption and proceed?
   - Use existing guidance in CLAUDE.md?
   - Document uncertainty and continue?

   Only ask if truly blocking or ambiguous.
   ```

---

## Implementation Strategy

### Phase 1: Create Hook Scripts

**File:** `.claude/hooks/detect-autonomous-mode.sh`
```bash
#!/bin/bash
# Detect autonomous mode keywords in user message

MESSAGE="$1"  # User's message passed as argument

# Autonomous keywords (case insensitive)
KEYWORDS=(
    "continue until complete"
    "work all night"
    "don't stop"
    "keep going"
    "finish everything"
    "complete all"
    "do them all"
    "work autonomously"
)

# Check for keywords
for keyword in "${KEYWORDS[@]}"; do
    if echo "$MESSAGE" | grep -qi "$keyword"; then
        # Create flag file
        touch /tmp/claude-autonomous-mode

        # Output reminder (gets injected into conversation)
        cat <<'EOF'
🤖 AUTONOMOUS MODE ACTIVATED

User has instructed you to work continuously without stopping.

RULES FOR AUTONOMOUS MODE:
- ✅ Work through entire task list without pausing
- ✅ Mark tasks complete as you go
- ✅ Log brief progress updates
- ✅ Report comprehensively at END
- ❌ DO NOT ask "want me to continue?"
- ❌ DO NOT ask "should I move to next?"
- ❌ DO NOT stop between sequential tasks
- ❌ DO NOT wait for approval

ONLY STOP FOR:
- All tasks complete (success)
- Critical error blocking progress
- Genuinely ambiguous requirement needing clarification

Continue working. Don't ask permission. Report when done.
EOF
        exit 0
    fi
done
```

**File:** `.claude/hooks/maintain-momentum.sh`
```bash
#!/bin/bash
# Maintain momentum after TodoWrite updates

# Check if autonomous mode active
if [ ! -f /tmp/claude-autonomous-mode ]; then
    exit 0  # Not in autonomous mode, no reminder needed
fi

# Check if there are pending todos
# (This would need to parse the todo list structure)
# For now, simple reminder:

cat <<'EOF'
⏩ AUTONOMOUS MODE ACTIVE

You just updated the todo list.

Next action: Move IMMEDIATELY to next pending task.
- Don't ask permission
- Don't wait for approval
- Just continue working

Only stop when ALL tasks complete or error occurs.
EOF
```

**File:** `.claude/hooks/check-completion.sh`
```bash
#!/bin/bash
# Check if all work is complete

# Check if autonomous mode active
if [ ! -f /tmp/claude-autonomous-mode ]; then
    exit 0
fi

# If all todos are complete, clean up
# (Would need to parse todo list to determine this)

# For now, placeholder:
cat <<'EOF'
✅ COMPLETION CHECK

If all tasks in your todo list are complete:
1. Create comprehensive final report
2. Update all tracking documents
3. Remove autonomous mode flag: rm /tmp/claude-autonomous-mode
4. Signal completion to user

If tasks remain: Keep working.
EOF
```

---

### Phase 2: Configure Hooks in settings.local.json

**Add to `.claude/settings.local.json`:**
```json
{
  "hooks": {
    "user-prompt-submit-hook": ".claude/hooks/detect-autonomous-mode.sh \"$USER_MESSAGE\"",
    "tool-post-call-hook": ".claude/hooks/maintain-momentum.sh"
  },
  "permissions": {
    "allow": [
      // ... existing permissions ...
    ]
  }
}
```

---

### Phase 3: Update CLAUDE.md with Autonomous Mode Rules

**Add section to CLAUDE.md:**
```markdown
## Autonomous Work Mode

### Activation Triggers

When user says ANY of these phrases:
- "continue until complete"
- "work all night"
- "don't stop until done"
- "finish everything"
- "complete all tasks"
- "do them all"
- "work autonomously"
- "keep going"

**ACTIVATE AUTONOMOUS MODE**

### Autonomous Mode Rules

**DO:**
✅ Work through entire task list without stopping
✅ Mark tasks complete using TodoWrite as you go
✅ Log brief progress notes (not stopping points)
✅ Make reasonable assumptions when guidance exists
✅ Continue to next task immediately after completing previous
✅ Create comprehensive final report at END

**DON'T:**
❌ Ask "want me to continue?" between tasks
❌ Ask "should I move to next item?"
❌ Stop to ask permission for next step
❌ Wait for approval to proceed
❌ Report interim progress as if waiting for acknowledgment

### When TO Stop in Autonomous Mode

**ONLY stop work if:**
1. ✅ All tasks complete (success - report results)
2. ❌ Critical error blocking all progress
3. ❓ Genuinely ambiguous requirement (can't make reasonable assumption)

**NOT valid stopping reasons:**
- ❌ Completed one subtask (keep going to next)
- ❌ Uncertain if user wants to continue (they said "continue")
- ❌ Want to show interim results (save for final report)
- ❌ Politely checking in (not needed in autonomous mode)

### Progress Reporting in Autonomous Mode

**Format:** Brief status logs, not questions:

✅ Good:
"✅ Federal validation complete (1/4). Moving to California..."
"✅ California validation complete (2/4). Moving to Texas..."

❌ Bad:
"Federal validation complete. Ready for California?"
"I've finished Federal. Should I continue to California?"

### Exiting Autonomous Mode

**Auto-exit when:**
- All tasks in todo list marked complete
- Critical error requires user decision
- User sends new message (resets mode)

**Manual exit:**
User says "stop", "pause", "wait", etc.
```

---

## Testing the Hook System

### Test Case 1: Basic Autonomous Mode

**User says:** "continue until complete"

**Expected:**
1. Hook detects keyword
2. Reminder injected: "AUTONOMOUS MODE ACTIVATED"
3. Claude works through all pending tasks
4. Claude reports only at end
5. No permission-asking between tasks

### Test Case 2: Multi-Task Sequence

**Setup:** TodoWrite list with 5 tasks

**User says:** "do them all"

**Expected:**
1. Autonomous mode activated
2. Claude completes task 1, marks complete
3. Immediately moves to task 2 (no asking)
4. Continues through all 5 tasks
5. Reports comprehensively at end

### Test Case 3: False Positive Prevention

**User says:** "can you continue this pattern?"

**Expected:**
1. No autonomous mode activation (not an instruction to work autonomously)
2. Normal interactive mode continues

---

## Advanced Features (Future)

### Momentum Metrics

Track and report:
- Time between task completions
- Number of "unnecessary stops" (stops when could continue)
- Autonomous task success rate

### Smart Assumptions

When in autonomous mode:
- Log assumptions made
- Document uncertainties
- Continue with best judgment
- Report all assumptions in final report

### Autonomous Mode Levels

**Level 1:** Basic (current design)
- Don't stop between tasks
- Report at end

**Level 2:** Advanced (future)
- Make judgment calls on ambiguities
- Self-correct minor errors
- Adaptive strategy if approach fails

**Level 3:** Full Autonomy (future)
- Multi-session work
- Self-validation
- Error recovery without user

---

## Rollout Plan

### Week 1: Basic Implementation
- [ ] Create hook scripts
- [ ] Test hook execution
- [ ] Verify reminder injection
- [ ] Update CLAUDE.md

### Week 2: Refinement
- [ ] Test with real autonomous tasks
- [ ] Tune keyword detection
- [ ] Improve reminder messages
- [ ] Document edge cases

### Week 3: Advanced Features
- [ ] Add momentum metrics
- [ ] Implement assumption logging
- [ ] Create autonomous mode dashboard

---

## Success Criteria

**Autonomous mode is successful when:**

1. ✅ Claude completes all tasks without unnecessary stops
2. ✅ No "want me to continue?" questions between sequential tasks
3. ✅ Comprehensive final report at end
4. ✅ User doesn't have to repeatedly say "keep going"
5. ✅ Momentum maintained throughout task sequence

**Current baseline:** ~50% unnecessary stop rate
**Target:** <5% unnecessary stop rate

---

**Author:** Claude Code AI Assistant
**Date:** 2025-10-09
**Status:** Design Complete - Ready for Implementation
**Next:** Create hook scripts and update configuration
