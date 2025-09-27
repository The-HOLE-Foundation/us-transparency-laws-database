import os
import json
import csv
import glob
import re
from pathlib import Path

def extract_state_name(filepath):
    filename = os.path.basename(filepath)
    state = filename.split('_')[0].split('-')[0].replace('.txt', '').replace('.md', '')
    return state.replace('01-Federal-FOIA-VERIFIED-Process-Map', 'FEDERAL')

def analyze_process_map(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    state = extract_state_name(filepath)

    vulnerabilities = []

    if 'clarification' in content.lower() or 'unclear' in content.lower():
        clarification_section = extract_section(content, ['clarification', 'unclear'])
        vulnerabilities.append({
            'type': 'Clarification Pause',
            'description': 'Statute allows agencies to pause deadlines by claiming requests are unclear',
            'severity': 'HIGH',
            'mechanism': clarification_section[:500] if clarification_section else 'Detected in statute'
        })

    if 'fee' in content.lower() or 'charge' in content.lower() or 'cost' in content.lower():
        fee_section = extract_section(content, ['fee', 'charge', 'cost'])
        vulnerabilities.append({
            'type': 'Fee Barriers',
            'description': 'Fee structure can be weaponized to deter requests',
            'severity': 'MEDIUM',
            'mechanism': fee_section[:500] if fee_section else 'Detected in statute'
        })

    if 'programming' in content.lower():
        vulnerabilities.append({
            'type': 'Programming Time Charges',
            'description': 'Allows charging for technical work with subjective billing',
            'severity': 'MEDIUM',
            'mechanism': 'Can inflate costs by claiming simple requests require programming'
        })

    if 'broad' in content.lower() or 'vague' in content.lower() or 'overbroad' in content.lower():
        vulnerabilities.append({
            'type': 'Vague Request Rejection',
            'description': 'Agencies can reject requests as too broad or vague',
            'severity': 'HIGH',
            'mechanism': 'Subjective interpretation allows denial of valid requests'
        })

    if 'exemption' in content.lower() or 'exception' in content.lower():
        exemption_section = extract_section(content, ['exemption', 'exception'])
        vulnerabilities.append({
            'type': 'Exemption Abuse',
            'description': 'Broad exemptions can be misapplied to withhold records',
            'severity': 'HIGH',
            'mechanism': exemption_section[:500] if exemption_section else 'Multiple exemptions present'
        })

    timelines = extract_timelines(content)
    response_deadline = timelines.get('response_deadline', 'Unknown')

    if 'promptly' in response_deadline.lower() or 'reasonable' in response_deadline.lower():
        vulnerabilities.append({
            'type': 'Vague Timeline',
            'description': 'Response deadline is subjective rather than fixed',
            'severity': 'MEDIUM',
            'mechanism': f'Deadline defined as: {response_deadline}'
        })

    return {
        'state': state,
        'vulnerabilities': vulnerabilities,
        'timelines': timelines,
        'total_vulnerability_count': len(vulnerabilities)
    }

def extract_section(content, keywords):
    lines = content.split('\n')
    section = []
    capture = False

    for i, line in enumerate(lines):
        if any(keyword in line.lower() for keyword in keywords):
            capture = True
            start = max(0, i - 2)
            section = lines[start:min(len(lines), i + 10)]
            break

    return '\n'.join(section)

def extract_timelines(content):
    timelines = {}

    response_match = re.search(r'(\d+)\s*(business\s+)?days?.*(?:response|deadline|initial)', content, re.IGNORECASE)
    if response_match:
        timelines['response_deadline'] = response_match.group(0)
    else:
        if 'promptly' in content.lower():
            timelines['response_deadline'] = 'Promptly (vague)'
        elif 'reasonable' in content.lower():
            timelines['response_deadline'] = 'Reasonable time (vague)'
        else:
            timelines['response_deadline'] = 'Unknown'

    ag_match = re.search(r'attorney\s+general.*?(\d+)\s*days?', content, re.IGNORECASE)
    if ag_match:
        timelines['attorney_general_review'] = ag_match.group(0)

    return timelines

def analyze_all_states():
    process_maps = sorted(glob.glob('Refrence Datasets/Process Maps/*.md'))

    all_analyses = []

    for map_file in process_maps:
        try:
            analysis = analyze_process_map(map_file)
            all_analyses.append(analysis)
            print(f"✓ Analyzed {analysis['state']}: {analysis['total_vulnerability_count']} vulnerabilities")
        except Exception as e:
            print(f"✗ Error analyzing {map_file}: {e}")

    return all_analyses

def create_csv_by_state(analyses, output_dir='output/csv'):
    os.makedirs(output_dir, exist_ok=True)

    for analysis in analyses:
        state = analysis['state']
        filename = f"{output_dir}/{state}_obstruction_analysis.csv"

        with open(filename, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=['type', 'severity', 'description', 'mechanism'])
            writer.writeheader()

            for vuln in analysis['vulnerabilities']:
                writer.writerow(vuln)

        print(f"Created CSV: {filename}")

def create_json_by_state(analyses, output_dir='output/json'):
    os.makedirs(output_dir, exist_ok=True)

    for analysis in analyses:
        state = analysis['state']
        filename = f"{output_dir}/{state}_obstruction_analysis.json"

        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(analysis, f, indent=2)

        print(f"Created JSON: {filename}")

def create_master_csv(analyses, output_file='output/master_obstruction_analysis.csv'):
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=['state', 'type', 'severity', 'description', 'mechanism'])
        writer.writeheader()

        for analysis in analyses:
            for vuln in analysis['vulnerabilities']:
                row = {'state': analysis['state']}
                row.update(vuln)
                writer.writerow(row)

    print(f"Created master CSV: {output_file}")

def create_master_json(analyses, output_file='output/master_obstruction_analysis.json'):
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(analyses, f, indent=2)

    print(f"Created master JSON: {output_file}")

if __name__ == '__main__':
    print("Starting statutory obstruction analysis...")
    print("=" * 60)

    analyses = analyze_all_states()

    print("\n" + "=" * 60)
    print(f"Analyzed {len(analyses)} jurisdictions")
    print("=" * 60)

    print("\nCreating state-specific CSV files...")
    create_csv_by_state(analyses)

    print("\nCreating state-specific JSON files...")
    create_json_by_state(analyses)

    print("\nCreating master consolidated datasets...")
    create_master_csv(analyses)
    create_master_json(analyses)

    print("\n" + "=" * 60)
    print("Analysis complete!")
    print("=" * 60)