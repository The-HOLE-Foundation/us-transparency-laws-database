#!/usr/bin/env python3
"""
Statutory Exemption Data Extractor - Enhanced Version
Extracts requestor rights and exemptions from FOIA/Public Records Act process maps
for all 51 U.S. jurisdictions (50 states + DC + Federal)
"""

import re
import json
import csv
import os
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional
from collections import defaultdict


class StatutoryDataExtractor:
    """Extracts and processes statutory exemption data from process map markdown files."""

    def __init__(self, input_dir: str, output_dir: str):
        self.input_dir = Path(input_dir)
        self.output_dir = Path(output_dir)
        self.by_state_dir = self.output_dir / "By-State"
        self.master_dir = self.output_dir / "Master-Datasets"

        # Ensure output directories exist
        self.by_state_dir.mkdir(parents=True, exist_ok=True)
        self.master_dir.mkdir(parents=True, exist_ok=True)

        # Master data collectors
        self.all_requestor_rights = []
        self.all_exemptions = []

        # Jurisdiction code mapping
        self.jurisdiction_codes = {
            "Federal": "US-FED",
            "Alabama": "US-AL",
            "Alaska": "US-AK",
            "Arizona": "US-AZ",
            "Arkansas": "US-AR",
            "California": "US-CA",
            "Colorado": "US-CO",
            "Connecticut": "US-CT",
            "Delaware": "US-DE",
            "Florida": "US-FL",
            "Georgia": "US-GA",
            "Hawaii": "US-HI",
            "Idaho": "US-ID",
            "Illinois": "US-IL",
            "Indiana": "US-IN",
            "Iowa": "US-IA",
            "Kansas": "US-KS",
            "Kentucky": "US-KY",
            "Louisiana": "US-LA",
            "Maine": "US-ME",
            "Maryland": "US-MD",
            "Massachusetts": "US-MA",
            "Michigan": "US-MI",
            "Minnesota": "US-MN",
            "Mississippi": "US-MS",
            "Missouri": "US-MO",
            "Montana": "US-MT",
            "Nebraska": "US-NE",
            "Nevada": "US-NV",
            "New Hampshire": "US-NH",
            "New Jersey": "US-NJ",
            "New Mexico": "US-NM",
            "New York": "US-NY",
            "North Carolina": "US-NC",
            "North Dakota": "US-ND",
            "Ohio": "US-OH",
            "Oklahoma": "US-OK",
            "Oregon": "US-OR",
            "Pennsylvania": "US-PA",
            "Rhode Island": "US-RI",
            "South Carolina": "US-SC",
            "South Dakota": "US-SD",
            "Tennessee": "US-TN",
            "Texas": "US-TX",
            "Utah": "US-UT",
            "Vermont": "US-VT",
            "Virginia": "US-VA",
            "Washington": "US-WA",
            "West Virginia": "US-WV",
            "Wisconsin": "US-WI",
            "Wyoming": "US-WY",
            "DC": "US-DC"
        }

    def parse_markdown_sections(self, content: str) -> Dict[str, str]:
        """Parse markdown into sections based on headers."""
        sections = {}
        current_section = None
        current_content = []

        lines = content.split('\n')
        for line in lines:
            # Check if it's a header
            header_match = re.match(r'^(#{1,3})\s+(.+)$', line)
            if header_match:
                # Save previous section
                if current_section:
                    sections[current_section] = '\n'.join(current_content)

                # Start new section
                level = len(header_match.group(1))
                title = header_match.group(2).strip()
                # Remove emoji and special characters from title
                title = re.sub(r'[⚠️✅\*\-]', '', title).strip()
                current_section = title
                current_content = [line]
            else:
                if current_section:
                    current_content.append(line)

        # Save last section
        if current_section:
            sections[current_section] = '\n'.join(current_content)

        return sections

    def extract_jurisdiction_info(self, content: str, filename: str) -> Tuple[str, str, str, str]:
        """Extract jurisdiction name, code, law name, and primary statute citation."""

        # Extract jurisdiction name from filename
        if filename.startswith("01-Federal"):
            jurisdiction_name = "Federal"
        elif "DC-FOIA" in filename:
            jurisdiction_name = "DC"
        elif "West-Virginia" in filename or "West Virginia" in filename:
            jurisdiction_name = "West Virginia"
        elif "New-Hampshire" in filename or "New Hampshire" in filename:
            jurisdiction_name = "New Hampshire"
        elif "New-Jersey" in filename or "New Jersey" in filename:
            jurisdiction_name = "New Jersey"
        elif "New-Mexico" in filename or "New Mexico" in filename:
            jurisdiction_name = "New Mexico"
        elif "New-York" in filename or "New York" in filename:
            jurisdiction_name = "New York"
        elif "North-Carolina" in filename or "North Carolina" in filename:
            jurisdiction_name = "North Carolina"
        elif "North-Dakota" in filename or "North Dakota" in filename:
            jurisdiction_name = "North Dakota"
        elif "Rhode-Island" in filename or "Rhode Island" in filename:
            jurisdiction_name = "Rhode Island"
        elif "South-Carolina" in filename or "South Carolina" in filename:
            jurisdiction_name = "South Carolina"
        elif "South-Dakota" in filename or "South Dakota" in filename:
            jurisdiction_name = "South Dakota"
        else:
            # Extract state name from filename
            match = re.match(r'([A-Za-z]+?)-', filename)
            jurisdiction_name = match.group(1).strip() if match else "Unknown"

        # Extract law name from title
        title_match = re.search(r'^#\s+(.+?)\s*-\s*VERIFIED', content, re.MULTILINE)
        law_name = title_match.group(1).strip() if title_match else "Unknown Law"

        jurisdiction_code = self.jurisdiction_codes.get(jurisdiction_name, "UNKNOWN")

        # Extract primary statute citation
        statute_citation = self._extract_primary_statute(content)

        return jurisdiction_name, jurisdiction_code, law_name, statute_citation

    def _extract_primary_statute(self, content: str) -> str:
        """Extract primary statute citation."""
        # Look for primary statute in Legal Framework section
        legal_framework = re.search(
            r'##\s+Legal Framework.*?(?=##|\Z)',
            content,
            re.DOTALL | re.IGNORECASE
        )

        if legal_framework:
            framework_text = legal_framework.group(0)

            # Try various patterns
            patterns = [
                r'\*\*Primary Statute\*\*.*?(?:§§?|Code|U\.S\.C\.|Stat\.)\s+[\d-]+(?:\s+through\s+[\d-]+)?',
                r'(?:§§?|Code)\s+[\d-]+(?:\s+through\s+[\d-]+)?',
                r'\d+\s+U\.S\.C\.\s+§\s+\d+',
                r'[A-Z][a-z]+\s+(?:Code|Stat\.)\s+§\s+[\d-]+',
            ]

            for pattern in patterns:
                match = re.search(pattern, framework_text)
                if match:
                    return match.group(0).replace('**Primary Statute**', '').strip()

        return "Citation not found"

    def extract_statute_references(self, text: str) -> List[str]:
        """Extract all statute references from text."""
        patterns = [
            r'(?:§§?|U\.S\.C\.|Code)\s+[\d-]+(?:\([a-z]\))?(?:\([0-9]+\))?(?:\([A-Z]\))?',
            r'\d+\s+U\.S\.C\.\s+§\s+\d+(?:\([a-z]\))?',
            r'[A-Z][a-z]+\.\s+(?:Code|Stat\.)\s+§\s+[\d-]+',
        ]

        refs = []
        for pattern in patterns:
            refs.extend(re.findall(pattern, text))

        return list(set(refs))  # Remove duplicates

    def extract_requestor_rights(self, sections: Dict[str, str],
                                 jurisdiction_name: str, jurisdiction_code: str,
                                 law_name: str, statute_citation: str) -> List[Dict]:
        """Extract requestor rights from various sections."""
        rights = []

        # Sections that contain requestor rights information
        rights_sections = [
            'Response Timeline', 'Response Timelines', 'Timeline', 'Timelines',
            'Response Timeline Framework', 'Standard Timeline',
            'Fee Structure', 'Fees', 'Fee Schedule', 'Costs',
            'Request Process', 'Submission Requirements', 'Standard Process Flow',
            'Phase 1', 'Phase 2', 'Phase 3',
            'Appeal Process', 'Enforcement', 'Remedies',
            'Expedited Processing', 'Special Access'
        ]

        for section_name, section_content in sections.items():
            # Check if this section contains requestor rights info
            if any(keyword in section_name for keyword in rights_sections):
                # Extract rights from this section
                section_rights = self._parse_rights_from_section(
                    section_name, section_content, jurisdiction_name,
                    jurisdiction_code, law_name, statute_citation
                )
                rights.extend(section_rights)

        return rights

    def _parse_rights_from_section(self, section_name: str, section_content: str,
                                   jurisdiction_name: str, jurisdiction_code: str,
                                   law_name: str, statute_citation: str) -> List[Dict]:
        """Parse rights from a specific section."""
        rights = []

        # Extract statute references
        statute_refs = self.extract_statute_references(section_content)

        # Split content into subsections based on ### headers or bullet points
        subsections = re.split(r'\n#{3,}\s+\*\*(.+?)\*\*|\n-\s+\*\*(.+?)\*\*', section_content)

        # If no clear subsections, treat as single block
        if len(subsections) <= 1:
            subsections = [section_content]

        for subsection in subsections:
            if not subsection or len(subsection.strip()) < 20:
                continue

            # Determine category
            category = self._determine_category(section_name, subsection)

            # Extract key provisions
            provisions = self._extract_provisions(subsection)

            for provision in provisions:
                rights.append({
                    'jurisdiction_name': jurisdiction_name,
                    'jurisdiction_code': jurisdiction_code,
                    'law_name': law_name,
                    'statute_citation': statute_citation,
                    'section_reference': ', '.join(statute_refs[:3]) if statute_refs else 'See statute',
                    'category': category,
                    'subcategory': provision['subcategory'],
                    'description': provision['description'],
                    'conditions': provision['conditions'],
                    'notes': f'Extracted from {section_name}',
                    'extraction_date': datetime.now().isoformat()
                })

        return rights

    def _determine_category(self, section_name: str, content: str) -> str:
        """Determine the category of requestor right."""
        section_lower = section_name.lower()

        if any(keyword in section_lower for keyword in ['timeline', 'response', 'deadline']):
            return 'Response Timeline'
        elif any(keyword in section_lower for keyword in ['fee', 'cost', 'charge']):
            return 'Fee Structure'
        elif any(keyword in section_lower for keyword in ['appeal', 'enforcement', 'remedy']):
            return 'Appeal Rights'
        elif any(keyword in section_lower for keyword in ['expedited', 'priority', 'urgent']):
            return 'Special Access'
        elif any(keyword in section_lower for keyword in ['request', 'submission', 'process']):
            return 'Request Process'
        else:
            return 'General Rights'

    def _extract_provisions(self, text: str) -> List[Dict]:
        """Extract individual provisions from text."""
        provisions = []

        # Look for bullet points with ** markers
        bullet_pattern = r'-\s+\*\*(.+?)\*\*:\s*(.+?)(?=\n-\s+\*\*|\n\n|\Z)'
        bullet_matches = re.finditer(bullet_pattern, text, re.DOTALL)

        for match in bullet_matches:
            subcategory = match.group(1).strip()
            description = match.group(2).strip()

            provisions.append({
                'subcategory': subcategory,
                'description': description[:500],  # Limit length
                'conditions': self._extract_conditions(description)
            })

        # If no bullet points found, extract paragraph-level info
        if not provisions:
            # Look for numbered items
            numbered_pattern = r'\d+\.\s+\*\*(.+?)\*\*:?\s*(.+?)(?=\n\d+\.|\n\n|\Z)'
            numbered_matches = re.finditer(numbered_pattern, text, re.DOTALL)

            for match in numbered_matches:
                subcategory = match.group(1).strip()
                description = match.group(2).strip()

                provisions.append({
                    'subcategory': subcategory,
                    'description': description[:500],
                    'conditions': self._extract_conditions(description)
                })

        # If still no provisions, extract from plain text
        if not provisions:
            paragraphs = [p.strip() for p in text.split('\n\n') if len(p.strip()) > 30]
            for para in paragraphs[:5]:  # Take first 5 paragraphs max
                # Extract first sentence as subcategory
                sentences = re.split(r'[.!?]\s+', para)
                if sentences:
                    first_sent = sentences[0][:100]
                    provisions.append({
                        'subcategory': first_sent,
                        'description': para[:500],
                        'conditions': self._extract_conditions(para)
                    })

        return provisions

    def _extract_conditions(self, text: str) -> str:
        """Extract conditions or limitations from text."""
        condition_keywords = [
            'provided that', 'unless', 'except', 'if', 'when',
            'subject to', 'limited to', 'may', 'shall', 'must',
            'only', 'however', 'but'
        ]

        sentences = re.split(r'[.!?]\s+', text)
        condition_sentences = []

        for sentence in sentences:
            if any(keyword in sentence.lower() for keyword in condition_keywords):
                condition_sentences.append(sentence.strip())

        result = ' '.join(condition_sentences[:2])  # Return up to 2 condition sentences
        return result[:300] if result else 'No specific conditions stated'

    def extract_exemptions(self, sections: Dict[str, str],
                          jurisdiction_name: str, jurisdiction_code: str,
                          law_name: str, statute_citation: str) -> List[Dict]:
        """Extract exemption data from exemption sections."""
        exemptions = []

        # Sections that contain exemption information
        exemption_section_names = [
            'Classification System and Exemptions', 'Exemptions and Common Barriers',
            'Exemptions', 'Protected Records', 'Exemptions and Limitations',
            'Protected Information', 'Confidential Records', 'Limitations'
        ]

        for section_name, section_content in sections.items():
            # Check if this section contains exemption info
            if any(keyword in section_name for keyword in exemption_section_names):
                section_exemptions = self._parse_exemptions_from_section(
                    section_name, section_content, jurisdiction_name,
                    jurisdiction_code, law_name, statute_citation
                )
                exemptions.extend(section_exemptions)

        return exemptions

    def _parse_exemptions_from_section(self, section_name: str, section_content: str,
                                      jurisdiction_name: str, jurisdiction_code: str,
                                      law_name: str, statute_citation: str) -> List[Dict]:
        """Parse exemptions from a specific section."""
        exemptions = []

        # Extract statute references
        statute_refs = self.extract_statute_references(section_content)

        # Look for Federal FOIA numbered exemptions (b)(1) through (b)(9)
        if jurisdiction_name == "Federal":
            numbered_pattern = r'\d+\.\s+\*\*\(b\)\((\d+)\)\*\*\s*-\s*(.+?)(?=\n\d+\.|\n\n|\Z)'
            for match in re.finditer(numbered_pattern, section_content, re.DOTALL):
                exemption_num = match.group(1)
                description = match.group(2).strip()

                exemptions.append({
                    'jurisdiction_name': jurisdiction_name,
                    'jurisdiction_code': jurisdiction_code,
                    'law_name': law_name,
                    'statute_citation': statute_citation,
                    'section_reference': f'5 U.S.C. § 552(b)({exemption_num})',
                    'category': 'Statutory Exemption',
                    'subcategory': f'Federal FOIA Exemption (b)({exemption_num})',
                    'description': description[:500],
                    'conditions': self._extract_conditions(description),
                    'notes': f'Federal FOIA exemption {exemption_num}',
                    'extraction_date': datetime.now().isoformat()
                })

        # Look for bullet-point exemptions
        bullet_pattern = r'-\s+\*\*(.+?)\*\*:?\s*(.+?)(?=\n-\s+\*\*|\n\n|\Z)'
        for match in re.finditer(bullet_pattern, section_content, re.DOTALL):
            exemption_type = match.group(1).strip()
            description = match.group(2).strip()

            # Determine exemption category
            category = self._categorize_exemption(exemption_type, description)

            exemptions.append({
                'jurisdiction_name': jurisdiction_name,
                'jurisdiction_code': jurisdiction_code,
                'law_name': law_name,
                'statute_citation': statute_citation,
                'section_reference': ', '.join(statute_refs[:3]) if statute_refs else 'See exemptions',
                'category': 'Statutory Exemption',
                'subcategory': category,
                'description': description[:500],
                'conditions': self._extract_conditions(description),
                'notes': f'Exemption type: {exemption_type}',
                'extraction_date': datetime.now().isoformat()
            })

        # Look for subsection headers
        subsection_pattern = r'###\s+\*\*(.+?)\*\*\n+(.*?)(?=###|\Z)'
        for match in re.finditer(subsection_pattern, section_content, re.DOTALL):
            exemption_type = match.group(1).strip()
            description = match.group(2).strip()

            if len(description) > 30:  # Only if there's meaningful content
                category = self._categorize_exemption(exemption_type, description)

                # Extract individual items from the description
                items = re.split(r'\n-\s+', description)
                for item in items:
                    if len(item.strip()) > 20:
                        exemptions.append({
                            'jurisdiction_name': jurisdiction_name,
                            'jurisdiction_code': jurisdiction_code,
                            'law_name': law_name,
                            'statute_citation': statute_citation,
                            'section_reference': ', '.join(statute_refs[:3]) if statute_refs else 'See exemptions',
                            'category': 'Statutory Exemption',
                            'subcategory': category,
                            'description': item.strip()[:500],
                            'conditions': self._extract_conditions(item),
                            'notes': f'From section: {exemption_type}',
                            'extraction_date': datetime.now().isoformat()
                        })

        return exemptions

    def _categorize_exemption(self, exemption_type: str, description: str) -> str:
        """Categorize exemption based on type and description."""
        combined_text = (exemption_type + ' ' + description).lower()

        if any(keyword in combined_text for keyword in ['national defense', 'national security', 'classified', 'foreign policy']):
            return 'National Security/Defense'
        elif any(keyword in combined_text for keyword in ['law enforcement', 'investigatory', 'criminal', 'police']):
            return 'Law Enforcement'
        elif any(keyword in combined_text for keyword in ['personal privacy', 'privacy', 'private']):
            return 'Personal Privacy'
        elif any(keyword in combined_text for keyword in ['trade secret', 'commercial', 'proprietary', 'business']):
            return 'Trade Secrets/Commercial'
        elif any(keyword in combined_text for keyword in ['attorney', 'legal', 'privilege']):
            return 'Attorney-Client Privilege'
        elif any(keyword in combined_text for keyword in ['deliberative', 'predecisional', 'inter-agency', 'intra-agency']):
            return 'Deliberative Process'
        elif any(keyword in combined_text for keyword in ['personnel', 'employee', 'staff']):
            return 'Personnel Records'
        elif any(keyword in combined_text for keyword in ['medical', 'health']):
            return 'Medical Records'
        elif any(keyword in combined_text for keyword in ['educational', 'student', 'ferpa']):
            return 'Educational Records'
        elif any(keyword in combined_text for keyword in ['security', 'safety', 'infrastructure']):
            return 'Security Information'
        elif any(keyword in combined_text for keyword in ['financial institution', 'bank']):
            return 'Financial Institution Records'
        elif any(keyword in combined_text for keyword in ['geological', 'well', 'oil', 'gas']):
            return 'Geological Information'
        elif any(keyword in combined_text for keyword in ['internal', 'administrative']):
            return 'Internal Agency Rules'
        else:
            return 'Other Exemption'

    def process_file(self, filepath: Path) -> Tuple[List[Dict], List[Dict]]:
        """Process a single process map file."""
        print(f"Processing: {filepath.name}")

        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            # Extract jurisdiction info
            jurisdiction_name, jurisdiction_code, law_name, statute_citation = \
                self.extract_jurisdiction_info(content, filepath.name)

            print(f"  Jurisdiction: {jurisdiction_name} ({jurisdiction_code})")
            print(f"  Law: {law_name}")
            print(f"  Citation: {statute_citation}")

            # Parse markdown sections
            sections = self.parse_markdown_sections(content)
            print(f"  Sections found: {len(sections)}")

            # Extract requestor rights
            requestor_rights = self.extract_requestor_rights(
                sections, jurisdiction_name, jurisdiction_code,
                law_name, statute_citation
            )
            print(f"  Requestor rights extracted: {len(requestor_rights)}")

            # Extract exemptions
            exemptions = self.extract_exemptions(
                sections, jurisdiction_name, jurisdiction_code,
                law_name, statute_citation
            )
            print(f"  Exemptions extracted: {len(exemptions)}")

            return requestor_rights, exemptions

        except Exception as e:
            print(f"  ERROR: {str(e)}")
            import traceback
            traceback.print_exc()
            return [], []

    def save_csv(self, data: List[Dict], filepath: Path):
        """Save data to CSV format."""
        if not data:
            return

        fieldnames = [
            'jurisdiction_name', 'jurisdiction_code', 'law_name', 'statute_citation',
            'section_reference', 'category', 'subcategory', 'description',
            'conditions', 'notes', 'extraction_date'
        ]

        with open(filepath, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(data)

        print(f"  Saved CSV: {filepath.name} ({len(data)} rows)")

    def save_json(self, data: List[Dict], filepath: Path, jurisdiction_name: str = None):
        """Save data to JSON format with structured nesting."""
        if not data:
            return

        # Group by category
        by_category = defaultdict(list)
        for record in data:
            by_category[record['category']].append(record)

        structured_data = {
            'metadata': {
                'extraction_date': datetime.now().isoformat(),
                'total_records': len(data),
                'jurisdiction': jurisdiction_name if jurisdiction_name else 'All Jurisdictions',
                'data_source': 'VERIFIED Process Maps',
                'verification_date': 'September 2025',
                'categories': list(by_category.keys())
            },
            'records': data,
            'records_by_category': dict(by_category)
        }

        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(structured_data, f, indent=2, ensure_ascii=False)

        print(f"  Saved JSON: {filepath.name} ({len(data)} records)")

    def process_all_files(self):
        """Process all verified process map files."""
        print("\n" + "="*80)
        print("STATUTORY EXEMPTION DATA EXTRACTION - ENHANCED VERSION")
        print("="*80 + "\n")

        # Find all verified process map files
        process_map_files = sorted(
            self.input_dir.glob("*VERIFIED-Process-Map.md")
        )
        process_map_files = [
            f for f in process_map_files
            if "COMPREHENSIVE-MASTER" not in f.name
        ]

        print(f"Found {len(process_map_files)} process map files\n")

        for filepath in process_map_files:
            try:
                # Process the file
                requestor_rights, exemptions = self.process_file(filepath)

                # Extract jurisdiction name for file naming
                if filepath.name.startswith("01-Federal"):
                    jurisdiction_name = "Federal"
                elif "DC-FOIA" in filepath.name:
                    jurisdiction_name = "DC"
                elif "West-Virginia" in filepath.name:
                    jurisdiction_name = "West_Virginia"
                elif "New-Hampshire" in filepath.name:
                    jurisdiction_name = "New_Hampshire"
                elif "New-Jersey" in filepath.name:
                    jurisdiction_name = "New_Jersey"
                elif "New-Mexico" in filepath.name:
                    jurisdiction_name = "New_Mexico"
                elif "New-York" in filepath.name:
                    jurisdiction_name = "New_York"
                elif "North-Carolina" in filepath.name:
                    jurisdiction_name = "North_Carolina"
                elif "North-Dakota" in filepath.name:
                    jurisdiction_name = "North_Dakota"
                elif "Rhode-Island" in filepath.name:
                    jurisdiction_name = "Rhode_Island"
                elif "South-Carolina" in filepath.name:
                    jurisdiction_name = "South_Carolina"
                elif "South-Dakota" in filepath.name:
                    jurisdiction_name = "South_Dakota"
                else:
                    match = re.match(r'([A-Za-z]+?)-', filepath.name)
                    jurisdiction_name = match.group(1) if match else "Unknown"

                # Save individual state files
                if requestor_rights:
                    self.save_csv(
                        requestor_rights,
                        self.by_state_dir / f"{jurisdiction_name}_requestor_rights.csv"
                    )
                    self.save_json(
                        requestor_rights,
                        self.by_state_dir / f"{jurisdiction_name}_requestor_rights.json",
                        jurisdiction_name
                    )
                    self.all_requestor_rights.extend(requestor_rights)

                if exemptions:
                    self.save_csv(
                        exemptions,
                        self.by_state_dir / f"{jurisdiction_name}_exemptions.csv"
                    )
                    self.save_json(
                        exemptions,
                        self.by_state_dir / f"{jurisdiction_name}_exemptions.json",
                        jurisdiction_name
                    )
                    self.all_exemptions.extend(exemptions)

                print()  # Blank line

            except Exception as e:
                print(f"ERROR: {str(e)}\n")

        # Save master datasets
        print("="*80)
        print("CREATING MASTER DATASETS")
        print("="*80 + "\n")

        print(f"Total requestor rights records: {len(self.all_requestor_rights)}")
        print(f"Total exemption records: {len(self.all_exemptions)}")

        if self.all_requestor_rights:
            self.save_csv(
                self.all_requestor_rights,
                self.master_dir / "ALL_JURISDICTIONS_requestor_rights.csv"
            )
            self.save_json(
                self.all_requestor_rights,
                self.master_dir / "ALL_JURISDICTIONS_requestor_rights.json"
            )

        if self.all_exemptions:
            self.save_csv(
                self.all_exemptions,
                self.master_dir / "ALL_JURISDICTIONS_exemptions.csv"
            )
            self.save_json(
                self.all_exemptions,
                self.master_dir / "ALL_JURISDICTIONS_exemptions.json"
            )

        print("\n" + "="*80)
        print("EXTRACTION COMPLETE")
        print("="*80)
        print(f"\nTotal jurisdictions processed: {len(process_map_files)}")
        print(f"Total requestor rights: {len(self.all_requestor_rights)}")
        print(f"Total exemptions: {len(self.all_exemptions)}")
        print(f"\nOutput directory: {self.output_dir}")
        print()


def main():
    """Main execution function."""
    base_dir = Path("/Users/jth/Desktop/Definitely Valid Statutory Data/Statutory-Analysis-Data/Statutory-Exemption-Database")
    input_dir = base_dir / "Refrence Datasets" / "Process Maps"
    output_dir = base_dir / "Output-Data"

    extractor = StatutoryDataExtractor(str(input_dir), str(output_dir))
    extractor.process_all_files()


if __name__ == "__main__":
    main()