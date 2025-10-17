#!/usr/bin/env python3
"""
Statute Name Validator - Additional Layer of Data Integrity Protection

Validates that transparency law names in jurisdiction data files match the canonical
official statute names exactly. This prevents common errors like:
- Using informal names ("California FOIA" instead of "California Public Records Act")
- Mixing up Act/Law terminology ("Texas Public Records Act" vs "Texas Public Information Act")
- Adding unnecessary prefixes ("Federal Freedom of Information Act" vs "Freedom of Information Act")

Part of the US Transparency Laws Database ground truth validation system.
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum


class ValidationSeverity(Enum):
    """Severity levels for statute name validation issues"""
    CRITICAL = "CRITICAL"  # Wrong statute name
    WARNING = "WARNING"    # Accepted variation used
    INFO = "INFO"          # Informational message


@dataclass
class StatuteNameIssue:
    """Represents a statute name validation issue"""
    jurisdiction: str
    file_path: str
    found_name: str
    expected_name: str
    severity: ValidationSeverity
    message: str
    suggestions: List[str] = None
    
    def to_dict(self) -> Dict:
        """Convert to dictionary for JSON serialization"""
        return {
            "jurisdiction": self.jurisdiction,
            "file_path": str(self.file_path),
            "found_name": self.found_name,
            "expected_name": self.expected_name,
            "severity": self.severity.value,
            "message": self.message,
            "suggestions": self.suggestions or []
        }


class StatuteNameValidator:
    """Validates statute names against canonical reference"""
    
    def __init__(self, canonical_names_file: Path):
        """
        Initialize validator with canonical names reference
        
        Args:
            canonical_names_file: Path to canonical-statute-names.json
        """
        self.canonical_names_file = canonical_names_file
        self.canonical_names = self._load_canonical_names()
        self.issues: List[StatuteNameIssue] = []
        
    def _load_canonical_names(self) -> Dict:
        """Load canonical statute names from reference file"""
        try:
            with open(self.canonical_names_file, 'r') as f:
                data = json.load(f)
            print(f"✅ Loaded canonical statute names for {len([k for k in data.keys() if not k.startswith('_')])} jurisdictions")
            return data
        except FileNotFoundError:
            print(f"❌ Error: Canonical names file not found: {self.canonical_names_file}")
            sys.exit(1)
        except json.JSONDecodeError as e:
            print(f"❌ Error: Invalid JSON in canonical names file: {e}")
            sys.exit(1)
    
    def validate_file(self, file_path: Path) -> Tuple[bool, List[StatuteNameIssue]]:
        """
        Validate statute name in a jurisdiction data file
        
        Args:
            file_path: Path to jurisdiction-data.json file
            
        Returns:
            Tuple of (passed: bool, issues: List[StatuteNameIssue])
        """
        print(f"\n🔍 Validating statute name in: {file_path}")
        
        # Load the data file
        try:
            with open(file_path, 'r') as f:
                data = json.load(f)
        except FileNotFoundError:
            print(f"❌ File not found: {file_path}")
            return False, []
        except json.JSONDecodeError as e:
            print(f"❌ Invalid JSON in file: {e}")
            return False, []
        
        # Extract jurisdiction and statute name
        jurisdiction = self._get_jurisdiction(data, file_path)
        statute_name = self._get_statute_name(data)
        
        if not statute_name:
            print(f"⚠️  No statute name found in file")
            return True, []  # Not an error, just empty template
        
        # Validate the name
        issues = self._validate_name(jurisdiction, file_path, statute_name)
        
        if not issues:
            print(f"✅ Statute name validated: '{statute_name}'")
            return True, []
        
        self.issues.extend(issues)
        
        # Determine if validation passed (only CRITICAL issues fail)
        has_critical = any(issue.severity == ValidationSeverity.CRITICAL for issue in issues)
        
        if has_critical:
            print(f"❌ Validation failed: Found {len([i for i in issues if i.severity == ValidationSeverity.CRITICAL])} critical issue(s)")
            return False, issues
        else:
            print(f"⚠️  Validation passed with {len(issues)} warning(s)")
            return True, issues
    
    def _get_jurisdiction(self, data: Dict, file_path: Path) -> str:
        """Extract jurisdiction name from data or file path"""
        # Try from data first
        if "jurisdiction" in data:
            jurisdiction = data["jurisdiction"].lower().replace(" ", "-")
            # Handle special case for DC
            if jurisdiction == "district-of-columbia":
                return "district-of-columbia"
            return jurisdiction
        
        # Try from file path
        if "states" in file_path.parts:
            state_index = file_path.parts.index("states") + 1
            if state_index < len(file_path.parts):
                return file_path.parts[state_index]
        
        if "federal" in file_path.parts:
            return "federal"
        
        return "unknown"
    
    def _get_statute_name(self, data: Dict) -> Optional[str]:
        """Extract statute name from jurisdiction data"""
        if "transparency_law" in data:
            return data["transparency_law"].get("name")
        return None
    
    def _validate_name(self, jurisdiction: str, file_path: Path, found_name: str) -> List[StatuteNameIssue]:
        """
        Validate statute name against canonical reference
        
        Args:
            jurisdiction: Jurisdiction key (e.g., 'california', 'federal')
            file_path: Path to file being validated
            found_name: Statute name found in the file
            
        Returns:
            List of validation issues
        """
        issues = []
        
        # Check if jurisdiction exists in canonical names
        if jurisdiction not in self.canonical_names:
            # Skip validation if jurisdiction not in reference (may be template)
            return issues
        
        canonical = self.canonical_names[jurisdiction]
        official_name = canonical["official_name"]
        accepted_variations = canonical.get("accepted_variations", [])
        rejected_variations = canonical.get("rejected_variations", [])
        
        # Check if name matches exactly
        if found_name == official_name:
            return issues  # Perfect match, no issues
        
        # Check if it's an accepted variation
        if found_name in accepted_variations:
            issue = StatuteNameIssue(
                jurisdiction=jurisdiction,
                file_path=file_path,
                found_name=found_name,
                expected_name=official_name,
                severity=ValidationSeverity.WARNING,
                message=f"Using accepted variation '{found_name}' instead of official name '{official_name}'",
                suggestions=[f"Consider using official name: '{official_name}'"]
            )
            issues.append(issue)
            return issues
        
        # Check if it's a known rejected variation
        if found_name in rejected_variations:
            issue = StatuteNameIssue(
                jurisdiction=jurisdiction,
                file_path=file_path,
                found_name=found_name,
                expected_name=official_name,
                severity=ValidationSeverity.CRITICAL,
                message=f"Using incorrect statute name '{found_name}' - this is a commonly confused variation",
                suggestions=[
                    f"Official name: '{official_name}'",
                    f"Statute citation: {canonical['statute_citation']}",
                    f"Verify at: {canonical.get('verified_source', 'N/A')}"
                ]
            )
            issues.append(issue)
            return issues
        
        # Unknown name - could be typo or outdated
        issue = StatuteNameIssue(
            jurisdiction=jurisdiction,
            file_path=file_path,
            found_name=found_name,
            expected_name=official_name,
            severity=ValidationSeverity.CRITICAL,
            message=f"Statute name '{found_name}' does not match official name",
            suggestions=[
                f"Expected: '{official_name}'",
                f"Accepted variations: {', '.join(accepted_variations) if accepted_variations else 'None'}",
                f"Check for typos or verify official statute title"
            ]
        )
        issues.append(issue)
        
        return issues
    
    def print_issues(self) -> None:
        """Print all validation issues in readable format"""
        if not self.issues:
            return
        
        print("\n" + "="*80)
        print("⚠️  STATUTE NAME VALIDATION ISSUES")
        print("="*80)
        
        critical_issues = [i for i in self.issues if i.severity == ValidationSeverity.CRITICAL]
        warning_issues = [i for i in self.issues if i.severity == ValidationSeverity.WARNING]
        
        if critical_issues:
            print(f"\n❌ CRITICAL ISSUES ({len(critical_issues)}):")
            for i, issue in enumerate(critical_issues, 1):
                print(f"\n[{i}] {issue.jurisdiction.upper()}")
                print(f"    File: {issue.file_path}")
                print(f"    Found: '{issue.found_name}'")
                print(f"    Expected: '{issue.expected_name}'")
                print(f"    Issue: {issue.message}")
                if issue.suggestions:
                    print(f"    Suggestions:")
                    for suggestion in issue.suggestions:
                        print(f"      • {suggestion}")
        
        if warning_issues:
            print(f"\n⚠️  WARNINGS ({len(warning_issues)}):")
            for i, issue in enumerate(warning_issues, 1):
                print(f"\n[{i}] {issue.jurisdiction.upper()}")
                print(f"    File: {issue.file_path}")
                print(f"    Found: '{issue.found_name}'")
                print(f"    Preferred: '{issue.expected_name}'")
                print(f"    Note: {issue.message}")
        
        print("\n" + "="*80)
    
    def generate_report(self, output_path: Path) -> None:
        """Generate JSON report of validation issues"""
        report = {
            "validation_date": "2025-10-03",
            "validator": "statute-name-validator",
            "total_issues": len(self.issues),
            "critical_issues": len([i for i in self.issues if i.severity == ValidationSeverity.CRITICAL]),
            "warning_issues": len([i for i in self.issues if i.severity == ValidationSeverity.WARNING]),
            "issues": [issue.to_dict() for issue in self.issues]
        }
        
        with open(output_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n📋 Validation report saved to: {output_path}")


def main():
    """Main entry point for statute name validation"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Validate statute names in jurisdiction data files"
    )
    parser.add_argument(
        "--file",
        type=Path,
        help="Specific jurisdiction data file to validate"
    )
    parser.add_argument(
        "--directory",
        type=Path,
        help="Directory to scan for jurisdiction data files"
    )
    parser.add_argument(
        "--canonical-names",
        type=Path,
        default=Path("data/ground-truth/canonical-statute-names.json"),
        help="Path to canonical statute names file"
    )
    parser.add_argument(
        "--report",
        type=Path,
        help="Output path for validation report JSON"
    )
    
    args = parser.parse_args()
    
    # Initialize validator
    validator = StatuteNameValidator(args.canonical_names)
    
    # Collect files to validate
    files_to_validate = []
    
    if args.file:
        files_to_validate.append(args.file)
    elif args.directory:
        files_to_validate.extend(args.directory.glob("**/jurisdiction-data.json"))
    else:
        # Default: validate all jurisdiction data files
        root = Path.cwd()
        files_to_validate.extend(root.glob("data/states/*/jurisdiction-data.json"))
        files_to_validate.extend(root.glob("data/federal/jurisdiction-data.json"))
    
    if not files_to_validate:
        print("❌ No files found to validate")
        sys.exit(1)
    
    print(f"\n{'='*80}")
    print(f"STATUTE NAME VALIDATION")
    print(f"{'='*80}")
    print(f"📁 Files to validate: {len(files_to_validate)}")
    print(f"📚 Canonical reference: {args.canonical_names}")
    
    # Validate all files
    all_passed = True
    for file_path in files_to_validate:
        passed, issues = validator.validate_file(file_path)
        if not passed:
            all_passed = False
    
    # Print summary
    validator.print_issues()
    
    # Generate report if requested
    if args.report:
        validator.generate_report(args.report)
    
    # Print final result
    print(f"\n{'='*80}")
    if all_passed:
        if validator.issues:
            print(f"✅ Validation PASSED with {len(validator.issues)} warning(s)")
        else:
            print("✅ All statute names validated successfully!")
        print(f"{'='*80}\n")
        sys.exit(0)
    else:
        critical_count = len([i for i in validator.issues if i.severity == ValidationSeverity.CRITICAL])
        print(f"❌ Validation FAILED - {critical_count} critical issue(s) found")
        print(f"{'='*80}\n")
        sys.exit(1)


if __name__ == "__main__":
    main()
