---
DATE: 2025-10-16
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Affirmative Rights Collection Workflow
VERSION: v0.12-alpha
STATUS: ACTIVE
---

# Affirmative Rights Collection Workflow

## Objective
Complete rights of access data collection for remaining 38 jurisdictions to achieve v0.12 (non-alpha) status.

---

## Current Status

**Completed**: 14/52 jurisdictions (27%)
- arkansas, california, connecticut, federal, florida, georgia, illinois, louisiana, massachusetts, new_york, north_carolina, oregon, texas, washington

**Remaining**: 38/52 jurisdictions (73%)
- alabama, alaska, arizona, colorado, delaware, district_of_columbia, hawaii, idaho, indiana, iowa, kansas, kentucky, maine, maryland, michigan, minnesota, mississippi, missouri, montana, nebraska, nevada, new_hampshire, new_jersey, new_mexico, north_dakota, ohio, oklahoma, pennsylvania, rhode_island, south_carolina, south_dakota, tennessee, utah, vermont, virginia, west_virginia, wisconsin, wyoming

**Total Rights Collected**: 272 rights across 14 jurisdictions

---

## Workflow Steps

### Step 1: Locate Official Statute
**Goal**: Find the official state transparency law on .gov website

**Sources (in priority order)**:
1. State Legislature Website (e.g., `legis.state.xx.us`)
2. State Code/Statute Database (e.g., `revisor.mn.gov`, `codes.ohio.gov`)
3. Official State Attorney General FOIA Guide
4. State Archives/Records Office

**Example URLs**:
- Alabama: https://codes.findlaw.com/al/title-36-public-officers-and-employees/al-code-sect-36-12-40.html
- Alaska: http://www.akleg.gov/basis/statutes.asp#40.25
- Arizona: https://www.azleg.gov/arsDetail/?title=39

**What to Extract**:
- Official statute name and citation
- Section numbers covering rights of access
- Full statutory text for relevant sections

---

### Step 2: Identify Affirmative Rights
**Goal**: Extract specific rights (not exemptions) from statute

**Right Categories** (from database schema):
- `proactive_disclosure` - Government must publish without request
- `enhanced_access` - Expedited processing, priority handling
- `technology_format` - Electronic records, specific formats
- `requester_specific` - Rights for journalists, researchers, etc.
- `inspection_rights` - Right to inspect before copying
- `timeliness_rights` - Guaranteed response timelines
- `fee_waiver` - Automatic or easy fee waivers
- `aggregation_rights` - Bulk data requests
- `privacy_protection` - Redaction instead of denial
- `appeal_rights` - Administrative or judicial appeal processes

**What Qualifies as a Right**:
✅ "Agency shall provide copies in electronic format if requested"
✅ "Records must be available for inspection within 3 business days"
✅ "Fee waiver granted for educational or news media purposes"
✅ "Requester may appeal denial to Attorney General within 30 days"

**What Does NOT Qualify**:
❌ Exemptions (what government can withhold)
❌ General procedures (how to file a request)
❌ Penalties for agencies (enforcement mechanisms belong elsewhere)

---

### Step 3: Structure Data for Each Right

**Required Fields**:
```json
{
  "right_name": "Short descriptive name (e.g., 'Electronic Format Right')",
  "right_category": "One of 10 categories above",
  "short_description": "1-2 sentence summary",
  "full_description": "Complete description with context",
  "statutory_citation": "Exact statute section (e.g., 'Ala. Code § 36-12-41(b)')",
  "statutory_text": "Verbatim quote from statute",
  "priority": "critical|high|medium|low",
  "assertion_language": "Template language for FOIA requests"
}
```

**Example**:
```json
{
  "right_name": "Electronic Format Right",
  "right_category": "technology_format",
  "short_description": "Requester may specify electronic format for records.",
  "full_description": "Alabama law grants requesters the right to receive public records in electronic format when records are maintained electronically. Agency must provide records in the requested format unless not technologically feasible.",
  "statutory_citation": "Ala. Code § 36-12-41(b)",
  "statutory_text": "If a public record is maintained in an electronic format, the public body shall provide a copy of the record in electronic format if requested by the person seeking access.",
  "priority": "high",
  "assertion_language": "Pursuant to Ala. Code § 36-12-41(b), I request these records be provided in electronic format as they are maintained electronically by your agency."
}
```

---

### Step 4: Save to File System

**File Structure**:
```
data/jurisdictions/states/[state-name]/rights.json
```

**File Format**:
```json
{
  "jurisdiction": {
    "id": "alabama",
    "name": "Alabama",
    "slug": "alabama"
  },
  "metadata": {
    "collected_date": "2025-10-16",
    "source_url": "https://codes.findlaw.com/al/title-36-public-officers-and-employees/",
    "statute_name": "Alabama Open Records Act",
    "primary_citation": "Ala. Code §§ 36-12-40 to 36-12-48",
    "verification_status": "verified",
    "verified_by": "Claude Code AI Assistant",
    "last_verified": "2025-10-16"
  },
  "rights": [
    {
      "right_name": "Electronic Format Right",
      "right_category": "technology_format",
      "short_description": "...",
      "full_description": "...",
      "statutory_citation": "Ala. Code § 36-12-41(b)",
      "statutory_text": "...",
      "priority": "high",
      "assertion_language": "..."
    }
  ]
}
```

---

### Step 5: Import to Neon Database

**Import Script**:
```bash
node scripts/import-rights-to-neon.js data/jurisdictions/states/alabama/rights.json
```

**Script Logic**:
1. Read JSON file
2. Look up jurisdiction_id from jurisdictions table
3. For each right in file:
   - Insert into rights_of_access table
   - Generate embedding (vector) if OpenAI key available
   - Set verification_status = 'verified'
4. Log import results

**SQL Insert**:
```sql
INSERT INTO rights_of_access (
  jurisdiction_id, right_category, right_name,
  short_description, full_description, statutory_citation,
  statutory_text, priority, assertion_language,
  verification_status, last_verified
) VALUES (
  'alabama', 'technology_format', 'Electronic Format Right',
  '...', '...', 'Ala. Code § 36-12-41(b)',
  '...', 'high', '...',
  'verified', '2025-10-16'
);
```

---

## Priority Order for Collection

### Tier 1: High-Traffic States (Complete First)
**Rationale**: Most user impact, largest populations
1. Pennsylvania (13M population)
2. Ohio (11.8M)
3. Michigan (10M)
4. Virginia (8.6M)
5. New Jersey (9.3M)
6. Indiana (6.8M)
7. Missouri (6.2M)
8. Maryland (6.2M)
9. Wisconsin (5.9M)
10. Minnesota (5.7M)

### Tier 2: Medium States
11. Colorado (5.8M)
12. Arizona (7.4M)
13. Tennessee (7M)
14. South Carolina (5.3M)
15. Alabama (5.1M)
16. Kentucky (4.5M)
17. Iowa (3.2M)
18. Utah (3.4M)
19. Nevada (3.2M)
20. Kansas (2.9M)

### Tier 3: Smaller States & Territories
21-38. All remaining jurisdictions alphabetically

---

## Automation Opportunities

### 1. Statute Text Extraction
**Tool**: Use MCP servers or web scraping
```bash
# Example with Perplexity MCP
mcp search "Alabama Open Records Act statute text section 36-12-41"
```

### 2. AI-Assisted Rights Identification
**Tool**: Use Claude or GPT-4 with prompt:
```
Analyze this statute text and identify all affirmative rights granted to requesters.
Do not include exemptions. Focus on what requesters CAN do or receive.
Format as JSON array with fields: right_name, category, description, citation.
```

### 3. Batch Processing
**Script**: Process multiple states in parallel
```bash
for state in pennsylvania ohio michigan; do
  node scripts/extract-rights.js $state &
done
wait
```

---

## ⚠️ CRITICAL: Data Validation Requirements

**WARNING**: Not all archived data is current or accurate. Some may be:
- ✅ Accurate but **outdated** (statute amended since collection)
- ✅ Correct at time of collection but **no longer valid**
- ❌ Never verified from official sources
- ❌ Based on secondary sources (blogs, summaries, AI hallucinations)

**MANDATORY VALIDATION FOR EVERY JURISDICTION**:

### 1. Check Effective Date
```
❓ When was this statute last amended?
❓ Is our data from before or after the last amendment?
❓ Are there any 2024-2025 legislative session changes?
```

**How to Verify**:
- Check state legislature "Recently Enacted" or "Session Laws"
- Search for "[State] FOIA amendments 2024" or "2025"
- Verify effective dates on .gov statute database

### 2. Verify Current Statute Text
```
⚠️ ALWAYS compare against CURRENT official .gov statute
⚠️ NEVER assume old data is still accurate
⚠️ NEVER trust secondary sources without verification
```

**Process**:
1. Go to official state statute database (e.g., leginfo.ca.gov, legis.state.tx.us)
2. Look up exact citation from our data
3. Read current statute text line by line
4. Note ANY differences from our archived data
5. Update our data to match current statute
6. Document verification date and source URL

### 3. Mark Verification Status
Every right must have:
```json
{
  "verification_status": "verified|outdated|unverified|disputed",
  "last_verified": "2025-10-16",
  "verification_source": "https://leginfo.legislature.ca.gov/...",
  "verification_notes": "Compared against current statute as of Oct 2025. No amendments since 2023."
}
```

**Verification Statuses**:
- `verified` - Checked against current official source within last 90 days
- `outdated` - Known to be superseded by newer statute version
- `unverified` - Not yet verified against official source
- `disputed` - Conflicting information from multiple sources

### 4. Document Chain of Custody
For each jurisdiction, create `VERIFICATION_LOG.md`:
```markdown
## Alabama - Verification Log

**Verification Date**: 2025-10-16
**Verified By**: Claude Code AI Assistant
**Primary Source**: https://codes.findlaw.com/al/title-36-public-officers-and-employees/

### Checks Performed:
- [x] Statute exists at cited location
- [x] No amendments since our data collected
- [x] Cross-referenced with AL AG FOIA guide
- [x] Verified effective dates
- [x] Compared statutory text word-for-word

### Changes Found:
- NONE - Data is current as of Oct 2025

### Legislative Session Check:
- 2024 Regular Session: No FOIA amendments
- 2025 Session: Not yet started

### Next Verification Due: 2026-01-16 (90 days)
```

## Quality Standards

**Every Right Must Have**:
- ✅ Official .gov source verification **FROM CURRENT STATUTE**
- ✅ Verification within last 90 days
- ✅ Exact statutory citation **checked against current code**
- ✅ Verbatim statutory text quote **from current version**
- ✅ Clear assertion language for FOIA requests
- ✅ Priority level justified by strategic value
- ✅ Verification log documenting source and date

**Common Mistakes to Avoid**:
- ❌ Using archived data without current verification
- ❌ Assuming old data is still accurate
- ❌ Mixing exemptions with rights
- ❌ Including procedural requirements (not rights)
- ❌ Citing unofficial sources (Wikipedia, blogs, etc.)
- ❌ Citing outdated statute versions
- ❌ Vague or generic descriptions
- ❌ Missing assertion language
- ❌ No verification date/source documentation

---

## Validation Checklist

Before importing to database:
- [ ] All sources are official .gov websites
- [ ] Statutory citations are exact and verifiable
- [ ] Each right is truly affirmative (not an exemption)
- [ ] Assertion language is request-ready
- [ ] Priority levels are assigned
- [ ] JSON validates against schema
- [ ] Jurisdiction slug matches database

---

## Progress Tracking

**Update After Each Jurisdiction**:
```sql
-- Check current completion
SELECT
  COUNT(DISTINCT jurisdiction_id) as completed_jurisdictions,
  COUNT(*) as total_rights,
  ROUND(COUNT(DISTINCT jurisdiction_id)::numeric / 52 * 100, 1) as completion_percentage
FROM rights_of_access;
```

**Target Metrics**:
- Jurisdictions: 52/52 (100%)
- Estimated Total Rights: 500-800 (based on current average of ~19 per jurisdiction)
- Timeline: 38 jurisdictions ÷ 5 per day = 8 business days

---

## Next Steps

1. **Start with Pennsylvania** (largest remaining state)
2. **Use Task tool with statute-researcher agent** for official statute location
3. **Extract rights systematically** using AI assistance
4. **Import to database** after each jurisdiction
5. **Verify in database** with SQL query
6. **Track progress** in DOCUMENTATION_UPDATES_TRACKER.md

---

## Success Criteria

✅ **v0.12 (non-alpha) Requirements**:
- All 52 jurisdictions have rights data
- Minimum 10 rights per jurisdiction (average)
- All rights verified from official sources
- All rights imported to Neon database
- Database schema v0.12-alpha promoted to v0.12

---

**Status**: 📋 Workflow Ready | 🚀 Ready to Execute
**Next Action**: Begin Tier 1 collection starting with Pennsylvania
