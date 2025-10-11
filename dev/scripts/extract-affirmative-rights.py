#!/usr/bin/env python3
"""
Extract Affirmative Rights from Statutory Text

This script reads statutory text files and extracts affirmative rights
provisions for use in the FOIA Generator.

Target: Simple, fast extraction of assertions like:
- "X is public information"
- "X may not be withheld"
- "must be disclosed"
- "shall make available"

Output: JSON structured for FOIA Generator assertion templates
"""

import re
import json
from pathlib import Path
from typing import List, Dict
import sys


class AffirmativeRightsExtractor:
    """Extract affirmative rights from transparency law statutory text"""

    # Patterns that indicate affirmative rights
    AFFIRMATIVE_PATTERNS = [
        r"is public information",
        r"are public information",
        r"may not be withheld",
        r"shall not be withheld",
        r"must be disclosed",
        r"shall be disclosed",
        r"shall make available",
        r"must make available",
        r"right to inspect",
        r"right of access",
        r"free of charge",
        r"at no cost",
        r"shall not exceed",
        r"may not charge",
    ]

    # Section citation patterns
    CITATION_PATTERNS = {
        'texas': r'Sec\.\s+(\d+\.\d+)',
        'california': r'§\s*(\d+)',
        'federal': r'§\s*(\d+)',
        'illinois': r'(\d+\s+ILCS\s+\d+/[\d\-\.]+)',
        'default': r'§\s*(\d+[\.\d]*)',
    }

    def __init__(self, jurisdiction_slug: str):
        self.jurisdiction_slug = jurisdiction_slug
        self.citation_pattern = self.CITATION_PATTERNS.get(
            jurisdiction_slug,
            self.CITATION_PATTERNS['default']
        )

    def extract_section_number(self, text: str, line_num: int, lines: List[str]) -> str:
        """Extract the section number for a given line"""
        # Look backwards from current line to find section header
        for i in range(max(0, line_num - 20), line_num + 1):
            if i >= len(lines):
                continue
            line = lines[i]
            match = re.search(self.citation_pattern, line)
            if match:
                return match.group(1)
        return "UNKNOWN"

    def extract_context(self, line_num: int, lines: List[str], context_lines: int = 3) -> str:
        """Extract surrounding context for a match"""
        start = max(0, line_num - context_lines)
        end = min(len(lines), line_num + context_lines + 1)
        context = ' '.join(lines[start:end])
        # Clean up whitespace
        context = re.sub(r'\s+', ' ', context).strip()
        return context

    def extract_rights(self, statutory_text_path: Path) -> List[Dict]:
        """Extract all affirmative rights from statutory text file"""

        if not statutory_text_path.exists():
            raise FileNotFoundError(f"Statutory text not found: {statutory_text_path}")

        with open(statutory_text_path, 'r', encoding='utf-8') as f:
            text = f.read()
            lines = text.split('\n')

        rights = []
        right_id = 1

        # Search for each pattern
        for pattern in self.AFFIRMATIVE_PATTERNS:
            for line_num, line in enumerate(lines):
                if re.search(pattern, line, re.IGNORECASE):
                    # Extract section number
                    section = self.extract_section_number(line, line_num, lines)

                    # Extract context
                    context = self.extract_context(line_num, lines, context_lines=3)

                    # Create right entry
                    right = {
                        "right_id": f"{self.jurisdiction_slug}-{right_id:03d}",
                        "section": section,
                        "pattern_matched": pattern,
                        "line_number": line_num + 1,
                        "statutory_text": context[:500],  # Limit to 500 chars
                        "full_line": line.strip()
                    }

                    rights.append(right)
                    right_id += 1

        return rights

    def generate_foia_assertions(self, rights: List[Dict],
                                 jurisdiction_name: str,
                                 statute_name: str) -> List[Dict]:
        """Generate FOIA assertion templates from extracted rights"""

        assertions = []

        for right in rights:
            # Determine assertion type based on pattern
            if "is public information" in right['pattern_matched']:
                assertion_type = "affirmative_disclosure"
                template = f"As per {right['section']} of the {statute_name}, [RECORD_TYPE] is public information and cannot be exempted from disclosure."

            elif "may not be withheld" in right['pattern_matched']:
                assertion_type = "prohibition_on_withholding"
                template = f"Under {right['section']} of the {statute_name}, [RECORD_TYPE] may not be withheld from disclosure."

            elif "free of charge" in right['pattern_matched'] or "at no cost" in right['pattern_matched']:
                assertion_type = "fee_protection"
                template = f"According to {right['section']} of the {statute_name}, [ACTION] must be provided at no cost."

            elif "shall not exceed" in right['pattern_matched']:
                assertion_type = "fee_cap"
                template = f"Per {right['section']} of the {statute_name}, fees shall not exceed [AMOUNT]."

            else:
                assertion_type = "general_right"
                template = f"Under {right['section']} of the {statute_name}, [RIGHT_DESCRIPTION]."

            assertion = {
                "right_id": right['right_id'],
                "section": right['section'],
                "assertion_type": assertion_type,
                "foia_template": template,
                "statutory_basis": right['statutory_text'],
                "source_verified": False,  # Requires manual verification
                "verification_notes": f"Auto-extracted from line {right['line_number']}, requires manual verification"
            }

            assertions.append(assertion)

        return assertions


def main():
    """Extract affirmative rights from Texas statute (example)"""

    # Configuration
    jurisdiction_slug = "texas"
    jurisdiction_name = "Texas"
    statute_name = "Texas Public Information Act"

    statutory_text_path = Path("consolidated-transparency-data/statutory-text-files/TEXAS_transparency_law-v0.11.txt")

    # Extract rights
    print(f"Extracting affirmative rights from {jurisdiction_slug}...")
    extractor = AffirmativeRightsExtractor(jurisdiction_slug)
    rights = extractor.extract_rights(statutory_text_path)

    print(f"Found {len(rights)} potential affirmative rights matches")

    # Generate FOIA assertions
    assertions = extractor.generate_foia_assertions(rights, jurisdiction_name, statute_name)

    # Output structure
    output = {
        "jurisdiction": {
            "slug": jurisdiction_slug,
            "name": jurisdiction_name
        },
        "statute_name": statute_name,
        "extraction_date": "2025-10-08",
        "extraction_method": "automated_pattern_matching",
        "requires_manual_verification": True,
        "affirmative_rights": assertions
    }

    # Save to file
    output_path = Path(f"data/v0.12/affirmative-rights/{jurisdiction_slug}-affirmative-rights-UNVERIFIED.json")
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    print(f"\nExtraction complete!")
    print(f"Output: {output_path}")
    print(f"Total rights extracted: {len(assertions)}")
    print(f"\nNOTE: This data requires manual verification before use in FOIA Generator")
    print(f"Each right must be verified against official statute to confirm accuracy")

    # Show sample
    print("\n--- Sample Extracted Rights (first 3) ---")
    for assertion in assertions[:3]:
        print(f"\n{assertion['right_id']}: {assertion['section']}")
        print(f"  Type: {assertion['assertion_type']}")
        print(f"  Template: {assertion['foia_template']}")
        print(f"  Basis: {assertion['statutory_basis'][:150]}...")


if __name__ == "__main__":
    main()
