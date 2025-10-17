#!/bin/bash
#
# Repository Reorganization Script
# Reorganizes us-transparency-laws-database into clean v0.11.0 structure
#
# IMPORTANT: Review REPOSITORY_REORGANIZATION_PLAN.md before running
#

set -e  # Exit on error

echo "🔄 Starting Repository Reorganization..."
echo ""

# Confirm with user
read -p "Have you reviewed REPOSITORY_REORGANIZATION_PLAN.md? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Please review the reorganization plan first."
    exit 1
fi

echo ""
echo "📁 Creating new directory structure..."

# Create new structure
mkdir -p releases/v0.11.0/{jurisdictions,process-maps,reference,metadata}
mkdir -p supabase/{migrations,functions}
mkdir -p future/{v0.12/{agencies,templates},v0.13/training-examples}
mkdir -p dev/{scripts,workflows,schemas}
mkdir -p archive/{process-artifacts,duplicates,old-structure,sessions,quarantine}
mkdir -p docs/{releases,guides}

echo "✅ Directory structure created"
echo ""

# ============================================================================
# STEP 1: Copy v0.11.0 Production Data to releases/
# ============================================================================

echo "📦 Step 1: Copying v0.11.0 production data..."

# Federal jurisdiction
echo "  Copying Federal jurisdiction..."
cp data/federal/jurisdiction-data.json releases/v0.11.0/jurisdictions/federal.json

# All 51 states (including DC)
echo "  Copying 51 state jurisdictions..."
for state_dir in data/states/*; do
    state_name=$(basename "$state_dir")
    if [ -f "$state_dir/jurisdiction-data.json" ]; then
        cp "$state_dir/jurisdiction-data.json" "releases/v0.11.0/jurisdictions/${state_name}.json"
    fi
done

# Process maps
echo "  Copying 52+ process maps..."
cp consolidated-transparency-data/verified-process-maps/*-v0.11.md releases/v0.11.0/process-maps/

# Reference materials
echo "  Copying reference materials..."
if [ -f "reference/holidays-matrix.csv" ]; then
    cp reference/holidays-matrix.csv releases/v0.11.0/reference/
fi
if [ -f "reference/statute-names-reference.md" ]; then
    cp reference/statute-names-reference.md releases/v0.11.0/reference/
fi

# Metadata
echo "  Copying metadata..."
cp data/consolidated/master_tracking_table-template.json releases/v0.11.0/metadata/tracking.json

# Create README for release
cat > releases/v0.11.0/README.md << 'EOF'
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
EOF

echo "✅ Production data copied to releases/v0.11.0/"
echo ""

# ============================================================================
# STEP 2: Move Development Tools
# ============================================================================

echo "🛠️  Step 2: Moving development tools..."

# Scripts
if [ -d "scripts" ]; then
    cp -r scripts/* dev/scripts/
    echo "  ✅ Scripts moved"
fi

# Workflows
if [ -d "workflows" ]; then
    cp -r workflows/* dev/workflows/
    echo "  ✅ Workflows moved"
fi

# Schemas
if [ -d "schemas" ]; then
    cp -r schemas/* dev/schemas/
    echo "  ✅ Schemas moved"
fi

# Templates (these are dev templates, not production data)
if [ -d "templates" ]; then
    cp -r templates/* dev/schemas/templates/
    mkdir -p dev/schemas/templates
    echo "  ✅ Templates moved"
fi

echo ""

# ============================================================================
# STEP 3: Archive Process Artifacts
# ============================================================================

echo "📦 Step 3: Archiving process artifacts..."

# Transparency-Data directory
if [ -d "Transparency-Data" ]; then
    mv Transparency-Data archive/process-artifacts/
    echo "  ✅ Transparency-Data archived"
fi

# Consolidated-Datasets
if [ -d "Consolidated-Datasets" ]; then
    mv Consolidated-Datasets archive/duplicates/
    echo "  ✅ Consolidated-Datasets archived"
fi

# Transparency-Map-Dataset
if [ -d "Transparency-Map-Dataset" ]; then
    mv Transparency-Map-Dataset archive/process-artifacts/
    echo "  ✅ Transparency-Map-Dataset archived"
fi

# Quarantined data
if [ -d "data/QUARANTINE-QUESTIONABLE-DATA-2025-10-03" ]; then
    mv data/QUARANTINE-QUESTIONABLE-DATA-2025-10-03 archive/quarantine/
    echo "  ✅ Quarantined data archived"
fi

# Old data structure (keep for reference)
echo "  Archiving old data structure..."
mkdir -p archive/old-structure/data
cp -r data/consolidated archive/old-structure/data/ 2>/dev/null || true
cp -r data/federal archive/old-structure/data/ 2>/dev/null || true
cp -r data/states archive/old-structure/data/ 2>/dev/null || true

echo ""

# ============================================================================
# STEP 4: Consolidate Documentation
# ============================================================================

echo "📚 Step 4: Consolidating documentation..."

# Move old documentation
if [ -d "documentation" ]; then
    mv documentation docs/archive
    echo "  ✅ Old documentation archived"
fi

# Release notes
if [ -f "RELEASE_NOTES_v0.11.0.md" ]; then
    mv RELEASE_NOTES_v0.11.0.md docs/releases/
    echo "  ✅ Release notes moved"
fi

# Session notes
for session_file in *SESSION*.md CURRENT_STATUS*.md FINAL_STATUS*.md NEXT_SESSION*.md; do
    if [ -f "$session_file" ]; then
        mv "$session_file" archive/sessions/ 2>/dev/null || true
    fi
done
echo "  ✅ Session notes archived"

# Create main docs
mkdir -p docs
if [ ! -f "docs/README.md" ]; then
    cat > docs/README.md << 'EOF'
# Documentation

## Architecture
- [PROJECT_ECOSYSTEM.md](../PROJECT_ECOSYSTEM.md) - Complete project architecture
- [VERSION.md](../VERSION.md) - Current version and roadmap

## Releases
- [v0.11.0](releases/RELEASE_NOTES_v0.11.0.md) - Complete Layer 2 metadata

## Guides
- Coming in v0.11.1: Supabase integration guide
- Coming in v0.12: Agency data collection guide

## Archive
- [archive/](archive/) - Historical documentation and process artifacts
EOF
fi

echo ""

# ============================================================================
# STEP 5: Clean Up Stale Files
# ============================================================================

echo "🧹 Step 5: Cleaning up stale files..."

# Remove stale status files (superseded by VERSION.md)
rm -f .validation-conflicts.json
echo "  ✅ Removed .validation-conflicts.json"

echo ""

# ============================================================================
# STEP 6: Initialize Supabase Structure
# ============================================================================

echo "🚀 Step 6: Initializing Supabase structure..."

# Create initial migration
cat > supabase/migrations/00000000000000_initial_schema.sql << 'EOF'
-- v0.11.0 Initial Schema
-- Generated from releases/v0.11.0/ data structure
--
-- This migration will be populated with the full schema
-- during Supabase integration (v0.11.1)

-- Placeholder for jurisdictions table
-- CREATE TABLE jurisdictions (...);

-- TODO: Generate complete schema from JSON structure
EOF

# Create config
cat > supabase/config.toml << 'EOF'
# Supabase Configuration
# Project: US Transparency Laws Database (v0.11.0)

[project]
name = "us-transparency-laws"

[api]
enabled = true
port = 54321
schemas = ["public", "storage"]
extra_search_path = ["public"]

[db]
port = 54322
shadow_port = 54320
major_version = 15

[studio]
enabled = true
port = 54323

[auth]
enabled = true
site_url = "https://theholetruth.org"
additional_redirect_urls = ["https://theholefoundation.org"]
external_email_enabled = true
external_anonymous_users_enabled = false
EOF

# Create Edge Function template
mkdir -p supabase/functions/generate-foia
cat > supabase/functions/generate-foia/index.ts << 'EOF'
// Edge Function: FOIA Generator (Azure AI Integration)
// Status: Placeholder - implement in v0.11.1

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  // TODO: Implement Azure AI integration
  return new Response(
    JSON.stringify({ message: "FOIA Generator - Coming in v0.11.1" }),
    { headers: { "Content-Type": "application/json" } },
  )
})
EOF

echo "  ✅ Supabase structure initialized"
echo ""

# ============================================================================
# STEP 7: Update README
# ============================================================================

echo "📝 Step 7: Updating README references..."

# README will need manual updates to reference new structure
echo "  ⚠️  README.md needs manual update for new paths"
echo ""

# ============================================================================
# Verification
# ============================================================================

echo "✅ Reorganization Complete!"
echo ""
echo "📊 Verification Summary:"
echo ""

# Count jurisdictions
JURISDICTION_COUNT=$(find releases/v0.11.0/jurisdictions -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
echo "  Jurisdictions in releases/v0.11.0/: $JURISDICTION_COUNT"

# Count process maps
MAPS_COUNT=$(find releases/v0.11.0/process-maps -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
echo "  Process maps in releases/v0.11.0/: $MAPS_COUNT"

# Check supabase
if [ -d "supabase" ]; then
    echo "  ✅ Supabase structure created"
fi

# Check future directories
if [ -d "future/v0.12" ]; then
    echo "  ✅ Future enhancement directories created"
fi

echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Review the new structure:"
echo "   - releases/v0.11.0/ (production data)"
echo "   - supabase/ (integration work)"
echo "   - dev/ (development tools)"
echo "   - archive/ (historical artifacts)"
echo ""
echo "2. Verify all production data is present:"
echo "   - 52 jurisdiction JSON files"
echo "   - 52+ process maps"
echo "   - Reference materials"
echo ""
echo "3. Update README.md with new directory paths"
echo ""
echo "4. Commit the reorganization:"
echo "   git add -A"
echo "   git commit -m 'refactor: Reorganize repository for v0.11.1 Supabase integration'"
echo ""
echo "5. Begin Supabase schema design using releases/v0.11.0/ data"
echo ""
echo "🎯 Ready for Supabase Integration (v0.11.1)!"
