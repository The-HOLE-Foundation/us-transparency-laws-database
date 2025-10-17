---
DATE: 2025-10-02
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Holiday Tracking Matrix for Business Day Calculations
VERSION: v0.12
---

# Holiday Tracking Matrix

## Purpose

This directory contains comprehensive holiday data for all 51 US jurisdictions (50 states + DC + Federal) to support **accurate business day calculations** for FOIA response deadlines.

## Problem Statement

FOIA laws specify response times in "business days" which excludes:
- Weekends (Saturday/Sunday)
- Official state/federal holidays
- Special observances (varies by jurisdiction)

**Without accurate holiday data, deadline calculations will be incorrect.**

## Data Structure

```
holiday-tracking-matrix/
├── README.md                          # This file
├── METHODOLOGY.md                     # Data collection methodology
├── sources/                           # Source documentation
│   ├── federal-holidays-source.md     # Federal .gov source
│   └── [state]-holidays-source.md     # State-specific .gov sources (51 files)
├── json/                              # Machine-readable data
│   ├── federal-holidays-2025.json     # Federal holidays
│   ├── federal-holidays-2026.json
│   ├── [state]-holidays-2025.json     # State-specific holidays (50 files)
│   ├── [state]-holidays-2026.json
│   └── master-holiday-matrix.json     # Consolidated matrix
└── csv/                               # Human-readable exports
    ├── master-holiday-matrix-2025.csv # Complete 2025 matrix
    └── master-holiday-matrix-2026.csv # Complete 2026 matrix
```

## Data Fields

Each jurisdiction's holiday data includes:

```json
{
  "jurisdiction": "California",
  "year": 2025,
  "source_url": "https://www.calhr.ca.gov/...",
  "verified_date": "2025-10-02",
  "holidays": [
    {
      "name": "New Year's Day",
      "date": "2025-01-01",
      "observed_date": "2025-01-01",
      "day_of_week": "Wednesday",
      "is_observed": true,
      "notes": "If falls on weekend, observed on adjacent weekday"
    }
  ]
}
```

## Master Matrix Format

The master matrix consolidates all jurisdictions:

| Holiday Name | Federal | AL | AK | AZ | ... | WY | DC |
|--------------|---------|----|----|----| --- |----|----|
| New Year's Day | 01/01 | 01/01 | 01/01 | 01/01 | ... | 01/01 | 01/01 |
| MLK Jr. Day | 01/20 | 01/20 | 01/20 | - | ... | 01/20 | 01/20 |
| Presidents' Day | 02/17 | 02/17 | - | 02/17 | ... | - | 02/17 |

**Legend**:
- Date (MM/DD) = Holiday observed on this date
- `-` = Not observed by this jurisdiction
- `*` = Different observation date (see notes)

## Source Requirements

### ONLY Acceptable Sources
1. **Federal**: OPM.gov (Office of Personnel Management)
2. **States**: Official state HR/Personnel office websites (.gov only)
3. **Alternative**: Official state employee handbooks/calendars (.gov only)

### PROHIBITED Sources
- Wikipedia or collaborative wikis
- Third-party holiday calendars
- Private company holiday lists
- AI-generated summaries

## Data Quality Standards

✅ **Required**:
- All dates verified from official .gov sources
- Source URL documented for each jurisdiction
- Verification date recorded
- Weekend observation rules documented

❌ **Not Acceptable**:
- Unverified dates
- Third-party aggregations
- Assumed/inferred holidays

## Usage

### For Business Day Calculations

```python
# Example: Calculate 10 business days from 2025-12-20 in California
from datetime import date, timedelta
import json

# Load California holidays
with open('json/california-holidays-2025.json') as f:
    ca_holidays = {h['observed_date'] for h in json.load(f)['holidays']}

def add_business_days(start_date, num_days, holidays):
    current = start_date
    days_added = 0

    while days_added < num_days:
        current += timedelta(days=1)
        # Skip weekends
        if current.weekday() >= 5:  # Saturday=5, Sunday=6
            continue
        # Skip holidays
        if current.isoformat() in holidays:
            continue
        days_added += 1

    return current

# Result accounts for holidays + weekends
deadline = add_business_days(date(2025, 12, 20), 10, ca_holidays)
```

## Maintenance Schedule

- **Annual Update**: December (for next year's holidays)
- **Verification Cycle**: Every 6 months (check for legislative changes)
- **Source Monitoring**: Quarterly (detect new holiday proclamations)

## Holiday Categories

### Federal Holidays (10-11 annually)
- New Year's Day
- Martin Luther King Jr. Day
- Presidents' Day (Washington's Birthday)
- Memorial Day
- Juneteenth
- Independence Day
- Labor Day
- Columbus Day (Indigenous Peoples' Day)
- Veterans Day
- Thanksgiving
- Christmas

### Common State Holidays (varies by jurisdiction)
- State-specific observances (e.g., Patriots' Day in MA/ME)
- Election Day (some states)
- Day after Thanksgiving (some states)
- Confederate Memorial Day (some Southern states)
- Cesar Chavez Day (some Western states)

## Validation

### Automated Checks
```bash
# Verify all jurisdictions present
python3 scripts/validation/validate-holiday-data.py --check-coverage

# Verify date formats
python3 scripts/validation/validate-holiday-data.py --check-formats

# Verify sources are .gov
python3 scripts/validation/validate-holiday-data.py --check-sources
```

### Manual Review Checklist
- [ ] All 51 jurisdictions have data files
- [ ] All source URLs are accessible .gov sites
- [ ] Dates match official calendars exactly
- [ ] Weekend observation rules documented
- [ ] Master matrix includes all jurisdictions

## Integration Points

### FOIA Deadline Calculator (v0.12+)
This data feeds the Azure AI Foundry FOIA Generator to calculate accurate response deadlines.

### Structured Law Metadata (Layer 2)
Holiday data complements response timeline requirements:
```json
{
  "response_requirements": {
    "initial_response_time": 5,
    "initial_response_unit": "business_days",
    "holiday_calendar": "california-holidays-2025.json"
  }
}
```

## Related Documentation

- [V0.12 Roadmap](../../documentation/V0.12_ROADMAP.md) - Feature requirements
- [Validation Methodology](../../documentation/VALIDATION_METHODOLOGY.md) - Data quality standards
- [Source Verification Guide](../../documentation/Source_Verification_and_Training_Guide.md) - Sourcing rules

## Status

**Current Phase**: Data Collection (October 2025)
**Target Completion**: November 2025
**Next Steps**: Research authoritative sources for all 51 jurisdictions

---

**Remember**: Incorrect holiday data = Incorrect deadline calculations = Failed FOIA requests. Verify everything from official sources.
