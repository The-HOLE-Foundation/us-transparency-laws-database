#!/bin/bash
# Phase 1: Fix .gitignore
# Safe operation - updates .gitignore to exclude critical files

set -e  # Exit on error

echo "======================================"
echo "PHASE 1: Fix .gitignore"
echo "======================================"
echo ""

# Backup current .gitignore
cp .gitignore .gitignore.backup
echo "✓ Backed up .gitignore to .gitignore.backup"

# Append comprehensive exclusions
cat >> .gitignore << 'EOF'

# Dependencies (CRITICAL - should never be in git)
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
package-lock.json

# Build outputs
dist/
build/
.next/
out/

# Caching
.cache/
.turbo/

# Vercel
.vercel/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Testing
coverage/
.nyc_output/

# Temporary files
*.tmp
tmp/
temp/

# Logs
*.log
logs/

# OS files
.DS_Store
Thumbs.db

# Session documents (archive these manually)
S-*-*.md
*_SESSION_*.md
EOF

echo "✓ Updated .gitignore with comprehensive exclusions"
echo ""

# Show what was added
echo "Added exclusions:"
echo "  - node_modules/"
echo "  - Build outputs (dist/, build/, .next/)"
echo "  - IDE files (.vscode/, .idea/)"
echo "  - Logs and temporary files"
echo "  - Session documents"
echo ""

echo "Next: Review the changes, then run cleanup-phase2-stop-tracking.sh"
