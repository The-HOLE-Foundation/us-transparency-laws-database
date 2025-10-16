---
DATE: 2025-10-12
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
PURPOSE: Analysis of root directories for cleanup decisions
---

# Root Directory Analysis - Keep or Delete?

## Directory-by-Directory Review

### 1. **Consolidated-Datasets/** (604K, 3 files)
**Contents**: v0.11 master files (MD, CSV, JSON)
**Last Modified**: 2025-09-29
**Purpose**: Legacy consolidated data from v0.11

**Recommendation**: ⚠️ **ARCHIVE** (old data format, superseded by current structure)
**Reason**: v0.11 is production complete but this is old format. Current data is in `data/` directory. Keep in archive for reference but not needed in root.
**Action**: Move to `.archive/2025-09-legacy-v0.11/Consolidated-Datasets/`

---

### 2. **Transparency-Data/** (2.1M, 115 files)
**Contents**: Full-Text-Statutes (53 files), Individual-Jurisdictions, Metadata
**Last Modified**: 2025-10-05
**Purpose**: Legacy organization of transparency data

**Recommendation**: ⚠️ **REVIEW THEN ARCHIVE/DELETE**
**Reason**: Appears to duplicate current `data/` structure. Need to verify no unique data.
**Action**:
1. Compare with current `data/` directory
2. If duplicate → archive
3. If unique content → migrate to `data/` then archive original

---

### 3. **Transparency-Map-Dataset/** (276K, 11 files)
**Contents**: Map data, import scripts, schema for transparency map visualization
**Last Modified**: 2025-10-10

**Recommendation**: ✅ **KEEP**
**Reason**: Active dataset for transparency map feature on theholetruth.org
**Purpose**: Powers interactive US map showing transparency law timelines
**Note**: Contains import scripts for Neon database

---

### 4. **archive/** (312K, 12 files)
**Contents**: Hidden archive directory
**Last Modified**: 2025-10-08

**Recommendation**: ✅ **KEEP**
**Reason**: Archive storage (but explore contents)
**Action**: Verify it's properly organized and documented

---

### 5. **data/** (5.2M, 415 files) ⭐ PRIMARY DATA
**Contents**: Current jurisdiction data, v0.12 structure
**Last Modified**: 2025-10-12 (TODAY)

**Recommendation**: ✅ **KEEP** - This is the primary data directory
**Reason**: Active, current, properly organized
**Purpose**: Ground truth for all 52 jurisdictions

---

### 6. **database/** (140K, 13 files)
**Contents**: Database configuration and scripts
**Last Modified**: 2025-10-11

**Recommendation**: ⚠️ **REVIEW** - Might be obsolete
**Reason**: We migrated from Supabase to Neon. This might be old Supabase config.
**Action**: Check if this is current Neon config or legacy Supabase
**User opened**: config.toml (just now)

---

### 7. **dev/** (540K, 52 files)
**Contents**: Development scripts and utilities
**Last Modified**: 2025-10-08

**Recommendation**: ✅ **KEEP BUT REORGANIZE**
**Reason**: Active development tools but could be better organized
**Suggestion**: Merge useful scripts into `scripts/` and archive rest

---

### 8. **docs/** (8K, 1 file)
**Contents**: Minimal documentation
**Last Modified**: 2025-10-08

**Recommendation**: ⚠️ **MERGE INTO DOCUMENTATION/**
**Reason**: We have a proper `documentation/` directory. No need for both.
**Action**: Move contents to `documentation/` and delete `docs/`

---

### 9. **documentation/** (6.8M, 76 files) ⭐ PRIMARY DOCS
**Contents**: Comprehensive project documentation, session archives
**Last Modified**: 2025-10-12 (TODAY)

**Recommendation**: ✅ **KEEP** - This is the primary documentation directory
**Reason**: Active, well-organized, includes session archives
**Purpose**: All project documentation, guides, reports

---

### 10. **future/** (8K, 1 file)
**Contents**: Future plans/ideas
**Last Modified**: 2025-10-08

**Recommendation**: ⚠️ **MERGE INTO DOCUMENTATION/**
**Reason**: Future plans should be in documentation or ROADMAP
**Action**: Review content, integrate into proper docs, delete directory

---

### 11. **neon-database/** (64K, 6 files)
**Contents**: Neon-specific database files
**Last Modified**: 2025-10-10

**Recommendation**: ✅ **KEEP**
**Reason**: Current database platform (we migrated from Supabase to Neon)
**Purpose**: Neon-specific migrations, schemas, configs

---

### 12. **schemas/** (28K, 2 files)
**Contents**: Data validation schemas
**Last Modified**: 2025-10-08

**Recommendation**: ✅ **KEEP**
**Reason**: Important for data validation
**Purpose**: JSON schemas for validating jurisdiction data structure

---

### 13. **scripts/** (288K, 26 files)
**Contents**: Various utility scripts (Python, shell, JS)
**Last Modified**: 2025-10-08

**Recommendation**: ✅ **KEEP BUT AUDIT**
**Reason**: Active utility scripts
**Action**: Review for obsolete scripts, document what each does

---

### 14. **supabase/** (316K, 12 files)
**Contents**: Supabase configuration and migrations
**Last Modified**: 2025-10-11

**Recommendation**: ⚠️ **ARCHIVE** - We migrated away from Supabase
**Reason**: We're now using Neon (per CLAUDE.md: "migrated from Supabase to Neon October 2025")
**Action**: Archive entire directory as `.archive/2025-10-supabase-legacy/`
**Note**: Keep for historical reference in case we need to look back

---

### 15. **templates/** (92K, 13 files)
**Contents**: JSON and markdown templates for data entry
**Last Modified**: 2025-10-08

**Recommendation**: ✅ **KEEP**
**Reason**: Active templates for data structure
**Purpose**: Templates for jurisdiction data, agencies, process maps

---

### 16. **types/** (28K, 1 file)
**Contents**: TypeScript type definitions
**Last Modified**: 2025-10-10

**Recommendation**: ✅ **KEEP**
**Reason**: Type definitions for TypeScript/JavaScript integration
**Purpose**: Generated from database schema for type safety

---

### 17. **workflows/** (176K, 14 files)
**Contents**: Workflow documentation and guides
**Last Modified**: 2025-10-08

**Recommendation**: ⚠️ **MERGE INTO DOCUMENTATION/**
**Reason**: Workflows are documentation. Should be in `documentation/workflows/`
**Action**: Move to `documentation/workflows/` and delete root `workflows/`

---

## Summary of Recommendations

### ✅ KEEP AS-IS (7 directories):
1. **data/** - Primary data directory (5.2M)
2. **documentation/** - Primary docs directory (6.8M)
3. **archive/** - Archive storage (312K)
4. **Transparency-Map-Dataset/** - Active map data (276K)
5. **neon-database/** - Current database platform (64K)
6. **schemas/** - Data validation (28K)
7. **templates/** - Active templates (92K)
8. **types/** - Type definitions (28K)

**Total to Keep**: ~12.7M

---

### ⚠️ REVIEW THEN DECIDE (4 directories):
1. **Transparency-Data/** (2.1M) - Check for duplicates vs `data/`
2. **database/** (140K) - Verify if current Neon or legacy
3. **dev/** (540K) - Audit scripts, merge into `scripts/`
4. **scripts/** (288K) - Audit for obsolete scripts

**Total to Review**: ~3M

---

### 🗑️ ARCHIVE OR CONSOLIDATE (6 directories):
1. **Consolidated-Datasets/** (604K) → Archive legacy v0.11
2. **supabase/** (316K) → Archive (migrated to Neon)
3. **docs/** (8K) → Merge into `documentation/`
4. **future/** (8K) → Merge into `documentation/`
5. **workflows/** (176K) → Merge into `documentation/workflows/`

**Total to Clean**: ~1.1M

---

## Recommended Cleanup Actions

### Phase 1: Safe Moves (No Data Loss)
```bash
# Move legacy v0.11 data to archive
mkdir -p .archive/2025-09-legacy-v0.11
mv Consolidated-Datasets .archive/2025-09-legacy-v0.11/

# Archive Supabase (we migrated to Neon)
mkdir -p .archive/2025-10-supabase-legacy
mv supabase .archive/2025-10-supabase-legacy/

# Consolidate documentation
mv docs/* documentation/ 2>/dev/null
rmdir docs

mv future/* documentation/ 2>/dev/null
rmdir future

mkdir -p documentation/workflows
mv workflows/* documentation/workflows/
rmdir workflows
```

### Phase 2: Review and Decide
```bash
# Compare Transparency-Data with data/
# If duplicate → archive
# If unique → migrate then archive

# Review database/ directory
# If legacy Supabase → archive
# If current Neon → keep

# Audit dev/ and scripts/
# Document purpose of each script
# Archive obsolete ones
```

### Phase 3: Final Cleanup
```bash
# Commit all changes
git add -A
git commit -m "chore: Consolidate and archive legacy directories"
```

---

## Expected Results

**Before Cleanup**:
- 17 root directories
- ~16.8M total size
- Confusion about what's current vs legacy

**After Cleanup**:
- 8-10 root directories
- ~12.7M (removed ~4M of legacy/duplicate data)
- Clear organization:
  - `data/` - all data
  - `documentation/` - all docs
  - `neon-database/` - current database
  - `schemas/` - validation
  - `templates/` - templates
  - `types/` - type definitions
  - `Transparency-Map-Dataset/` - map feature
  - `scripts/` - utility scripts (audited)
  - `.archive/` - historical reference

---

## Questions for User

1. **database/** directory - Is this current Neon config or legacy Supabase?
   - You just opened database/config.toml - is this actively used?

2. **Transparency-Data/** - Should we compare with `data/` to check for duplicates?

3. **dev/** - Do you use these scripts actively or can we merge into `scripts/`?

4. Any directories you know are important that I might not understand?

---

**Status**: Awaiting user input on questions above
**Next**: Execute approved cleanup actions
