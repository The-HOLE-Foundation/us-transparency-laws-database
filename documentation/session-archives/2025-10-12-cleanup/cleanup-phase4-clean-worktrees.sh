#!/bin/bash
# Phase 4: Clean up worktrees
# CAUTION: This deletes files from worktrees (but data already backed up in phase 3)

set -e  # Exit on error

echo "======================================"
echo "PHASE 4: Clean Up Worktrees"
echo "======================================"
echo ""

# Safety check
echo "⚠️  WARNING: This will delete files from worktrees"
echo "   - node_modules/"
echo "   - documentation/"
echo "   - .claude/"
echo "   - supabase/"
echo "   - All *.md files"
echo ""
echo "   Only jurisdiction-specific rights files will remain"
echo ""
read -p "Have you verified data consolidation in phase 3? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted. Run cleanup-phase3-consolidate-data.sh first."
    exit 1
fi
echo ""

# Create checkpoint
echo "Creating git checkpoint..."
git add -A
git commit -m "checkpoint: before cleaning worktrees" || echo "Nothing to commit"
git tag "cleanup-checkpoint-worktrees-$(date +%Y%m%d-%H%M)"
echo "✓ Checkpoint created"
echo ""

# Test on ONE worktree first
echo "Testing cleanup on ONE worktree first..."
echo "  Testing: alabama"
test_dir="worktrees/affirmative/alabama"

if [ -d "$test_dir" ]; then
    echo "  Before cleanup: $(du -sh $test_dir 2>/dev/null | cut -f1)"

    cd "$test_dir"

    # Remove unnecessary directories
    [ -d "node_modules" ] && rm -rf node_modules/ && echo "    ✓ Removed node_modules"
    [ -d "documentation" ] && rm -rf documentation/ && echo "    ✓ Removed documentation"
    [ -d ".claude" ] && rm -rf .claude/ && echo "    ✓ Removed .claude"
    [ -d "supabase" ] && rm -rf supabase/ && echo "    ✓ Removed supabase"
    [ -d "dev" ] && rm -rf dev/ && echo "    ✓ Removed dev"
    [ -d "scripts" ] && rm -rf scripts/ && echo "    ✓ Removed scripts"
    [ -d ".github" ] && rm -rf .github/ && echo "    ✓ Removed .github"
    [ -d ".vscode" ] && rm -rf .vscode/ && echo "    ✓ Removed .vscode"
    [ -d "archive" ] && rm -rf archive/ && echo "    ✓ Removed archive"

    # Remove markdown files (keep only rights data)
    find . -maxdepth 1 -name "*.md" -type f -delete 2>/dev/null && echo "    ✓ Removed *.md files"

    # Remove config files
    [ -f ".eslintrc.json" ] && rm -f .eslintrc.json
    [ -f ".prettierrc.json" ] && rm -f .prettierrc.json
    [ -f "package.json" ] && rm -f package.json
    [ -f "package-lock.json" ] && rm -f package-lock.json

    cd - > /dev/null
    echo "  After cleanup: $(du -sh $test_dir 2>/dev/null | cut -f1)"
    echo ""

    # Verify worktree still works
    echo "  Verifying git functionality..."
    cd "$test_dir"
    if git status > /dev/null 2>&1; then
        echo "    ✓ Git status works"
    else
        echo "    ✗ Git status FAILED"
        exit 1
    fi

    if git branch > /dev/null 2>&1; then
        echo "    ✓ Git branch works"
    else
        echo "    ✗ Git branch FAILED"
        exit 1
    fi
    cd - > /dev/null
    echo ""
fi

echo "Test cleanup successful!"
echo ""
read -p "Continue with all other worktrees? (yes/no): " confirm_all

if [ "$confirm_all" != "yes" ]; then
    echo "Stopping. Test worktree (alabama) has been cleaned."
    echo "Review and run again to clean remaining worktrees."
    exit 0
fi
echo ""

# Clean all remaining worktrees
echo "Cleaning all worktrees..."
count=0
for dir in worktrees/affirmative/*/; do
    jurisdiction=$(basename "$dir")

    # Skip alabama (already done)
    if [ "$jurisdiction" = "alabama" ]; then
        continue
    fi

    echo "  Cleaning: $jurisdiction"
    before_size=$(du -sh "$dir" 2>/dev/null | cut -f1)

    cd "$dir"

    # Remove unnecessary directories
    [ -d "node_modules" ] && rm -rf node_modules/
    [ -d "documentation" ] && rm -rf documentation/
    [ -d ".claude" ] && rm -rf .claude/
    [ -d "supabase" ] && rm -rf supabase/
    [ -d "dev" ] && rm -rf dev/
    [ -d "scripts" ] && rm -rf scripts/
    [ -d ".github" ] && rm -rf .github/
    [ -d ".vscode" ] && rm -rf .vscode/
    [ -d "archive" ] && rm -rf archive/

    # Remove markdown files
    find . -maxdepth 1 -name "*.md" -type f -delete 2>/dev/null

    # Remove config files
    [ -f ".eslintrc.json" ] && rm -f .eslintrc.json
    [ -f ".prettierrc.json" ] && rm -f .prettierrc.json
    [ -f "package.json" ] && rm -f package.json
    [ -f "package-lock.json" ] && rm -f package-lock.json

    cd - > /dev/null

    after_size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    echo "    Before: $before_size → After: $after_size"

    count=$((count + 1))
done
echo ""
echo "✓ Cleaned $count additional worktrees"
echo ""

# Final summary
echo "======================================"
echo "CLEANUP SUMMARY"
echo "======================================"
echo ""
echo "Total worktrees cleaned: $((count + 1))"
echo "Worktrees size before: 4.5 GB"
echo "Worktrees size after: $(du -sh worktrees/ 2>/dev/null | cut -f1)"
echo ""
echo "Saved: ~4.4 GB"
echo ""

echo "Next: Run cleanup-phase5-archive-docs.sh to organize documentation"
