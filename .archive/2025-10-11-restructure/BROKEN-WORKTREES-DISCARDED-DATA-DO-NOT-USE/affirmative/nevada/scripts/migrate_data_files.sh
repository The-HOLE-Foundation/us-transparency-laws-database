#!/bin/bash

# Data Migration Script for HOLE Foundation Project Reorganization
# This script moves Copilot-generated files to proper repository structure

echo "🔄 Starting HOLE Foundation Data Migration..."

SOURCE_DIR="/Users/jth/Desktop/HOLE-Foundation/The HOLE Truth Project/website/THE-HOLE-TRUTH-PROJECT/FOIA-Data-Collection-HOME/project"
TARGET_DIR="/Users/jth/Desktop/AI-Chat-Archive/Statute-Project/data"

# Create state mapping for proper naming
declare -A state_mapping=(
    ["wisconsin"]="wisconsin"
    ["ohio"]="ohio"
    ["hawaii"]="hawaii"
    ["nevada"]="nevada"
    ["nebraska"]="nebraska"
    ["indiana"]="indiana"
    ["mississippi"]="mississippi"
    ["wyoming"]="wyoming"
    ["north_dakota"]="north-dakota"
    ["south_carolina"]="south-carolina"
    ["arkansas"]="arkansas"
    ["connecticut"]="connecticut"
    ["iowa"]="iowa"
    ["montana"]="montana"
    ["idaho"]="idaho"
    ["rhode_island"]="rhode-island"
    ["maine"]="maine"
    ["utah"]="utah"
    ["kansas"]="kansas"
    ["alabama"]="alabama"
    ["alaska"]="alaska"
    ["arizona"]="arizona"
    ["california"]="california"
    ["colorado"]="colorado"
    ["delaware"]="delaware"
    ["florida"]="florida"
    ["georgia"]="georgia"
    ["illinois"]="illinois"
    ["kentucky"]="kentucky"
    ["louisiana"]="louisiana"
    ["maryland"]="maryland"
    ["massachusetts"]="massachusetts"
    ["michigan"]="michigan"
    ["minnesota"]="minnesota"
    ["missouri"]="missouri"
    ["new_hampshire"]="new-hampshire"
    ["new_jersey"]="new-jersey"
    ["new_mexico"]="new-mexico"
    ["new_york"]="new-york"
    ["north_carolina"]="north-carolina"
    ["oklahoma"]="oklahoma"
    ["oregon"]="oregon"
    ["pennsylvania"]="pennsylvania"
    ["south_dakota"]="south-dakota"
    ["tennessee"]="tennessee"
    ["texas"]="texas"
    ["vermont"]="vermont"
    ["virginia"]="virginia"
    ["washington"]="washington"
    ["west_virginia"]="west-virginia"
)

# Function to migrate state agency files
migrate_state_files() {
    local count=0

    for file in "$SOURCE_DIR"/*_agencies_database.json; do
        if [ -f "$file" ]; then
            # Extract state name from filename
            filename=$(basename "$file")
            state_raw=${filename%_agencies_database.json}

            # Map to proper state directory name
            state_dir=${state_mapping[$state_raw]}

            if [ -n "$state_dir" ] && [ -d "$TARGET_DIR/states/$state_dir" ]; then
                # Copy file with proper naming
                cp "$file" "$TARGET_DIR/states/$state_dir/agencies.json"
                echo "✅ Migrated $state_raw -> $state_dir/agencies.json"
                ((count++))
            else
                echo "❌ Could not map state: $state_raw"
            fi
        fi
    done

    echo "📊 Migrated $count state agency files"
}

# Function to migrate other data files
migrate_consolidated_files() {
    echo "🔄 Looking for consolidated database files..."

    # Look for master files
    if [ -f "$SOURCE_DIR/master_tracking_table.json" ]; then
        cp "$SOURCE_DIR/master_tracking_table.json" "$TARGET_DIR/consolidated/"
        echo "✅ Migrated master tracking table"
    fi

    if [ -f "$SOURCE_DIR/comprehensive_transparency_database.json" ]; then
        cp "$SOURCE_DIR/comprehensive_transparency_database.json" "$TARGET_DIR/consolidated/master-database.json"
        echo "✅ Migrated comprehensive database"
    fi

    # Look for federal files
    if [ -f "$SOURCE_DIR/federal_agencies_database.json" ]; then
        cp "$SOURCE_DIR/federal_agencies_database.json" "$TARGET_DIR/federal/agencies.json"
        echo "✅ Migrated federal agencies"
    fi

    if [ -f "$SOURCE_DIR/federal_foia_templates.json" ]; then
        cp "$SOURCE_DIR/federal_foia_templates.json" "$TARGET_DIR/federal/templates.json"
        echo "✅ Migrated federal templates"
    fi
}

# Execute migrations
echo "🎯 Starting state agency file migration..."
migrate_state_files

echo "🎯 Starting consolidated file migration..."
migrate_consolidated_files

echo "✅ Data migration completed!"
echo "📁 Files organized in: $TARGET_DIR"