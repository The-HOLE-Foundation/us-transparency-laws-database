#!/usr/bin/env python3
"""
Check all jurisdiction-data.json files for validation status.
"""

import json
import os
from pathlib import Path

def check_file(filepath):
    """Check if a jurisdiction file is properly structured."""
    try:
        with open(filepath, 'r') as f:
            data = json.load(f)

        # Check required fields
        if not data.get('jurisdiction'):
            return False, "Missing jurisdiction name"

        if not isinstance(data.get('transparency_law'), dict):
            return False, "Missing or invalid transparency_law object"

        law = data['transparency_law']
        required_fields = ['name', 'statute_citation', 'response_requirements', 'exemptions']

        for field in required_fields:
            if field not in law:
                return False, f"Missing {field} in transparency_law"

        return True, "Valid"

    except json.JSONDecodeError:
        return False, "Invalid JSON"
    except Exception as e:
        return False, str(e)

def main():
    base_dir = Path("/Volumes/HOLE-RAID-DRIVE/HOLE/Projects/us-transparency-laws-database")

    # Check federal
    federal_file = base_dir / "data" / "federal" / "jurisdiction-data.json"

    files_to_check = [federal_file]

    # Check all states
    states_dir = base_dir / "data" / "states"
    for state_dir in sorted(states_dir.iterdir()):
        if state_dir.is_dir():
            jd_file = state_dir / "jurisdiction-data.json"
            if jd_file.exists():
                files_to_check.append(jd_file)

    valid_count = 0
    invalid_count = 0
    invalid_files = []

    for filepath in files_to_check:
        is_valid, message = check_file(filepath)

        if is_valid:
            valid_count += 1
            print(f"✅ {filepath.parent.name}")
        else:
            invalid_count += 1
            invalid_files.append((filepath.parent.name, message))
            print(f"❌ {filepath.parent.name}: {message}")

    print(f"\n{'='*60}")
    print(f"Summary: {valid_count} valid, {invalid_count} invalid")
    print(f"{'='*60}")

    if invalid_files:
        print("\nFiles needing attention:")
        for name, msg in invalid_files:
            print(f"  - {name}: {msg}")

if __name__ == "__main__":
    main()
