# Data Directory Structure

This directory contains all transparency law data organized by jurisdiction.

## Directory Structure

### `/federal/`
Federal FOIA statute, agencies, and templates.

### `/states/`
Individual state directories containing:
- `statute.json` - State transparency law details
- `agencies.json` - State agency contact information
- `templates.json` - State-specific request templates

### `/consolidated/`
- `master-database.json` - Complete consolidated database
- `tracking-table.json` - Progress tracking for all jurisdictions
- `validation-status.json` - Data validation status

## File Naming Conventions

- State directories: kebab-case (e.g., `new-york/`, `north-dakota/`)
- JSON files: kebab-case with purpose (e.g., `texas-statute.json`)
- Documentation: descriptive kebab-case

## Data Quality Standards

- All data verified from official .gov sources
- Current as of 2024-2025
- Cross-referenced for accuracy
- Structured for database import