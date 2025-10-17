# Business Days Calculation Complexity in Public Records Laws

## The Challenge

**Business days are the standard in FOIA/public records laws**, but they introduce significant implementation complexity that calendar days don't have.

> "This is one of the trickiest parts of programming for public records laws. They almost all use business days, which require calculations that are tricky." - Project Lead

## Why Business Days Are Tricky

### 1. **Not Just "Weekdays"**

Business days ≠ Monday-Friday. They exclude:
- **Federal holidays** (varies by jurisdiction)
- **State holidays** (each state has unique observances)
- **Local government holidays** (city/county variations)
- **Special closures** (emergencies, natural disasters)

### 2. **Jurisdiction-Specific Holiday Calendars**

Each of the 51 jurisdictions has different holiday schedules:

```
Federal: 11 federal holidays (New Year's, MLK Day, Presidents Day, etc.)
Alabama: State holidays may include Confederate Memorial Day
Hawaii: Prince Kuhio Day, King Kamehameha Day, Statehood Day
Texas: State Independence Day, Juneteenth (before federal adoption)
```

### 3. **Forward vs. Backward Counting**

Some deadlines count forward, others backward:
- **Response deadline**: Count forward from request date
- **Appeal deadline**: Count backward from response receipt
- **Fee payment**: Count forward from fee notice

###4. **Date Arithmetic Edge Cases**

```python
# Example: 10 business days from Friday, December 20, 2024

Start: Friday, Dec 20
Weekend: Dec 21-22 (don't count)
Christmas Eve: Dec 23 (some jurisdictions closed)
Christmas: Dec 24-25 (federal holiday)
Weekend: Dec 28-29 (don't count)
New Year's Eve: Dec 30 (some jurisdictions closed)
New Year's: Dec 31-Jan 1 (federal holiday)
Weekend: Jan 4-5 (don't count)

Actual deadline: Could be January 6, 7, or 8 depending on:
- Whether jurisdiction observes Christmas Eve
- Whether jurisdiction observes New Year's Eve
- When "day 1" starts (receipt day or next business day)
```

## Data Model Implications

### Current Ground Truth Structure

```json
{
  "california": {
    "response_timeline_days": 10,
    "response_timeline_type": "business_days",
    "statute_citation": "California Government Code § 7920.000",
    "verified_date": "2025-09-26"
  }
}
```

### What's Missing for Full Business Day Calculations

```json
{
  "california": {
    "response_timeline_days": 10,
    "response_timeline_type": "business_days",
    
    // NEEDED FOR ACCURATE CALCULATION:
    "holiday_calendar": "california_state",  // Reference to holiday schedule
    "counting_method": "exclude_receipt_day",  // or "include_receipt_day"
    "weekend_definition": ["saturday", "sunday"],  // Some jurisdictions: Fri-Sat
    "special_rules": {
      "if_deadline_weekend": "next_monday",  // or "previous_friday"
      "if_deadline_holiday": "next_business_day"
    }
  }
}
```

## Real-World Complexity Examples

### Example 1: Vermont (2 Business Days - Fastest)

```
Request filed: Thursday at 4:45 PM
Receipt day: Thursday (counts as day 0? or day 1?)
Day 1: Friday
Weekend: Saturday-Sunday (don't count)
Day 2: Monday

Deadline: Monday or Tuesday depending on counting method
```

### Example 2: Wisconsin (60 Business Days)

```
60 business days ≈ 12 calendar weeks
But could range from 84 to 95 calendar days depending on:
- Number of weekends in the period (8-10)
- Federal holidays during the period (0-4)
- State holidays during the period (0-2)
- Starting day of week
```

### Example 3: Alabama (Reasonable Time - Flexible)

```json
{
  "response_timeline_days": -1,  // Special code for flexible deadline
  "response_timeline_type": "business_days",
  "timeline_description": "reasonable time given the nature of the request"
}
```

No calculation needed - handled case-by-case by agency.

## Implementation Strategies

### Strategy 1: Library-Based (Recommended for Production)

```python
from business_days import BusinessDays
from holiday_calendars import get_state_holidays

# Configure calendar
cal = BusinessDays(
    holidays=get_state_holidays('california', year=2025),
    weekends=['saturday', 'sunday']
)

# Calculate deadline
request_date = date(2025, 12, 20)
deadline = cal.add_business_days(request_date, 10)
```

**Pros**: Handles edge cases, well-tested, maintains holiday data
**Cons**: External dependency, requires holiday calendar maintenance

### Strategy 2: Rule-Based Approximation

```python
def estimate_business_days(start_date, num_days):
    """
    Rough estimate: 1.4 calendar days per business day
    (accounts for weekends but not holidays)
    """
    calendar_days = int(num_days * 1.4) + 1
    return start_date + timedelta(days=calendar_days)
```

**Pros**: Simple, no dependencies, "good enough" for estimates
**Cons**: Not legally accurate, fails around holidays

### Strategy 3: Lookup Table

```python
# Pre-calculate common scenarios for each jurisdiction
DEADLINE_LOOKUP = {
    'california': {
        '2025-01-15': {'10_business_days': '2025-01-29'},
        '2025-01-16': {'10_business_days': '2025-01-30'},
        # ... thousands of entries
    }
}
```

**Pros**: Fast lookup, precomputed accuracy
**Cons**: Storage intensive, requires annual updates, limited date range

## Recommended Approach for This Project

### Phase 1: Ground Truth (Current)
Store the **statutory definition** only:
```json
{
  "response_timeline_days": 10,
  "response_timeline_type": "business_days"
}
```

### Phase 2: Holiday Calendars (Future)
Create separate holiday calendar files:
```json
// data/holiday-calendars/california-2025.json
{
  "jurisdiction": "california",
  "year": 2025,
  "holidays": [
    {"date": "2025-01-01", "name": "New Year's Day"},
    {"date": "2025-01-20", "name": "Martin Luther King Jr. Day"},
    // ...
  ],
  "weekend_days": ["saturday", "sunday"],
  "source": "https://www.calhr.ca.gov/holidays"
}
```

### Phase 3: Calculation Engine (Future)
Build deadline calculator that:
1. Reads ground truth response timelines
2. Loads appropriate holiday calendar
3. Applies jurisdiction-specific counting rules
4. Returns both estimated and exact deadlines

## Testing Challenges

### Unit Tests Must Account For:

```python
def test_business_days_across_christmas():
    """Test 10 business days spanning Christmas/New Year"""
    start = date(2024, 12, 20)  # Friday
    
    # Expected: ~3 weeks due to holiday cluster
    expected_min = date(2025, 1, 6)  # Monday
    expected_max = date(2025, 1, 8)  # Wednesday
    
    actual = calculate_deadline('california', start, 10)
    assert expected_min <= actual <= expected_max

def test_business_days_leap_year():
    """Ensure Feb 29 handled correctly"""
    start = date(2024, 2, 28)  # Wednesday, leap year
    actual = calculate_deadline('texas', start, 10)
    # Should properly skip Feb 29 if it's a business day

def test_business_days_dst_transition():
    """Daylight saving time shouldn't affect day counting"""
    start = date(2025, 3, 7)  # Friday before DST starts
    actual = calculate_deadline('california', start, 10)
    # 10 business days, not 10*24 hours
```

## Impact on User Experience

### What Users See Now (Simple but Imprecise)

```
California: 10 business days
Estimated deadline: January 30, 2025
```

### What Users Should See (Accurate and Helpful)

```
California: 10 business days

📅 Estimated Deadline: January 30, 2025
   (Excludes weekends and state holidays)

⚠️ Important Dates:
   • Jan 20: MLK Day (holiday - not counted)
   • Jan 25-26: Weekend (not counted)
   • Total calendar days: ~14 days

💡 This is an estimate. Agencies may calculate differently.
   For legal advice, consult an attorney.
```

## Database Requirements

### Minimum Viable (Current State)
- ✅ Timeline days (integer or -1 for flexible)
- ✅ Timeline type (business_days, working_days, calendar_days)
- ✅ Verified statute citation

### Production Ready (Future Enhancement)
- ⚠️ Holiday calendar reference per jurisdiction
- ⚠️ Counting methodology (include/exclude receipt day)
- ⚠️ Weekend definition (for non-traditional work weeks)
- ⚠️ Deadline extension rules (weekend/holiday rollover)
- ⚠️ Historical holiday data (for retroactive calculations)

## Related Standards

### Federal "Working Days" vs State "Business Days"

```
Working Days (Federal, 5 USC § 552):
- Monday-Friday excluding federal holidays
- Does NOT include Saturdays even if office open
- Consistent definition across all agencies

Business Days (Most States):
- "Day on which the office is open for business"
- May include Saturdays if office open
- Can vary by agency within same state
```

## Jurisdictions Using Each Type

### Business Days (49 jurisdictions)
Most states define business days as "days the agency is open"

### Working Days (2 jurisdictions)  
- **Federal**: 20 working days (5 USC § 552)
- **Idaho**: 3 working days
- **Mississippi**: 7 working days

### Calendar Days (0 jurisdictions currently)
None of the 51 jurisdictions use calendar days for response deadlines

### Flexible "Reasonable Time" (9 jurisdictions)
Using timeline code `-1`:
- Alabama, Alaska, Louisiana, Maine, North Carolina, North Dakota, South Dakota, Tennessee, Wyoming

## Future Development Roadmap

### Q1 2026: Holiday Calendar Integration
- Collect official holiday schedules for all 51 jurisdictions
- Create standardized holiday calendar JSON format
- Build calendar maintenance system (annual updates)

### Q2 2026: Calculation Engine
- Implement business day calculator library
- Add deadline estimation to API
- Create developer documentation

### Q3 2026: User Features
- "Calculate my deadline" interactive tool
- iCal/Google Calendar deadline exports
- Email reminder system

### Q4 2026: Advanced Features
- Historical deadline validation ("Was my request late?")
- Agency-specific holiday calendars (some agencies have unique hours)
- Real-time holiday updates (emergency closures)

## Key Takeaways

1. **Business days ≠ weekdays** - Must account for holidays
2. **Every jurisdiction is different** - No universal calendar
3. **Edge cases are common** - Holidays cluster near year-end
4. **Precision matters legally** - Wrong deadline = missed appeal rights
5. **Start simple, enhance later** - Ground truth first, calculations second

## Resources

- [Python business days libraries](https://github.com/search?q=business+days+python)
- [Federal holiday schedule](https://www.opm.gov/policy-data-oversight/pay-leave/federal-holidays/)
- [State holiday calendars](https://www.timeanddate.com/holidays/us/)
- [FOIA deadline calculator examples](https://www.foia.gov/how-to.html)

---

**Document Purpose**: Capture institutional knowledge about business days complexity for future developers

**Last Updated**: October 2, 2025

**Related**: `VALIDATION_METHODOLOGY.md`, `data/ground-truth/canonical-values.json`
