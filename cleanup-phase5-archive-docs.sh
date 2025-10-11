#!/bin/bash
# Phase 5: Archive obsolete documentation
# Safe operation - moves files, doesn't delete

set -e  # Exit on error

echo "======================================"
echo "PHASE 5: Archive Documentation"
echo "======================================"
echo ""

# Create archive directory
archive_dir=".archive/2025-10-11-cleanup"
mkdir -p "$archive_dir"
echo "✓ Created archive directory: $archive_dir"
echo ""

# Archive session summaries and status reports
echo "Archiving session documents..."
for file in SESSION_*.md S-*.md *_STATUS_*.md CURRENT_STATUS*.md FINAL_STATUS*.md; do
    if [ -f "$file" ]; then
        mv "$file" "$archive_dir/"
        echo "  ✓ Archived: $file"
    fi
done
echo ""

# Archive completed project documents
echo "Archiving completed project documents..."
for file in WORKTREE_OVERVIEW.md REPOSITORY_REORGANIZATION_PLAN.md REORGANIZATION_COMPLETE.md; do
    if [ -f "$file" ]; then
        mv "$file" "$archive_dir/"
        echo "  ✓ Archived: $file"
    fi
done
echo ""

# Archive validation reports (keep latest, archive old)
echo "Archiving old validation reports..."
for file in FEDERAL_VALIDATION_REPORT.md V0.12_*.md DC_STATUTE_COMPLETE.md; do
    if [ -f "$file" ]; then
        mv "$file" "$archive_dir/"
        echo "  ✓ Archived: $file"
    fi
done
echo ""

# Move technical docs to documentation/
echo "Moving technical docs to documentation/ directory..."
for file in AUTONOMOUS_MODE_IMPLEMENTATION.md PRODUCTION_DEPLOYMENT_SUMMARY.md PROJECT_ECOSYSTEM.md NEON_MIGRATION_SUCCESS.md; do
    if [ -f "$file" ]; then
        mv "$file" documentation/
        echo "  ✓ Moved: $file → documentation/"
    fi
done
echo ""

# Create archive inventory
echo "Creating archive inventory..."
cat > "$archive_dir/ARCHIVE_INVENTORY.md" << 'EOF'
# Archive Inventory

**Archive Date**: $(date +%Y-%m-%d)
**Archive Reason**: Repository cleanup - consolidating obsolete documentation

## Contents

This archive contains:
- Session summaries and status reports
- Completed project documentation
- Old validation reports

## Files Archived

EOF

ls -lh "$archive_dir"/*.md | awk '{print "- " $9 " (" $5 ")"}' >> "$archive_dir/ARCHIVE_INVENTORY.md"

echo "✓ Archive inventory created"
echo ""

# Show what remains in root
echo "======================================"
echo "REMAINING ROOT DOCUMENTATION"
echo "======================================"
echo ""
echo "Core files (should remain in root):"
ls -1 *.md 2>/dev/null | grep -E "^(README|CHANGELOG|CLAUDE|CONTRIBUTING|LICENSE)" || echo "  (standard files not found)"
echo ""
echo "Other documentation:"
ls -1 *.md 2>/dev/null | grep -v -E "^(README|CHANGELOG|CLAUDE|CONTRIBUTING|LICENSE)" || echo "  (none - good!)"
echo ""

echo "Archive location: $archive_dir"
echo "Archived files: $(ls -1 $archive_dir/*.md 2>/dev/null | wc -l | tr -d ' ')"
echo ""

echo "Next: Review changes and commit, then run check-repository-health.sh"
