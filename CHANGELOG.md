---
DATE: 2025-09-29
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Change Log
VERSION: v0.11
---

# Changelog

All notable changes to this project will be documented in this file.

## [v0.11] - 2025-09-29

### Added - Transparency Map Dataset (MAJOR UPDATE)
- **NEW DIRECTORY**: `/Transparency-Map-Dataset/` - Complete curated dataset for interactive map
- **Master Dataset**: `transparency-map-data-v0.11.json` - All 51 jurisdictions (181 KB)
- **Supabase Schema**: `supabase-schema.sql` - Production-ready database schema
  - 3 main tables (`timeline_code_reference`, `transparency_map_jurisdictions`, `jurisdiction_2025_amendments`)
  - 4 optimized views for common queries
  - 2 utility functions (`get_timeline_display`, `search_jurisdictions`)
  - Full Row Level Security (RLS) policies
  - 10+ performance indexes
- **Timeline Code System**: Negative integer codes for flexible deadlines
  - `-1`: Reasonable time
  - `-2`: Promptly
  - `-3`: Immediate (certain records)
  - `-4`: Variable by request type
- **JSON Schema**: `schema.json` - Complete validation schema
- **Import Script**: `import-to-supabase.js` - Automated data import tool
- **Documentation**: Comprehensive README and deployment guide

### Changed - File Organization
- **Renamed ALL statute files** to include `-v0.11` suffix (51 files)
  - Fixed inconsistent naming (`v.0.11` → `v0.11`)
  - Standardized all Full-Text-Statutes files
- **Consolidated statutes** to `consolidated-transparency-data/statutory-text-files/` (52 files)
- **Updated CLAUDE.md** with global document header requirements
- **Updated DATA_ORGANIZATION_REFERENCE.md** with latest status

### Added - Documentation
- **NEW**: `/documentation/DUPLICATE_FILES_REPORT.md` - Complete duplicate analysis
- **NEW**: `/documentation/DATA_ORGANIZATION_REFERENCE.md` - Comprehensive data guide
- **NEW**: `/Transparency-Map-Dataset/PROJECT_COMPLETE.md` - Deployment instructions
- **NEW**: `/Transparency-Map-Dataset/README.md` - Dataset documentation
- **NEW**: `/CHANGELOG.md` - This file

### Added - Scripts
- **NEW**: `/scripts/rename_to_v0_11.py` - Automated file renaming
- **NEW**: `/scripts/find_duplicates.py` - Duplicate file detection
- **NEW**: `/scripts/extract_map_data.py` - Data extraction from process maps

### Fixed
- California and Colorado statute files had incorrect version format (`v.0.11` → `v0.11`)
- Removed duplicate files from root `/Consolidated-Datasets/` directory
- Cleaned up 51 duplicate statute files in statutory-text-files directory

### Identified - Pending Work
- 51 empty agency.json templates need population with verified data
- Official resource URLs need to be added to map dataset
- `jurisdiction_2025_amendments` table needs detailed amendment data
- Comprehensive wiki dataset (separate from map dataset) needs creation

---

## [v0.10] - 2025-09-26

### Changed
- Complete validation of all 51 transparency law statutes
- Verified against official government sources
- Identified 10 jurisdictions with 2024-2025 amendments
- Created verified process maps for all jurisdictions

### Fixed
- Updated Texas statute with HB 4219 (effective 2025-09-01)
- Updated California statute with AB 370 & AB 1785 (effective 2025-07-01)
- Updated Illinois statute with 2024-2025 amendments
- Updated 7 other jurisdictions with recent changes

---

## Earlier Versions

### [v0.9 and earlier]
- Initial data collection
- Template creation
- Repository structure establishment
- Basic validation methodology

---

## Statistics by Version

### v0.11 (Current)
- **Total Jurisdictions**: 51 (100% complete)
- **Verified Process Maps**: 52 files
- **Full-Text Statutes**: 51 files (all v0.11)
- **Transparency Map Dataset**: ✅ Complete (181 KB)
- **Supabase Schema**: ✅ Complete (18 KB)
- **Documentation Files**: 15+ files
- **Scripts**: 6 utility scripts

### v0.10
- **Total Jurisdictions**: 51 (100% validated)
- **Process Maps**: 51 files
- **2025 Amendments Tracked**: 10 jurisdictions

---

## Upcoming in v0.12 (Planned)

### High Priority
- [ ] Populate 51 agency.json templates with verified data
- [ ] Add official resource URLs to map dataset
- [ ] Create comprehensive wiki dataset (separate from map)
- [ ] Implement automated validation tests
- [ ] Create admin interface for data updates

### Medium Priority
- [ ] Add historical amendment tracking
- [ ] Create API endpoint documentation
- [ ] Build example frontend components
- [ ] Add multilingual support infrastructure

### Low Priority
- [ ] Create data visualization tools
- [ ] Add export functionality for various formats
- [ ] Build automated monitoring for statute changes

---

## Migration Guide

### From v0.10 to v0.11

**Data Files**:
- No data loss - all v0.10 data preserved
- File naming standardized (all now include `-v0.11`)
- New curated dataset created for map interface
- Original comprehensive data unchanged

**Breaking Changes**:
- None - v0.11 is additive only

**Action Required**:
1. Review `/Transparency-Map-Dataset/` for new curated data
2. Use `supabase-schema.sql` for database deployment
3. Update any scripts referencing old file names
4. Read `PROJECT_COMPLETE.md` for deployment instructions

---

## Contributors

- Claude Code AI Assistant - Data extraction, organization, schema design
- The HOLE Foundation - Project direction, validation, verification

---

## License

CC0 1.0 Universal (Public Domain)

---

*This changelog follows [Keep a Changelog](https://keepachangelog.com/) principles.*