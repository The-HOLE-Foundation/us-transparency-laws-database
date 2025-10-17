---
DATE: 2025-10-03
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Manual Layer 2 Parsing Instructions
VERSION: v0.11
---

# Manual Layer 2 Parsing Instructions

## Context

After discovering that autonomous parsing generated fake data for 44 jurisdictions, we must manually parse the remaining states with proper verification.

**Status**: 7/51 complete (Federal + 6 states)
**Remaining**: 44 states to manually parse
**Estimated time**: 18-20 hours

## High-Quality Examples to Reference

Before starting each new jurisdiction, review these completed examples:

1. `data/federal/jurisdiction-data.json` - Federal FOIA
2. `data/states/alabama/jurisdiction-data.json` - Alabama Open Records Act
3. `data/states/alaska/jurisdiction-data.json` - Alaska Public Records Act
4. `data/states/arizona/jurisdiction-data.json` - Arizona Public Records Law
5. `data/states/california/jurisdiction-data.json` - California Public Records Act
6. `data/states/florida/jurisdiction-data.json` - Florida Public Records Law
7. `data/states/illinois/jurisdiction-data.json` - Illinois FOIA

These show the expected level of detail and accuracy.

## Manual Parsing Workflow (Per Jurisdiction)

### Step 1: Read Statutory Text

```bash
# Find the statutory text file
ls consolidated-transparency-data/statutory-text-files/ | grep -i {STATE}

# Read the full statutory text
cat consolidated-transparency-data/statutory-text-files/{STATE}_transparency_law-v0.11.txt
```

**Look for:**
- Official law name (exact wording)
- Statute citation (with § symbols)
- Response timelines (business days vs calendar days)
- Fee structure
- Exemption categories
- Appeal process

### Step 2: Extract Data Manually

Create JSON following this exact structure:

```json
{
  "jurisdiction": "State Name",
  "transparency_law": {
    "name": "EXACT OFFICIAL NAME from statute",
    "statute_citation": "Proper citation with § or 'section'",
    "effective_date": "YYYY-MM-DD or null",
    "last_amended": "YYYY-MM-DD or null",

    "response_requirements": {
      "initial_response_time": <number or null>,
      "initial_response_unit": "business_days|calendar_days|working_days|variable",
      "initial_response_description": "Optional context",
      "final_response_time": <number or null>,
      "final_response_unit": "business_days|calendar_days|working_days|variable",
      "final_response_notes": "Optional context",
      "extension_allowed": true|false,
      "extension_max_days": <number or null>,
      "extension_notes": "Optional context"
    },

    "fee_structure": {
      "search_fee": "Description or 'Not allowed'",
      "search_fee_notes": "Optional clarification",
      "search_fee_statutory_cite": "Optional citation",
      "copy_fee_per_page": <number or null>,
      "copy_fee_notes": "Optional context",
      "copy_fee_cite": "Optional citation",
      "electronic_fee": "Description",
      "fee_waiver_available": true|false,
      "fee_waiver_criteria": "Description or null"
    },

    "exemptions": [
      {
        "category": "Personal Privacy|Law Enforcement|Deliberative Process|etc",
        "citation": "Exact statute citation",
        "description": "What this exemption covers",
        "scope": "narrow|moderate|broad"
      }
      // Add all major exemption categories
    ],

    "appeal_process": {
      "first_level": "Who handles first appeal",
      "first_level_deadline_days": <number or null>,
      "first_level_notes": "Optional context",
      "second_level": "Who handles second appeal",
      "second_level_deadline_days": <number or null>,
      "attorney_fees_recoverable": true|false,
      "attorney_fees_notes": "Optional context"
    },

    "validation_metadata": {
      "parsed_date": "2025-10-03",
      "confidence_level": "high",
      "source_url": "https://official.gov.source",
      "source_verified": true,
      "primary_sources": [
        "List of sources consulted"
      ],
      "notes": "Any parsing notes or special considerations"
    }
  },
  "agencies": []
}
```

### Step 3: Critical Parsing Rules

#### ✅ DO:
1. **Use exact official law names** from the statute
   - ✅ "Texas Public Information Act"
   - ❌ "Texas Public Records Law"

2. **Include § symbol in citations**
   - ✅ "Tex. Gov't Code § 552.001 et seq."
   - ❌ "Tex. Gov't Code 552.001 et seq."

3. **Be specific about response units**
   - `business_days` = excludes weekends/holidays
   - `calendar_days` = includes all days
   - `working_days` = synonym for business_days
   - `variable` = "promptly", "reasonable time", no fixed deadline

4. **Use null for unknown values, not placeholders**
   - ✅ `"copy_fee_per_page": null`
   - ❌ `"copy_fee_per_page": "Varies"`

5. **Extract ALL major exemption categories**
   - Minimum 5-10 exemptions
   - Include citation for each
   - Categorize scope: narrow/moderate/broad

6. **Set confidence to "high" only when fully verified**
   - "high" = Verified against official statute
   - "medium" = Some interpretation required
   - "low" = Uncertain or incomplete

#### ❌ DON'T:
1. Don't use generic placeholders
2. Don't guess at law names
3. Don't use "citation pending verification"
4. Don't leave critical fields empty (use null instead)
5. Don't batch commits - commit after EACH jurisdiction

### Step 4: Validate Before Committing

```bash
# Validate the file you just created
python3 scripts/validation/layer2-simple-validation.py --file data/states/{state}/jurisdiction-data.json

# Should see: ✅ Valid: data/states/{state}/jurisdiction-data.json
```

**Common validation errors:**
- Missing § in citation
- Invalid response unit (typo)
- Empty required fields (use null instead)
- Missing exemptions array

### Step 5: Commit Immediately

```bash
git add data/states/{state}/jurisdiction-data.json
git commit -m "feat({state}): Add Layer 2 structured metadata

Parsed from: {STATE}_transparency_law-v0.11.txt
Law name: {Official Law Name}
Citation: {Statute citation}

Key details:
- Response timeline: {X} {business_days/calendar_days}
- Fee structure: {Brief description}
- {N} exemption categories
- Appeal process: {Brief description}

Confidence: high
Manually verified against official statute

🤖 Generated with Claude Code"
```

## Remaining Jurisdictions (Alphabetical)

### Priority 1: Large/Complex States (Start Here)
- [ ] Texas (Public Information Act)
- [ ] New York (Freedom of Information Law)
- [ ] Pennsylvania (Right-to-Know Law)
- [ ] Ohio (Public Records Act)
- [ ] Georgia (Open Records Act)
- [ ] North Carolina (Public Records Law)
- [ ] Michigan (Freedom of Information Act)
- [ ] Virginia (Freedom of Information Act)
- [ ] Washington (Public Records Act)
- [ ] Massachusetts (Public Records Law)

### Priority 2: Remaining States (A-Z)
- [ ] Arkansas
- [ ] Colorado
- [ ] Connecticut
- [ ] Delaware
- [ ] District of Columbia
- [ ] Hawaii
- [ ] Idaho
- [ ] Indiana
- [ ] Iowa
- [ ] Kansas
- [ ] Kentucky
- [ ] Louisiana
- [ ] Maine
- [ ] Maryland
- [ ] Minnesota
- [ ] Mississippi
- [ ] Missouri
- [ ] Montana
- [ ] Nebraska
- [ ] Nevada
- [ ] New Hampshire
- [ ] New Jersey
- [ ] New Mexico
- [ ] North Dakota
- [ ] Oklahoma
- [ ] Oregon
- [ ] Rhode Island
- [ ] South Carolina
- [ ] South Dakota
- [ ] Tennessee
- [ ] Utah
- [ ] Vermont
- [ ] West Virginia
- [ ] Wisconsin
- [ ] Wyoming

## Quality Checkpoints

After every 5 jurisdictions, verify:
1. All 5 have confidence: "high"
2. All 5 pass validation
3. All 5 have correct official law names
4. All 5 have specific citations (not generic)
5. All 5 have detailed exemptions (5+ categories)

## Time Estimates

- **Simple states** (clear, short statutes): 15-20 minutes each
- **Complex states** (multiple laws, amendments): 30-45 minutes each
- **Average**: 25 minutes per state
- **Total**: 44 states × 25 min = ~18 hours

## Session Resume Command

When starting a new session with `--dangerously-skip-permissions`:

```
Read /Volumes/HOLE-RAID-DRIVE/HOLE/Projects/us-transparency-laws-database/workflows/MANUAL_PARSING_INSTRUCTIONS.md
and continue manual parsing of Layer 2 structured metadata. Start with Texas.
```

## Example: Texas (First State to Parse)

### Source File
```
consolidated-transparency-data/statutory-text-files/TEXAS_transparency_law-v0.11.txt
```

### Key Information to Extract
- **Name**: "Texas Public Information Act" (NOT "Public Records Law")
- **Citation**: "Tex. Gov't Code Ch. 552" or "Tex. Gov't Code § 552.001 et seq."
- **Response**: "Promptly" = variable (no fixed timeline)
- **AG Review**: 10 business days to request opinion
- **AG Decision**: 45 working days
- **Fees**: Reasonable charges, varies by agency
- **Exemptions**: 20+ categories in statute

### Expected Output Location
```
data/states/texas/jurisdiction-data.json
```

---

**Remember**: Manual parsing is tedious but essential. The alternative (autonomous parsing) gave us fake data. This work ensures 100% accuracy for ground truth database.

**Estimated completion**: 18-20 hours of focused manual work
**Quality standard**: Every jurisdiction must match the quality of the 7 examples
