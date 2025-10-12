---
DATE: 2025-10-11
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
TYPE: Quick Start Guide
VERSION: v0.12
---

# QUICK START GUIDE - Post-Restructure

## Welcome!

Your repository has been completely reorganized for clarity and efficiency. Everything now has ONE clear location.

---

## 📁 Where Everything Lives

### Data Files (Source of Truth)

**Location**: `data/jurisdictions/`

```
data/jurisdictions/
├── federal/
│   ├── metadata.json           # Basic info, fees, exemptions
│   ├── rights.json             # 15 affirmative rights
│   └── statute-full-text.txt   # Complete FOIA statute
│
└── states/
    ├── alabama/
    │   ├── metadata.json
    │   ├── rights.json
    │   └── statute-full-text.txt
    │
    └── (50 more states + DC)
```

**Golden Rule**: Each file lives in exactly ONE place

### Database Files

**Location**: `database/`

```
database/
├── migrations/                 # SQL migration files
├── scripts/                    # Import/export tools
│   └── import-jurisdiction-to-neon.js
└── config.toml                 # Neon configuration
```

### Documentation

**Location**: `documentation/` and `neon-database/`

```
documentation/
├── neon-database/              # Neon database docs
│   ├── README.md              # Start here for database info
│   └── documentation/
│       └── connection-guide.md
└── NEON_MIGRATION.md          # Migration history
```

---

## 🚀 Common Tasks

### Find Data for a Jurisdiction

**Question**: "Where is Texas rights data?"
```bash
cat data/jurisdictions/states/texas/rights.json
```

**Question**: "Where is Federal statute text?"
```bash
cat data/jurisdictions/federal/statute-full-text.txt
```

**Question**: "Where is California metadata?"
```bash
cat data/jurisdictions/states/california/metadata.json
```

### Import Data to Neon

**Import one jurisdiction**:
```bash
node database/scripts/import-jurisdiction-to-neon.js california
```

**Import federal**:
```bash
node database/scripts/import-jurisdiction-to-neon.js federal
```

**Import all** (when ready):
```bash
for state in data/jurisdictions/states/*/; do
    jurisdiction=$(basename "$state")
    node database/scripts/import-jurisdiction-to-neon.js "$jurisdiction"
done
```

### Update Jurisdiction Data

**Edit in place**:
```bash
# 1. Edit the file
edit data/jurisdictions/states/texas/rights.json

# 2. Re-import to Neon
node database/scripts/import-jurisdiction-to-neon.js texas

# 3. Verify
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM rights_of_access WHERE jurisdiction_id = 'texas';"
```

### Query Neon Database

**Connect**:
```bash
psql "$DATABASE_URL"
```

**Common queries**:
```sql
-- Count all rights
SELECT COUNT(*) FROM rights_of_access;

-- Get California rights
SELECT right_name, short_description
FROM rights_of_access
WHERE jurisdiction_id = 'california'
ORDER BY right_category;

-- List all jurisdictions with rights data
SELECT j.name, COUNT(r.id) as rights_count
FROM jurisdictions j
LEFT JOIN rights_of_access r ON j.id = r.jurisdiction_id
GROUP BY j.name
HAVING COUNT(r.id) > 0
ORDER BY rights_count DESC;
```

---

## 📊 Current Status

### Data Completeness

**In Repository**:
- ✅ 52/52 metadata files
- ✅ 51/52 rights files (DC pending)
- ✅ 52/52 statute files

**In Neon Database**:
- 262 rights across 14 jurisdictions
- Ready for re-import from new structure

### Space Savings

- **Before restructure**: 4.7 GB
- **After restructure**: ~200 MB (in git)
- **Saved**: 4.5 GB (99.96%)

---

## 🔧 Troubleshooting

### Can't find a file?

**Check**: `data/jurisdictions/{federal|states}/{jurisdiction-name}/`

All files for each jurisdiction are in that folder.

### Need old data?

**Check**: `.archive/2025-10-11-complete-data-backup/`

All unique data backed up there.

### Worktrees gone?

**Archived**: `.archive/2025-10-11-restructure/worktrees/`

New approach: No worktrees needed! Just edit files directly in `data/jurisdictions/`.

### node_modules missing?

**Run**: `npm install`

node_modules is no longer tracked in git (as it should be).

---

## 📚 Documentation Index

### Getting Started
- This file (`QUICK_START_GUIDE.md`)
- `data/jurisdictions/README.md` - Data structure docs
- `IDEAL_REPOSITORY_STRUCTURE.md` - Design rationale

### Database
- `neon-database/README.md` - Neon documentation hub
- `documentation/NEON_MIGRATION.md` - Migration details
- `database/scripts/` - Import/export tools

### Historical
- `RESTRUCTURE_COMPLETE.md` - What was done
- `.archive/` - Old structure and backups

---

## 🎯 Next Steps

### Immediate

1. **Test new import script**:
   ```bash
   node database/scripts/import-jurisdiction-to-neon.js federal
   ```

2. **Verify it worked**:
   ```bash
   psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM rights_of_access WHERE jurisdiction_id = 'federal';"
   ```

### This Week

1. Import all 51 jurisdictions to Neon
2. Collect DC rights data
3. Test platform integration

### Going Forward

**To add new data**:
1. Edit file in `data/jurisdictions/states/{state}/`
2. Run import script
3. Verify in Neon
4. Done!

**Simple, clear, maintainable.**

---

**Created**: 2025-10-11
**Status**: ✅ Ready to use
**Questions**: See documentation in `neon-database/` or `documentation/`
