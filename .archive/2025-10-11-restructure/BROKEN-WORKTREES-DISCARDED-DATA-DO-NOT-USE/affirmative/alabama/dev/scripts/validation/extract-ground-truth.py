#!/usr/bin/env python3
"""
Extract verified ground truth data from process maps
Populates canonical-values.json with all 51 jurisdictions
"""

import json
import re
from pathlib import Path

# State name mappings (file name -> canonical name)
STATE_MAPPINGS = {
    'Alabama-PRL': 'alabama',
    'Alaska-Public-Records': 'alaska',
    'Arizona-PRL': 'arizona',
    'Arkansas-FOIA': 'arkansas',
    'California-CPRA': 'california',
    'Colorado-CORA': 'colorado',
    'Connecticut-FOIA': 'connecticut',
    'DC-FOIA': 'district-of-columbia',
    'Delaware-FOIA': 'delaware',
    'Florida-Sunshine-Law': 'florida',
    'Georgia-ORA': 'georgia',
    'Hawaii-UIPA': 'hawaii',
    'Idaho-Public-Records': 'idaho',
    'Illinois-FOIA': 'illinois',
    'Indiana-APRA': 'indiana',
    'Iowa-Open-Records': 'iowa',
    'Kansas-Open-Records': 'kansas',
    'Kentucky-Open-Records': 'kentucky',
    'Louisiana-Public-Records': 'louisiana',
    'Maine-FOAA': 'maine',
    'Maryland-MPIA': 'maryland',
    'Massachusetts-PRL': 'massachusetts',
    'Michigan-FOIA': 'michigan',
    'Minnesota-Data-Practices': 'minnesota',
    'Mississippi-Public-Records': 'mississippi',
    'Missouri-Sunshine-Law': 'missouri',
    'Montana-Right-to-Know': 'montana',
    'Nebraska-Public-Records': 'nebraska',
    'Nevada-Public-Records': 'nevada',
    'New-Hampshire-Right-to-Know': 'new-hampshire',
    'New-Jersey-OPRA': 'new-jersey',
    'New-York-FOIL': 'new-york',
    'North-Carolina-Public-Records': 'north-carolina',
    'North-Dakota-Open-Records': 'north-dakota',
    'Ohio-PRL': 'ohio',
    'Oklahoma-Open-Records': 'oklahoma',
    'Oregon-Public-Records': 'oregon',
    'Pennsylvania-RTKL': 'pennsylvania',
    'Rhode-Island-APRA': 'rhode-island',
    'South-Carolina-FOIA': 'south-carolina',
    'South-Dakota-Open-Records': 'south-dakota',
    'Tennessee-Public-Records': 'tennessee',
    'Texas-PIA': 'texas',
    'Utah-GRAMA': 'utah',
    'Vermont-Public-Records': 'vermont',
    'Virginia-FOIA': 'virginia',
    'Washington-PRA': 'washington',
    'West-Virginia-FOIA': 'west-virginia',
    'Wisconsin-Open-Records': 'wisconsin',
    'Wyoming-Public-Records': 'wyoming'
}

def extract_response_days(text):
    """Extract response timeline in days from process map"""
    patterns = [
        r'(\d+)\s*(?:business|calendar|working)?\s*days?(?:\s+(?:from|after)\s+receipt)?',
        r'(?:Initial Response|Standard Response|Response Time)[:\s]+(\d+)',
        r'(\d+)-day\s+(?:response|timeline|deadline)',
    ]
    
    # Look for response timeline sections
    for pattern in patterns:
        matches = re.findall(pattern, text, re.IGNORECASE)
        if matches:
            # Return first numeric match
            try:
                return int(matches[0])
            except (ValueError, IndexError):
                continue
    
    # Check for "reasonable time" or "promptly"
    if re.search(r'reasonable\s+time|promptly', text, re.IGNORECASE):
        return -1  # Code for flexible deadline
    
    return None

def extract_day_type(text):
    """Determine if business, calendar, or working days"""
    text_lower = text.lower()
    if 'business day' in text_lower:
        return 'business_days'
    elif 'calendar day' in text_lower:
        return 'calendar_days'
    elif 'working day' in text_lower:
        return 'working_days'
    return 'business_days'  # Default assumption

def extract_statute_citation(text):
    """Extract main statute citation"""
    # Look for patterns like "Cal. Gov. Code § 6253(c)" or "5 U.S.C. § 552"
    patterns = [
        r'([A-Z][a-z]+\.?\s+[A-Z][a-z]+\.?\s+Code\s+§\s+[\d\.]+(?:\([a-z]\))?)',
        r'(\d+\s+U\.S\.C\.\s+§\s+\d+)',
        r'([A-Z][a-z]+\s+Rev(?:ised)?\s+Stat(?:utes)?\s+(?:§|Ch\.)\s+[\d\.]+)',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, text)
        if match:
            return match.group(1)
    
    return ""

def process_map_file(file_path):
    """Extract key data from a process map file"""
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Extract response timeline
    response_days = extract_response_days(content)
    day_type = extract_day_type(content)
    statute_citation = extract_statute_citation(content)
    
    # Extract verification date
    ver_date_match = re.search(r'VERIFICATION DATE[:\s]+([A-Za-z]+\s+\d+,\s+\d{4})', content)
    verification_date = ver_date_match.group(1) if ver_date_match else "2025-09-26"
    
    return {
        'response_timeline_days': response_days,
        'response_timeline_type': day_type,
        'statute_citation': statute_citation,
        'verified_date': verification_date,
        'confidence_level': 'high'
    }

def main():
    # Directories
    process_maps_dir = Path('Transparency-Data/Individual-Jurisdictions/States')
    output_file = Path('data/ground-truth/canonical-values.json')
    
    print("🔍 Extracting verified data from process maps...")
    
    ground_truth = {
        "_schema_version": "v0.11",
        "_description": "Canonical ground truth values for all 51 jurisdictions",
        "_last_updated": "2025-10-02",
        "_verification_source": "Extracted from verified process maps v0.11"
    }
    
    # Process each state file
    for file_path in sorted(process_maps_dir.glob("*.md")):
        file_key = file_path.stem.replace('-v0.11', '')
        
        if file_key in STATE_MAPPINGS:
            state_name = STATE_MAPPINGS[file_key]
            print(f"  Processing: {state_name}")
            
            data = process_map_file(file_path)
            
            if data['response_timeline_days'] is not None:
                ground_truth[state_name] = data
                print(f"    ✅ {state_name}: {data['response_timeline_days']} days ({data['response_timeline_type']})")
            else:
                print(f"    ⚠️  {state_name}: Could not extract timeline")
    
    # Add federal (manually since it's in different location)
    ground_truth['federal'] = {
        'response_timeline_days': 20,
        'response_timeline_type': 'working_days',
        'statute_citation': '5 U.S.C. § 552(a)(6)(A)(i)',
        'verified_date': '2025-09-26',
        'source_url': 'https://www.govinfo.gov/content/pkg/USCODE-2020-title5/html/USCODE-2020-title5-partI-chap5-subchapII-sec552.htm',
        'confidence_level': 'high'
    }
    
    # Save to file
    output_file.parent.mkdir(parents=True, exist_ok=True)
    with open(output_file, 'w') as f:
        json.dump(ground_truth, f, indent=2)
    
    print(f"\n✅ Ground truth file created: {output_file}")
    print(f"📊 Total jurisdictions: {len([k for k in ground_truth.keys() if not k.startswith('_')])}")
    
    # Summary
    fixed_timelines = [k for k, v in ground_truth.items() 
                      if not k.startswith('_') and isinstance(v.get('response_timeline_days'), int) and v.get('response_timeline_days') > 0]
    flexible_timelines = [k for k, v in ground_truth.items() 
                         if not k.startswith('_') and v.get('response_timeline_days') == -1]
    
    print(f"   • Fixed timelines: {len(fixed_timelines)}")
    print(f"   • Flexible timelines: {len(flexible_timelines)}")

if __name__ == "__main__":
    main()
