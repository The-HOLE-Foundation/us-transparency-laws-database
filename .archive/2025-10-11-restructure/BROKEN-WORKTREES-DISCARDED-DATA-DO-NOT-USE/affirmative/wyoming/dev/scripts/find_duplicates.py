#!/usr/bin/env python3
"""
Find duplicate or potentially redundant data files in the repository.
Reports findings without deleting anything.
"""

import os
import json
from pathlib import Path
from collections import defaultdict
import hashlib

def get_file_hash(file_path):
    """Calculate MD5 hash of file contents"""
    try:
        with open(file_path, 'rb') as f:
            return hashlib.md5(f.read()).hexdigest()
    except:
        return None

def get_file_size(file_path):
    """Get file size in bytes"""
    try:
        return os.path.getsize(file_path)
    except:
        return 0

def analyze_json_files(repo_root):
    """Find duplicate or similar JSON files"""
    print("\n" + "="*80)
    print("ANALYZING JSON FILES FOR DUPLICATES")
    print("="*80)

    json_files = []
    for root, dirs, files in os.walk(repo_root):
        # Skip .git and node_modules
        if '.git' in root or 'node_modules' in root:
            continue
        for file in files:
            if file.endswith('.json'):
                full_path = os.path.join(root, file)
                json_files.append(full_path)

    # Group by filename (ignoring path)
    filename_groups = defaultdict(list)
    for path in json_files:
        filename = os.path.basename(path)
        filename_groups[filename].append(path)

    # Report duplicates by filename
    duplicates_found = False
    for filename, paths in sorted(filename_groups.items()):
        if len(paths) > 1:
            duplicates_found = True
            print(f"\n📋 DUPLICATE FILENAME: {filename}")
            print(f"   Found in {len(paths)} locations:")
            for path in sorted(paths):
                rel_path = path.replace(str(repo_root), '')
                size = get_file_size(path)
                file_hash = get_file_hash(path)
                print(f"   - {rel_path}")
                print(f"     Size: {size:,} bytes | Hash: {file_hash[:8]}...")

    if not duplicates_found:
        print("\n✅ No duplicate JSON filenames found")

    # Check for identical file contents
    print("\n" + "-"*80)
    print("CHECKING FOR IDENTICAL JSON FILE CONTENTS")
    print("-"*80)

    hash_groups = defaultdict(list)
    for path in json_files:
        file_hash = get_file_hash(path)
        if file_hash:
            hash_groups[file_hash].append(path)

    identical_found = False
    for file_hash, paths in hash_groups.items():
        if len(paths) > 1:
            identical_found = True
            print(f"\n🔄 IDENTICAL CONTENTS (Hash: {file_hash[:8]}...):")
            print(f"   {len(paths)} files with identical content:")
            for path in sorted(paths):
                rel_path = path.replace(str(repo_root), '')
                print(f"   - {rel_path}")

    if not identical_found:
        print("\n✅ No JSON files with identical contents found")

def analyze_txt_files(repo_root):
    """Find duplicate or similar TXT files"""
    print("\n" + "="*80)
    print("ANALYZING TXT FILES FOR DUPLICATES")
    print("="*80)

    txt_files = []
    for root, dirs, files in os.walk(repo_root):
        if '.git' in root or 'node_modules' in root:
            continue
        for file in files:
            if file.endswith('.txt'):
                full_path = os.path.join(root, file)
                txt_files.append(full_path)

    # Check for files with similar names (e.g., with/without v0.11)
    print(f"\n📊 Total TXT files found: {len(txt_files)}")

    # Group by base name (removing version suffixes)
    base_name_groups = defaultdict(list)
    for path in txt_files:
        filename = os.path.basename(path)
        # Remove version suffixes for comparison
        base = filename.replace('-v0.11', '').replace('-v.0.11', '').replace('-v0.10', '')
        base_name_groups[base].append(path)

    similar_found = False
    for base_name, paths in sorted(base_name_groups.items()):
        if len(paths) > 1:
            similar_found = True
            print(f"\n📄 SIMILAR FILENAMES (base: {base_name}):")
            print(f"   Found {len(paths)} variants:")
            for path in sorted(paths):
                rel_path = path.replace(str(repo_root), '')
                size = get_file_size(path)
                file_hash = get_file_hash(path)
                print(f"   - {rel_path}")
                print(f"     Size: {size:,} bytes | Hash: {file_hash[:8]}...")

    if not similar_found:
        print("\n✅ No similar TXT filenames found")

def analyze_md_files(repo_root):
    """Find duplicate or similar MD files"""
    print("\n" + "="*80)
    print("ANALYZING MARKDOWN FILES FOR DUPLICATES")
    print("="*80)

    md_files = []
    for root, dirs, files in os.walk(repo_root):
        if '.git' in root or 'node_modules' in root:
            continue
        for file in files:
            if file.endswith('.md'):
                full_path = os.path.join(root, file)
                md_files.append(full_path)

    print(f"\n📊 Total MD files found: {len(md_files)}")

    # Group by filename
    filename_groups = defaultdict(list)
    for path in md_files:
        filename = os.path.basename(path)
        filename_groups[filename].append(path)

    duplicates_found = False
    for filename, paths in sorted(filename_groups.items()):
        if len(paths) > 1:
            duplicates_found = True
            print(f"\n📝 DUPLICATE FILENAME: {filename}")
            print(f"   Found in {len(paths)} locations:")
            for path in sorted(paths):
                rel_path = path.replace(str(repo_root), '')
                size = get_file_size(path)
                print(f"   - {rel_path} ({size:,} bytes)")

    if not duplicates_found:
        print("\n✅ No duplicate MD filenames found")

def analyze_consolidated_directories(repo_root):
    """Check for data duplication between main directories"""
    print("\n" + "="*80)
    print("ANALYZING DATA CONSOLIDATION")
    print("="*80)

    dirs_to_check = [
        ('Transparency-Data/Consolidated-Datasets', 'Primary consolidated data'),
        ('Consolidated-Datasets', 'Secondary consolidated location'),
        ('data/consolidated', 'Data consolidated location'),
    ]

    print("\n📂 Checking consolidated data locations:")
    for rel_path, description in dirs_to_check:
        full_path = os.path.join(repo_root, rel_path)
        if os.path.exists(full_path):
            files = list(Path(full_path).glob('*.json'))
            print(f"\n   {description}:")
            print(f"   Location: {rel_path}")
            print(f"   Files: {len(files)}")
            for f in sorted(files):
                size = get_file_size(f)
                print(f"     - {f.name} ({size:,} bytes)")
        else:
            print(f"\n   {description}: NOT FOUND")

def main():
    repo_root = Path("/Users/jth/Documents/GitHub/us-transparency-laws-database")

    print("\n" + "="*80)
    print("DUPLICATE DATA ANALYSIS REPORT")
    print("Repository: us-transparency-laws-database")
    print("="*80)

    analyze_json_files(repo_root)
    analyze_txt_files(repo_root)
    analyze_md_files(repo_root)
    analyze_consolidated_directories(repo_root)

    print("\n" + "="*80)
    print("ANALYSIS COMPLETE")
    print("="*80)
    print("\n⚠️  NO FILES WERE DELETED - Review findings before taking action")

if __name__ == "__main__":
    main()