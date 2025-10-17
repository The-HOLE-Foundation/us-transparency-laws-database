#!/bin/bash
#
# Git Pre-Commit Hook Installer for Data Integrity Validation
# Installs hook that validates data against ground truth before allowing commits
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"
HOOK_FILE="$HOOKS_DIR/pre-commit"

echo "🔧 Installing Data Integrity Pre-Commit Hook..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if .git directory exists
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo "❌ Error: Not a git repository"
    echo "   Run this script from within the git repository"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Backup existing pre-commit hook if it exists
if [ -f "$HOOK_FILE" ]; then
    BACKUP_FILE="$HOOK_FILE.backup-$(date +%Y%m%d-%H%M%S)"
    echo "📦 Backing up existing pre-commit hook to: $BACKUP_FILE"
    mv "$HOOK_FILE" "$BACKUP_FILE"
fi

# Create the pre-commit hook
cat > "$HOOK_FILE" << 'EOF'
#!/bin/bash
#
# Data Integrity Validation Pre-Commit Hook
# Automatically validates data changes against ground truth
#

echo ""
echo "🔍 Running Data Integrity Validation..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get the project root
PROJECT_ROOT="$(git rev-parse --show-toplevel)"

# Run validation on staged files
python3 "$PROJECT_ROOT/scripts/validation/validate-against-ground-truth.py" --staged

VALIDATION_RESULT=$?

if [ $VALIDATION_RESULT -ne 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ COMMIT BLOCKED - Data integrity validation failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📋 Conflict report saved to: .validation-conflicts.json"
    echo ""
    echo "Next steps:"
    echo "  1. Review conflicts in .validation-conflicts.json"
    echo "  2. Choose resolution:"
    echo "     • Fix data to match ground truth, OR"
    echo "     • Update ground truth with official source verification"
    echo "  3. Re-run: git add [files] && git commit"
    echo ""
    echo "To bypass (NOT RECOMMENDED):"
    echo "  git commit --no-verify"
    echo ""
    exit 1
fi

echo ""
echo "✅ Data integrity validated - proceeding with commit"
echo ""

exit 0
EOF

# Make the hook executable
chmod +x "$HOOK_FILE"

echo "✅ Pre-commit hook installed successfully!"
echo ""
echo "📝 The hook will now run automatically before each commit"
echo "   and validate data changes against ground truth."
echo ""
echo "To test the hook:"
echo "  1. Make a change to a data file"
echo "  2. Run: git add [file]"
echo "  3. Run: git commit -m 'test'"
echo ""
echo "To bypass the hook (NOT RECOMMENDED):"
echo "  git commit --no-verify"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
