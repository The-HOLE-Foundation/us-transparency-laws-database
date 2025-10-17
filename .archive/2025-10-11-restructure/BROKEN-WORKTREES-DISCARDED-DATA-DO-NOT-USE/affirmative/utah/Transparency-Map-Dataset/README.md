---
DATE: 2025-09-29
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Transparency Map - Curated Dataset
VERSION: v0.11
---

# Transparency Map Dataset

## Purpose

This directory contains the **curated, concise dataset** specifically designed for the **Transparency Map** interactive interface. This is a streamlined subset of the comprehensive database, optimized for quick loading and visual display on the map.

## Dataset Design

### Target Use Case
- Interactive state-by-state map on theholetruth.org
- Quick reference information displayed on hover/click
- Simplified for non-expert users
- Optimized for performance and clarity

### Data Fields Included

1. **Jurisdiction Identification**
   - State/Federal name
   - Statute abbreviation (e.g., "CPRA", "PIA", "FOIA")
   - Official statute name

2. **Core Principle**
   - Brief statement of the law's foundational principle
   - 1-2 sentences maximum

3. **Recent Legislative Changes**
   - 2024-2025 amendments only
   - Brief summary (1-2 sentences)
   - Effective dates

4. **Response Timeline**
   - Number of business days (if fixed)
   - OR negative integer code for non-fixed timelines
   - Timeline code key:
     - `-1` = "Reasonable time" (no fixed deadline)
     - `-2` = "Promptly" (no specific day count)
     - `-3` = "Immediately" (for certain record types)
     - `-4` = "Variable by request type"

5. **Record Categories Made Public**
   - Key types of records presumptively public
   - Bullet list format (3-5 main categories)

6. **Fee Structure**
   - Standard copying fees
   - Search/labor fees (if allowed)
   - Electronic records fees
   - Fee waiver availability (boolean)

7. **Appeal Process**
   - Basic appeal method (court, AG review, administrative)
   - Timeline for filing appeal (if specified)
   - Attorney fees available (boolean)

8. **Key Features Tags**
   - Quick reference tags (e.g., "AG Review Available", "Criminal Penalties", "Fee Waivers")
   - 3-5 tags maximum per jurisdiction

9. **Official Resources**
   - Primary statute URL
   - State AG FOIA page URL
   - Request portal URL (if available)

## Timeline Code System

### Negative Integer Codes

**Purpose**: Handle jurisdictions without fixed statutory deadlines

**Implementation**:
```json
{
  "response_timeline_days": -1,
  "response_timeline_description": "Reasonable time (no fixed deadline)",
  "response_timeline_factors": ["Request complexity", "Agency resources", "Volume of records"]
}
```

### Examples by State

- **Alabama**: `-1` (Reasonable time standard)
- **California**: `10` (10 calendar days)
- **Texas**: `10` (10 business days)
- **Florida**: `-2` (Promptly, reasonable time)
- **Federal**: `20` (20 working days)

### Display Logic for Map

```javascript
if (response_timeline_days > 0) {
  display: `${response_timeline_days} days`
} else {
  display: response_timeline_description
}
```

## File Structure

```
Transparency-Map-Dataset/
├── README.md                          # This file
├── schema.json                        # JSON schema definition
├── timeline-codes-reference.json      # Timeline code lookup table
├── transparency-map-data-v0.11.json   # Master dataset (all 51 jurisdictions)
├── validation/
│   └── validate-map-data.js          # Validation script
└── examples/
    ├── example-california.json       # Example: Fixed timeline state
    └── example-alabama.json           # Example: Reasonable time state
```

## Data Quality Standards

- **Accuracy**: 100% verified from official sources
- **Conciseness**: Maximum 2-3 sentences per field
- **Clarity**: Non-legal-expert friendly language
- **Currency**: Includes all 2024-2025 amendments
- **Completeness**: All 51 jurisdictions included

## Supabase Schema Preview

### Primary Table: `transparency_map_jurisdictions`

```sql
CREATE TABLE transparency_map_jurisdictions (
  id SERIAL PRIMARY KEY,
  jurisdiction_code VARCHAR(2) NOT NULL UNIQUE,  -- e.g., "CA", "TX", "FED"
  jurisdiction_name VARCHAR(100) NOT NULL,
  statute_abbreviation VARCHAR(20) NOT NULL,
  statute_full_name VARCHAR(200) NOT NULL,
  core_principle TEXT NOT NULL,
  recent_changes_2024_2025 TEXT,
  response_timeline_days INTEGER NOT NULL,  -- Positive or negative code
  response_timeline_description VARCHAR(200),
  response_timeline_factors JSONB,
  public_record_categories JSONB,
  fee_structure JSONB,
  fee_waiver_available BOOLEAN DEFAULT false,
  appeal_process_type VARCHAR(50),
  appeal_timeline_days INTEGER,
  attorney_fees_available BOOLEAN DEFAULT false,
  key_features_tags TEXT[],
  statute_url TEXT,
  ag_page_url TEXT,
  request_portal_url TEXT,
  last_updated TIMESTAMP DEFAULT NOW(),
  version VARCHAR(10) DEFAULT 'v0.11'
);
```

### Supporting Table: `timeline_code_reference`

```sql
CREATE TABLE timeline_code_reference (
  code INTEGER PRIMARY KEY,
  description VARCHAR(200) NOT NULL,
  display_text VARCHAR(100) NOT NULL,
  explanation TEXT,
  common_factors JSONB
);
```

## Usage

1. **For Map Development**: Use `transparency-map-data-v0.11.json` directly
2. **For Supabase Migration**: Import JSON into tables using provided schema
3. **For Validation**: Run `validation/validate-map-data.js` before deployment
4. **For Documentation**: Refer to timeline codes in `timeline-codes-reference.json`

## Next Steps

1. ✅ Extract data from 51 verified process maps
2. ✅ Create timeline code reference table
3. ✅ Build master JSON dataset
4. ⏳ Create Supabase migration script
5. ⏳ Build validation tests
6. ⏳ Deploy to Supabase

---

*This dataset is optimized for the Transparency Map interface. For comprehensive legal analysis, refer to the full process maps in `/consolidated-transparency-data/verified-process-maps/`*