---
DATE: 2025-10-16
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Rights Extraction from Database Statutes
VERSION: v0.12-alpha
---

# Extract Affirmative Rights from Database Statute Texts

## CORRECT PROCESS

**Source**: `statute_texts` table in Neon database (52/52 jurisdictions complete)
**NOT**: External .gov websites (data already collected and verified)

---

## What Are Affirmative Rights?

**Affirmative rights** are provisions in transparency statutes that grant citizens specific entitlements:

### Examples of Affirmative Rights:
✅ "Any person has the right to inspect public records"
✅ "Agency shall provide copies in electronic format if requested"
✅ "Records about oneself shall be disclosed upon request"
✅ "Requester may examine documents without written request"
✅ "Citizens may appeal denial to Attorney General"
✅ "Verbal requests are sufficient for inspection"
✅ "Fee waivers granted for educational purposes"
✅ "Agency must respond within X days"

### NOT Affirmative Rights:
❌ Exemptions (what government can withhold)
❌ Penalties for agencies (enforcement mechanisms)
❌ General procedures without guaranteed outcomes

---

## The Balance: Rights vs Exemptions

**Critical Understanding:**

Disclosure decisions = **Rights of Access** vs **Exemptions**

When agency claims exemption, requester asserts right:
- "I have right to records about myself" (affirmative right)
- "But this reveals police methods" (exemption claim)
- **Which wins?** Statute determines priority/hierarchy

**Why This Matters:**
- Rights often override weak exemptions
- Some rights are explicitly prioritized in statute
- Texas example: Right to own records > most exemptions EXCEPT police means/methods
- FOIA Generator needs to assert strongest applicable rights

**Ground Reality vs Statute:**
- We document what statute SAYS (law as written)
- Agencies often abuse exemptions (claim everything is "police methods")
- But our database reflects statutory rights, not agency abuse
- Users can assert what law guarantees, even if agencies resist

---

## Extraction Process

### Step 1: Retrieve Statute from Database

```sql
SELECT full_text, statute_citation, jurisdiction_id
FROM statute_texts
WHERE jurisdiction_id = 'oklahoma';
```

### Step 2: Read Through Looking For Rights Language

**Key phrases indicating affirmative rights:**
- "shall permit"
- "has the right to"
- "may request"
- "agency must"
- "shall provide"
- "entitled to"
- "guaranteed access"
- "cannot deny"
- "requester may"

### Step 3: Extract Each Distinct Right

For each right found, create entry with:

```json
{
  "category": "One of 10 categories",
  "subcategory": "Specific right name",
  "statute_citation": "Exact section (e.g., 'Okla. Stat. tit. 51, § 24A.5')",
  "description": "What the right grants in plain language",
  "conditions": "Any limitations or qualifications",
  "applies_to": "Who/what this right covers",
  "implementation_notes": "Practical guidance on using this right",
  "request_tips": "Template language to assert this right in FOIA request"
}
```

### Step 4: Categorize Appropriately

**10 Right Categories:**
1. `proactive_disclosure` - Gov must publish without request
2. `enhanced_access` - Special procedures, expedited processing
3. `technology_format` - Electronic records, format rights
4. `requester_specific` - Rights for journalists, researchers, self-records
5. `inspection_rights` - View/examine without copying
6. `timeliness_rights` - Response deadlines, deemed denials
7. `fee_waiver` - Cost reductions or waivers
8. `aggregation_rights` - Bulk requests, databases
9. `privacy_protection` - Redaction instead of denial
10. `appeal_rights` - Challenge denials, attorney fees

---

## Example Extraction: Oklahoma

**Statute Text from Database** (8,264 characters):

Read through looking for affirmative rights like:

"Any person shall have the right to examine and inspect..."
→ **Inspection Rights: Basic Right to Examine**

"No person shall be denied the right to inspect...solely because of refusal to state purpose"
→ **Requester-Specific Rights: No Purpose Statement Required**

"Agency shall provide copies in the format maintained..."
→ **Technology Rights: Native Format Right**

"If request denied, requester may appeal to district attorney"
→ **Appeal Rights: DA Appeal Process**

**Target**: Extract 15-25 rights from Oklahoma statute

---

## Quality Standards

**Use California as Template:**
- 50 rights extracted
- Detailed descriptions (2-3 sentences minimum)
- Implementation notes explain practical use
- Request tips provide assertion language
- Conditions clearly state limitations
- Covers all major categories

**Minimum Per Jurisdiction:**
- 15 rights (absolute minimum)
- 20+ rights (preferred)
- Multiple categories represented
- Practical request tips included

---

## Workflow for 21 Remaining States

### For Each Jurisdiction:

1. **Query database for statute text**
```sql
SELECT full_text, statute_citation
FROM statute_texts
WHERE jurisdiction_id = 'oklahoma';
```

2. **Read entire statute carefully**
   - Look for "shall", "must", "has right to"
   - Identify every distinct affirmative right
   - Note exact section citations

3. **Create JSON file**
   - Use California format as template
   - Aim for 15-25 rights
   - Include all required fields
   - Add implementation notes and request tips

4. **Save and import**
```bash
# Save to: data/jurisdictions/states/oklahoma/rights.json
node scripts/import-rights-to-neon.js [file]
```

5. **Verify in database**
```sql
SELECT COUNT(*) FROM rights_of_access WHERE jurisdiction_id = 'oklahoma';
```

---

## Priority Order (Backwards Alphabetically)

### Tier 3 - Smaller States (9 states - extract first)
1. Oklahoma → 2. North Dakota → 3. New Mexico → 4. New Hampshire → 5. Nebraska → 6. Montana → 7. Mississippi → 8. Maine → 9. Idaho

### Tier 2 - Medium States (4 states)
10. Nevada → 11. Kentucky → 12. Kansas → 13. Iowa

### Tier 1 - Major States (8 states - extract last, most important)
14. Pennsylvania → 15. Ohio → 16. New Jersey → 17. Missouri → 18. Minnesota → 19. Michigan → 20. Maryland → 21. Indiana

---

## Success Criteria

**For each jurisdiction:**
- [ ] Retrieved statute text from database
- [ ] Read entire statute for affirmative rights
- [ ] Extracted 15+ distinct rights
- [ ] Categorized correctly
- [ ] Added implementation notes
- [ ] Added request tips/assertion language
- [ ] Verified against California quality standard
- [ ] Imported to Neon database
- [ ] Verified in database with SQL query

**For completion (v0.12 promotion):**
- [ ] All 52 jurisdictions in database
- [ ] Average 20+ rights per jurisdiction
- [ ] All rights have detailed descriptions
- [ ] All rights have request tips
- [ ] Quality matches California baseline

---

**Process:** Extract from `statute_texts` table → Create JSON → Import to `rights_of_access` table
**Timeline:** 21 states × 2-3 hours each = 7-11 business days
**Next:** Start with Oklahoma statute extraction
