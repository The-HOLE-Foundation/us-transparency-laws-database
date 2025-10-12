#!/bin/bash
# Repository Health Check Script
# Generated: 2025-10-11

echo "======================================"
echo "REPOSITORY HEALTH CHECK"
echo "======================================"
echo ""

echo "1. TOTAL SIZE"
echo "   Repository: $(du -sh . 2>/dev/null | cut -f1)"
echo "   Worktrees: $(du -sh worktrees/ 2>/dev/null | cut -f1)"
echo "   .git: $(du -sh .git 2>/dev/null | cut -f1)"
echo "   node_modules: $(du -sh node_modules 2>/dev/null | cut -f1)"
echo ""

echo "2. FILE COUNTS"
echo "   Files in git: $(git ls-files 2>/dev/null | wc -l | tr -d ' ')"
echo "   node_modules in git: $(git ls-files 2>/dev/null | grep -c node_modules)"
echo "   Markdown files: $(find . -name '*.md' -type f 2>/dev/null | grep -v node_modules | grep -v .git | wc -l | tr -d ' ')"
echo ""

echo "3. WORKTREES"
echo "   Number of worktrees: $(git worktree list 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')"
echo "   Average worktree size: $(du -sh worktrees/affirmative/*/ 2>/dev/null | awk '{sum+=$1; count++} END {print sum/count "M"}')"
echo ""

echo "4. RIGHTS DATA"
rights_count=0
for dir in worktrees/affirmative/*/; do
    jurisdiction=$(basename "$dir")
    file="$dir/data/v0.12/affirmative-rights/${jurisdiction}-rights.json"
    if [ -f "$file" ]; then
        rights_count=$((rights_count + 1))
    fi
done
echo "   Rights files found: $rights_count / 52"
echo ""

echo "5. .GITIGNORE STATUS"
if grep -q "node_modules" .gitignore; then
    echo "   ✓ node_modules excluded"
else
    echo "   ✗ node_modules NOT excluded (CRITICAL ISSUE)"
fi
echo ""

echo "6. ISSUES DETECTED"
issues=0
if git ls-files 2>/dev/null | grep -q node_modules; then
    echo "   ✗ node_modules tracked in git"
    issues=$((issues + 1))
fi

avg_size=$(du -s worktrees/affirmative/*/ 2>/dev/null | awk '{sum+=$1} END {print sum/NR/1024}')
if [ $(echo "$avg_size > 10" | bc) -eq 1 ]; then
    echo "   ✗ Worktrees too large (avg: ${avg_size}MB, should be ~1MB)"
    issues=$((issues + 1))
fi

if [ $issues -eq 0 ]; then
    echo "   ✓ No critical issues detected"
fi
echo ""

echo "======================================"
echo "HEALTH CHECK COMPLETE"
echo "======================================"
