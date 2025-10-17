---
DATE: 2025-10-03
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Holiday Tracking Matrix - Master Consolidation
VERSION: v0.11
---

# Master Holiday Matrix Documentation

## Overview

This directory contains the consolidated master holiday matrix for all US jurisdictions. The matrix consolidates individual jurisdiction holiday files into comprehensive comparison tools for FOIA deadline calculation.

## Generated Files

### 1. CSV Matrices (Human-Readable)

**File**: `csv/master-holiday-matrix-2025.csv`
- **Purpose**: Quick visual comparison of holidays across 12 completed jurisdictions for 2025
- **Format**: Holiday name in first column, jurisdiction abbreviations as headers (US, AZ, CA, FL, GA, IL, MI, NY, NC, OH, PA, TX)
- **Date Format**: MM/DD
- **Missing holidays**: Indicated by `-`
- **Usage**: Excel/Google Sheets, visual analysis, quick reference

**File**: `csv/master-holiday-matrix-2026.csv`
- **Purpose**: Same as 2025, but for 2026 data (only 7 jurisdictions have 2026 data)
- **Jurisdictions**: US, CA, IL, NY, NC, OH, TX
- **Special notations**: `*` indicates observed date differs from statutory date due to weekend

**Key CSV Features**:
- Chronological ordering of holidays within each year
- Clear indication of state-specific holidays (only certain columns populated)
- Easy to identify common vs. unique holidays

### 2. JSON Master Matrix

**File**: `json/master-holiday-matrix-part1.json`
- **Purpose**: Comprehensive structured data for programmatic use
- **Structure**:
  - `metadata`: Completion statistics, jurisdiction lists, data years
  - `weekend_observation_rules`: Detailed documentation of 4 different rule types
  - `holiday_comparison`: Holiday-centric view showing which jurisdictions observe each holiday and when

**Key JSON Features**:
- Normalized holiday names across jurisdictions
- Weekend observation rules documented and categorized
- Ready for API consumption
- Compatible with React/Supabase integration
- Suitable for AI Foundry FOIA generator

**Weekend Observation Rule Categories**:
1. **Standard Federal Rule**: Saturday→Friday, Sunday→Monday (9 jurisdictions)
2. **California Rule**: Only Sunday→Monday, Saturday stays (1 jurisdiction)
3. **Texas Rule**: No shift, observed on actual date (1 jurisdiction)
4. **Custom Rules**: See individual jurisdiction notes (1 jurisdiction - Georgia)

### 3. Completion Status Report

**File**: `COMPLETION_STATUS.md`
- **Purpose**: Comprehensive project status and analysis document
- **Contents**:
  - Completion statistics (12 of 51 jurisdictions = 23.5%)
  - Jurisdiction-by-jurisdiction status table
  - Pending jurisdictions organized by region
  - State-specific holiday analysis
  - Weekend observation rule summary
  - Critical findings for FOIA deadline calculation
  - Next steps and workflow recommendations

## Data Sources

All data compiled from official government sources:
- Federal: OPM.gov
- States: Official HR calendars, statutory codes, state government websites
- Verification date: 2025-10-02 to 2025-10-03
- Source URLs documented in individual jurisdiction JSON files

## Critical Findings for FOIA Deadline Calculator

### Weekend Observation Rule Impact

The master matrix revealed **three distinct weekend observation patterns** that will require separate logic in the FOIA deadline calculator:

1. **Standard Federal Pattern** (9 jurisdictions):
   - Saturday holidays → Observed Friday (extends Friday deadlines)
   - Sunday holidays → Observed Monday (extends Monday deadlines)
   - States: Federal, AZ, FL, IL, MI, NY, NC, OH, PA

2. **California Pattern** (1 jurisdiction):
   - Saturday holidays → Observed Saturday (NO shift, does NOT extend Friday deadlines)
   - Sunday holidays → Observed Monday (extends Monday deadlines)
   - State: CA only

3. **Texas Pattern** (1 jurisdiction):
   - Saturday holidays → Observed Saturday (NO shift, does NOT extend deadlines)
   - Sunday holidays → Observed Sunday (NO shift, does NOT extend deadlines)
   - State: TX only
   - **Additional complexity**: Distinguishes between "mandatory closure" (national holidays) and "skeleton crew" (state holidays)

### Common Holidays (All 12 Jurisdictions)

These holidays are observed universally and will affect FOIA deadlines in all jurisdictions:
1. New Year's Day
2. MLK Jr. Day
3. Memorial Day
4. Independence Day
5. Labor Day
6. Veterans Day
7. Thanksgiving Day
8. Christmas Day

### State-Specific Holidays

**Critical for jurisdiction-specific deadline calculations**:

- **California**: Cesar Chavez Day (03/31)
- **Georgia**: Good Friday (04/18)
- **Illinois**: Lincoln's Birthday (02/12), Election Day (even years)
- **Michigan**: Christmas Eve, New Year's Eve
- **New York**: Lincoln's Birthday (02/12), Election Day
- **North Carolina**: Good Friday, Christmas Eve, Day after Christmas (3 consecutive Christmas days)
- **Ohio**: Washington-Lincoln Day (combined)
- **Texas**: Texas Independence Day (03/02), San Jacinto Day (04/21), LBJ Day (08/27), plus Dec 24 & 26

### 2026 Special Cases

**July 4, 2026 falls on Saturday**:
- **Federal, CA, IL, NC, OH**: Observed Friday, July 3
- **New York**: Observed Saturday, July 4 (pass day)
- **Texas**: Data not yet available (likely observed on actual date per Texas rule)

This demonstrates the importance of accurate weekend observation logic.

## Usage Examples

### For Developers

```javascript
// Load master matrix
import holidayMatrix from './master-holiday-matrix-part1.json';

// Check if specific date is a holiday in a jurisdiction
function isHoliday(jurisdiction, date) {
  const holidays = holidayMatrix.holiday_comparison;
  for (const [holidayName, jurisdictions] of Object.entries(holidays)) {
    const jurisdictionKey = jurisdiction.toLowerCase().replace(' ', '_');
    const year = date.getFullYear().toString();
    if (jurisdictions[jurisdictionKey]?.[year] === date.toISOString().split('T')[0]) {
      return holidayName;
    }
  }
  return null;
}

// Get weekend observation rule for jurisdiction
function getWeekendRule(jurisdiction) {
  const rules = holidayMatrix.weekend_observation_rules;
  for (const [ruleName, ruleData] of Object.entries(rules)) {
    if (ruleData.jurisdictions.includes(jurisdiction)) {
      return {
        rule: ruleName,
        description: ruleData.description
      };
    }
  }
  return null;
}
```

### For Data Analysis

```python
import pandas as pd

# Load CSV matrix for quick analysis
df_2025 = pd.read_csv('csv/master-holiday-matrix-2025.csv')

# Count how many jurisdictions observe each holiday
holiday_counts = (df_2025.set_index('Holiday Name') != '-').sum(axis=1)

# Find state-specific holidays (observed by 3 or fewer jurisdictions)
state_specific = holiday_counts[holiday_counts <= 3]

print("State-specific holidays:")
print(state_specific)
```

### For FOIA Deadline Calculator

```typescript
// Calculate business days considering jurisdiction-specific holidays
function calculateFOIADeadline(
  startDate: Date,
  businessDays: number,
  jurisdiction: string
): Date {
  const holidayMatrix = loadHolidayMatrix();
  const weekendRule = getWeekendRule(jurisdiction);

  let currentDate = new Date(startDate);
  let daysAdded = 0;

  while (daysAdded < businessDays) {
    currentDate.setDate(currentDate.getDate() + 1);

    // Skip weekends
    if (currentDate.getDay() === 0 || currentDate.getDay() === 6) {
      continue;
    }

    // Skip jurisdiction-specific holidays
    if (isHolidayInJurisdiction(currentDate, jurisdiction, holidayMatrix)) {
      continue;
    }

    // Handle observed holidays based on weekend rule
    if (isObservedHoliday(currentDate, jurisdiction, weekendRule, holidayMatrix)) {
      continue;
    }

    daysAdded++;
  }

  return currentDate;
}
```

## Data Quality Notes

- **Verification**: All data verified from official .gov sources
- **Currency**: Data current as of October 2025
- **Completeness**: 23.5% complete (12 of 51 jurisdictions)
- **2026 Data**: 58% of completed jurisdictions have 2026 data (7 of 12)

## Next Steps

1. **Complete 2026 data** for Arizona, Florida, Georgia, Michigan, Pennsylvania
2. **Add remaining 39 jurisdictions** (see COMPLETION_STATUS.md for priority order)
3. **Create validation scripts** to ensure ongoing data accuracy
4. **Build FOIA deadline calculator** with jurisdiction-specific logic
5. **Integrate with TheHoleTruth.org** React platform
6. **Connect to Microsoft AI Foundry** FOIA generator

## File Relationships

```
data/holiday-tracking-matrix/
├── json/
│   ├── federal-holidays-2025.json          # Source data
│   ├── federal-holidays-2026.json
│   ├── [state]-holidays-2025.json          # Source data (11 states)
│   ├── [state]-holidays-2026.json          # Source data (6 states with 2026)
│   └── master-holiday-matrix-part1.json    # Generated master matrix
├── csv/
│   ├── master-holiday-matrix-2025.csv      # Generated human-readable
│   └── master-holiday-matrix-2026.csv      # Generated human-readable
├── COMPLETION_STATUS.md                     # Generated status report
└── MASTER_MATRIX_README.md                  # This file
```

## Contributing

When adding new jurisdiction data:
1. Create individual JSON file following existing format
2. Document weekend observation rule
3. Include both 2025 and 2026 data when available
4. Verify all dates from official .gov sources
5. Run validation scripts (when available)
6. Regenerate master matrix files
7. Update COMPLETION_STATUS.md

## Contact

For questions about this matrix or to contribute data:
- Project: The HOLE Foundation - US Transparency Laws Database
- Repository: us-transparency-laws-database
- Related: theholetruth-platform (React application)

## License

This data is compiled from official US government sources and is in the public domain.
Compilation and formatting: The HOLE Foundation

---

*Last Updated: 2025-10-03*
*Master Matrix Version: v0.11*
*Data Currency: Current through October 2025*
