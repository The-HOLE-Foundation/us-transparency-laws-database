---
DATE: 2025-10-11
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
TYPE: Safe Cleanup Plan - REVIEWED FOR DATA SAFETY
STATUS: AWAITING APPROVAL
---

# SAFE REPOSITORY CLEANUP PLAN - DATA AUDIT COMPLETE

## CRITICAL FINDINGS - DATA REVIEW

### ✅ SAFE TO CLEAN (Duplicates Only)

**1. Old Rights Files in Each Worktree** (468 duplicate files):
- Every worktree has `data/v0.12/rights/` folder with 9 identical files:
  - arkansas-rights.json
  - california-rights.json
  - federal-rights.json
  - florida-rights.json
  - georgia-rights.json
  - new-york-rights.json
  - north-carolina-rights.json
  - texas-rights.json
  - washington-rights.json

**Verification**: MD5 hashes show these are IDENTICAL across all 52 worktrees
**Conclusion**: These are old duplicates - SAFE TO DELETE from worktrees
**Preservation**: Main repo has master copy in `/data/v0.12/rights/`

**2. node_modules** (52 copies × 73 MB = 3.8 GB):
- Every worktree has complete node_modules
- All identical duplicates
- **SAFE TO DELETE** from worktrees
- Main repo keeps one copy (not in git)

**3. Documentation** (16,000+ duplicate .md files):
- CLAUDE.md duplicated 52 times
- README.md duplicated 52 times
- All validation reports duplicated 52 times
- **SAFE TO DELETE** from worktrees
- Main repo has master copies

### ⚠️ IMPORTANT DATA (Must Preserve)

**Unique Rights Files** (45 files) - Each worktree has ONE unique file:

```
worktrees/affirmative/alabama/data/v0.12/affirmative-rights/alabama-rights.json ✅
worktrees/affirmative/alaska/data/v0.12/affirmative-rights/alaska-rights.json ✅
worktrees/affirmative/arizona/data/v0.12/affirmative-rights/arizona-rights.json ✅
... (45 total unique jurisdiction files)
```

**STATUS**: These are the ONLY unique data in worktrees
**ACTION**: COPY to main repo BEFORE any deletion
**LOCATION AFTER CLEANUP**: `/data/v0.12/affirmative-rights/`

## DATA PRESERVATION STRATEGY

### Step 1: Inventory ALL Unique Data (READ-ONLY)

```bash
# Find all unique affirmative-rights files
find worktrees/affirmative/*/data/v0.12/affirmative-rights -name "*.json" -exec md5 {} \; > /tmp/rights-inventory.txt

# List them
find worktrees/affirmative/*/data/v0.12/affirmative-rights -name "*.json" | sort
```

### Step 2: Copy ALL Unique Data to Main Repo (SAFE - Creates Copies)

```bash
# Create backup collection directory
mkdir -p data/v0.12/affirmative-rights-FROM-WORKTREES-BACKUP

# Copy each worktree's unique file
for dir in worktrees/affirmative/*/; do
    jurisdiction=$(basename "$dir")
    source="$dir/data/v0.12/affirmative-rights/${jurisdiction}-rights.json"

    if [ -f "$source" ]; then
        cp -v "$source" "data/v0.12/affirmative-rights-FROM-WORKTREES-BACKUP/"
        echo "✓ Backed up $jurisdiction"
    fi
done

# List what was collected
ls -lh data/v0.12/affirmative-rights-FROM-WORKTREES-BACKUP/
```

### Step 3: Verify Data Integrity (READ-ONLY)

```bash
# Count files
total=$(ls -1 data/v0.12/affirmative-rights-FROM-WORKTREES-BACKUP/*.json 2>/dev/null | wc -l)
echo "Collected $total unique jurisdiction files"

# Expected: ~45 files (states that have been worked on)
# Missing: ~7 jurisdictions (not yet started)

# Create manifest
ls -lh data/v0.12/affirmative-rights-FROM-WORKTREES-BACKUP/ > data/v0.12/BACKUP-MANIFEST-$(date +%Y%m%d).txt
```

### Step 4: ONLY AFTER VERIFICATION - Clean Worktrees

**DO NOT RUN UNTIL STEP 3 COMPLETE AND VERIFIED**

```bash
# For each worktree, remove:
# - data/v0.12/rights/ (9 duplicate old files)
# - node_modules/ (duplicate)
# - documentation/ (duplicate)
# - All .md files (duplicate)
# - .claude/ (duplicate)
# - supabase/ (duplicate)

# KEEP in each worktree:
# - data/v0.12/affirmative-rights/{jurisdiction}-rights.json
# - .git (git metadata)
```

## WHAT'S IN THE NEON DATABASE NOW?

Based on earlier query, Neon database has:
- **14 jurisdictions with rights data** (262 total rights)
- Arkansas: 15 rights ✅
- California: 25 rights ✅
- Connecticut: 20 rights ✅
- Florida: 20 rights ✅
- Georgia: 17 rights ✅
- Illinois: 20 rights ✅
- Louisiana: 16 rights ✅
- Massachusetts: 20 rights ✅
- New York: 20 rights ✅
- North Carolina: 15 rights ✅
- Oregon: 19 rights ✅
- Texas: 20 rights ✅
- Washington: 20 rights ✅
- Federal: 15 rights ✅

**Question**: Where did this data come from if main repo only has 1 file?

**Answer**: It was imported from worktrees or another source!

## RECOMMENDED SAFE APPROACH

### Option A: Conservative (RECOMMENDED - No Data Loss Risk)

**Phase 1: Data Collection ONLY** (No Deletion)
```bash
# 1. Copy all unique files from worktrees
mkdir -p data/v0.12/affirmative-rights-consolidated

for dir in worktrees/affirmative/*/; do
    jurisdiction=$(basename "$dir")

    # Copy affirmative-rights file (unique to each worktree)
    if [ -f "$dir/data/v0.12/affirmative-rights/${jurisdiction}-rights.json" ]; then
        cp "$dir/data/v0.12/affirmative-rights/${jurisdiction}-rights.json" \
           "data/v0.12/affirmative-rights-consolidated/"
    fi
done

# 2. Verify all files collected
ls -lh data/v0.12/affirmative-rights-consolidated/

# 3. Create inventory
cat > data/v0.12/affirmative-rights-consolidated/README.md << 'EOF'
# Consolidated Affirmative Rights Data

**Source**: Collected from worktrees on 2025-10-11
**Purpose**: Single source of truth for all jurisdiction rights
**Status**: Backup collection before worktree cleanup

## Files
EOF

ls -1 data/v0.12/affirmative-rights-consolidated/*.json | while read file; do
    basename=$(basename "$file")
    size=$(du -h "$file" | cut -f1)
    echo "- $basename ($size)" >> data/v0.12/affirmative-rights-consolidated/README.md
done

# 4. STOP HERE - DO NOT DELETE ANYTHING YET
```

**Phase 2: Verify Against Neon Database**
```bash
# Check if Neon has all the data
psql "$DATABASE_URL" -c "
SELECT j.name, COUNT(r.id) as rights_in_db
FROM jurisdictions j
LEFT JOIN rights_of_access r ON j.id = r.jurisdiction_id
GROUP BY j.name
HAVING COUNT(r.id) > 0
ORDER BY j.name;
"

# Compare with collected files
ls data/v0.12/affirmative-rights-consolidated/
```

**Phase 3: ONLY AFTER VERIFICATION - Minimal Cleanup**
```bash
# Only delete CONFIRMED duplicates:
# - node_modules from worktrees (keeps in main repo)
# - data/v0.12/rights/ from worktrees (old duplicates)
# - .md files from worktrees (keeps in main repo)

# Keep everything else until we understand it better
```

### Option B: Wait and Investigate Further

Before ANY cleanup:
1. Map out exactly what data is where
2. Verify what's in Neon vs what's in files
3. Understand the worktree workflow intent
4. Create comprehensive data map
5. Then decide on cleanup

## CRITICAL QUESTIONS BEFORE PROCEEDING

1. **Where is the source of truth for rights data?**
   - Neon database has 262 rights (14 jurisdictions)
   - Worktrees have 45 unique JSON files
   - Main repo has 1 file (texas-UNVERIFIED.json)
   - **Which is authoritative?**

2. **What are the old files in `/rights/` folder?**
   - 9 files: arkansas, california, federal, florida, georgia, new-york, north-carolina, texas, washington
   - Duplicated in every worktree
   - Are these obsolete? Or backup?

3. **What's the data flow?**
   - Worktrees → Where?
   - Files → Neon? How?
   - Neon → Platform?

## MY RECOMMENDATION

**DO NOT run the automated cleanup scripts yet.**

**Instead**:

1. **First, let's manually collect the data safely**:
   ```bash
   mkdir -p data/v0.12/ALL-RIGHTS-BACKUP-$(date +%Y%m%d)

   # Copy everything
   cp -r worktrees/affirmative/*/data/v0.12/affirmative-rights/*.json \
         data/v0.12/ALL-RIGHTS-BACKUP-$(date +%Y%m%d)/

   cp -r worktrees/affirmative/*/data/v0.12/rights/*.json \
         data/v0.12/ALL-RIGHTS-BACKUP-$(date +%Y%m%d)/old-rights/
   ```

2. **Second, analyze what we have**:
   - Compare files vs Neon database
   - Identify which files are current
   - Map the data workflow

3. **Third, create a targeted cleanup**:
   - Only delete CONFIRMED duplicates
   - Keep data until we understand it
   - Incremental approach

**Would you like me to**:
- A) Run Step 1 (safe data collection) now
- B) Create a comprehensive data inventory first
- C) Something else

I want to make sure we don't lose ANY important data!