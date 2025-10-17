#!/usr/bin/env python3
"""
Generate master holiday matrix from individual jurisdiction JSON files.

This script consolidates all holiday data from individual jurisdiction files
into a master JSON matrix and CSV files for easy comparison across jurisdictions.
"""

import json
import csv
from pathlib import Path
from datetime import datetime
from collections import defaultdict
from typing import Dict, List, Any

# Define the base directory
BASE_DIR = Path("/Volumes/HOLE-RAID-DRIVE/HOLE/Projects/us-transparency-laws-database")
JSON_DIR = BASE_DIR / "data/holiday-tracking-matrix/json"
CSV_DIR = BASE_DIR / "data/holiday-tracking-matrix/csv"

# Ensure CSV directory exists
CSV_DIR.mkdir(parents=True, exist_ok=True)

# Holiday name normalization mapping
HOLIDAY_NORMALIZATION = {
    "Birthday of Martin Luther King, Jr.": "MLK Jr. Day",
    "Martin Luther King Jr. Day": "MLK Jr. Day",
    "Martin Luther King, Jr. Day": "MLK Jr. Day",
    "Washington's Birthday": "Presidents' Day",
    "President's Day": "Presidents' Day",
    "Presidents' Day": "Presidents' Day",
    "Presidents Day": "Presidents' Day",
    "Day after Thanksgiving": "Day After Thanksgiving",
    "Friday after Thanksgiving": "Day After Thanksgiving",
    "Emancipation Day in Texas (Juneteenth)": "Juneteenth",
    "Juneteenth National Independence Day": "Juneteenth",
}

# Jurisdiction name to abbreviation mapping
JURISDICTION_ABBREV = {
    "Federal": "US",
    "Arizona": "AZ",
    "California": "CA",
    "Florida": "FL",
    "Georgia": "GA",
    "Illinois": "IL",
    "Michigan": "MI",
    "New York": "NY",
    "North Carolina": "NC",
    "Ohio": "OH",
    "Pennsylvania": "PA",
    "Texas": "TX",
}

def normalize_holiday_name(name: str) -> str:
    """Normalize holiday names across jurisdictions."""
    return HOLIDAY_NORMALIZATION.get(name, name)

def load_all_holidays() -> Dict[str, Dict[int, Any]]:
    """Load all holiday JSON files and organize by jurisdiction and year."""
    jurisdictions = defaultdict(dict)

    # Get all JSON files
    json_files = sorted(JSON_DIR.glob("*-holidays-*.json"))

    for json_file in json_files:
        try:
            with open(json_file, 'r') as f:
                data = json.load(f)

            jurisdiction = data.get('jurisdiction', '')
            year = data.get('year', 0)

            if jurisdiction and year:
                # Store the complete data
                jurisdictions[jurisdiction][year] = data

        except Exception as e:
            print(f"Error loading {json_file}: {e}")

    return dict(jurisdictions)

def build_holiday_comparison(jurisdictions_data: Dict) -> Dict[str, Dict]:
    """Build a comparison matrix of all holidays across jurisdictions and years."""
    holiday_comparison = defaultdict(lambda: defaultdict(dict))

    for jurisdiction, years_data in jurisdictions_data.items():
        for year, data in years_data.items():
            for holiday in data.get('holidays', []):
                holiday_name = normalize_holiday_name(holiday['name'])
                observed_date = holiday['observed_date']

                # Store just the date (YYYY-MM-DD format)
                if jurisdiction not in holiday_comparison[holiday_name]:
                    holiday_comparison[holiday_name][jurisdiction] = {}

                holiday_comparison[holiday_name][jurisdiction][str(year)] = observed_date

    return dict(holiday_comparison)

def get_unique_holidays_by_state(jurisdictions_data: Dict) -> Dict[str, List[str]]:
    """Identify unique holidays observed by each jurisdiction."""
    unique_holidays = defaultdict(set)
    all_holidays = defaultdict(int)

    # Count how many jurisdictions observe each holiday
    for jurisdiction, years_data in jurisdictions_data.items():
        for year, data in years_data.items():
            for holiday in data.get('holidays', []):
                holiday_name = normalize_holiday_name(holiday['name'])
                all_holidays[holiday_name] += 1
                unique_holidays[jurisdiction].add(holiday_name)

    # Find holidays unique to each jurisdiction (or observed by few)
    state_unique = {}
    for jurisdiction, holidays in unique_holidays.items():
        state_specific = [h for h in holidays if all_holidays[h] <= 3]
        if state_specific:
            state_unique[jurisdiction] = sorted(state_specific)

    return state_unique

def generate_master_json(jurisdictions_data: Dict, holiday_comparison: Dict) -> Dict:
    """Generate the master JSON matrix."""
    completed_jurisdictions = sorted(jurisdictions_data.keys())

    # All 51 jurisdictions
    all_jurisdictions = ["Federal"] + [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
        "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia",
        "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky",
        "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
        "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
        "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota",
        "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
        "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia",
        "Washington", "West Virginia", "Wisconsin", "Wyoming"
    ]

    pending_jurisdictions = sorted(set(all_jurisdictions) - set(completed_jurisdictions))

    # Determine which years have data
    all_years = set()
    for years_data in jurisdictions_data.values():
        all_years.update(years_data.keys())

    master_data = {
        "metadata": {
            "created_date": datetime.now().strftime("%Y-%m-%d"),
            "total_jurisdictions": 51,
            "completed_jurisdictions": completed_jurisdictions,
            "pending_jurisdictions": pending_jurisdictions,
            "completed_count": len(completed_jurisdictions),
            "pending_count": len(pending_jurisdictions),
            "data_years": sorted(all_years)
        },
        "jurisdictions": {},
        "holiday_comparison": holiday_comparison
    }

    # Build jurisdictions section
    for jurisdiction, years_data in jurisdictions_data.items():
        jurisdiction_key = jurisdiction.lower().replace(" ", "_")
        master_data["jurisdictions"][jurisdiction_key] = {}

        for year in [2025, 2026]:
            if year in years_data:
                # Include the full holiday data
                master_data["jurisdictions"][jurisdiction_key][str(year)] = years_data[year]
            else:
                master_data["jurisdictions"][jurisdiction_key][str(year)] = None

    return master_data

def generate_csv_matrix(jurisdictions_data: Dict, year: int):
    """Generate CSV matrix for a specific year."""
    # Collect all unique holidays for this year
    all_holidays = set()
    jurisdiction_holidays = defaultdict(dict)

    for jurisdiction, years_data in jurisdictions_data.items():
        if year in years_data:
            for holiday in years_data[year].get('holidays', []):
                holiday_name = normalize_holiday_name(holiday['name'])
                all_holidays.add(holiday_name)

                # Store date in MM/DD format
                date_obj = datetime.strptime(holiday['observed_date'], '%Y-%m-%d')
                jurisdiction_holidays[jurisdiction][holiday_name] = date_obj.strftime('%m/%d')

    # Sort holidays chronologically by earliest occurrence
    holiday_dates = {}
    for jurisdiction, holidays in jurisdiction_holidays.items():
        for holiday_name, date_str in holidays.items():
            if holiday_name not in holiday_dates:
                holiday_dates[holiday_name] = date_str

    sorted_holidays = sorted(holiday_dates.items(), key=lambda x: x[1])

    # Generate CSV
    csv_file = CSV_DIR / f"master-holiday-matrix-{year}.csv"

    # Get jurisdiction abbreviations in order
    jurisdictions_ordered = sorted([j for j in jurisdictions_data.keys() if year in jurisdictions_data[j]])
    jurisdiction_abbrevs = [JURISDICTION_ABBREV.get(j, j[:2].upper()) for j in jurisdictions_ordered]

    with open(csv_file, 'w', newline='') as f:
        writer = csv.writer(f)

        # Header row
        header = ["Holiday Name"] + jurisdiction_abbrevs
        writer.writerow(header)

        # Data rows
        for holiday_name, _ in sorted_holidays:
            row = [holiday_name]

            for jurisdiction in jurisdictions_ordered:
                date_str = jurisdiction_holidays[jurisdiction].get(holiday_name, '-')
                row.append(date_str)

            writer.writerow(row)

    print(f"Generated CSV matrix for {year}: {csv_file}")
    return csv_file

def generate_status_report(jurisdictions_data: Dict, unique_holidays: Dict) -> str:
    """Generate completion status markdown report."""
    completed_jurisdictions = sorted(jurisdictions_data.keys())

    # All 51 jurisdictions
    all_jurisdictions = ["Federal"] + [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
        "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia",
        "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky",
        "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
        "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
        "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota",
        "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
        "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia",
        "Washington", "West Virginia", "Wisconsin", "Wyoming"
    ]

    pending_jurisdictions = sorted(set(all_jurisdictions) - set(completed_jurisdictions))

    # Check which jurisdictions have 2026 data
    has_2026 = [j for j in jurisdictions_data if 2026 in jurisdictions_data[j]]
    missing_2026 = [j for j in completed_jurisdictions if j not in has_2026]

    # Get weekend observation rules
    weekend_rules = {}
    for jurisdiction, years_data in jurisdictions_data.items():
        for year, data in years_data.items():
            rule = data.get('weekend_observation_rule', 'unknown')
            weekend_rules[jurisdiction] = rule
            break  # Just need one year's data

    # Generate report
    report = f"""---
DATE: {datetime.now().strftime('%Y-%m-%d')}
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Holiday Tracking Matrix
VERSION: v0.11
---

# Holiday Matrix Completion Status

## Overview

- **Total Jurisdictions**: 51 (50 states + DC + Federal)
- **Completed Jurisdictions**: {len(completed_jurisdictions)}
- **Pending Jurisdictions**: {len(pending_jurisdictions)}
- **Completion Percentage**: {(len(completed_jurisdictions) / 51 * 100):.1f}%

## Completed Jurisdictions

| Jurisdiction | 2025 Data | 2026 Data | Weekend Observation Rule |
|--------------|-----------|-----------|--------------------------|
"""

    for jurisdiction in completed_jurisdictions:
        has_2025 = "✓" if 2025 in jurisdictions_data[jurisdiction] else "✗"
        has_2026_mark = "✓" if 2026 in jurisdictions_data[jurisdiction] else "✗"
        rule = weekend_rules.get(jurisdiction, 'unknown')
        report += f"| {jurisdiction} | {has_2025} | {has_2026_mark} | {rule} |\n"

    report += f"\n## Pending Jurisdictions ({len(pending_jurisdictions)})\n\n"

    # Group by region for easier assignment
    regions = {
        "Northeast": ["Connecticut", "Maine", "Massachusetts", "New Hampshire",
                     "New Jersey", "Rhode Island", "Vermont"],
        "Mid-Atlantic": ["Delaware", "District of Columbia", "Maryland", "Virginia", "West Virginia"],
        "Southeast": ["Alabama", "Arkansas", "Kentucky", "Louisiana", "Mississippi",
                     "South Carolina", "Tennessee"],
        "Midwest": ["Indiana", "Iowa", "Kansas", "Minnesota", "Missouri", "Nebraska",
                   "North Dakota", "South Dakota", "Wisconsin"],
        "Southwest": ["Colorado", "New Mexico", "Oklahoma", "Utah"],
        "West": ["Alaska", "Hawaii", "Idaho", "Montana", "Nevada", "Oregon", "Washington", "Wyoming"]
    }

    for region, states in regions.items():
        region_pending = [s for s in states if s in pending_jurisdictions]
        if region_pending:
            report += f"\n### {region}\n"
            for state in region_pending:
                report += f"- {state}\n"

    report += f"\n## State-Specific Holidays\n\n"
    report += "Holidays observed by only a few jurisdictions:\n\n"

    for jurisdiction in sorted(unique_holidays.keys()):
        holidays = unique_holidays[jurisdiction]
        if holidays:
            report += f"\n### {jurisdiction}\n"
            for holiday in holidays:
                report += f"- {holiday}\n"

    report += f"\n## Weekend Observation Rules Summary\n\n"

    rule_groups = defaultdict(list)
    for jurisdiction, rule in weekend_rules.items():
        rule_groups[rule].append(jurisdiction)

    for rule, jurisdictions in sorted(rule_groups.items()):
        report += f"\n### {rule}\n"
        for jurisdiction in sorted(jurisdictions):
            report += f"- {jurisdiction}\n"

    report += f"\n## Data Availability\n\n"
    report += f"### 2025 Data\n"
    report += f"- Complete: {len([j for j in completed_jurisdictions if 2025 in jurisdictions_data[j]])} jurisdictions\n\n"

    report += f"### 2026 Data\n"
    report += f"- Complete: {len(has_2026)} jurisdictions\n"
    report += f"- Missing: {len(missing_2026)} jurisdictions\n\n"

    if missing_2026:
        report += "Jurisdictions missing 2026 data:\n"
        for jurisdiction in sorted(missing_2026):
            report += f"- {jurisdiction}\n"

    report += f"\n## Next Steps\n\n"
    report += f"1. **Complete 2026 data** for {len(missing_2026)} jurisdictions currently missing it\n"
    report += f"2. **Add remaining {len(pending_jurisdictions)} jurisdictions** (prioritize by region or population)\n"
    report += "3. **Verify weekend observation rules** for all jurisdictions\n"
    report += "4. **Document state-specific holidays** and their legal basis\n"
    report += "5. **Create validation scripts** to ensure data accuracy\n"
    report += "6. **Build FOIA deadline calculator** using this matrix\n\n"

    report += "## Notes\n\n"
    report += "- All data verified from official government sources (.gov domains)\n"
    report += "- Weekend observation rules critical for accurate deadline calculations\n"
    report += "- State-specific holidays may affect FOIA response deadlines\n"
    report += "- This matrix serves as ground truth for TheHoleTruth.org FOIA generator\n"

    return report

def main():
    """Main execution function."""
    print("Loading all holiday JSON files...")
    jurisdictions_data = load_all_holidays()

    print(f"Loaded data for {len(jurisdictions_data)} jurisdictions")
    for jurisdiction, years in jurisdictions_data.items():
        print(f"  - {jurisdiction}: {sorted(years.keys())}")

    print("\nBuilding holiday comparison matrix...")
    holiday_comparison = build_holiday_comparison(jurisdictions_data)

    print(f"Found {len(holiday_comparison)} unique holidays across all jurisdictions")

    print("\nIdentifying unique holidays by jurisdiction...")
    unique_holidays = get_unique_holidays_by_state(jurisdictions_data)

    print("\nGenerating master JSON matrix...")
    master_data = generate_master_json(jurisdictions_data, holiday_comparison)

    # Save master JSON
    master_json_file = JSON_DIR / "master-holiday-matrix.json"
    with open(master_json_file, 'w') as f:
        json.dump(master_data, f, indent=2)
    print(f"Saved master JSON: {master_json_file}")

    print("\nGenerating CSV matrices...")
    generate_csv_matrix(jurisdictions_data, 2025)
    generate_csv_matrix(jurisdictions_data, 2026)

    print("\nGenerating completion status report...")
    status_report = generate_status_report(jurisdictions_data, unique_holidays)

    status_file = BASE_DIR / "data/holiday-tracking-matrix/COMPLETION_STATUS.md"
    with open(status_file, 'w') as f:
        f.write(status_report)
    print(f"Saved status report: {status_file}")

    print("\n✓ Holiday matrix generation complete!")
    print(f"\nGenerated files:")
    print(f"  1. {master_json_file}")
    print(f"  2. {CSV_DIR / 'master-holiday-matrix-2025.csv'}")
    print(f"  3. {CSV_DIR / 'master-holiday-matrix-2026.csv'}")
    print(f"  4. {status_file}")

if __name__ == "__main__":
    main()
