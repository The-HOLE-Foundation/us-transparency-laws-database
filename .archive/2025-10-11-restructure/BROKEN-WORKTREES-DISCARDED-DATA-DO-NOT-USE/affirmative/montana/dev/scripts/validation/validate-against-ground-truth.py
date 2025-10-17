#!/usr/bin/env python3
"""
Data Integrity Validation System - Ground Truth Guardian

Validates all data changes against canonical ground truth values
to prevent inaccurate information from entering the database.

Usage:
    python3 validate-against-ground-truth.py --file <path>
    python3 validate-against-ground-truth.py --staged  # Git pre-commit
    python3 validate-against-ground-truth.py --all     # Full database scan
"""

import json
import sys
import hashlib
import argparse
from pathlib import Path
from typing import Dict, List, Any, Tuple
from dataclasses import dataclass
from enum import Enum

class ConflictSeverity(Enum):
    CRITICAL = "CRITICAL"      # Blocks merge - legal accuracy issue
    WARNING = "WARNING"        # Requires review but can proceed
    INFO = "INFO"              # Informational only

@dataclass
class DataConflict:
    jurisdiction: str
    field_path: str
    ground_truth_value: Any
    new_value: Any
    severity: ConflictSeverity
    ground_truth_source: str
    conflict_reason: str
    
    def to_dict(self):
        return {
            "jurisdiction": self.jurisdiction,
            "field_path": self.field_path,
            "ground_truth_value": self.ground_truth_value,
            "new_value": self.new_value,
            "severity": self.severity.value,
            "ground_truth_source": self.ground_truth_source,
            "reason": self.conflict_reason
        }

class GroundTruthValidator:
    """Validates data changes against canonical ground truth"""
    
    def __init__(self, ground_truth_path: Path):
        self.ground_truth_path = ground_truth_path
        self.ground_truth = self._load_ground_truth()
        self.validation_rules = self._load_validation_rules()
        self.conflicts: List[DataConflict] = []
        
    def _load_ground_truth(self) -> Dict:
        """Load canonical ground truth data"""
        if not self.ground_truth_path.exists():
            print(f"⚠️  Warning: Ground truth file not found at {self.ground_truth_path}")
            return {}
        
        with open(self.ground_truth_path, 'r') as f:
            return json.load(f)
    
    def _load_validation_rules(self) -> Dict:
        """Load validation rules defining critical fields"""
        # In production, load from external config file
        return {
            "critical_fields": [
                "response_timeline_days",
                "response_timeline_type",
                "statute_citation",
                "appeal_deadline_days",
                "fee_structure.standard_copy_fee"
            ],
            "review_fields": [
                "agency_contact",
                "request_portal_url"
            ],
            "ignore_fields": [
                "last_updated",
                "data_version",
                "validation_audit.verification_date"
            ]
        }
    
    def validate_file(self, file_path: Path) -> Tuple[bool, List[DataConflict]]:
        """Validate a single file against ground truth"""
        print(f"🔍 Validating: {file_path}")
        
        try:
            with open(file_path, 'r') as f:
                data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"❌ Invalid JSON in {file_path}: {e}")
            return False, []
        
        # Extract jurisdiction identifier
        jurisdiction = self._extract_jurisdiction(file_path, data)
        
        if jurisdiction not in self.ground_truth:
            print(f"ℹ️  No ground truth reference for {jurisdiction} - skipping validation")
            return True, []
        
        # Compare critical fields
        conflicts = self._compare_data(jurisdiction, data, self.ground_truth[jurisdiction])
        
        if conflicts:
            self.conflicts.extend(conflicts)
            return False, conflicts
        
        print(f"✅ Validation passed for {jurisdiction}")
        return True, []
    
    def _extract_jurisdiction(self, file_path: Path, data: Dict) -> str:
        """Extract jurisdiction identifier from file path or data"""
        # Try from data first
        if "jurisdiction_info" in data:
            return data["jurisdiction_info"].get("jurisdiction_name", "").lower()
        
        # Try from file path
        if "states" in file_path.parts:
            state_index = file_path.parts.index("states") + 1
            if state_index < len(file_path.parts):
                return file_path.parts[state_index]
        
        return "unknown"
    
    def _compare_data(self, jurisdiction: str, new_data: Dict, truth_data: Dict) -> List[DataConflict]:
        """Compare new data against ground truth"""
        conflicts = []
        
        for field_path in self.validation_rules["critical_fields"]:
            truth_value = self._get_nested_value(truth_data, field_path)
            
            # Try multiple possible locations in new data
            # 1. Direct path (for flat structure)
            new_value = self._get_nested_value(new_data, field_path)
            
            # 2. Check common nested locations if direct path not found
            if new_value is None and '.' not in field_path:
                # Try response_requirements.{field}
                nested_path = f"response_requirements.{field_path}"
                new_value = self._get_nested_value(new_data, nested_path)
                
                # Try statute_details.{field}
                if new_value is None:
                    nested_path = f"statute_details.{field_path}"
                    new_value = self._get_nested_value(new_data, nested_path)
            
            if truth_value is None:
                continue  # No ground truth for this field
            
            if new_value is None:
                continue  # Field not present in new data (not necessarily an error)
            
            if new_value != truth_value:
                conflict = DataConflict(
                    jurisdiction=jurisdiction,
                    field_path=field_path,
                    ground_truth_value=truth_value,
                    new_value=new_value,
                    severity=ConflictSeverity.CRITICAL,
                    ground_truth_source=truth_data.get("source_url", "Unknown"),
                    conflict_reason=f"Value mismatch: ground truth={truth_value}, new={new_value}"
                )
                conflicts.append(conflict)
        
        return conflicts
    
    def _get_nested_value(self, data: Dict, field_path: str) -> Any:
        """Get value from nested dict using dot notation (e.g., 'fee_structure.standard_copy_fee')"""
        keys = field_path.split('.')
        value = data
        
        for key in keys:
            if isinstance(value, dict):
                value = value.get(key)
            else:
                return None
        
        return value
    
    def generate_conflict_report(self, output_path: Path) -> None:
        """Generate detailed conflict report for manual review"""
        report = {
            "validation_date": "2025-10-02",
            "total_conflicts": len(self.conflicts),
            "critical_conflicts": len([c for c in self.conflicts if c.severity == ConflictSeverity.CRITICAL]),
            "conflicts": [c.to_dict() for c in self.conflicts]
        }
        
        with open(output_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n📋 Conflict report saved to: {output_path}")
    
    def print_conflicts(self) -> None:
        """Print conflicts to console in readable format"""
        if not self.conflicts:
            return
        
        print("\n" + "="*80)
        print("⚠️  DATA INTEGRITY CONFLICTS DETECTED")
        print("="*80)
        
        for i, conflict in enumerate(self.conflicts, 1):
            print(f"\n[{i}] {conflict.severity.value}: {conflict.jurisdiction}")
            print(f"    Field: {conflict.field_path}")
            print(f"    Ground Truth: {conflict.ground_truth_value}")
            print(f"    New Value: {conflict.new_value}")
            print(f"    Source: {conflict.ground_truth_source}")
            print(f"    Reason: {conflict.conflict_reason}")
        
        print("\n" + "="*80)

def main():
    parser = argparse.ArgumentParser(description="Validate data against ground truth")
    parser.add_argument("--file", type=str, help="Validate specific file")
    parser.add_argument("--all", action="store_true", help="Validate all data files")
    parser.add_argument("--staged", action="store_true", help="Validate git staged files")
    parser.add_argument("--ground-truth", type=str, 
                       default="data/ground-truth/canonical-values.json",
                       help="Path to ground truth file")
    parser.add_argument("--report", type=str,
                       default=".validation-conflicts.json",
                       help="Output path for conflict report")
    
    args = parser.parse_args()
    
    # Get project root
    project_root = Path(__file__).parent.parent.parent
    ground_truth_path = project_root / args.ground_truth
    
    validator = GroundTruthValidator(ground_truth_path)
    
    files_to_validate = []
    
    if args.file:
        files_to_validate.append(Path(args.file))
    elif args.all:
        # Find all JSON data files
        files_to_validate.extend((project_root / "data" / "states").rglob("*.json"))
        files_to_validate.extend((project_root / "data" / "federal").rglob("*.json"))
    elif args.staged:
        # Get git staged files (implement git integration)
        import subprocess
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only", "--diff-filter=ACM"],
            capture_output=True,
            text=True,
            cwd=project_root
        )
        staged_files = result.stdout.strip().split('\n')
        files_to_validate = [
            project_root / f for f in staged_files 
            if f.endswith('.json') and ('states/' in f or 'federal/' in f)
        ]
    else:
        print("❌ Error: Must specify --file, --all, or --staged")
        sys.exit(1)
    
    print(f"🔍 Validating {len(files_to_validate)} file(s)...\n")
    
    all_passed = True
    for file_path in files_to_validate:
        if file_path.exists():
            passed, conflicts = validator.validate_file(file_path)
            if not passed:
                all_passed = False
    
    if validator.conflicts:
        validator.print_conflicts()
        validator.generate_conflict_report(Path(args.report))
        
        print(f"\n❌ VALIDATION FAILED - {len(validator.conflicts)} conflict(s) detected")
        print(f"📋 Review conflicts and update ground truth or fix data")
        print(f"📝 Conflict report: {args.report}")
        sys.exit(1)
    else:
        print("\n✅ All validations passed - data integrity confirmed")
        sys.exit(0)

if __name__ == "__main__":
    main()
