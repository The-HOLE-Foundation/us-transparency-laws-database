# v0.11.0 Production Release

**Release Date**: October 3, 2025
**Status**: Production Ready

## Contents

This directory contains the **complete v0.11.0 production dataset** ready for Supabase deployment.

### Jurisdictions (52 files)
- `jurisdictions/federal.json` - Federal FOIA (5 U.S.C. § 552)
- `jurisdictions/{state}.json` - 51 state transparency laws (50 states + DC)

### Process Maps (52+ files)
- Visual workflow diagrams for each jurisdiction
- Markdown format with standardized structure

### Reference Materials
- `reference/holidays-matrix.csv` - Business day calculation data
- `reference/statute-names-reference.md` - Official law names and citations

### Metadata
- `metadata/tracking.json` - Master tracking table (52/52 complete)

## Data Quality

- ✅ 100% manual verification
- ✅ Official .gov sources only
- ✅ Current through 2024-2025 legislative sessions
- ✅ Standardized JSON schema

## Usage

This data is ready for:
1. Supabase database import
2. TheHoleTruth.org platform consumption
3. API serving
4. Static site generation

See [PROJECT_ECOSYSTEM.md](../../PROJECT_ECOSYSTEM.md) for integration architecture.
