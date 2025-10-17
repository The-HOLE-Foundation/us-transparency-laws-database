---
DATE: 2025-10-16
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: v0.12 Affirmative Rights Extraction Methodology
VERSION: v0.12
---

# Affirmative Rights Extraction Methodology
## v0.12 Manual Extraction Protocol

**Purpose:** Extract ALL affirmative rights of access from transparency law statutes for 52 US jurisdictions

**Quality Standard:** 15-25 rights per jurisdiction (California's 25 is gold standard)

**Critical Rule:** 100% MANUAL EXTRACTION - NO SCRIPTS, NO AI SUMMARIES, NO AUTOMATION

---

## What is an "Affirmative Right"?

**Definition:** Any provision in a transparency law statute where:
- Citizens/requesters/persons "**HAVE THE RIGHT TO**" something
- Agencies "**SHALL**" or "**MUST**" do something that benefits requesters
- Statutes grant specific access, procedure, or remedy to requesters

**Examples:**
- ✅ "Records SHALL be provided within 5 days" → Timeliness Right
- ✅ "First 50 pages provided FREE" → Fee Waiver Right
- ✅ "Requester MAY appeal to Attorney General" → Appeal Right
- ✅ "Agency SHALL provide in electronic format when requested" → Technology Right
- ✅ "Burden of proof on AGENCY to justify withholding" → Enhanced Access Right
- ❌ "Agency MAY charge fees" → NOT an affirmative right (agency power, not requester right)
- ❌ "Records exempt if law enforcement investigation" → NOT a right (exemption)

---

## Source Data Locations

### Full Statutory Texts:
```
data/jurisdictions/states/{state-slug}/statute-full-text.txt
```

**Each statute file contains:**
- Complete unabridged statutory text from official .gov source
- All sections of the state's transparency law
- Response requirements, fees, exemptions, appeals
- Typically 3-30 KB of text

### Output Location:
```
data/jurisdictions/quality-tiers/high-quality/{state-slug}-rights.json
```

---

## Extraction Method - Step by Step

### Step 1: Read ENTIRE Statute

Open the state's `statute-full-text.txt` file and read it **completely** from beginning to end.

**Do NOT skip sections.** Affirmative rights appear throughout:
- Definitions sections (may define requester rights)
- Procedure sections (response timelines, formats)
- Fee sections (caps, waivers, free provisions)
- Appeal sections (remedies, attorney fees, penalties)
- Policy declarations (liberal construction, presumptions)

### Step 2: Identify Every Affirmative Right

As you read, mark EVERY instance of:

**Requester CAN/MAY/HAS RIGHT TO:**
- Inspect records
- Receive copies
- Get electronic format
- Appeal denials
- Recover attorney fees
- Request fee waivers

**Agency SHALL/MUST:**
- Respond within X days
- Provide written decisions
- Separate exempt from non-exempt
- Accommodate electronic requests
- Maintain indexes
- Prove exemptions

**Look for These Common Rights:**
1. **Inspection/copying rights** - Fundamental access
2. **Response deadlines** - 3, 5, 10, 15, 20 days etc.
3. **Fee caps** - $X per page, first Y pages free
4. **Fee waivers** - Public interest, journalists, researchers
5. **Electronic format** - Email, PDF, Excel, native format
6. **No purpose required** - Don't have to state why requesting
7. **No residency required** - Out-of-state access
8. **Segregable portions** - Must separate exempt from public
9. **Appeals processes** - Administrative and judicial
10. **Attorney fees** - Fee-shifting to prevailing party
11. **Burden on agency** - Agency must prove exemption
12. **Presumption of openness** - Doubt favors disclosure
13. **Liberal construction** - Interpret in favor of access
14. **Penalties for violations** - Criminal or civil penalties
15. **Oversight bodies** - Ombudsman, AG, special counsel

### Step 3: Extract Using Template

For EACH affirmative right identified, create an entry using this exact JSON structure:

```json
{
  "category": "[Proactive Disclosure | Enhanced Access Rights | Technology Rights | Requester-Specific Rights | Inspection Rights | Timeliness Rights]",
  "subcategory": "[Specific classification]",
  "statute_citation": "[State Code] § [Section]",
  "description": "[What requester can do / what agency must provide. 2-4 sentences. Use statutory language.]",
  "conditions": "[Any limitations, requirements, or qualifications. If none: 'No conditions' or 'Applies to all requests']",
  "applies_to": "[Who can use this right: 'All requesters' | 'Residents only' | 'Journalists' | etc.]",
  "implementation_notes": "[How this works in practice. Include practical tips, common agency practices, portal URLs.]",
  "request_tips": "[EXACT language to use in FOIA request. Include statutory citation and assertion language.]"
}
```

### Step 4: Quality Check

Before finalizing, verify:

**Completeness Checks:**
- [ ] Read ENTIRE statute (didn't skip sections)
- [ ] Extracted ALL affirmative rights (compared to similar states)
- [ ] Target: 15-25 rights (California's 25 is gold standard)
- [ ] No obvious rights missing

**Accuracy Checks:**
- [ ] Every citation verified from statute text
- [ ] Descriptions use statutory language (not paraphrased)
- [ ] Conditions are complete and accurate
- [ ] No information from non-.gov sources

**Format Checks:**
- [ ] Valid JSON (no syntax errors)
- [ ] All required fields present for each right
- [ ] Consistent category taxonomy
- [ ] Citations follow state's format (not generic)

---

## Quality Tiers

### ✅ HIGH QUALITY (15-25+ rights)
**Characteristics:**
- Comprehensive extraction (didn't miss obvious rights)
- Detailed descriptions with statutory language
- Complete implementation notes
- Specific request tips
- File size: typically 10-25 KB

**Examples:**
- California: 25 rights, 23.6 KB
- New York: 20 rights
- Illinois: 17 rights
- Idaho: 17 rights

**Action:** KEEP - Ready for database import

### ⚠️ MEDIUM QUALITY (10-14 rights)
**Characteristics:**
- Missing some rights but core rights present
- May need supplementation
- File size: 6-15 KB

**Action:** MANUAL REVIEW - Check statute for missing rights, supplement to 15+

### ❌ POOR QUALITY (3-9 rights)
**Characteristics:**
- Severely incomplete
- Missing obvious affirmative rights
- Evidence of automated extraction
- File size: <10 KB

**Action:** REDO - Full re-extraction from statute

---

## JSON File Structure (Complete Template)

```json
{
  "jurisdiction": {
    "name": "[Full State Name]",
    "slug": "[state-slug]",
    "type": "state",
    "transparency_law": "[Official Law Name]"
  },
  "validation_metadata": {
    "parsed_date": "2025-10-16",
    "source_url": "[Primary statute URL from official .gov site]",
    "verified_by": "[Your name or 'Claude Code AI Assistant']",
    "verification_method": "Complete manual review of [statute citation]",
    "statutory_text_file": "statute-full-text.txt"
  },
  "rights_of_access": [
    {
      "category": "Inspection Rights",
      "subcategory": "Right to Inspect and Copy",
      "statute_citation": "[State] Code § [Section]",
      "description": "[Statutory language describing the right]",
      "conditions": "[Limitations or requirements]",
      "applies_to": "[Who can use this]",
      "implementation_notes": "[Practical details]",
      "request_tips": "[Exact assertion language with citation]"
    }
    // ... repeat for each right found
  ]
}
```

---

## Working Directions

### FORWARD Extraction (A→Z)
**Assigned to:** Primary worker
**Start:** Alabama
**Progress through:** Alabama, Alaska, Arizona...Wyoming
**Current Status:** Completed A-K (20 states done)

### BACKWARD Extraction (Z→A)
**Assigned to:** Secondary worker
**Start:** Wyoming
**Progress through:** Wyoming, Wisconsin, West Virginia...Louisiana (skip K and above)
**Meet in middle:** Around Louisiana/Kentucky

### Meeting Point Strategy:
When forward worker reaches same letter as backward worker:
1. **STOP extraction**
2. **Compare completed states** for consistency
3. **Review each other's work** for quality
4. **Merge and finalize** any overlapping states

---

## State-by-State Checklist

### States COMPLETE (High Quality - SKIP THESE):
- ✅ Alabama (15 rights)
- ✅ Alaska (16 rights)
- ✅ Arizona (16 rights)
- ✅ Arkansas (16 rights)
- ✅ California (25 rights - BASELINE)
- ✅ Colorado (16 rights)
- ✅ Connecticut (16 rights)
- ✅ Delaware (16 rights)
- ✅ District of Columbia (20 rights)
- ✅ Florida (20 rights)
- ✅ Georgia (17 rights)
- ✅ Hawaii (16 rights)
- ✅ Idaho (17 rights)
- ✅ Illinois (17 rights)
- ✅ Kansas (16 rights)
- ✅ New York (20 rights)
- ✅ North Carolina (15 rights)
- ✅ Utah (15 rights)
- ✅ Federal (15 rights)

**Total Complete: 19 states + 1 federal = 20/52 jurisdictions**

### States NEEDING WORK:

**MEDIUM QUALITY (needs supplementation to 15+):**
- Indiana (18 rights but JSON formatting issue)
- Iowa (needs rebuild due to JSON issue)
- Rhode Island (12 rights)
- South Carolina (10 rights)
- South Dakota (10 rights)
- Tennessee (14 rights)
- Texas (14 rights)
- Vermont (12 rights)
- Virginia (12 rights)
- Washington (12 rights)
- West Virginia (12 rights)
- Wisconsin (12 rights)
- Wyoming (10 rights)

**POOR QUALITY (needs complete re-extraction):**
- Kentucky (5 rights)
- Louisiana (4 rights)
- Maine (5 rights)
- Maryland (4 rights)
- Massachusetts (4 rights)
- Michigan (5 rights)
- Minnesota (4 rights)
- Mississippi (3 rights)
- Missouri (4 rights)
- Montana (4 rights)
- Nebraska (5 rights)
- Nevada (5 rights)
- New Hampshire (5 rights)
- New Jersey (6 rights)
- New Mexico (7 rights)
- North Dakota (7 rights)
- Ohio (8 rights)
- Oklahoma (8 rights)
- Oregon (7 rights)
- Pennsylvania (9 rights)

---

## Common Pitfalls to Avoid

### ❌ WRONG: Automated/Scripted Extraction
**Why it fails:** State statutes have too many subtle variations in:
- How rights are phrased ("shall" vs "may")
- Conditions and exceptions
- Agency vs requester obligations
- Scope (state vs local, commercial vs non-commercial)

Scripts miss these nuances and produce incomplete, inaccurate data.

### ❌ WRONG: Skipping "Boring" Sections
Affirmative rights appear in unexpected places:
- Definitions sections (who has standing)
- Fee sections (caps, waivers, free provisions)
- Exemptions sections (segregable portions, burden of proof)
- Penalty sections (enforcement mechanisms)

**Must read ENTIRE statute.**

### ❌ WRONG: Copying Other States
Each state is unique:
- Different timelines (3, 5, 7, 10, 15, 20 days)
- Different fee structures ($0.10, $0.15, $0.25, $1.00 per page)
- Different free page thresholds (0, 20, 50, 100 pages)
- Different residency requirements
- Different oversight bodies

**Must extract from actual statute, not template.**

### ❌ WRONG: Combining Multiple Rights
Each distinct right gets its own entry:
- "3-day acknowledgment" = separate right from "15-day production"
- "First 50 pages free" = separate right from "Pages 51+ at 15¢"
- "Attorney fees" = separate from "civil penalties"

**One statutory provision = one rights entry (sometimes multiple if provision grants multiple distinct rights).**

---

## Baseline Comparison - California (25 Rights)

Use California as your quality standard. If your extraction has significantly fewer rights than California, you've likely missed something.

**California's 25 rights cover:**
1. Inspection right
2. Copying right
3. Electronic format provision
4. Immediate access for available records
5. 10-day response deadline
6. Extension limitations
7. Deemed denial for non-response
8. First 50 pages free (wait, that's Illinois - need to verify California)
9. Fee waiver for public interest
10. Segregable portions
11. Burden on agency
12. Liberal construction
13. Attorney fees
14. Civil penalties
15. Proactive disclosure requirements
16-25. [Various specific rights unique to California]

**If your state has <15 rights, ask yourself:**
- Did I read the entire statute?
- Did I check fee sections for caps/waivers?
- Did I extract appeal/enforcement rights?
- Did I find deadline/timeline provisions?
- Did I identify presumptions/liberal construction language?

---

## Parallel Workflow Instructions

### For BACKWARD Worker (Z→A):

**Your Assignment:** Extract states from Wyoming → Louisiana (stopping before K states)

**Start Here:**
1. Begin with **Wyoming** (currently 10 rights - needs review/supplement)
2. Open: `data/jurisdictions/states/wyoming/statute-full-text.txt`
3. Read entire statute
4. Extract ALL affirmative rights
5. Create: `data/jurisdictions/quality-tiers/high-quality/wyoming-rights.json`
6. Validate JSON
7. Move to Wisconsin

**States to Process (Z→A):**
Wyoming, Wisconsin, West Virginia, Washington, Virginia, Vermont, Utah (skip - done), Texas, Tennessee, South Dakota, South Carolina, Rhode Island, Pennsylvania, Oregon, Oklahoma, Ohio, North Dakota, New York (skip - done), New Mexico, New Jersey, New Hampshire, Nevada, Nebraska, Montana, Missouri, Mississippi, Minnesota, Michigan, Massachusetts, Maryland, Maine, Louisiana

**STOP at Louisiana** (Forward worker will handle Kentucky and earlier)

### Progress Tracking:

**After EVERY 3 states**, update `MASTER_EXTRACTION_TRACKER.md` with:
```
### [State Name]
- **Status:** ✅ COMPLETE ([X] rights - High Quality)
- **File:** `quality-tiers/high-quality/[state]-rights.json`
- **Extracted:** [Date]
- **Extractor:** [Your name/identifier]
- **Original:** [X] rights → **Final:** [Y] rights
```

### Cross-Check Every 3 States:

Compare your work to Forward worker's completed states:
1. **Rights count:** Are you finding similar numbers? (15-25 range)
2. **Categories:** Are you using same 6 categories?
3. **Detail level:** Are descriptions similarly detailed?
4. **Citation format:** Are you matching the pattern?

**If major differences:** STOP and discuss before continuing.

---

## JSON Template (Copy/Paste This)

```json
{
  "jurisdiction": {
    "name": "",
    "slug": "",
    "type": "state",
    "transparency_law": ""
  },
  "validation_metadata": {
    "parsed_date": "2025-10-16",
    "source_url": "",
    "verified_by": "",
    "verification_method": "Complete manual review of [statute citation]",
    "statutory_text_file": "statute-full-text.txt"
  },
  "rights_of_access": [

  ]
}
```

---

## Category Taxonomy (Use Exactly These)

### 1. Proactive Disclosure
Records agencies must publish without request:
- Meeting agendas/minutes
- Budgets and spending
- Contracts
- Salary databases
- Required publications

### 2. Enhanced Access Rights
Special provisions and protections:
- Fee waivers
- Expedited processing
- Burden of proof on agency
- Liberal construction mandates
- Oversight body access
- Attorney fees
- Penalties for violations

### 3. Technology Rights
Digital and electronic access:
- Electronic format provision
- Email/fax submission
- Database access
- Machine-readable formats
- Electronic submission of requests

### 4. Requester-Specific Rights
Rights for specific requester types:
- Journalist privileges
- Academic researcher access
- No purpose statement required
- No residency requirement
- No identification required
- Personal records access (own records)

### 5. Inspection Rights
Physical/in-person access:
- Right to inspect before copying
- Business hours access
- On-site examination
- Segregable portions
- Presumption of openness

### 6. Timeliness Rights
Time-based provisions:
- Response deadlines (acknowledgment)
- Production deadlines (records delivery)
- Extension limitations
- Deemed denial for non-response
- Immediate release requirements

---

## Field-by-Field Guidance

### `statute_citation`
**Format:** Use state's official citation style
- **Alabama:** Ala. Code § 36-12-40
- **California:** Cal. Gov. Code § 7920.000
- **Federal:** 5 U.S.C. § 552(a)(2)
- **Illinois:** 5 ILCS 140/3
- **New York:** N.Y. Pub. Off. Law § 87

**Find format in:** First few lines of state's statute-full-text.txt file

### `description`
**Good Example:**
"Public bodies must respond to FOIA requests within 5 business days after receipt. Response must either comply with the request, deny it with specific justification, or notify requester of extension with reasons for delay."

**Bad Example:**
"Agencies have to respond fast."

**Guidelines:**
- 2-4 sentences
- Use statutory language (quote or close paraphrase)
- Explain WHAT the right grants
- Be specific about requirements

### `conditions`
**Good Example:**
"Applies to all non-commercial requests. Commercial requests have 21-day timeline. Extension limited to one 5-day period with written notice required."

**Bad Example:**
"Some conditions apply."

**Guidelines:**
- Document ALL conditions
- Note exceptions
- Specify who/what/when limitations
- If truly no conditions: state "No conditions" or "Applies to all requests"

### `applies_to`
**Good Examples:**
- "All requesters - no residency requirement"
- "Kentucky residents only (includes workers, property owners, registered businesses)"
- "Journalists with professional credentials"
- "Individuals seeking their own personal records"

**Bad Example:**
- "People"

### `implementation_notes`
**Good Example:**
"Illinois provides first 50 pages completely free, then charges $0.15 per page for additional copies. This means a 100-page request costs only $7.50 (50 free + 50 × $0.15). One of the most requester-friendly fee structures in the nation."

**Bad Example:**
"There are fees."

**Include:**
- How agencies typically comply
- Portal URLs if available
- Practical tips
- Common agency practices
- Cost calculations/examples

### `request_tips`
**Good Example:**
"Assert in your request: 'Under 5 ILCS 140/6(a), the first 50 pages must be provided free of charge. There should be no fee for this request since it is only [X] pages.' Include the statutory citation and specific assertion."

**Bad Example:**
"Mention the law."

**Guidelines:**
- Provide EXACT language to use
- Include statutory citation in assertion
- Give specific phrasing
- Explain when/how to use

---

## Common Rights Found in Most States

Use this as a **CHECKLIST** when extracting (most states have 10-15 of these):

- [ ] Right to inspect public records
- [ ] Right to copy public records
- [ ] Response deadline (acknowledgment)
- [ ] Production deadline (records delivery)
- [ ] Extension limitations (if delays allowed)
- [ ] Deemed denial (if no response)
- [ ] Fee cap per page
- [ ] Fee actual cost limitation
- [ ] Fee waiver (public interest)
- [ ] Electronic format provision
- [ ] Electronic submission of requests
- [ ] No purpose statement required
- [ ] Segregable portions must be released
- [ ] Burden of proof on agency
- [ ] Presumption of openness / liberal construction
- [ ] Attorney fees for prevailing requesters
- [ ] Administrative appeal (AG, Ombudsman, etc.)
- [ ] Judicial review (court enforcement)
- [ ] Penalties for violations (criminal or civil)
- [ ] Oversight body (PAC, Ombudsman, etc.)

**If your extraction has <10 of these common rights, you've likely missed something!**

---

## Validation Before Finalizing

### JSON Validation:
```bash
python3 -m json.tool your-state-rights.json > /dev/null
```
Must return no errors.

### Rights Count:
```bash
grep -c '"category"' your-state-rights.json
```
Should return 15-25 (California standard).

### Category Distribution:
Most states should have rights in 4-6 categories:
- Usually: Timeliness (3-5 rights), Enhanced Access (3-6 rights), Fee Waiver (2-4 rights)
- Often: Inspection Rights (2-3), Technology Rights (1-3)
- Sometimes: Proactive Disclosure (1-3), Requester-Specific (1-3)

**If all rights in 1-2 categories, extraction is incomplete.**

---

## When You're Stuck

### "I can't find 15 rights in this statute"

**Expand your search:**
- Procedural sections → timelines are rights!
- Fee sections → caps, waivers, limits are rights!
- Definitions → standing/eligibility provisions are rights!
- Enforcement → appeals, fees, penalties are rights!
- Policy declarations → presumptions, liberal construction are rights!

**Remember:** Any "shall" or "must" that benefits requesters is an affirmative right.

### "I found 30+ rights - is that too many?"

**NO!** Some states (like California, Hawaii, Illinois) have very comprehensive laws.

If you're finding 25-35 rights, you're probably being thorough. Just verify:
- Not double-counting (same right stated twice)
- Not splitting one right into multiple entries
- Each is genuinely distinct

### "This statute has weird provisions I don't understand"

**Include them anyway!** Examples:
- "Records over 70 years old are open" (Kansas)
- "Hot check fees are public" (Arkansas)
- "Body-worn camera recordings have 25-day timeline" (DC)

If statute creates a right, extract it even if unusual.

---

## Quality Assurance Checklist

Before marking a state COMPLETE:

- [ ] Read entire statute file (didn't skip)
- [ ] Extracted 15-25 rights (meets California standard)
- [ ] Every citation verified from statute text
- [ ] JSON validates (no syntax errors)
- [ ] File saved in correct location
- [ ] MASTER_EXTRACTION_TRACKER.md updated
- [ ] Compared to similar states for consistency
- [ ] All required fields complete
- [ ] Request tips include specific assertion language
- [ ] No AI summaries or non-.gov sources used

---

## File Naming and Locations

### Statute Files (READ FROM):
`data/jurisdictions/states/{slug}/statute-full-text.txt`

### Output Files (WRITE TO):
`data/jurisdictions/quality-tiers/high-quality/{slug}-rights.json`

### Slugs:
- Lowercase
- Hyphenated
- No spaces
- Examples: `new-york`, `north-carolina`, `district-of-columbia`, `new-hampshire`

---

## Coordination Protocol

### Every 3 States Completed:

1. **Update progress tracker:**
```bash
# Add your completed states to MASTER_EXTRACTION_TRACKER.md
```

2. **Check other worker's progress:**
```bash
# Look for newly completed states from other direction
find data/jurisdictions/quality-tiers/high-quality -name "*-rights.json" -newer MASTER_EXTRACTION_TRACKER.md
```

3. **Compare quality:**
- Pick one of your states
- Pick one of their states
- Compare rights count, detail level, format
- Ensure consistency

4. **Flag discrepancies:**
If major differences in approach, STOP and discuss before continuing.

---

## Critical Data Integrity Issues Found

### ISSUE: Wrong Statute Files
**Problem:** Kansas directory had Arkansas statute in its statute-full-text.txt file

**Solution:** Always verify first line of statute file matches the state you're extracting:
```bash
head -1 data/jurisdictions/states/[state]/statute-full-text.txt
```

Should say "[STATE NAME] [LAW NAME]", NOT a different state.

**If wrong statute:** Find correct one in:
```
.archive/2025-10-11-complete-data-backup/statutory-text-files/[STATE]_transparency_law-v0.11.txt
```

Copy to correct location before extracting.

### ISSUE: JSON Formatting
**Problem:** Appending with `cat >>` creates malformed JSON

**Solution:** Create complete file in one operation:
- Use temp file: `/tmp/state-extraction.json`
- Build complete JSON
- Validate with `python3 -m json.tool`
- Move to final location only if valid

---

## Support Resources

### Quality Baseline:
`data/jurisdictions/quality-tiers/high-quality/california-rights.json`
- 25 rights
- Gold standard for completeness
- Reference for formatting and detail level

### Methodology Questions:
Check `MASTER_EXTRACTION_TRACKER.md` for:
- Current progress
- Which states are done
- Examples of completed extractions
- Quality standards

### Statute Locations:
All verified statutory texts in:
`data/jurisdictions/states/{state-slug}/statute-full-text.txt`

### Archive Backup:
If statute file is missing or wrong:
`.archive/2025-10-11-complete-data-backup/statutory-text-files/`

---

## Success Metrics

### Individual State:
- ✅ 15-25 rights extracted
- ✅ JSON validates
- ✅ All citations verified
- ✅ Comprehensive coverage

### Overall Project:
- 🎯 Target: 52/52 jurisdictions with high quality extractions
- 📊 Current: 20/52 complete (38%)
- ⏳ Remaining: 32 jurisdictions
- 🎯 Goal: 100% by end of coordinated effort

---

## Final Notes

**This is painstaking work** - and that's intentional. This database will:
- Train AI systems on transparency law
- Power FOIA generators for real requests
- Serve as authoritative reference for journalists and citizens
- Last for years as definitive source

**One-time investment in accuracy pays dividends forever.**

**Every right you extract correctly helps someone access government information they're entitled to.**

**Thank you for your careful, thorough work!**

---

## Contact for Questions

If you encounter issues or have questions:
- Check `CLAUDE.md` for project context
- Review `MASTER_EXTRACTION_TRACKER.md` for current status
- Compare your work to California baseline
- Document uncertainties in validation_metadata notes field

---

**Last Updated:** 2025-10-16
**Forward Progress:** Through Kansas (A-K complete)
**Backward Progress:** [To be updated by backward worker]
**Meeting Point:** Estimated around Louisiana/Maine
