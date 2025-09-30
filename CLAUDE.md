# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Document Standards (GLOBAL REQUIREMENT)

**Every document generated must include the following header:**

```
---
DATE: [YYYY-MM-DD]
AUTHOR: [Author Name or "Claude Code AI Assistant"]
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: [Specific component, e.g., "Supabase Schema Design", "Data Validation", "Process Maps"]
VERSION: v0.11
---
```

This applies to all markdown files, documentation, reports, schemas, and any other documents created for this project.

## Project Overview

This repository is a comprehensive database of US transparency laws (FOIA and public records laws) for all 51 jurisdictions (50 states + DC + Federal). The project is currently in **template mode (v0.11)** - all data files have been cleared and replaced with empty templates ready to be populated with verified data.

**Critical**: This database serves as ground truth for AI training. **100% accuracy is mandatory**. All data must be verified from official government sources only (state legislature websites, official state code databases, official AG offices, official agency .gov sites).

## Repository Structure

```
us-transparency-laws-database/
├── templates/                          # v0.11 templates for all data types
│   ├── json/                          # JSON templates (jurisdictions, agencies, databases)
│   ├── markdown/                      # Process map templates
│   ├── statutory-text_template-v0.11.txt
│   └── state-agencies_template-v0.11.json
├── data/
│   ├── federal/                       # Federal FOIA data (agencies.json, templates.json)
│   ├── states/                        # 50 state directories, each with agencies.json
│   └── consolidated/                  # Master database and tracking table
├── consolidated-transparency-data/
│   ├── verified-process-maps/         # Jurisdiction-specific process maps
│   └── statutory-text-files/          # Full statutory text (currently empty)
├── documentation/                      # Validation methodology, verification guides
├── statutory-data/                     # Ground truth data organized by version
├── schemas/                           # Data validation schemas (currently empty)
└── scripts/                           # Migration scripts (Python and shell)
```

## Data Architecture

### Three-Layer Data Model

1. **Raw Statutory Data** (`statutory-data/`)
   - Full statute text files
   - Official statutory citations
   - Ground truth from official sources only

2. **Structured Jurisdiction Data** (`data/states/`, `data/federal/`)
   - Parsed statute information in JSON format
   - Agency contact databases
   - Request templates
   - Each state has its own directory with `agencies.json`

3. **Consolidated Resources** (`data/consolidated/`, `consolidated-transparency-data/`)
   - Master tracking table for all 51 jurisdictions
   - Consolidated master database
   - Verified process maps for each jurisdiction

### Key Data Files (Currently Templates)

- **`data/consolidated/master_tracking_table-template.json`**: Tracks completion status for all 51 jurisdictions, including priority levels, statute collection status, agency data collection status, and template creation status
- **`templates/json/STANDARD_JURISDICTION_TEMPLATE_template-v0.11.json`**: Standard schema for jurisdiction data including statute details, response requirements, appeal process, fee structure, exemptions, requester requirements, agency obligations, oversight body, and validation metadata
- **State agencies files**: `data/states/{state-name}/agencies.json` - Contains jurisdiction info, transparency law details, and agency contact information

## Data Validation Rules (CRITICAL)

### ONLY Acceptable Sources:
1. Official State Legislature Websites (e.g., legis.state.xx.us)
2. Official State Code/Statute Databases (e.g., revisor.mn.gov, codes.ohio.gov)
3. Official State Attorney General Offices (for FOIA guidance)
4. Official State Archives/Records Offices (for procedural guidance)
5. Official Agency FOIA Pages (.gov domains only)

### PROHIBITED Sources:
- Perplexity AI or any AI summarization
- Wikipedia or collaborative wikis
- Legal blog posts or commentary
- Third-party law firm summaries
- News articles or media summaries

### Data Quality Standards:
- All legal citations must be verified from official sources
- Response timelines must distinguish between business days and calendar days
- Fee structures must reflect exact statutory language
- All URLs must link directly to official .gov sites
- Validation metadata must document verification date and primary sources

## Working with This Repository

### Adding New Jurisdiction Data

1. Start with the template: `templates/json/STANDARD_JURISDICTION_TEMPLATE_template-v0.11.json`
2. Locate official state statute from acceptable sources only
3. Fill in all fields following validation methodology in `documentation/VALIDATION_METHODOLOGY.md`
4. Update tracking table: `data/consolidated/master_tracking_table-template.json`
5. Create corresponding process map in `consolidated-transparency-data/verified-process-maps/`

### Data Migration Tools

- **`scripts/migrate_data_files.sh`**: Shell script for bulk data migration
- **`scripts/complete_migration.py`**: Python script for data processing and validation

### Version Naming Convention

All templates use the suffix `_template-v0.11` to indicate:
- Data has been cleared (template mode)
- Version 0.11 of the template schema
- Ready for population with verified data

## Integration Points

This repository is part of the HOLE Foundation ecosystem:
- **theholetruth-platform**: React application consuming this database
- **foundation-meta**: Central coordination repository
- Database is structured for Supabase compatibility
- JSON structure designed for direct API consumption

## Development Commands

### Supabase Development
```bash
# Start Supabase local development
cd supabase && pnpm setup:cli

# Generate TypeScript types from database
pnpm generate:types

# Run development server
pnpm dev

# Build for production
pnpm build

# Run linting and formatting
pnpm lint
pnpm typecheck
pnpm test:prettier
pnpm format
```

### Data Migration and Validation
```bash
# Run data migration scripts
./scripts/migrate_data_files.sh
python3 scripts/complete_migration.py

# Find and resolve duplicates
python3 scripts/find_duplicates.py

# Extract and process map data
python3 scripts/extract_map_data.py

# Rename files to v0.11 convention
python3 scripts/rename_to_v0_11.py
```

### Data Validation (Required for PR approval)
```bash
# Verify all 51 jurisdictions present
scripts/verify_jurisdictions.sh

# Validate JSON schema compliance
scripts/validate_data.py

# Check Supabase compatibility
scripts/check_supabase.sh
```

## Architecture Overview

### Database Design
- **Supabase Backend**: Full Supabase integration with TypeScript types generated from schema
- **Three-Layer Architecture**: Raw statutory → Structured jurisdiction → Consolidated resources
- **Cross-Repository Integration**: Designed to serve theholetruth-platform React application

### Code Quality Gates
- Minimum 80% test coverage required
- Maximum complexity score of 10
- TypeScript definitions required for all data structures
- Naming conventions enforced per .github/claude-code.yml

### Development Workflow
1. **Data Entry**: Start with templates in `templates/json/`
2. **Validation**: Use official government sources only (see validation rules)
3. **Migration**: Run migration scripts to organize data
4. **Integration**: Sync with Supabase schema using `pnpm generate:types`
5. **Quality Checks**: All PRs require Claude Code review and custom validation scripts

## Important Notes

- README.md describes the repository as "production ready" but this reflects the template structure, not data completeness
- Current state: All data files are empty templates awaiting verified data
- Priority jurisdictions: Federal (priority 1), major states including CA, FL, IL, NY, TX (priority 2), all others (priority 3)
- Target: 51 total jurisdictions (50 states + DC + Federal)
- **Package Manager**: Use `pnpm` (required by Supabase setup, engines requirement: pnpm >=10.16)