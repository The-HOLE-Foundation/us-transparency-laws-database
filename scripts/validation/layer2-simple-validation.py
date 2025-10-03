#!/usr/bin/env python3
"""
Simple Layer 2 Validation for v0.11
Validates nested transparency_law structure without complex holiday logic

NOTE: This validator does NOT calculate exact deadlines accounting for weekends
and holidays. That functionality is deferred to v0.12 when we implement the
comprehensive BusinessDayCalculator with state-specific holiday calendars.

For v0.11, we only validate:
- Data structure correctness
- Required fields present
- Response timeline values match ground truth (lenient comparison)
- Timeline units are valid (business_days, calendar_days, working_days, variable)
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Tuple
from datetime import date, timedelta

class Layer2Validator:
    """Simple validator for Layer 2 nested structure"""

    def __init__(self, ground_truth_path: str):
        with open(ground_truth_path, 'r') as f:
            self.ground_truth = json.load(f)

    @staticmethod
    def _is_weekend(check_date: date) -> bool:
        """
        Check if a date falls on a weekend

        NOTE: This is a helper function for future v0.12 deadline calculation.
        Currently NOT used in v0.11 validation (deferred for complexity).

        For v0.12, we'll expand this to include state-specific holidays:
        - Federal holidays (New Year's, MLK Day, Presidents Day, Memorial Day,
          Juneteenth, Independence Day, Labor Day, Columbus Day, Veterans Day,
          Thanksgiving, Christmas)
        - State-specific holidays (e.g., Texas Independence Day, Patriots' Day
          in MA/ME, Cesar Chavez Day in CA)

        Args:
            check_date: Date to check

        Returns:
            True if weekend (Saturday=5 or Sunday=6), False otherwise
        """
        return check_date.weekday() >= 5  # 5 = Saturday, 6 = Sunday

    def validate_file(self, file_path: str) -> Tuple[bool, List[str]]:
        """
        Validate Layer 2 jurisdiction-data.json file

        Returns:
            (is_valid, error_messages)
        """
        errors = []

        try:
            with open(file_path, 'r') as f:
                data = json.load(f)
        except Exception as e:
            return (False, [f"Failed to load JSON: {e}"])

        # Get jurisdiction from file path or data
        jurisdiction = self._get_jurisdiction(file_path, data)

        # Check if jurisdiction has transparency_law populated
        if not data.get('transparency_law'):
            errors.append(f"Missing 'transparency_law' object")
            return (False, errors)

        # If we have ground truth for this jurisdiction, validate critical fields
        if jurisdiction in self.ground_truth:
            gt = self.ground_truth[jurisdiction]
            tl = data['transparency_law']

            # Validate response timeline
            response_errors = self._validate_response_timeline(jurisdiction, gt, tl)
            errors.extend(response_errors)

            # Validate statute citation (lenient - just check it exists)
            citation_errors = self._validate_citation(jurisdiction, gt, tl)
            errors.extend(citation_errors)

        # Validate structure (schema-like checks)
        structure_errors = self._validate_structure(data['transparency_law'])
        errors.extend(structure_errors)

        return (len(errors) == 0, errors)

    def _get_jurisdiction(self, file_path: str, data: Dict) -> str:
        """Extract jurisdiction name from file path or data"""
        # Try from data first
        if 'jurisdiction' in data and data['jurisdiction']:
            return data['jurisdiction'].lower().replace(' ', '_')

        # Try from file path
        path_parts = Path(file_path).parts
        if 'states' in path_parts:
            state_idx = path_parts.index('states') + 1
            if state_idx < len(path_parts):
                return path_parts[state_idx].lower().replace('-', '_')

        if 'federal' in path_parts:
            return 'federal'

        return 'unknown'

    def _validate_response_timeline(
        self,
        jurisdiction: str,
        ground_truth: Dict,
        transparency_law: Dict
    ) -> List[str]:
        """
        Validate response timeline against ground truth

        v0.11 SIMPLIFIED VALIDATION:
        - Compares timeline values (days)
        - Validates timeline units are correct
        - Does NOT calculate exact deadlines
        - Does NOT account for weekends/holidays

        v0.12 WILL ADD:
        - Weekend detection using _is_weekend() helper
        - State-specific holiday calendars
        - Exact deadline calculation
        - Business day vs calendar day calculations
        """
        errors = []

        # Ground truth uses flat structure
        gt_days = ground_truth.get('response_timeline_days')
        gt_type = ground_truth.get('response_timeline_type')

        # Layer 2 uses nested structure
        if 'response_requirements' not in transparency_law:
            return [f"{jurisdiction}: Missing 'response_requirements'"]

        resp_req = transparency_law['response_requirements']

        # Check initial response time
        if 'initial_response_time' in resp_req:
            layer2_days = resp_req['initial_response_time']
            layer2_unit = resp_req.get('initial_response_unit', 'unknown')

            # Compare (lenient - allow some variation)
            if gt_days and gt_days > 0:  # Only validate if ground truth has fixed deadline
                if layer2_days != gt_days:
                    errors.append(
                        f"{jurisdiction}: Response time mismatch - "
                        f"Ground truth: {gt_days}, Layer 2: {layer2_days}"
                    )

            # Validate unit is reasonable
            valid_units = ['business_days', 'calendar_days', 'working_days', 'variable']
            if layer2_unit not in valid_units:
                errors.append(
                    f"{jurisdiction}: Invalid response unit '{layer2_unit}' "
                    f"(expected one of {valid_units})"
                )

        return errors

    def _validate_citation(
        self,
        jurisdiction: str,
        ground_truth: Dict,
        transparency_law: Dict
    ) -> List[str]:
        """Validate statute citation exists (lenient check)"""
        errors = []

        citation = transparency_law.get('statute_citation', '')

        # Just check it exists and has basic format
        if not citation:
            errors.append(f"{jurisdiction}: Missing statute_citation")
        elif '§' not in citation and 'section' not in citation.lower():
            errors.append(
                f"{jurisdiction}: Citation may be incomplete (missing § or 'section'): {citation}"
            )

        return errors

    def _validate_structure(self, transparency_law: Dict) -> List[str]:
        """Validate required fields exist in transparency_law"""
        errors = []
        required_fields = [
            'name',
            'statute_citation',
            'response_requirements',
            'fee_structure',
            'exemptions',
            'appeal_process',
            'validation_metadata'
        ]

        for field in required_fields:
            if field not in transparency_law:
                errors.append(f"Missing required field: '{field}'")

        # Validate nested structures exist
        if 'response_requirements' in transparency_law:
            resp = transparency_law['response_requirements']
            if 'initial_response_time' not in resp and 'timeline_description' not in resp:
                errors.append("response_requirements missing timeline information")

        if 'validation_metadata' in transparency_law:
            meta = transparency_law['validation_metadata']
            if 'parsed_date' not in meta:
                errors.append("validation_metadata missing 'parsed_date'")
            if 'confidence_level' not in meta:
                errors.append("validation_metadata missing 'confidence_level'")

        return errors


def validate_staged_files():
    """Validate all staged Layer 2 files"""
    import subprocess

    # Get staged JSON files
    result = subprocess.run(
        ['git', 'diff', '--cached', '--name-only', '--diff-filter=ACM'],
        capture_output=True,
        text=True
    )

    staged_files = [
        f for f in result.stdout.strip().split('\n')
        if f.endswith('jurisdiction-data.json') and ('states/' in f or 'federal/' in f)
    ]

    if not staged_files:
        print("✅ No Layer 2 files staged for commit")
        return True

    # Initialize validator
    ground_truth_path = 'data/ground-truth/canonical-values.json'
    if not Path(ground_truth_path).exists():
        print(f"⚠️  Warning: Ground truth not found at {ground_truth_path}")
        print("✅ Skipping validation (ground truth not populated)")
        return True

    validator = Layer2Validator(ground_truth_path)

    all_valid = True
    for file_path in staged_files:
        if not Path(file_path).exists():
            continue

        is_valid, errors = validator.validate_file(file_path)

        if is_valid:
            print(f"✅ {file_path}")
        else:
            print(f"❌ {file_path}")
            for error in errors:
                print(f"   - {error}")
            all_valid = False

    return all_valid


if __name__ == '__main__':
    # Can be run standalone or as pre-commit hook
    if '--staged' in sys.argv:
        success = validate_staged_files()
        sys.exit(0 if success else 1)
    elif '--file' in sys.argv:
        file_idx = sys.argv.index('--file') + 1
        if file_idx >= len(sys.argv):
            print("Usage: --file <path>")
            sys.exit(1)

        file_path = sys.argv[file_idx]
        ground_truth_path = 'data/ground-truth/canonical-values.json'

        if not Path(ground_truth_path).exists():
            print(f"Ground truth not found, skipping validation")
            sys.exit(0)

        validator = Layer2Validator(ground_truth_path)
        is_valid, errors = validator.validate_file(file_path)

        if is_valid:
            print(f"✅ Valid: {file_path}")
        else:
            print(f"❌ Validation failed: {file_path}")
            for error in errors:
                print(f"   - {error}")
            sys.exit(1)
    else:
        print("Usage:")
        print("  python3 layer2-simple-validation.py --staged")
        print("  python3 layer2-simple-validation.py --file <path>")
        sys.exit(1)
