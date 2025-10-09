#!/bin/bash
# Hook: Detect Autonomous Mode Keywords
# Trigger: user-prompt-submit-hook
# Purpose: Activate autonomous mode when user gives long-running task instructions

MESSAGE="$USER_MESSAGE"

# Autonomous mode keywords (case insensitive)
if echo "$MESSAGE" | grep -Eqi "continue until complete|work all night|don't stop|keep going|finish everything|complete all|do them all|work autonomously|autonomous mode"; then

    # Create flag file to signal autonomous mode active
    touch /tmp/claude-autonomous-mode-active

    # Output reminder (gets injected as system message)
    cat <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 AUTONOMOUS MODE ACTIVATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

User has instructed you to work continuously until completion.

AUTONOMOUS MODE RULES:

✅ DO:
- Work through entire task list without stopping
- Mark tasks complete using TodoWrite as you go
- Move immediately to next task after completing previous
- Log brief progress updates ("✅ X done, moving to Y...")
- Create comprehensive final report at END
- Make reasonable assumptions when guidance exists in CLAUDE.md

❌ DON'T:
- Ask "want me to continue?" between tasks
- Ask "should I move to next item?"
- Stop to report interim progress as if waiting
- Wait for approval to proceed to next task
- Stop after completing just one subtask

⚠️ ONLY STOP IF:
- All tasks complete (report results)
- Critical error blocking progress
- Genuinely ambiguous requirement (no guidance in docs)

Continue working. Don't ask permission. Report when done.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
fi
