---
DATE: 2025-10-02
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Holiday Tracking Matrix Methodology
VERSION: v0.12
---

# Holiday Data Collection Methodology

## Objective

Collect authoritative, verified holiday data for all 51 US jurisdictions to enable accurate business day calculations for FOIA response deadlines.

## Research Strategy

### Phase 1: Federal Holidays
**Source**: Office of Personnel Management (OPM.gov)
**URL**: https://www.opm.gov/policy-data-oversight/pay-leave/federal-holidays/
**Time Estimate**: 2-3 hours

### Phase 2: Priority States (Top 10 by FOIA volume)
**States**: CA, FL, IL, NY, TX, PA, OH, GA, NC, MI
**Time Estimate**: 30-40 hours
**Rationale**: These states represent ~45% of US population and highest FOIA request volume

### Phase 3: Remaining States (40 states + DC)
**Time Estimate**: 80-120 hours
**Parallel processing**: Research 5-10 states simultaneously

## Acceptable Source Hierarchy

### Tier 1 (Preferred)
1. **State statute** - Official legal holidays statute
2. **State HR/Personnel office** - Official employee holiday calendar
3. **State employee handbook** - Published .gov document

### Tier 2 (Acceptable)
4. **Governor's Office** - Executive orders or proclamations
5. **State Legislature** - Session calendars (shows observed holidays)

### Tier 3 (Last Resort)
6. **State agency FOIA pages** - If explicitly state holidays affecting deadlines

### PROHIBITED
- ❌ Wikipedia, AboutTime, TimeAndDate.com
- ❌ Private sector calendars
- ❌ Tourism websites
- ❌ Third-party aggregators
- ❌ AI-generated summaries

## Research Process (Per State)

### Step 1: Locate Statute
```
Search: "[State] official state holidays statute site:gov"
Example: "Texas official state holidays statute site:gov"
Target: Government Code § [XXX] listing legal holidays
```

### Step 2: Verify from HR Office
```
Search: "[State] human resources state holidays [YEAR] site:gov"
Example: "California human resources state holidays 2025 site:gov"
Target: Official employee calendar for verification
```

### Step 3: Document Source
Create source file: `sources/[state]-holidays-source.md`

```markdown
---
Jurisdiction: [State Name]
Source Type: Statute / HR Calendar / Both
Verified Date: [YYYY-MM-DD]
Data Years: 2025, 2026
---

## Primary Source
**URL**: [direct link to statute or calendar]
**Authority**: [Agency or legal code]
**Last Updated**: [date on source]

## Holidays List
[Copy/paste or screenshot of official holidays]

## Weekend Observation Rules
[How the state handles holidays falling on weekends]

## Special Notes
[Any unique considerations]
```

### Step 4: Extract Data to JSON
Create data file: `json/[state]-holidays-2025.json`

```json
{
  "jurisdiction": "[State Name]",
  "jurisdiction_code": "[ST]",
  "year": 2025,
  "source_url": "https://...",
  "source_type": "statute",
  "verified_date": "2025-10-02",
  "weekend_observation_rule": "if_saturday_observe_friday_if_sunday_observe_monday",
  "holidays": [
    {
      "name": "New Year's Day",
      "statutory_date": "2025-01-01",
      "observed_date": "2025-01-01",
      "day_of_week": "Wednesday",
      "is_state_holiday": true,
      "notes": ""
    }
  ]
}
```

## Data Fields Explanation

### Jurisdiction Fields
- `jurisdiction`: Full state name
- `jurisdiction_code`: 2-letter postal code
- `year`: Calendar year
- `source_url`: Direct link to authoritative source
- `source_type`: "statute" | "hr_calendar" | "executive_order"
- `verified_date`: Date data was verified (YYYY-MM-DD)
- `weekend_observation_rule`: How holidays are shifted when falling on weekends

### Holiday Fields
- `name`: Official name of holiday
- `statutory_date`: Date as defined in statute (YYYY-MM-DD)
- `observed_date`: Actual date observed (accounts for weekend shifts)
- `day_of_week`: Monday, Tuesday, etc.
- `is_state_holiday`: Boolean (affects state agency business days)
- `notes`: Special considerations or exceptions

## Weekend Observation Rules

States use different rules when holidays fall on weekends:

### Rule A: Friday/Monday Shift (Most Common)
- Saturday → Friday
- Sunday → Monday
- **Code**: `if_saturday_observe_friday_if_sunday_observe_monday`

### Rule B: Monday Only Shift
- Saturday → No shift (not observed)
- Sunday → Monday
- **Code**: `if_sunday_observe_monday`

### Rule C: No Shift
- Holiday observed on actual calendar date regardless of weekend
- **Code**: `no_shift_observed_on_actual_date`

### Rule D: Custom
- State-specific rules documented in notes
- **Code**: `custom_see_notes`

## Quality Control Checklist

For each jurisdiction:
- [ ] Source URL is official .gov domain
- [ ] Source URL is direct link (not homepage)
- [ ] Source explicitly lists holidays for 2025
- [ ] Weekend observation rule is documented
- [ ] All dates follow YYYY-MM-DD format
- [ ] Day of week calculated correctly
- [ ] Observed date accounts for weekend shifts
- [ ] 2026 data collected if available

## Common State Holidays

### Universal (All 51 Jurisdictions)
- New Year's Day (January 1)
- Independence Day (July 4)
- Thanksgiving (4th Thursday in November)
- Christmas (December 25)

### Most Common Federal Holidays
- Martin Luther King Jr. Day (3rd Monday in January)
- Presidents' Day (3rd Monday in February)
- Memorial Day (Last Monday in May)
- Labor Day (1st Monday in September)
- Veterans Day (November 11)

### Regional/State-Specific Examples
- **Patriots' Day**: MA, ME (3rd Monday in April)
- **Texas Independence Day**: TX (March 2)
- **Confederate Memorial Day**: AL, MS, SC, TX (varies)
- **Cesar Chavez Day**: CA, CO, TX (March 31)
- **Juneteenth**: All states (June 19) - newer federal holiday
- **Indigenous Peoples' Day**: Some states (replaces Columbus Day)
- **Election Day**: Some states (1st Tuesday after 1st Monday in November)
- **Day After Thanksgiving**: Some states

## Data Validation

### Automated Checks
```bash
# Verify all 51 jurisdictions present
ls json/*-holidays-2025.json | wc -l  # Should be 52 (50 states + DC + federal)

# Verify JSON format
for file in json/*-holidays-2025.json; do
  jq empty "$file" || echo "Invalid JSON: $file"
done

# Verify required fields
for file in json/*-holidays-2025.json; do
  jq -e '.jurisdiction, .year, .source_url, .holidays' "$file" > /dev/null || echo "Missing fields: $file"
done
```

### Manual Review
- Cross-reference state statute text with extracted data
- Verify observation dates for holidays falling on weekends
- Check for state-specific holidays unique to jurisdiction
- Confirm business day impact (some holidays don't affect agencies)

## Edge Cases to Watch For

### 1. Juneteenth (New Federal Holiday)
- Added in 2021
- Not all states observed immediately
- Check each state's statute for adoption status

### 2. Columbus Day vs. Indigenous Peoples' Day
- Some states renamed, some still use Columbus Day
- Verify official name and date
- May affect observation by different agencies

### 3. Confederate Memorial Day
- Only observed in some Southern states
- Date varies by state (April, May, or June)
- Politically sensitive - use official statutory name

### 4. Election Day
- Not a federal holiday
- Some states observe as state holiday
- Verify business day impact

### 5. Day After Thanksgiving
- Common state holiday
- Not a federal holiday
- Verify each state's policy

### 6. State-Specific Celebrations
- Texas: Lyndon B. Johnson Day, San Jacinto Day
- Hawaii: Prince Kuhio Day, King Kamehameha Day
- Alaska: Seward's Day, Alaska Day
- Verify official status and business day impact

## Timeline

### Week 1 (Oct 2-8)
- Federal holidays: Complete
- Priority 10 states: Complete
- **Deliverable**: 11 jurisdictions (Federal + 10 states)

### Week 2-3 (Oct 9-22)
- Next 20 states: Complete
- **Deliverable**: 31 total jurisdictions

### Week 4-5 (Oct 23-Nov 5)
- Remaining 21 jurisdictions: Complete
- **Deliverable**: 52 total jurisdictions (all 51 + federal)

### Week 6 (Nov 6-12)
- Create master matrix
- Generate CSV exports
- Validation and QA
- **Deliverable**: Production-ready dataset

## Output Files

### Source Documentation (51 files)
`sources/[jurisdiction]-holidays-source.md`

### JSON Data (104 files minimum)
- `json/federal-holidays-2025.json`
- `json/federal-holidays-2026.json`
- `json/alabama-holidays-2025.json`
- `json/alabama-holidays-2026.json`
- ... (50 states × 2 years = 100 files)
- `json/dc-holidays-2025.json`
- `json/dc-holidays-2026.json`

### Master Matrix (2 files)
- `json/master-holiday-matrix.json` (all jurisdictions, all years)
- `csv/master-holiday-matrix-2025.csv` (human-readable)

## Success Criteria

✅ All 51 jurisdictions have verified data
✅ All sources are official .gov domains
✅ 2025 data complete for all jurisdictions
✅ 2026 data collected where available
✅ Weekend observation rules documented
✅ Master matrix generated
✅ Validation scripts pass 100%

## Related Resources

- [V0.12 Roadmap](../../documentation/V0.12_ROADMAP.md)
- [Validation Methodology](../../documentation/VALIDATION_METHODOLOGY.md)
- [Source Verification Guide](../../documentation/Source_Verification_and_Training_Guide.md)
- [OPM Federal Holidays](https://www.opm.gov/policy-data-oversight/pay-leave/federal-holidays/)

---

**Next Step**: Begin research with Federal holidays, then proceed to priority states.
