#!/bin/bash
# Hook: Maintain Momentum After TodoWrite
# Trigger: tool-post-call-hook
# Purpose: Remind Claude to keep moving if autonomous mode active

# Only activate if autonomous mode flag exists
if [ ! -f /tmp/claude-autonomous-mode-active ]; then
    exit 0
fi

# Check if TodoWrite was the tool just called
TOOL_NAME="$TOOL_NAME"
if [ "$TOOL_NAME" != "TodoWrite" ]; then
    exit 0
fi

# Output momentum reminder
cat <<'EOF'

⏩ AUTONOMOUS MODE: MOMENTUM CHECK

You just updated the todo list while in autonomous mode.

NEXT ACTION: Move IMMEDIATELY to next pending task.

- Don't ask "want me to continue?"
- Don't stop to report interim progress
- Don't wait for approval
- Just continue to next task

Check your todo list: Any pending tasks? → Start working on first one NOW.

EOF
