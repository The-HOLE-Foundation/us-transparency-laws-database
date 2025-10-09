#!/bin/bash
# create-all-worktrees.sh - Create worktrees for all 52 jurisdictions
# This creates one worktree per jurisdiction for parallel data collection work

set -e  # Exit on error

echo "Creating worktrees for all 52 jurisdictions..."
echo "This will take a moment..."
echo ""

# Counter for progress
count=0
total=52

# Get all jurisdiction directories
for jurisdiction_dir in data/states/*; do
    jurisdiction=$(basename "$jurisdiction_dir")
    worktree_path="worktrees/affirmative/$jurisdiction"
    branch_name="verification/$jurisdiction-affirmative"

    # Skip if worktree already exists
    if [ -d "$worktree_path" ]; then
        echo "⏭️  Skipping $jurisdiction (already exists)"
        count=$((count + 1))
        continue
    fi

    # Create worktree
    git worktree add "$worktree_path" -b "$branch_name" 2>&1 | grep -v "^Preparing" || true
    count=$((count + 1))
    echo "✅ [$count/$total] Created: $jurisdiction"
done

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ All worktrees created!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "View all worktrees:"
echo "  git worktree list"
echo ""
echo "Start work on a jurisdiction:"
echo "  cd worktrees/affirmative/{jurisdiction}"
echo ""
echo "Track progress:"
echo "  cat .claude/JURISDICTION_TRACKING.md"
