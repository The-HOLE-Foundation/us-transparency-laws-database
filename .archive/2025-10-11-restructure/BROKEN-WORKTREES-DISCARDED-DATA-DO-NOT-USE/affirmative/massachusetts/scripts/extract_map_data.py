#!/usr/bin/env python3
"""
Extract curated data from all 51 process maps for the Transparency Map interface.
Creates the master transparency-map-data-v0.11.json dataset.
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Optional, Any

# Jurisdiction code mapping
JURISDICTION_CODES = {
    "Federal": "FED",
    "Alabama": "AL",
    "Alaska": "AK",
    "Arizona": "AZ",
    "Arkansas": "AR",
    "California": "CA",
    "Colorado": "CO",
    "Connecticut": "CT",
    "Delaware": "DE",
    "District of Columbia": "DC",
    "Florida": "FL",
    "Georgia": "GA",
    "Hawaii": "HI",
    "Idaho": "ID",
    "Illinois": "IL",
    "Indiana": "IN",
    "Iowa": "IA",
    "Kansas": "KS",
    "Kentucky": "KY",
    "Louisiana": "LA",
    "Maine": "ME",
    "Maryland": "MD",
    "Massachusetts": "MA",
    "Michigan": "MI",
    "Minnesota": "MN",
    "Mississippi": "MS",
    "Missouri": "MO",
    "Montana": "MT",
    "Nebraska": "NE",
    "Nevada": "NV",
    "New Hampshire": "NH",
    "New Jersey": "NJ",
    "New Mexico": "NM",
    "New York": "NY",
    "North Carolina": "NC",
    "North Dakota": "ND",
    "Ohio": "OH",
    "Oklahoma": "OK",
    "Oregon": "OR",
    "Pennsylvania": "PA",
    "Rhode Island": "RI",
    "South Carolina": "SC",
    "South Dakota": "SD",
    "Tennessee": "TN",
    "Texas": "TX",
    "Utah": "UT",
    "Vermont": "VT",
    "Virginia": "VA",
    "Washington": "WA",
    "West Virginia": "WV",
    "Wisconsin": "WI",
    "Wyoming": "WY"
}

# Statute abbreviations (from file names)
STATUTE_ABBREVIATIONS = {
    "Alabama": "PRL",
    "Alaska": "Public Records",
    "Arizona": "PRL",
    "Arkansas": "FOIA",
    "California": "CPRA",
    "Colorado": "CORA",
    "Connecticut": "FOIA",
    "Delaware": "FOIA",
    "District of Columbia": "FOIA",
    "Florida": "Sunshine Law",
    "Georgia": "ORA",
    "Hawaii": "UIPA",
    "Idaho": "Public Records",
    "Illinois": "FOIA",
    "Indiana": "APRA",
    "Iowa": "Open Records",
    "Kansas": "KORA",
    "Kentucky": "Open Records",
    "Louisiana": "Public Records",
    "Maine": "FOAA",
    "Maryland": "PIA",
    "Massachusetts": "PRL",
    "Michigan": "FOIA",
    "Minnesota": "Data Practices",
    "Mississippi": "Public Records",
    "Missouri": "Sunshine Law",
    "Montana": "Right to Know",
    "Nebraska": "Public Records",
    "Nevada": "Public Records",
    "New Hampshire": "Right-to-Know",
    "New Jersey": "OPRA",
    "New Mexico": "IPRA",
    "New York": "FOIL",
    "North Carolina": "Public Records",
    "North Dakota": "Open Records",
    "Ohio": "PRL",
    "Oklahoma": "Open Records",
    "Oregon": "Public Records",
    "Pennsylvania": "RTKL",
    "Rhode Island": "APRA",
    "South Carolina": "FOIA",
    "South Dakota": "Open Records",
    "Tennessee": "TPRA",
    "Texas": "PIA",
    "Utah": "GRAMA",
    "Vermont": "Public Records",
    "Virginia": "FOIA",
    "Washington": "PRA",
    "West Virginia": "FOIA",
    "Wisconsin": "Open Records",
    "Wyoming": "Public Records",
    "Federal": "FOIA"
}

def extract_section(content: str, section_name: str) -> str:
    """Extract content from a markdown section"""
    pattern = rf"#+\s*{re.escape(section_name)}.*?\n(.*?)(?=\n#+|\Z)"
    match = re.search(pattern, content, re.DOTALL | re.IGNORECASE)
    return match.group(1).strip() if match else ""

def extract_core_principle(content: str) -> str:
    """Extract core principle from process map"""
    # Try multiple patterns
    patterns = [
        r"###\s*Core Principle\s*\n+(.*?)(?=\n###|\n##|\Z)",
        r"Core Principle:?\s*\n+(.*?)(?=\n###|\n##|\Z)",
        r"belongs to the people",
        r"Every.*?resident.*?right to inspect",
        r"public.*?right.*?access"
    ]

    for pattern in patterns:
        match = re.search(pattern, content, re.DOTALL | re.IGNORECASE)
        if match:
            text = match.group(1) if match.lastindex else match.group(0)
            # Clean up
            text = re.sub(r'\n+', ' ', text)
            text = re.sub(r'\s+', ' ', text)
            # Get first 2-3 sentences
            sentences = re.split(r'[.!?]\s+', text)
            return '. '.join(sentences[:2]) + '.' if sentences else text[:300]

    return "Public records belong to the people and should be accessible except as otherwise provided by law."

def extract_response_timeline(content: str, jurisdiction: str) -> Dict[str, Any]:
    """Extract response timeline information"""
    timeline_section = extract_section(content, "Response Timeline")
    if not timeline_section:
        timeline_section = extract_section(content, "Standard Response")

    result = {
        "response_timeline_days": None,
        "response_timeline_type": None,
        "response_timeline_description": None,
        "response_timeline_factors": []
    }

    # Check for "reasonable time" jurisdictions
    if re.search(r"reasonable time|no fixed.*?deadline", timeline_section, re.IGNORECASE):
        result["response_timeline_days"] = -1
        result["response_timeline_type"] = "flexible"
        result["response_timeline_description"] = "Reasonable time (no fixed statutory deadline)"
        result["response_timeline_factors"] = ["Request complexity", "Volume of records", "Agency resources"]
        return result

    # Check for "promptly"
    if re.search(r"promptly|prompt", timeline_section, re.IGNORECASE) and not re.search(r"\d+\s*(?:business|calendar|working)?\s*days", timeline_section, re.IGNORECASE):
        result["response_timeline_days"] = -2
        result["response_timeline_type"] = "flexible"
        result["response_timeline_description"] = "Promptly (no specific day count)"
        result["response_timeline_factors"] = ["Nature of records", "Urgency", "Practical accessibility"]
        return result

    # Extract fixed number of days
    day_patterns = [
        r"(\d+)\s*(?:business|working)\s*days",
        r"(\d+)\s*calendar\s*days",
        r"(\d+)\s*days"
    ]

    for pattern in day_patterns:
        match = re.search(pattern, timeline_section, re.IGNORECASE)
        if match:
            days = int(match.group(1))
            result["response_timeline_days"] = days

            if "business" in match.group(0).lower() or "working" in match.group(0).lower():
                result["response_timeline_type"] = "business"
            elif "calendar" in match.group(0).lower():
                result["response_timeline_type"] = "calendar"
            else:
                result["response_timeline_type"] = "unspecified"

            result["response_timeline_description"] = f"{days} {result['response_timeline_type']} days from receipt of request"
            return result

    # Default for unclear cases
    result["response_timeline_days"] = -1
    result["response_timeline_type"] = "flexible"
    result["response_timeline_description"] = "Timeline not clearly specified in statute"
    return result

def extract_recent_changes(content: str) -> str:
    """Extract 2024-2025 legislative changes"""
    patterns = [
        r"2025.*?(?:Amendment|Update|Change|Bill|Act|Effective).*?(?=\n###|\n##|\n-|\Z)",
        r"2024.*?(?:Amendment|Update|Change|Bill|Act|Effective).*?(?=\n###|\n##|\n-|\Z)",
        r"Recent.*?(?:Update|Change|Amendment).*?2025.*?(?=\n###|\n##|\Z)",
        r"Legislative.*?(?:Update|Change).*?202[45].*?(?=\n###|\n##|\Z)"
    ]

    for pattern in patterns:
        matches = re.findall(pattern, content, re.DOTALL | re.IGNORECASE)
        if matches:
            text = ' '.join(matches)
            # Clean up
            text = re.sub(r'\n+', ' ', text)
            text = re.sub(r'\s+', ' ', text)
            # Limit length
            if len(text) > 300:
                sentences = re.split(r'[.!?]\s+', text)
                text = '. '.join(sentences[:3]) + '.'
            return text.strip()

    if re.search(r"no.*?(?:significant|major).*?(?:change|amendment|update)", content, re.IGNORECASE):
        return "No significant statutory changes in 2024-2025."

    return "Recent legislative activity not documented in current version."

def extract_public_record_categories(content: str) -> List[str]:
    """Extract key categories of public records"""
    categories = []

    # Look for common record types
    record_patterns = [
        r"(?:arrest|booking|police)\s+(?:log|record|report)",
        r"government\s+(?:calendar|correspondence)",
        r"emergency\s+response\s+record",
        r"contract\s+(?:record|document)",
        r"meeting\s+(?:minute|agenda)",
        r"financial\s+record",
        r"personnel\s+record",
        r"email.*?public business",
        r"text message.*?public business"
    ]

    for pattern in record_patterns:
        matches = re.findall(pattern, content, re.IGNORECASE)
        if matches:
            # Clean up and capitalize
            category = matches[0]
            category = re.sub(r'\s+', ' ', category).strip()
            category = category.capitalize()
            if category not in categories:
                categories.append(category)

    # Ensure we have at least 3 categories
    if len(categories) < 3:
        categories.extend([
            "Government agency records",
            "Public official communications",
            "Financial and budgetary documents"
        ])

    return categories[:5]  # Return top 5

def extract_fee_structure(content: str) -> Dict[str, Any]:
    """Extract fee structure information"""
    fee_section = extract_section(content, "Fee Structure")
    if not fee_section:
        fee_section = extract_section(content, "Fees")

    result = {
        "standard_copying": "Actual cost of reproduction",
        "search_fees": None,
        "electronic_records": None,
        "fee_waiver_available": False,
        "waiver_criteria": []
    }

    # Extract copying fees
    copy_fee_match = re.search(r"\$?(\d+(?:\.\d{2})?)\s*(?:per|/)\s*page", fee_section, re.IGNORECASE)
    if copy_fee_match:
        result["standard_copying"] = f"${copy_fee_match.group(1)} per page"

    # Check for search fees
    if re.search(r"search.*?fee.*?(?:allowed|charged|permitted)", fee_section, re.IGNORECASE):
        result["search_fees"] = "Allowed"
    elif re.search(r"no.*?search.*?fee|search.*?fee.*?not.*?(?:allowed|permitted)", fee_section, re.IGNORECASE):
        result["search_fees"] = "Not allowed"

    # Check for fee waivers
    if re.search(r"waiver|fee.*?reduction|indigent", fee_section, re.IGNORECASE):
        result["fee_waiver_available"] = True
        if re.search(r"public interest", fee_section, re.IGNORECASE):
            result["waiver_criteria"].append("Public interest")
        if re.search(r"indigent|unable to pay|financial hardship", fee_section, re.IGNORECASE):
            result["waiver_criteria"].append("Indigent requesters")
        if re.search(r"news media|journalist|press", fee_section, re.IGNORECASE):
            result["waiver_criteria"].append("News media")

    return result

def extract_appeal_process(content: str) -> Dict[str, Any]:
    """Extract appeal process information"""
    appeal_section = extract_section(content, "Appeal")

    result = {
        "type": "Court action",
        "attorney_fees_available": False,
        "timeline_days": None
    }

    # Determine appeal type
    if re.search(r"attorney general|AG review", appeal_section, re.IGNORECASE):
        result["type"] = "Attorney General review"
    elif re.search(r"mandamus", appeal_section, re.IGNORECASE):
        result["type"] = "Court (Petition for Mandamus)"
    elif re.search(r"superior court|circuit court|district court", appeal_section, re.IGNORECASE):
        result["type"] = "Court action"

    # Check for attorney fees
    if re.search(r"attorney.*?fee.*?(?:available|awarded|may be)", appeal_section, re.IGNORECASE):
        result["attorney_fees_available"] = True

    # Extract timeline
    timeline_match = re.search(r"(\d+)\s*(?:business|calendar|working)?\s*days", appeal_section, re.IGNORECASE)
    if timeline_match:
        result["timeline_days"] = int(timeline_match.group(1))

    return result

def extract_key_features(content: str, jurisdiction: str, timeline_days: int) -> List[str]:
    """Extract key feature tags"""
    features = []

    # Check for attorney fees
    if re.search(r"attorney.*?fee.*?(?:available|awarded)", content, re.IGNORECASE):
        features.append("Attorney Fees Available")

    # Check for AG review
    if re.search(r"attorney general.*?review", content, re.IGNORECASE):
        features.append("AG Review Available")

    # Check for criminal penalties
    if re.search(r"criminal.*?penalt", content, re.IGNORECASE):
        features.append("Criminal Penalties")

    # Check for fee waivers
    if re.search(r"fee.*?waiver", content, re.IGNORECASE):
        features.append("Fee Waivers")

    # Check for 2025 amendments
    if re.search(r"2025.*?(?:amendment|effective|bill|act)", content, re.IGNORECASE):
        features.append("2025 Amendments")

    # Add timeline feature
    if timeline_days and timeline_days > 0:
        features.append(f"{timeline_days}-Day Deadline")
    elif timeline_days == -1:
        features.append("Reasonable Time Standard")

    return features[:5]  # Top 5 features

def process_map_file(file_path: Path) -> Optional[Dict[str, Any]]:
    """Process a single process map file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Extract jurisdiction name from file
        filename = file_path.stem  # e.g., "California-CPRA-v0.11"

        # Try to identify jurisdiction
        jurisdiction = None
        for j in JURISDICTION_CODES.keys():
            if j.replace(" ", "-") in filename or j.replace(" ", "_") in filename:
                jurisdiction = j
                break

        if not jurisdiction:
            # Try harder - look in content
            for j in JURISDICTION_CODES.keys():
                if re.search(rf"\b{j}\b", content):
                    jurisdiction = j
                    break

        if not jurisdiction:
            print(f"⚠️  Could not identify jurisdiction for {filename}")
            return None

        print(f"Processing: {jurisdiction}...")

        # Extract all fields
        data = {
            "jurisdiction_code": JURISDICTION_CODES[jurisdiction],
            "jurisdiction_name": jurisdiction,
            "statute_abbreviation": STATUTE_ABBREVIATIONS.get(jurisdiction, "N/A"),
            "statute_full_name": extract_section(content, "Primary Statute") or f"{jurisdiction} Public Records Law",
            "core_principle": extract_core_principle(content),
            "recent_changes_2024_2025": extract_recent_changes(content),
        }

        # Timeline data
        timeline_data = extract_response_timeline(content, jurisdiction)
        data.update(timeline_data)

        # Other fields
        data["public_record_categories"] = extract_public_record_categories(content)
        data["fee_structure"] = extract_fee_structure(content)
        data["appeal_process"] = extract_appeal_process(content)
        data["key_features_tags"] = extract_key_features(content, jurisdiction, data["response_timeline_days"])

        # Official resources (placeholder - would need specific extraction)
        data["official_resources"] = {
            "statute_url": None,
            "ag_page_url": None,
            "request_portal_url": None
        }

        # Metadata
        data["metadata"] = {
            "version": "v0.11",
            "verification_date": "2025-09-26",
            "process_map_source": filename + ".md",
            "extraction_date": "2025-09-29"
        }

        return data

    except Exception as e:
        print(f"❌ Error processing {file_path}: {e}")
        return None

def main():
    """Main extraction process"""
    print("\n" + "="*80)
    print("EXTRACTING TRANSPARENCY MAP DATA FROM PROCESS MAPS")
    print("="*80 + "\n")

    # Process map directory
    process_maps_dir = Path("/Users/jth/Documents/GitHub/us-transparency-laws-database/consolidated-transparency-data/verified-process-maps")

    # Output directory
    output_dir = Path("/Users/jth/Documents/GitHub/us-transparency-laws-database/Transparency-Map-Dataset")

    all_data = []

    # Process all markdown files
    for file_path in sorted(process_maps_dir.glob("*.md")):
        data = process_map_file(file_path)
        if data:
            all_data.append(data)

    # Create master dataset
    master_dataset = {
        "dataset_name": "US Transparency Laws - Interactive Map Dataset",
        "version": "v0.11",
        "created_date": "2025-09-29",
        "total_jurisdictions": len(all_data),
        "description": "Curated dataset for the Transparency Map interface. Contains concise information optimized for interactive display.",
        "timeline_code_reference": {
            "-1": "Reasonable time (no fixed deadline)",
            "-2": "Promptly (no specific day count)",
            "-3": "Immediate (certain records)",
            "-4": "Variable by request type",
            "positive": "Fixed number of days"
        },
        "jurisdictions": all_data
    }

    # Write to file
    output_file = output_dir / "transparency-map-data-v0.11.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(master_dataset, f, indent=2, ensure_ascii=False)

    print(f"\n" + "="*80)
    print(f"✅ EXTRACTION COMPLETE")
    print(f"="*80)
    print(f"\nProcessed: {len(all_data)} jurisdictions")
    print(f"Output: {output_file}")
    print(f"Size: {output_file.stat().st_size:,} bytes")

    # Summary statistics
    fixed_deadlines = sum(1 for d in all_data if d["response_timeline_days"] and d["response_timeline_days"] > 0)
    flexible_deadlines = sum(1 for d in all_data if d["response_timeline_days"] and d["response_timeline_days"] < 0)

    print(f"\nTimeline Statistics:")
    print(f"  - Fixed deadlines: {fixed_deadlines}")
    print(f"  - Flexible deadlines: {flexible_deadlines}")
    print(f"  - Fee waivers available: {sum(1 for d in all_data if d['fee_structure'].get('fee_waiver_available'))}")
    print(f"  - Attorney fees available: {sum(1 for d in all_data if d['appeal_process'].get('attorney_fees_available'))}")
    print(f"  - 2025 amendments: {sum(1 for d in all_data if '2025' in d.get('recent_changes_2024_2025', ''))}")

if __name__ == "__main__":
    main()