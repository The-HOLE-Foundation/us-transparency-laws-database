#!/bin/bash
# worktree-cycle.sh - Manage worktree lifecycle for parallel jurisdiction work
# Usage: ./scripts/worktree-cycle.sh {jurisdiction} {create|merge|cleanup|cycle}

set -e  # Exit on error

JURISDICTION=$1
ACTION=$2
WORKTREE_PATH="worktrees/affirmative/$JURISDICTION"
BRANCH_NAME="verification/$JURISDICTION-affirmative"

if [ -z "$JURISDICTION" ] || [ -z "$ACTION" ]; then
    echo "Usage: ./scripts/worktree-cycle.sh {jurisdiction} {create|merge|cleanup|cycle}"
    echo ""
    echo "Actions:"
    echo "  create  - Create new worktree for jurisdiction"
    echo "  merge   - Merge jurisdiction work to main"
    echo "  cleanup - Remove worktree and delete branch"
    echo "  cycle   - Complete cycle: merge + cleanup"
    echo ""
    echo "Example: ./scripts/worktree-cycle.sh illinois create"
    exit 1
fi

case $ACTION in
    create)
        echo "Creating worktree for $JURISDICTION..."
        git worktree add $WORKTREE_PATH -b $BRANCH_NAME
        echo "✅ Created worktree at: $WORKTREE_PATH"
        echo "✅ Branch: $BRANCH_NAME"
        echo ""
        echo "To start work:"
        echo "  cd $WORKTREE_PATH"
        ;;

    merge)
        echo "Merging $JURISDICTION work to main..."

        # Verify we're on main branch
        CURRENT_BRANCH=$(git branch --show-current)
        if [ "$CURRENT_BRANCH" != "main" ]; then
            echo "❌ Error: Must be on main branch to merge"
            echo "Current branch: $CURRENT_BRANCH"
            exit 1
        fi

        git merge $BRANCH_NAME
        echo "✅ Merged $BRANCH_NAME to main"
        ;;

    cleanup)
        echo "Cleaning up $JURISDICTION worktree..."

        # Remove worktree
        if [ -d "$WORKTREE_PATH" ]; then
            git worktree remove $WORKTREE_PATH
            echo "✅ Removed worktree: $WORKTREE_PATH"
        else
            echo "⚠️  Worktree not found: $WORKTREE_PATH"
        fi

        # Delete branch
        if git show-ref --verify --quiet refs/heads/$BRANCH_NAME; then
            git branch -d $BRANCH_NAME
            echo "✅ Deleted branch: $BRANCH_NAME"
        else
            echo "⚠️  Branch not found: $BRANCH_NAME"
        fi
        ;;

    cycle)
        echo "Running complete cycle for $JURISDICTION..."

        # Verify we're on main branch
        CURRENT_BRANCH=$(git branch --show-current)
        if [ "$CURRENT_BRANCH" != "main" ]; then
            echo "❌ Error: Must be on main branch to cycle"
            echo "Current branch: $CURRENT_BRANCH"
            exit 1
        fi

        # Merge
        echo "Step 1/2: Merging..."
        git merge $BRANCH_NAME
        echo "✅ Merged $BRANCH_NAME to main"

        # Cleanup
        echo "Step 2/2: Cleaning up..."
        if [ -d "$WORKTREE_PATH" ]; then
            git worktree remove $WORKTREE_PATH
            echo "✅ Removed worktree"
        fi

        if git show-ref --verify --quiet refs/heads/$BRANCH_NAME; then
            git branch -d $BRANCH_NAME
            echo "✅ Deleted branch"
        fi

        echo ""
        echo "✅ Complete! $JURISDICTION has been cycled."
        echo "Ready to create worktree for next jurisdiction."
        ;;

    list)
        echo "Active worktrees:"
        git worktree list
        ;;

    *)
        echo "❌ Unknown action: $ACTION"
        echo "Valid actions: create, merge, cleanup, cycle, list"
        exit 1
        ;;
esac
