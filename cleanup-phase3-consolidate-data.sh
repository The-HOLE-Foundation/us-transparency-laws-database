#!/bin/bash
# Phase 3: Consolidate affirmative rights data
# Safe operation - creates copies, doesn't delete originals

set -e  # Exit on error

echo "======================================"
echo "PHASE 3: Consolidate Rights Data"
echo "======================================"
echo ""

# Create collection directory
mkdir -p data/v0.12/affirmative-rights-consolidated
echo "✓ Created collection directory"
echo ""

# Copy all rights files from worktrees
echo "Collecting rights files from worktrees..."
count=0
for dir in worktrees/affirmative/*/; do
    jurisdiction=$(basename "$dir")
    source_file="$dir/data/v0.12/affirmative-rights/${jurisdiction}-rights.json"

    if [ -f "$source_file" ]; then
        cp "$source_file" "data/v0.12/affirmative-rights-consolidated/"
        size=$(du -h "$source_file" | cut -f1)
        echo "  ✓ $jurisdiction ($size)"
        count=$((count + 1))
    fi
done
echo ""
echo "✓ Collected $count rights files"
echo ""

# List what was collected
echo "Collected files:"
ls -lh data/v0.12/affirmative-rights-consolidated/ | tail -n +2
echo ""

# Calculate total size
total_size=$(du -sh data/v0.12/affirmative-rights-consolidated/ | cut -f1)
echo "Total size: $total_size"
echo ""

# Create inventory
echo "Creating inventory..."
cat > data/v0.12/affirmative-rights-consolidated/INVENTORY.md << 'EOF'
# Affirmative Rights Data Inventory

**Collection Date**: $(date +%Y-%m-%d)
**Source**: Worktrees (verification branches)
**Total Files**: $count

## Files Collected

EOF

for file in data/v0.12/affirmative-rights-consolidated/*.json; do
    if [ -f "$file" ]; then
        basename=$(basename "$file")
        size=$(du -h "$file" | cut -f1)
        echo "- $basename ($size)" >> data/v0.12/affirmative-rights-consolidated/INVENTORY.md
    fi
done

echo "✓ Inventory created"
echo ""

echo "Verification:"
echo "  Expected: 52 jurisdictions"
echo "  Collected: $count files"
echo "  Missing: $((52 - count)) jurisdictions"
echo ""

if [ $count -lt 52 ]; then
    echo "Missing jurisdictions (need to verify):"
    all_jurisdictions="alabama alaska arizona arkansas california colorado connecticut delaware district-of-columbia federal florida georgia hawaii idaho illinois indiana iowa kansas kentucky louisiana maine maryland massachusetts michigan minnesota mississippi missouri montana nebraska nevada new-hampshire new-jersey new-mexico new-york north-carolina north-dakota ohio oklahoma oregon pennsylvania rhode-island south-carolina south-dakota tennessee texas utah vermont virginia washington west-virginia wisconsin wyoming"

    for jurisdiction in $all_jurisdictions; do
        if [ ! -f "data/v0.12/affirmative-rights-consolidated/${jurisdiction}-rights.json" ]; then
            echo "  ✗ $jurisdiction"
        fi
    done
    echo ""
fi

echo "Next: Review collected files, then run cleanup-phase4-clean-worktrees.sh"
