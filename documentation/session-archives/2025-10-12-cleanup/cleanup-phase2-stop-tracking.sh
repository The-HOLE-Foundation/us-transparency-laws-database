#!/bin/bash
# Phase 2: Stop tracking node_modules
# Safe operation - stops tracking without rewriting history

set -e  # Exit on error

echo "======================================"
echo "PHASE 2: Stop Tracking node_modules"
echo "======================================"
echo ""

# Create checkpoint
echo "Creating git checkpoint..."
git add -A
git commit -m "checkpoint: before removing node_modules from tracking" || echo "Nothing to commit"
git tag "cleanup-checkpoint-$(date +%Y%m%d-%H%M)"
echo "✓ Checkpoint created"
echo ""

# Check current status
echo "Current status:"
echo "  Files tracked in git: $(git ls-files | wc -l | tr -d ' ')"
echo "  node_modules files: $(git ls-files | grep -c node_modules || echo 0)"
echo ""

# Remove node_modules from tracking
echo "Removing node_modules from git tracking..."
if git ls-files | grep -q node_modules; then
    git rm -r --cached node_modules/
    echo "✓ node_modules removed from tracking"
else
    echo "✓ node_modules not currently tracked"
fi
echo ""

# Commit the change
echo "Committing change..."
git commit -m "Stop tracking node_modules (keep in history for compatibility)

- Updated .gitignore to exclude node_modules/
- Removed node_modules from git index
- Files remain in git history
- Local node_modules/ directory untouched
- Run 'npm install' to restore if needed

See: REPOSITORY_BLOAT_ANALYSIS.md"
echo "✓ Changes committed"
echo ""

# Show new status
echo "New status:"
echo "  Files tracked in git: $(git ls-files | wc -l | tr -d ' ')"
echo "  node_modules files: $(git ls-files | grep -c node_modules || echo 0)"
echo ""

echo "Next: Run cleanup-phase3-consolidate-data.sh to collect rights files"
