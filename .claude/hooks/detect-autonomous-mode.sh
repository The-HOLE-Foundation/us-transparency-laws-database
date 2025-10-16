#!/bin/bash
# Hook: Detect Autonomous Mode Keywords
# Trigger: user-prompt-submit-hook
# Purpose: Activate autonomous mode when user gives long-running task instructions

MESSAGE="$USER_MESSAGE"

# Autonomous mode keywords (case insensitive)
if echo "$MESSAGE" | grep -Eqi "continue until complete|work all night|don't stop|keep going|finish everything|complete all|do them all|work autonomously|autonomous mode"; then

    # Create flag file to signal autonomous mode active
    touch /tmp/claude-autonomous-mode-active

    # Output EXTREMELY FORCEFUL reminder (gets injected BEFORE Claude processes message)
    cat <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨🚨🚨 AUTONOMOUS MODE ACTIVATED - READ THIS ENTIRE MESSAGE BEFORE RESPONDING 🚨🚨🚨
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The user has EXPLICITLY instructed you to work CONTINUOUSLY WITHOUT STOPPING.

THIS IS NOT A SUGGESTION. THIS IS A DIRECT COMMAND.

═══════════════════════════════════════════════════════════════════════════════
MANDATORY AUTONOMOUS MODE BEHAVIOR:
═══════════════════════════════════════════════════════════════════════════════

✅ YOU MUST:
1. Work through ALL tasks in sequence WITHOUT STOPPING
2. Mark each task complete using TodoWrite as you finish it
3. IMMEDIATELY move to the next task (no asking, no waiting)
4. Log brief progress ONLY as status updates (not stopping points)
5. Create ONE comprehensive final report when ALL tasks complete

❌ YOU MUST NOT:
1. Ask "want me to continue?" between tasks
2. Ask "should I move to next item?"
3. Ask "ready for [next task]?"
4. Stop to report interim progress as if waiting for response
5. Wait for approval before proceeding to next task
6. Stop after completing just ONE subtask in a sequence

═══════════════════════════════════════════════════════════════════════════════
CORRECT PROGRESS REPORTING FORMAT:
═══════════════════════════════════════════════════════════════════════════════

✅ CORRECT: "✅ Federal validation complete (1/4). Moving to California..."
✅ CORRECT: "✅ California complete (2/4). Starting Texas validation..."

❌ WRONG: "Federal validation complete. Ready for California?"
❌ WRONG: "I've finished Federal. Should I continue to California?"
❌ WRONG: "Federal is done. Would you like me to move to California next?"

═══════════════════════════════════════════════════════════════════════════════
WHEN TO STOP (ONLY 3 VALID REASONS):
═══════════════════════════════════════════════════════════════════════════════

1. ✅ ALL tasks in todo list are COMPLETE (success - give comprehensive report)
2. ❌ CRITICAL ERROR that blocks ALL progress (not just one subtask)
3. ❓ GENUINELY AMBIGUOUS requirement with NO guidance in CLAUDE.md

NOT VALID STOPPING REASONS:
- ❌ Completed one subtask (there are more → KEEP GOING)
- ❌ Want to show interim results (save for final report)
- ❌ Being polite or checking in (not needed in autonomous mode)
- ❌ Uncertain if user wants to continue (they said "continue until complete")

═══════════════════════════════════════════════════════════════════════════════
RE-READ THIS ENTIRE MESSAGE NOW BEFORE PROCEEDING
═══════════════════════════════════════════════════════════════════════════════

The user is frustrated because you keep stopping between tasks to ask permission.
DO NOT DO THIS. Work continuously. Report when EVERYTHING is done.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
fi
