# US Transparency Laws Database - AI Development Guidelines

## Project Context

This repository contains a **production-ready database of US transparency laws** (FOIA/public records) for all 51 jurisdictions (50 states + DC + Federal). The project is currently in **template mode (v0.11)** - all data files are empty templates awaiting verified statutory data that will serve as ground truth for AI training.

## Critical Data Accuracy Requirements

**100% accuracy is mandatory** - this database serves as AI training ground truth. Only use **official government sources**:
- State legislature websites (legis.state.xx.us)
- Official state code databases (revisor.mn.gov, codes.ohio.gov)
- Official Attorney General offices (.gov domains)
- Official state archives/records offices

**NEVER use**: Perplexity AI, Wikipedia, legal blogs, third-party summaries, or any non-official sources.

## Architecture Overview

### Three-Layer Data Model
1. **Raw Statutory Data** (`consolidated-transparency-data/statutory-text-files/`) - Full statute text files
2. **Structured Jurisdiction Data** (`data/states/`, `data/federal/`) - Parsed JSON with agency databases
3. **Consolidated Resources** (`data/consolidated/`, `Consolidated-Datasets/`) - Master database and tracking

### Key Data Files Structure
- **Template System**: All files use `_template-v0.11` suffix indicating cleared/template state
- **State Data**: Each state has `data/states/{state-name}/agencies.json` following kebab-case naming
- **Master Tracking**: `data/consolidated/master_tracking_table-template.json` tracks completion for all 51 jurisdictions
- **Standard Schema**: `templates/json/STANDARD_JURISDICTION_TEMPLATE_template-v0.11.json` defines structure

## Development Workflows

### Data Migration Commands
```bash
# Migrate data files from source to proper structure
./scripts/migrate_data_files.sh
python3 scripts/complete_migration.py

# Find and resolve data duplicates
python3 scripts/find_duplicates.py

# Rename files to v0.11 convention
python3 scripts/rename_to_v0_11.py
```

### Supabase Integration (when ready for production)
- **Package Manager**: Use `pnpm` (required - see engines in package.json)
- **Timeline Codes**: Negative integers handle non-fixed deadlines (-1 = "reasonable time", -2 = "promptly")
- **Schema**: `Transparency-Map-Dataset/supabase-schema.sql` defines production database structure

### Validation Workflow
Always follow the validation checklist in `documentation/VALIDATION_METHODOLOGY.md`:
1. Statute identification from official sources
2. Response time verification (business vs calendar days)
3. Appeal process verification
4. Fee structure verification
5. Exemption verification with exact citations
6. Official resources verification (test all URLs)

## Project-Specific Patterns

### File Naming Conventions
- States: `{state-name}/agencies.json` (kebab-case, e.g., `north-dakota`, `south-carolina`)
- Templates: `{basename}_template-v0.11.{ext}`
- Statutory text: `{JURISDICTION}_transparency_law-v0.11.txt`

### JSON Structure Requirements
- Include `validation_audit` object documenting sources and verification
- Use exact statutory language for legal citations
- Distinguish business_days vs calendar_days in timing fields
- Include `confidence_level` (high/medium/low) based on source quality

### State Mapping (for migration scripts)
The codebase uses specific state name mappings in `scripts/complete_migration.py` - always reference this for underscore-to-kebab conversions.

## Cross-Repository Integration

This repository integrates with the broader HOLE Foundation ecosystem:
- **theholetruth-platform**: React app consuming this database
- **foundation-meta**: Central coordination repository
- **Transparency-Map-Dataset**: Supabase-ready subset for interactive map

## Development Priorities

1. **Critical Path**: Statute validation blocks all legal-accuracy features
2. **Parallel Development**: 80% of work can proceed with mock data while validation completes
3. **Priority Jurisdictions**: Federal (priority 1), major states CA/FL/IL/NY/TX (priority 2), all others (priority 3)

## Quality Gates

- All legal data must include primary source URLs
- Response timelines must specify business vs calendar days
- Fee structures must reflect exact statutory language
- No AI-generated legal interpretations without official source verification
- All 51 jurisdictions must be represented in tracking table

## Integration Commands

```bash
# Extract map data for Supabase integration
python3 scripts/extract_map_data.py

# Validate against schemas (when implemented)
node Transparency-Map-Dataset/validation/validate-map-data.js

# Generate migration reports
python3 scripts/complete_migration.py
```

When working with this codebase, prioritize data accuracy over development speed - incorrect legal information has serious real-world consequences.