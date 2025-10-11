---
DATE: 2025-10-11
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
TYPE: Data Structure Documentation
VERSION: v0.12
---

# Jurisdiction Data - Single Source of Truth

## Overview

**This folder contains ALL jurisdiction data for the US Transparency Laws Database.**

**Golden Rule**: Each file lives in exactly ONE place. No duplicates.

## Structure

```
data/jurisdictions/
├── federal/
│   ├── metadata.json           # Basic jurisdiction info
│   ├── rights.json             # Affirmative rights of access
│   └── statute-full-text.txt   # Complete FOIA statute text
│
└── states/
    ├── alabama/
    │   ├── metadata.json
    │   ├── rights.json
    │   └── statute-full-text.txt
    │
    ├── (49 more states alphabetically)
    │
    └── district-of-columbia/
        ├── metadata.json
        ├── rights.json (pending collection)
        └── statute-full-text.txt
```

## File Descriptions

### metadata.json
**Source of Truth**: Basic jurisdiction information
- Jurisdiction name, type, statute citation
- Response requirements, fee structures
- Appeal processes, agency obligations
- Exemptions (extracted to separate file in future)
- **From**: Original v0.11 data structure

### rights.json
**Source of Truth**: Affirmative rights of access
- All rights a requester has under this jurisdiction's transparency law
- Categories: Proactive Disclosure, Enhanced Access, Technology Rights, etc.
- Statutory citations and assertion language
- **Used by**: FOIA Generator to assert rights in requests

### statute-full-text.txt
**Source of Truth**: Complete statutory text
- Full text of transparency law statute
- All sections, subsections, amendments
- Verified from official .gov sources
- **Used for**: Legal research, AI training, public education

## Data Flow

```
Official .gov Statute
    ↓
statute-full-text.txt (collect full text)
    ↓
Extract rights/requirements/exemptions
    ↓
metadata.json + rights.json (structure data)
    ↓
Import to Neon Database
    ↓
rights_of_access table + other tables
    ↓
THEHOLETRUTH.ORG Platform (FOIA Generator, Wiki, Map)
```

## Current Status

**Complete Jurisdictions** (51/52):
- ✅ Federal Government
- ✅ 50 US States
- ⏸️ District of Columbia (rights.json pending)

**Files Present**:
- 52 metadata.json files ✅
- 51 rights.json files (DC pending) ⏸️
- 52 statute-full-text.txt files ✅

## How to Add/Update Data

### Adding a New Jurisdiction

```bash
# 1. Create folder
mkdir data/jurisdictions/territories/puerto-rico

# 2. Add statute text
# Download from official source
# Save as: statute-full-text.txt

# 3. Create metadata.json
# Extract from statute or use template

# 4. Create rights.json
# Extract affirmative rights from statute

# 5. Import to Neon
node database/scripts/import-jurisdiction-to-neon.js puerto-rico
```

### Updating an Existing Jurisdiction

```bash
# 1. Edit the file in place
edit data/jurisdictions/states/california/rights.json

# 2. Re-import to Neon
node database/scripts/import-jurisdiction-to-neon.js california

# 3. Verify
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM rights_of_access WHERE jurisdiction_id = 'california';"
```

## Verification

### Check Completeness

```bash
# Verify all jurisdictions have all files
for dir in data/jurisdictions/federal data/jurisdictions/states/*; do
    jurisdiction=$(basename "$dir")
    echo "Checking $jurisdiction..."
    [ -f "$dir/metadata.json" ] && echo "  ✓ metadata" || echo "  ✗ metadata MISSING"
    [ -f "$dir/rights.json" ] && echo "  ✓ rights" || echo "  ✗ rights MISSING"
    [ -f "$dir/statute-full-text.txt" ] && echo "  ✓ statute" || echo "  ✗ statute MISSING"
done
```

### Compare with Neon Database

```bash
# Get jurisdictions with rights in database
psql "$DATABASE_URL" -c "
SELECT j.name, COUNT(r.id) as rights_count
FROM jurisdictions j
LEFT JOIN rights_of_access r ON j.id = r.jurisdiction_id
GROUP BY j.name
HAVING COUNT(r.id) > 0
ORDER BY j.name;
"

# Compare with files
ls -1 data/jurisdictions/states/*/rights.json | wc -l
```

## Migration Notes

**This structure was created**: 2025-10-11

**Migrated from**:
- Old location: `worktrees/affirmative/{jurisdiction}/data/v0.12/affirmative-rights/`
- Old location: `data/v0.12/rights/`
- Old location: `consolidated-transparency-data/statutory-text-files/`
- Old location: `releases/v0.11.0/jurisdictions/`

**Benefits**:
- ✅ Single source of truth
- ✅ Clear file locations
- ✅ Easy to find data
- ✅ No duplicates
- ✅ 4.5 GB space saved (99.96% reduction)

**Old structure archived**: `.archive/2025-10-11-restructure/`

---

**Last Updated**: 2025-10-11
**Maintained By**: The HOLE Foundation Engineering Team
**Status**: ✅ Operational
