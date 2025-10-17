---
DATE: 2025-10-03
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Holiday Tracking Database for Deadline Calculation
VERSION: v0.12
---

# Holiday Tracking Database & Educational FOIA Generator

## Overview

**Purpose**: Create a comprehensive database of federal and state-specific holidays to enable accurate FOIA deadline calculations within the AI-powered FOIA Generator.

**Key Innovation**: Combine deadline calculation with rights education - the FOIA Generator doesn't just create requests, it educates users about their transparency rights while writing their FOIA request.

## The Problem

Current FOIA tools fail because they don't account for:
1. **Weekends** (business days exclude Saturdays and Sundays)
2. **Federal holidays** (observed by federal agencies and many states)
3. **State-specific holidays** (Texas Independence Day, Patriots' Day in MA/ME, Cesar Chavez Day in CA, etc.)
4. **Holiday observance variations** (when a holiday falls on weekend, observance may shift)
5. **Business day calculation rules** (some jurisdictions include/exclude the start date)

**Result**: Inaccurate deadline calculations lead to missed deadlines, rejected requests, and frustrated requesters.

## The Solution: Three-Part System

### Part 1: Holiday Database (Structured Data)

Create a queryable database of all government holidays:

```json
{
  "federal_holidays": [
    {
      "name": "New Year's Day",
      "date_rule": "january_1",
      "observed_by": ["federal", "all_states"],
      "observance_shift": "if_weekend_to_monday",
      "type": "fixed_date"
    },
    {
      "name": "Martin Luther King Jr. Day",
      "date_rule": "third_monday_january",
      "observed_by": ["federal", "all_states"],
      "type": "floating_date"
    },
    {
      "name": "Juneteenth",
      "date_rule": "june_19",
      "observed_by": ["federal", "all_states"],
      "observance_shift": "if_weekend_to_closest_weekday",
      "type": "fixed_date",
      "notes": "Added as federal holiday in 2021"
    }
  ],
  "state_specific_holidays": {
    "texas": [
      {
        "name": "Texas Independence Day",
        "date_rule": "march_2",
        "observed_by": ["texas"],
        "type": "fixed_date",
        "affects_business_days": true,
        "source_url": "https://statutes.capitol.texas.gov/..."
      },
      {
        "name": "Confederate Heroes Day",
        "date_rule": "january_19",
        "observed_by": ["texas"],
        "type": "fixed_date",
        "affects_business_days": true,
        "source_url": "https://statutes.capitol.texas.gov/..."
      },
      {
        "name": "Lyndon Baines Johnson Day",
        "date_rule": "august_27",
        "observed_by": ["texas"],
        "type": "fixed_date",
        "affects_business_days": true,
        "source_url": "https://statutes.capitol.texas.gov/..."
      }
    ],
    "massachusetts": [
      {
        "name": "Patriots' Day",
        "date_rule": "third_monday_april",
        "observed_by": ["massachusetts", "maine"],
        "type": "floating_date",
        "affects_business_days": true,
        "source_url": "https://malegislature.gov/..."
      },
      {
        "name": "Bunker Hill Day",
        "date_rule": "june_17",
        "observed_by": ["massachusetts"],
        "type": "fixed_date",
        "affects_business_days": "suffolk_county_only",
        "source_url": "https://malegislature.gov/..."
      }
    ],
    "california": [
      {
        "name": "Cesar Chavez Day",
        "date_rule": "march_31",
        "observed_by": ["california"],
        "type": "fixed_date",
        "affects_business_days": true,
        "source_url": "https://leginfo.legislature.ca.gov/..."
      },
      {
        "name": "Indigenous Peoples' Day",
        "date_rule": "second_monday_october",
        "observed_by": ["california"],
        "type": "floating_date",
        "affects_business_days": true,
        "replaces": "Columbus Day",
        "source_url": "https://leginfo.legislature.ca.gov/..."
      }
    ]
  }
}
```

### Part 2: Deadline Calculator (Business Logic)

Enhanced version of the BusinessDayCalculator from comprehensive-validation-system.md:

```python
class DeadlineCalculator:
    """Calculate FOIA deadlines accounting for weekends and holidays"""

    def __init__(self, jurisdiction: str, holiday_db: HolidayDatabase):
        self.jurisdiction = jurisdiction
        self.holiday_db = holiday_db

    def calculate_deadline(
        self,
        request_date: date,
        timeline_days: int,
        timeline_unit: str,
        include_start_date: bool = False
    ) -> Dict:
        """
        Calculate response deadline with educational explanation

        Returns:
            {
                "deadline": date,
                "explanation": [str],  # Educational step-by-step
                "business_days_counted": int,
                "weekends_skipped": int,
                "holidays_skipped": [str],
                "jurisdiction_rules": str,
                "requester_rights": [str]
            }
        """
        if timeline_unit == "calendar_days":
            return self._calculate_calendar_deadline(request_date, timeline_days)
        elif timeline_unit == "business_days":
            return self._calculate_business_deadline(
                request_date,
                timeline_days,
                include_start_date
            )
        elif timeline_unit == "variable":
            return self._explain_variable_deadline(request_date)

    def _calculate_business_deadline(
        self,
        start: date,
        days: int,
        include_start: bool
    ) -> Dict:
        """Calculate business days with educational explanation"""
        explanation = []
        explanation.append(f"📅 Request submitted: {start.strftime('%A, %B %d, %Y')}")
        explanation.append(f"⏱️  Jurisdiction: {self.jurisdiction.title()}")
        explanation.append(f"📋 Response timeline: {days} business days")
        explanation.append("")
        explanation.append("🔍 What are 'business days'?")
        explanation.append("   Business days exclude weekends (Saturday/Sunday) and government holidays.")
        explanation.append("   This means the agency has more calendar time to respond.")
        explanation.append("")

        current = start
        days_counted = 0
        weekends = 0
        holidays = []

        explanation.append("📊 Day-by-day calculation:")

        if include_start and self._is_business_day(start):
            days_counted = 1
            explanation.append(f"   Day 1: {start.strftime('%a, %b %d')} ✓ (start date counts)")

        while days_counted < days:
            current += timedelta(days=1)

            if self._is_business_day(current):
                days_counted += 1
                explanation.append(f"   Day {days_counted}: {current.strftime('%a, %b %d')} ✓")
            else:
                skip_reason = self._get_skip_reason(current)
                if "weekend" in skip_reason.lower():
                    weekends += 1
                    explanation.append(f"   SKIP: {current.strftime('%a, %b %d')} ⏭️  ({skip_reason})")
                else:
                    holidays.append(skip_reason)
                    explanation.append(f"   SKIP: {current.strftime('%a, %b %d')} 🎉 ({skip_reason})")

        explanation.append("")
        explanation.append(f"✅ Response due by: {current.strftime('%A, %B %d, %Y')}")
        explanation.append(f"   • Business days counted: {days_counted}")
        explanation.append(f"   • Weekends skipped: {weekends}")
        explanation.append(f"   • Holidays skipped: {len(holidays)}")

        # Add educational rights information
        rights = self._get_requester_rights()
        explanation.append("")
        explanation.append("📚 Your Rights:")
        for right in rights:
            explanation.append(f"   • {right}")

        return {
            "deadline": current,
            "explanation": explanation,
            "business_days_counted": days_counted,
            "weekends_skipped": weekends,
            "holidays_skipped": holidays,
            "jurisdiction_rules": self._get_jurisdiction_rules(),
            "requester_rights": rights
        }

    def _is_business_day(self, check_date: date) -> bool:
        """Check if date is a business day"""
        # Weekend check
        if check_date.weekday() >= 5:
            return False

        # Query holiday database
        if self.holiday_db.is_holiday(check_date, self.jurisdiction):
            return False

        return True

    def _get_requester_rights(self) -> List[str]:
        """Get educational information about requester rights"""
        # This will be populated from transparency_law data
        return [
            "Agencies must respond within the legal deadline",
            "If no response, you can file an appeal",
            "Agencies must cite specific exemptions for denials",
            "You have the right to appeal any denial",
            f"Fee waivers may be available (check {self.jurisdiction} rules)"
        ]

    def _get_jurisdiction_rules(self) -> str:
        """Get jurisdiction-specific calculation rules"""
        # This explains quirks like "start date included" vs "excluded"
        return f"{self.jurisdiction.title()} calculates business days..."
```

### Part 3: Educational FOIA Generator Integration

The FOIA Generator uses the deadline calculator to educate while generating:

```typescript
// In FOIA Generator (Azure AI Foundry agent)

interface FOIAGeneratorContext {
  jurisdiction: string;
  requestDate: Date;
  requestType: string;
  deadlineCalculation: DeadlineResult;
}

async function generateEducationalFOIA(context: FOIAGeneratorContext) {
  const prompt = `
You are an educational FOIA Generator. Your goal is to:
1. Generate a legally compliant FOIA request
2. Educate the user about their transparency rights
3. Explain deadline calculations and expectations
4. Provide actionable next steps

Context:
- Jurisdiction: ${context.jurisdiction}
- Request submitted: ${context.requestDate}
- Calculated deadline: ${context.deadlineCalculation.deadline}
- Business days: ${context.deadlineCalculation.business_days_counted}
- Weekends skipped: ${context.deadlineCalculation.weekends_skipped}
- Holidays skipped: ${context.deadlineCalculation.holidays_skipped}

Generate:
1. FOIA request letter (compliant with ${context.jurisdiction} requirements)
2. Timeline explanation (why deadline is X days away)
3. Rights education (what to expect, how to appeal, fee waivers)
4. Next steps (how to track, when to follow up)
`;

  // Agent generates educational content
  return await aiFoundryAgent.generate(prompt);
}
```

## Data Collection Strategy

### Source Identification

Official sources for holiday information:
1. **Federal**: [OPM.gov Federal Holidays](https://www.opm.gov/policy-data-oversight/pay-leave/federal-holidays/)
2. **States**: Each state's official holidays statute
   - Example: [Texas State Holidays](https://statutes.capitol.texas.gov/Docs/GV/htm/GV.662.htm)
   - Example: [Massachusetts Holidays](https://malegislature.gov/Laws/GeneralLaws/PartI/TitleII/Chapter4/Section7)
   - Example: [California Holidays](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=GOV&sectionNum=6700)

### Automated Collection Workflow

```python
# Holiday data scraper (to be built in v0.12)

class HolidayDataCollector:
    """Collect holiday information from official .gov sources"""

    def collect_federal_holidays(self) -> List[Holiday]:
        """Scrape federal holidays from OPM.gov"""
        # Use official OPM.gov API or scrape
        pass

    def collect_state_holidays(self, state: str) -> List[Holiday]:
        """Scrape state holidays from official statutes"""
        # Parse state code for holiday definitions
        # Example: Texas Government Code § 662.003
        pass

    def build_holiday_matrix(self) -> Dict:
        """Create matrix of which holidays are observed in which states"""
        matrix = {
            "new_years_day": ["federal", "all_states"],
            "mlk_day": ["federal", "all_states"],
            "texas_independence_day": ["texas"],
            "patriots_day": ["massachusetts", "maine"],
            "cesar_chavez_day": ["california", "colorado", "texas"],
            # ... etc
        }
        return matrix
```

## Implementation Timeline

### Phase 1: Federal Holidays (Week 1)
- [ ] Collect all 11 federal holidays
- [ ] Document observance rules (weekend shifts)
- [ ] Create federal holiday database schema
- [ ] Integrate into DeadlineCalculator

### Phase 2: Top 10 States (Week 2-3)
- [ ] California, Texas, Florida, New York, Illinois, Pennsylvania, Ohio, Michigan, North Carolina, Georgia
- [ ] Collect state-specific holidays from official statutes
- [ ] Build state holiday database
- [ ] Create holiday matrix (which states observe which holidays)

### Phase 3: Remaining 40 States (Week 4-6)
- [ ] Collect all remaining state holidays
- [ ] Complete holiday matrix
- [ ] Validate against official sources

### Phase 4: Educational Integration (Week 7-8)
- [ ] Integrate DeadlineCalculator into FOIA Generator
- [ ] Create educational prompts for AI agent
- [ ] Test deadline explanations
- [ ] Build rights education database

### Phase 5: Testing & Validation (Week 9-10)
- [ ] Test deadline calculations for 100+ scenarios
- [ ] Validate against known deadlines
- [ ] User testing of educational content
- [ [ ] Document edge cases

## Database Schema

```sql
-- Holiday database schema (Supabase)

CREATE TABLE holidays (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  date_rule TEXT NOT NULL,  -- e.g., "january_1", "third_monday_april"
  type TEXT NOT NULL CHECK (type IN ('fixed_date', 'floating_date')),
  observance_shift TEXT,  -- e.g., "if_weekend_to_monday"
  source_url TEXT NOT NULL,  -- Official .gov source
  affects_business_days BOOLEAN DEFAULT true,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE holiday_observance (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  holiday_id UUID REFERENCES holidays(id),
  jurisdiction TEXT NOT NULL,  -- "federal", "texas", "california", etc.
  is_observed BOOLEAN DEFAULT true,
  local_variations TEXT,  -- e.g., "suffolk_county_only" for Bunker Hill Day
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE calculated_dates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  holiday_id UUID REFERENCES holidays(id),
  year INTEGER NOT NULL,
  calculated_date DATE NOT NULL,
  is_observed_date DATE,  -- May differ if weekend shift applies
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(holiday_id, year)
);
```

## Integration with FOIA Generator

### User Experience Flow

1. **User Input**: "I want to request police body camera footage from Austin Police Department"

2. **Generator Response**:
   ```
   📝 Generating your Texas Public Information Act request...

   📅 Timeline Calculation:
   • Request submitted: October 3, 2025 (Friday)
   • Response deadline: 10 business days
   • Calculated deadline: October 17, 2025 (Friday)

   📊 Day-by-day breakdown:
   • Days 1-5: Oct 6-10 (Mon-Fri) ✓
   • Skip: Oct 11-12 (Weekend) ⏭️
   • Skip: Oct 13 (Columbus Day - Federal) 🎉
   • Days 6-10: Oct 14-17 (Tue-Fri) ✓

   📚 Your Rights in Texas:
   • Agencies must respond within 10 business days
   • If voluminous, agency may request additional time
   • You can appeal denials to the Attorney General
   • Fee waivers available if "in the public interest"

   📋 Your Request Letter:
   [Generated FOIA letter appears here]

   📧 Next Steps:
   1. Send this request to: records@austintexas.gov
   2. Mark your calendar for October 17, 2025
   3. If no response by then, you can file an appeal
   4. Track your request using our dashboard
   ```

3. **Ongoing Education**: As user navigates the generator, educational tooltips explain:
   - Why business days ≠ calendar days
   - What exemptions might apply
   - How to calculate fees
   - When to escalate to appeal

## Benefits

### For Users:
- ✅ Accurate deadline calculations (first time anyone has done this right)
- ✅ Educational experience (learn rights while making request)
- ✅ Transparency about process (see exactly how deadline is calculated)
- ✅ Confidence in system (backed by official statutory sources)

### For The HOLE Foundation:
- ✅ Unique competitive advantage (nobody else has comprehensive holiday tracking)
- ✅ Educational mission fulfilled (transparency + civic education)
- ✅ Database becomes authoritative source (can license to other FOIA tools)
- ✅ AI training data goldmine (deadline calculation examples for future models)

## Next Steps

1. **Approve this approach** for v0.12
2. **Prioritize states** for Phase 2 (top 10 states first)
3. **Integrate with FOIA Generator** architecture planning
4. **Begin federal holiday collection** (can start immediately)

## References

- [comprehensive-validation-system.md](./comprehensive-validation-system.md) - Original business day calculator specification
- [V0.12_ROADMAP.md](../V0.12_ROADMAP.md) - Full v0.12 feature roadmap
- Federal holidays: https://www.opm.gov/policy-data-oversight/pay-leave/federal-holidays/
- State holidays: See each state's official government code

---

**This holiday tracking system transforms the FOIA Generator from a simple letter-writing tool into an educational platform that empowers citizens to exercise their transparency rights with confidence.**
