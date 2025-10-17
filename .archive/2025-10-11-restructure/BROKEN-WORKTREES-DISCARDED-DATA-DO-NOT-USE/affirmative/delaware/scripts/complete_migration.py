#!/usr/bin/env python3
"""
Complete State Data Migration Script
Migrates all Copilot-generated state JSON files to proper repository structure
"""

import os
import json
import shutil
from pathlib import Path

def get_state_mapping():
    """Map underscored state names to kebab-case directory names"""
    return {
        'wisconsin': 'wisconsin',
        'ohio': 'ohio',
        'hawaii': 'hawaii',
        'nevada': 'nevada',
        'nebraska': 'nebraska',
        'indiana': 'indiana',
        'mississippi': 'mississippi',
        'wyoming': 'wyoming',
        'north_dakota': 'north-dakota',
        'south_carolina': 'south-carolina',
        'arkansas': 'arkansas',
        'connecticut': 'connecticut',
        'iowa': 'iowa',
        'montana': 'montana',
        'idaho': 'idaho',
        'rhode_island': 'rhode-island',
        'maine': 'maine',
        'utah': 'utah',
        'kansas': 'kansas',
        'alabama': 'alabama',
        'alaska': 'alaska',
        'arizona': 'arizona',
        'california': 'california',
        'colorado': 'colorado',
        'delaware': 'delaware',
        'florida': 'florida',
        'georgia': 'georgia',
        'illinois': 'illinois',
        'kentucky': 'kentucky',
        'louisiana': 'louisiana',
        'maryland': 'maryland',
        'massachusetts': 'massachusetts',
        'michigan': 'michigan',
        'minnesota': 'minnesota',
        'missouri': 'missouri',
        'new_hampshire': 'new-hampshire',
        'new_jersey': 'new-jersey',
        'new_mexico': 'new-mexico',
        'new_york': 'new-york',
        'north_carolina': 'north-carolina',
        'oklahoma': 'oklahoma',
        'oregon': 'oregon',
        'pennsylvania': 'pennsylvania',
        'south_dakota': 'south-dakota',
        'tennessee': 'tennessee',
        'texas': 'texas',
        'vermont': 'vermont',
        'virginia': 'virginia',
        'washington': 'washington',
        'west_virginia': 'west-virginia'
    }

def migrate_state_files():
    """Migrate all state agency database files"""
    source_dir = Path("/Users/jth/Desktop/HOLE-Foundation/The HOLE Truth Project/website/THE-HOLE-TRUTH-PROJECT/FOIA-Data-Collection-HOME/project")
    target_base = Path("/Users/jth/Desktop/AI-Chat-Archive/Statute-Project/data/states")

    state_mapping = get_state_mapping()
    migrated_count = 0

    print("🔄 Starting complete state file migration...")

    # Find all state agency database files
    agency_files = list(source_dir.glob("*_agencies_database.json"))
    print(f"📁 Found {len(agency_files)} state agency database files")

    for file_path in agency_files:
        # Extract state name from filename
        filename = file_path.stem
        state_raw = filename.replace('_agencies_database', '')

        # Map to proper directory name
        if state_raw in state_mapping:
            state_dir = state_mapping[state_raw]
            target_dir = target_base / state_dir
            target_file = target_dir / "agencies.json"

            # Create directory if it doesn't exist
            target_dir.mkdir(exist_ok=True)

            # Copy file
            try:
                shutil.copy2(file_path, target_file)
                print(f"✅ Migrated {state_raw} -> {state_dir}/agencies.json")
                migrated_count += 1
            except Exception as e:
                print(f"❌ Error migrating {state_raw}: {e}")
        else:
            print(f"❌ Could not map state: {state_raw}")

    print(f"📊 Successfully migrated {migrated_count} state agency files")
    return migrated_count

def create_migration_report():
    """Create a report of the migration results"""
    data_dir = Path("/Users/jth/Desktop/AI-Chat-Archive/Statute-Project/data")

    report = {
        "migration_date": "2024-09-24",
        "migration_summary": {
            "federal_files": 0,
            "state_files": 0,
            "consolidated_files": 0,
            "total_files": 0
        },
        "state_coverage": {},
        "file_inventory": {}
    }

    # Count federal files
    federal_dir = data_dir / "federal"
    if federal_dir.exists():
        federal_files = list(federal_dir.glob("*.json"))
        report["migration_summary"]["federal_files"] = len(federal_files)
        report["file_inventory"]["federal"] = [f.name for f in federal_files]

    # Count consolidated files
    consolidated_dir = data_dir / "consolidated"
    if consolidated_dir.exists():
        consolidated_files = list(consolidated_dir.glob("*.json"))
        report["migration_summary"]["consolidated_files"] = len(consolidated_files)
        report["file_inventory"]["consolidated"] = [f.name for f in consolidated_files]

    # Count state files
    states_dir = data_dir / "states"
    if states_dir.exists():
        state_count = 0
        for state_dir in states_dir.iterdir():
            if state_dir.is_dir():
                state_files = list(state_dir.glob("*.json"))
                if state_files:
                    report["state_coverage"][state_dir.name] = len(state_files)
                    state_count += len(state_files)
        report["migration_summary"]["state_files"] = state_count

    # Calculate total
    report["migration_summary"]["total_files"] = (
        report["migration_summary"]["federal_files"] +
        report["migration_summary"]["state_files"] +
        report["migration_summary"]["consolidated_files"]
    )

    # Write report
    report_file = data_dir / "MIGRATION_REPORT.json"
    with open(report_file, 'w') as f:
        json.dump(report, f, indent=2)

    print(f"📋 Migration report created: {report_file}")
    return report

def main():
    """Execute complete migration"""
    print("🚀 HOLE Foundation - Complete Data Migration")
    print("=" * 50)

    # Migrate state files
    migrated_count = migrate_state_files()

    # Create migration report
    report = create_migration_report()

    print("\n📊 MIGRATION SUMMARY:")
    print(f"  • Federal files: {report['migration_summary']['federal_files']}")
    print(f"  • State files: {report['migration_summary']['state_files']}")
    print(f"  • Consolidated files: {report['migration_summary']['consolidated_files']}")
    print(f"  • Total files: {report['migration_summary']['total_files']}")
    print(f"  • States with data: {len(report['state_coverage'])}")

    print(f"\n✅ Migration completed successfully!")
    print(f"📁 All files organized in proper repository structure")

if __name__ == "__main__":
    main()