# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This project analyzes state transparency laws to identify statutory loopholes that corrupt officials can exploit to unlawfully conceal public records. The analysis extracts vulnerabilities from 50+ U.S. state transparency statutes and produces structured datasets for database import and AI training.

## Core Analysis Script

**Primary tool**: `analyze_statutes.py`

Run the complete analysis pipeline:
```bash
python3 analyze_statutes.py
```

This script:
1. Parses all state process maps in `Refrence Datasets/Process Maps/`
2. Identifies obstruction vulnerabilities (clarification pauses, fee barriers, vague timelines, exemption abuse)
3. Generates state-specific datasets in `output/csv/` and `output/json/`
4. Creates master consolidated files combining all jurisdictions

## Data Architecture

### Input Data Structure
- **Full-Text-Statutes-Data/**: Raw statutory text files (`[STATE]_transparency_law.txt`)
- **Process Maps/**: Verified process flow documents (`[State]-[Law]-VERIFIED-Process-Map.md`)
- Process maps contain structured sections on timelines, fees, exemptions, and known obstruction tactics

### Output Data Structure
- **output/csv/[STATE]_obstruction_analysis.csv**: Per-state CSV with columns: type, severity, description, mechanism
- **output/json/[STATE]_obstruction_analysis.json**: Per-state JSON with full vulnerability analysis including timelines
- **output/master_obstruction_analysis.csv**: Combined CSV with additional 'state' column
- **output/master_obstruction_analysis.json**: Array of all state analyses

## Vulnerability Categories

The analysis identifies these obstruction mechanism types:

1. **Clarification Pause** (HIGH): Agencies pause statutory deadlines by claiming requests are unclear
2. **Fee Barriers** (MEDIUM): Fee structures weaponized to deter requests
3. **Programming Time Charges** (MEDIUM): Subjective technical billing for data extraction
4. **Vague Request Rejection** (HIGH): Broad/vague rejection with subjective standards
5. **Exemption Abuse** (HIGH): Misapplication of legitimate exemptions to withhold records
6. **Vague Timeline** (MEDIUM): Response deadlines using subjective terms like "promptly" or "reasonable time"

## Key Functions in analyze_statutes.py

- `analyze_process_map(filepath)`: Extracts vulnerabilities from a single state's process map
- `extract_timelines(content)`: Parses response deadlines and AG review periods using regex
- `extract_section(content, keywords)`: Context extraction around vulnerability indicators
- `create_csv_by_state()`: Generates individual state CSV files
- `create_json_by_state()`: Generates individual state JSON files
- `create_master_csv()`: Consolidates all states into single CSV
- `create_master_json()`: Consolidates all states into single JSON array

## Data Format Notes

**CSV columns** (for Notion/Supabase import):
- `state`: Jurisdiction name
- `type`: Vulnerability category
- `severity`: HIGH or MEDIUM
- `description`: Brief explanation of obstruction method
- `mechanism`: Detailed explanation with statutory context (may be truncated to 500 chars)

**JSON structure** (for AI training):
```json
{
  "state": "Texas",
  "vulnerabilities": [
    {
      "type": "Clarification Pause",
      "severity": "HIGH",
      "description": "...",
      "mechanism": "..."
    }
  ],
  "timelines": {
    "response_deadline": "...",
    "attorney_general_review": "..."
  },
  "total_vulnerability_count": 5
}
```

## State Name Extraction

The `extract_state_name()` function handles various filename patterns. Note: Some states with multi-word names (New York, North Carolina, South Dakota, etc.) may be truncated to just the first word in current implementation.

## Extending the Analysis

To add new vulnerability detection patterns:
1. Add keyword detection logic in `analyze_process_map()`
2. Use `extract_section()` to capture statutory context
3. Append to `vulnerabilities` list with type/severity/description/mechanism
4. Consider adding timeline extraction patterns in `extract_timelines()` if relevant