---
DATE: 2025-10-07
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Git Branch Merge Strategy
VERSION: v0.11.1
---

# Branch Merge Strategy: Development → Main

## Current Situation Analysis

### Branch Divergence
```bash
git diff --stat main origin/Development
# Result: 174 files changed, 273 insertions(+), 38559 deletions(-)
```

**The branches are VERY different**:
- **Main branch**: Contains v0.11.1 Supabase integration work (migrations, scripts, documentation)
- **Development branch**: Contains v0.11.0 data release (52 jurisdictions, process maps)

### What Each Branch Has

**Main Branch (Current)**:
- ✅ Supabase migrations (7 migration files)
- ✅ Import scripts (smart-import.js, verify-schema.js)
- ✅ v0.11.1 documentation (Supabase integration docs)
- ✅ TypeScript types (types/supabase.ts)
- ✅ Updated CLAUDE.md, README.md, VERSION.md (v0.11.1)
- ✅ Production deployment documentation
- ❌ Missing: v0.11.0 JSON data files
- ❌ Missing: Process maps
- ❌ Missing: Holiday matrix and statute references

**Development Branch (origin/Development)**:
- ✅ All 52 jurisdiction JSON files (releases/v0.11.0/jurisdictions/)
- ✅ Process maps (releases/v0.11.0/process-maps/)
- ✅ Holiday matrix and statute name references
- ✅ Master tracking table
- ❌ Missing: All Supabase integration work
- ❌ Missing: v0.11.1 migrations and scripts
- ❌ Missing: Updated documentation

## Merge Complexity Assessment

**Difficulty Level**: 🔴 HIGH

**Why It's Complex**:
1. **38,559 deletions** - Main branch has removed many files Development still has
2. **Different purposes** - Main = infrastructure, Development = data
3. **Conflicting documentation** - Both updated README, CHANGELOG, VERSION
4. **No common ancestor for new work** - Parallel development paths

## Recommended Strategy: Selective Merge

### Option 1: Two-Step Merge (RECOMMENDED)

**Step 1: Create a clean v0.11.1 branch with everything**

```bash
# 1. Create new branch from main (has Supabase work)
git checkout main
git checkout -b v0.11.1-complete

# 2. Selectively merge data files from Development
git checkout origin/Development -- releases/
git checkout origin/Development -- consolidated-transparency-data/
git checkout origin/Development -- data/federal/
git checkout origin/Development -- data/states/
git checkout origin/Development -- data/consolidated/

# 3. Keep main's documentation (it's newer and includes v0.11.1)
# Don't merge: README.md, VERSION.md, CLAUDE.md, CHANGELOG.md

# 4. Commit the merge
git add releases/ consolidated-transparency-data/ data/
git commit -m "merge: Integrate v0.11.0 data release into v0.11.1

Merged from Development branch:
- 52 jurisdiction JSON files
- Process maps
- Holiday matrix and statute references
- Master tracking table

Preserved from main:
- Supabase migrations and integration
- v0.11.1 documentation
- TypeScript types and scripts

This creates a complete v0.11.1 release with both data and infrastructure.

🤖 Generated with Claude Code (https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Step 2: Test and merge to main**

```bash
# 5. Verify everything works
node dev/scripts/verify-schema.js
node dev/scripts/smart-import.js --dry-run  # Verify data can be imported

# 6. Merge to main
git checkout main
git merge v0.11.1-complete --no-ff -m "feat: Complete v0.11.1 with data and infrastructure

Combines:
- v0.11.0 data release (52 jurisdictions, process maps)
- v0.11.1 Supabase integration (database, migrations, scripts)

This is the complete v0.11.1 release ready for production.

🤖 Generated with Claude Code (https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 7. Push to GitHub
git push origin main
```

### Option 2: Manual Merge with Conflict Resolution

**Not Recommended** - Too many conflicts (174 files)

```bash
# This will create massive conflicts
git merge origin/Development
# Result: CONFLICT in 50+ files requiring manual resolution
```

### Option 3: Keep Branches Separate (Alternative)

**If merge is too risky**:

1. **Main branch** = Production deployment (v0.11.1 Supabase)
2. **Development branch** = Data archive (v0.11.0 JSON)
3. **Create new release branch** when needed

```bash
# Tag Development as v0.11.0 archive
git checkout Development
git tag -a v0.11.0-data-archive -m "v0.11.0 JSON data release archive"
git push origin v0.11.0-data-archive

# Tag main as v0.11.1 production
git checkout main
git tag -a v0.11.1-production -m "v0.11.1 Supabase integration production release"
git push origin v0.11.1-production
```

## Detailed Step-by-Step: Option 1 (Recommended)

### Pre-Merge Checklist

- [ ] Commit all current changes on main
- [ ] Backup current main branch
- [ ] Have git rollback plan ready

### Execution Steps

#### Phase 1: Prepare Clean State

```bash
# Save current work
git status
# If you have uncommitted changes from our documentation updates:
git add .
git commit -m "docs: Update all v0.11.1 documentation and production configs

- Updated README.md, CLAUDE.md, VERSION.md
- Created production deployment summary
- Added environment configs for platforms
- Generated TypeScript types

🤖 Generated with Claude Code (https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Ensure we're on main and up to date
git checkout main
git pull origin main
```

#### Phase 2: Create Merge Branch

```bash
# Create new branch for merge work
git checkout -b v0.11.1-complete

# Verify we're on the new branch
git branch
# Should show: * v0.11.1-complete
```

#### Phase 3: Selectively Import from Development

```bash
# Fetch latest from Development
git fetch origin Development

# Import data directories (keep main's structure, add Development's data)
git checkout origin/Development -- releases/
git checkout origin/Development -- consolidated-transparency-data/

# Import state data
git checkout origin/Development -- data/federal/
git checkout origin/Development -- data/states/
git checkout origin/Development -- data/consolidated/

# Check what was added
git status
```

#### Phase 4: Resolve Conflicts Manually

**Expected conflicts** (handle these manually):

1. **data/consolidated/master_tracking_table-template.json**
   - Development has completion data
   - Main might have different structure
   - **Solution**: Use Development's version (has real data)

2. **CHANGELOG.md**
   - Both branches modified
   - **Solution**: Keep main's version, manually add Development entries if needed

3. **.gitignore**
   - Different ignore rules
   - **Solution**: Keep main's version (has Supabase ignores)

```bash
# For each conflict, choose which version:
# Use Development's version:
git checkout origin/Development -- data/consolidated/master_tracking_table-template.json

# Use main's version (current):
git checkout HEAD -- CHANGELOG.md
git checkout HEAD -- .gitignore
git checkout HEAD -- README.md
git checkout HEAD -- VERSION.md
git checkout HEAD -- CLAUDE.md
```

#### Phase 5: Commit the Merge

```bash
# Review what's staged
git status

# Commit the selective merge
git add .
git commit -m "merge: Integrate v0.11.0 data release into v0.11.1

Merged from Development branch:
- 52 jurisdiction JSON files (releases/v0.11.0/jurisdictions/)
- 52+ process maps (releases/v0.11.0/process-maps/)
- Holiday matrix and statute name references
- Master tracking table with completion status
- All state data directories

Preserved from main (v0.11.1):
- Supabase migrations (7 files)
- Import scripts (smart-import.js, verify-schema.js)
- Documentation (README, CLAUDE, VERSION all v0.11.1)
- TypeScript types (types/supabase.ts)
- Production deployment docs

This creates a complete v0.11.1 release with:
✅ Data layer (52 jurisdictions from v0.11.0)
✅ Infrastructure layer (Supabase from v0.11.1)
✅ Complete documentation
✅ Production-ready deployment

🤖 Generated with Claude Code (https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

#### Phase 6: Verify the Merge

```bash
# Check that both data and infrastructure exist
ls -la releases/v0.11.0/jurisdictions/  # Should have 52 JSON files
ls -la supabase/migrations/             # Should have 7 migration files
ls -la dev/scripts/                     # Should have import scripts
ls -la types/                           # Should have supabase.ts

# Optional: Re-run import to verify data compatibility
node dev/scripts/smart-import.js --dry-run
```

#### Phase 7: Merge to Main

```bash
# Switch back to main
git checkout main

# Merge the completed branch
git merge v0.11.1-complete --no-ff -m "feat: Complete v0.11.1 with data and infrastructure

This merge combines:
- v0.11.0 data release (Development branch)
- v0.11.1 Supabase integration (main branch)

Result: Complete production-ready v0.11.1 release

🤖 Generated with Claude Code (https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Verify main looks correct
git log --oneline -5
ls -la releases/ supabase/
```

#### Phase 8: Push to GitHub

```bash
# Push updated main
git push origin main

# Push the merge branch (for reference)
git push origin v0.11.1-complete

# Optional: Tag the release
git tag -a v0.11.1 -m "v0.11.1: Complete Supabase Integration

- 52 jurisdictions deployed to PostgreSQL
- 365 exemptions with jurisdiction context
- 10 tables + 1 view
- Production-ready database
- Complete documentation"

git push origin v0.11.1
```

## Rollback Plan

If something goes wrong:

```bash
# Find the commit before merge
git log --oneline -10

# Hard reset to before merge (DESTRUCTIVE)
git reset --hard <commit-before-merge>

# Or create a revert commit (SAFE)
git revert -m 1 <merge-commit-hash>

# Push the rollback
git push origin main --force  # Only if not shared with others
```

## Post-Merge Verification

- [ ] All 52 jurisdiction files present in `releases/v0.11.0/jurisdictions/`
- [ ] All process maps present in `releases/v0.11.0/process-maps/`
- [ ] All 7 Supabase migrations present
- [ ] TypeScript types file exists
- [ ] Documentation reflects v0.11.1 (not v0.11.0)
- [ ] Import scripts work: `node dev/scripts/smart-import.js --dry-run`
- [ ] No merge conflict markers in any files

## Why This Approach Works

1. **Selective merge** - Only take what we need from Development
2. **Keep infrastructure** - Preserve all v0.11.1 Supabase work on main
3. **Add data** - Import the v0.11.0 data files we need
4. **Clean history** - Clear commit message explaining what was merged
5. **Testable** - Can verify everything works before pushing

## Alternative: If This Feels Too Risky

Create a **new repository structure**:

```
us-transparency-laws-database/
├── main branch           # Production deployments (Supabase)
├── data-archive branch   # v0.11.0 JSON data
└── releases/
    ├── v0.11.0/         # JSON data release
    └── v0.11.1/         # Supabase integration
```

Then link them with git submodules or keep separate repos.

---

## Recommendation

**Use Option 1: Two-Step Selective Merge**

It's the cleanest way to:
- Preserve all v0.11.1 infrastructure work
- Add v0.11.0 data files
- Avoid massive merge conflicts
- Keep clean git history
- Result in production-ready main branch

Estimated time: 30-45 minutes
Risk level: Medium (testable before pushing)
