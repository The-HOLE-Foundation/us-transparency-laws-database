#!/usr/bin/env python3
"""Rename all statute files to include v0.11 version suffix"""

import os
from pathlib import Path

# Full-Text-Statutes directory
statutes_dir = Path("/Users/jth/Documents/GitHub/us-transparency-laws-database/Transparency-Data/Full-Text-Statutes")

renamed_count = 0
skipped_count = 0

print("Renaming statute files to include v0.11...")

for file_path in statutes_dir.glob("*.txt"):
    filename = file_path.name

    # Skip if already has v0.11 or v.0.11
    if "v0.11" in filename or "v.0.11" in filename:
        print(f"  ✓ Already versioned: {filename}")
        skipped_count += 1
        continue

    # Create new filename with v0.11
    base_name = filename.replace(".txt", "")
    new_filename = f"{base_name}-v0.11.txt"
    new_path = statutes_dir / new_filename

    # Rename the file
    file_path.rename(new_path)
    print(f"  ✓ Renamed: {filename} → {new_filename}")
    renamed_count += 1

print(f"\nSummary:")
print(f"  - Renamed: {renamed_count} files")
print(f"  - Already versioned: {skipped_count} files")
print(f"  - Total: {renamed_count + skipped_count} files")