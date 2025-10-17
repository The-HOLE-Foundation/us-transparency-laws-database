---
DATE: 2025-10-05
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Repository Reorganization Plan
VERSION: v0.11.0 → v0.11.1
---

# Repository Reorganization Plan

## Current Problem

The repository has accumulated multiple directories with overlapping purposes and unclear versioning:
- `Transparency-Data/` (2.1 MB) - Old process artifacts?
- `Transparency-Map-Dataset/` (264 KB) - Specific subset for map?
- `Consolidated-Datasets/` (604 KB) - Duplicates?
- `data/` (2.6 MB) - **PRODUCTION v0.11.0 data** ✅
- `templates/` (44 KB) - Template files marked v0.11
- Multiple files marked "v0.11" but unclear which are production vs artifacts

## Goal

Create a **clean, obvious structure** that clearly separates:
1. **v0.11.0 Production Data** - What powers Supabase and platforms
2. **v0.12+ Future Work** - Empty structures ready for enhancement
3. **Process Artifacts** - Historical work that got us here
4. **Development Tools** - Scripts, validation, workflows

## Proposed New Structure

```
us-transparency-laws-database/
│
├── releases/                          # 🎯 PRODUCTION RELEASES (version-tagged)
│   └── v0.11.0/                      # Current production release
│       ├── README.md                 # What's in this release
│       ├── jurisdictions/            # 52 jurisdiction JSON files
│       │   ├── federal.json
│       │   ├── alabama.json
│       │   └── ... (all 52)
│       ├── process-maps/             # 52+ verified process maps
│       ├── reference/                # Holiday matrix, statute names
│       └── metadata/                 # Tracking table, validation info
│
├── supabase/                          # 🚀 SUPABASE INTEGRATION (v0.11.1)
│   ├── migrations/                   # Database migrations
│   ├── functions/                    # Edge Functions
│   ├── seed.sql                      # Initial data import
│   └── config.toml                   # Supabase configuration
│
├── future/                            # 🔮 FUTURE ENHANCEMENTS
│   ├── v0.12/                        # Agency data, templates
│   │   ├── agencies/                 # Empty, ready for Layer 4
│   │   └── templates/                # Empty, ready for Layer 5
│   └── v0.13/                        # AI training examples
│       └── training-examples/        # Empty, ready for future
│
├── dev/                               # 🛠️ DEVELOPMENT TOOLS (not versioned)
│   ├── scripts/                      # Validation, migration scripts
│   ├── workflows/                    # Development workflows
│   └── schemas/                      # JSON schemas for validation
│
├── archive/                           # 📦 HISTORICAL ARTIFACTS
│   ├── process-artifacts/            # Old Transparency-Data, etc.
│   ├── duplicates/                   # Consolidated-Datasets duplicates
│   └── old-structure/                # Legacy directory structure
│
├── docs/                              # 📚 DOCUMENTATION
│   ├── PROJECT_ECOSYSTEM.md
│   ├── VERSION.md
│   ├── CHANGELOG.md
│   └── guides/
│
├── .github/                           # GitHub Actions, PR templates
├── README.md                          # Main project README
└── package.json                       # Tooling dependencies
```

## Migration Actions

### Step 1: Create New Structure
```bash
mkdir -p releases/v0.11.0/{jurisdictions,process-maps,reference,metadata}
mkdir -p supabase/{migrations,functions}
mkdir -p future/{v0.12/{agencies,templates},v0.13/training-examples}
mkdir -p dev/{scripts,workflows,schemas}
mkdir -p archive/{process-artifacts,duplicates,old-structure}
mkdir -p docs
```

### Step 2: Identify v0.11.0 Production Data

**Primary Source of Truth** (keep these):
- `data/federal/jurisdiction-data.json` → `releases/v0.11.0/jurisdictions/federal.json`
- `data/states/*/jurisdiction-data.json` → `releases/v0.11.0/jurisdictions/{state}.json` (51 files)
- `consolidated-transparency-data/verified-process-maps/*-v0.11.md` → `releases/v0.11.0/process-maps/`
- `reference/holidays-matrix.csv` → `releases/v0.11.0/reference/`
- `reference/statute-names-reference.md` → `releases/v0.11.0/reference/`
- `data/consolidated/master_tracking_table-template.json` → `releases/v0.11.0/metadata/tracking.json`

### Step 3: Archive Process Artifacts

**Move to archive** (historical value only):
- `Transparency-Data/` → `archive/process-artifacts/transparency-data/`
- `Consolidated-Datasets/` → `archive/duplicates/consolidated-datasets/`
- `Transparency-Map-Dataset/` → `archive/process-artifacts/map-dataset/`
- Old template files → `archive/old-structure/templates/`

### Step 4: Reorganize Dev Tools

**Move to dev** (development tools):
- `scripts/` → `dev/scripts/`
- `workflows/` → `dev/workflows/`
- `schemas/` → `dev/schemas/`
- `templates/` → `dev/templates/` (these are dev templates, not production data)

### Step 5: Consolidate Documentation

**Move to docs**:
- `documentation/` → `docs/archive/` (old docs)
- Keep at root: `README.md`, `CHANGELOG.md`, `VERSION.md`, `PROJECT_ECOSYSTEM.md`
- `RELEASE_NOTES_v0.11.0.md` → `docs/releases/`
- Session notes → `docs/archive/sessions/`

### Step 6: Remove Stale Files

**Delete these** (no longer needed):
- `CURRENT_STATUS_2025-10-03.md` (superseded by VERSION.md)
- `FINAL_STATUS_2025-10-03.md` (superseded by VERSION.md)
- `NEXT_SESSION_START_HERE.md` (superseded by VERSION.md)
- `SESSION_COMPLETE_2025-10-03.md` (archive or delete)
- `.validation-conflicts.json` (stale validation artifact)

## What Goes Where?

### releases/v0.11.0/ (PRODUCTION - Deploy to Supabase)
**Rule**: Only production-ready, verified data that powers the platform
- 52 jurisdiction JSON files (the actual data)
- 52 process maps (verified workflows)
- Reference materials (holidays, statute names)
- Metadata (tracking table)

### supabase/ (INTEGRATION - Next immediate work)
**Rule**: Everything needed to deploy to Supabase
- Database schema migrations
- Edge Functions for AI integration
- Seed data scripts
- Configuration files

### future/ (PLANNED - Empty structures)
**Rule**: Organized by version, empty and ready
- v0.12: Agency contacts, request templates
- v0.13: AI training examples
- Each version gets its own directory

### dev/ (DEVELOPMENT - Tools and workflows)
**Rule**: Things developers use but platforms don't consume
- Validation scripts
- Data migration scripts
- Development workflows
- JSON schemas for validation

### archive/ (HISTORICAL - Reference only)
**Rule**: Things that helped us get here but aren't needed going forward
- Old directory structures
- Process artifacts
- Duplicates and experiments
- Superseded files

### docs/ (DOCUMENTATION - Living reference)
**Rule**: Human-readable documentation
- Architecture documents
- Version history
- Release notes
- Guides and how-tos

## Verification Checklist

After reorganization, verify:
- [ ] Can import v0.11.0 data into Supabase from `releases/v0.11.0/`
- [ ] All 52 jurisdictions present in `releases/v0.11.0/jurisdictions/`
- [ ] All 52 process maps present in `releases/v0.11.0/process-maps/`
- [ ] No duplicate files between releases/ and archive/
- [ ] Dev tools still work from `dev/scripts/`
- [ ] Documentation is complete in `docs/`
- [ ] GitHub Actions still work (update paths if needed)
- [ ] README.md updated with new structure

## Benefits

1. **Crystal Clear**: Anyone can find production data in `releases/v0.11.0/`
2. **Version Ready**: Easy to add v0.11.1, v0.12.0, etc.
3. **Supabase Focused**: Dedicated directory for integration work
4. **Clean Git History**: Archive artifacts without deleting history
5. **Future Proof**: Structure supports future enhancements
6. **Developer Friendly**: Dev tools separate from data
7. **Smaller Repo**: Archive can be .gitignored if needed

## Implementation Order

1. ✅ Create this plan document
2. ⏳ Create new directory structure
3. ⏳ Copy v0.11.0 production data to releases/
4. ⏳ Move dev tools to dev/
5. ⏳ Move process artifacts to archive/
6. ⏳ Consolidate documentation
7. ⏳ Update README.md with new structure
8. ⏳ Update paths in scripts and GitHub Actions
9. ⏳ Verify all tools still work
10. ⏳ Remove old directories
11. ⏳ Commit and push reorganization
12. ⏳ Begin Supabase setup in supabase/

---

**Status**: Plan created, pending execution
**Target**: Complete before starting Supabase integration (v0.11.1)
