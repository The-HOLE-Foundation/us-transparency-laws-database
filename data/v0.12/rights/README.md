# Rights of Access JSON Files

This directory contains Rights of Access data for all 52 US jurisdictions (Federal + 50 States + DC).

## Current Status (2025-10-07)

### Verified & Imported to Database (8 jurisdictions) ✅

These files have been verified against official government sources and imported to the Neon database:

- `arkansas-rights.json` (15 rights)
- `california-rights.json` (25 rights)
- `federal-rights.json` (15 rights)
- `florida-rights.json` (20 rights)
- `georgia-rights.json` (17 rights)
- `new-york-rights.json` (20 rights)
- `texas-rights.json` (20 rights)
- `washington-rights.json` (20 rights)

**Total: 172 verified rights in database**

### Template Files - Pending Verification (44 jurisdictions) ⚠️

These files are **UNVERIFIED TEMPLATES** with generic citations that must be verified before import:

- `alabama-rights.json`
- `alaska-rights.json`
- `arizona-rights.json`
- `colorado-rights.json`
- `connecticut-rights.json`
- `delaware-rights.json`
- `district_of_columbia-rights.json`
- `hawaii-rights.json`
- `idaho-rights.json`
- `illinois-rights.json`
- `indiana-rights.json`
- `iowa-rights.json`
- `kansas-rights.json`
- `kentucky-rights.json`
- `louisiana-rights.json`
- `maine-rights.json`
- `maryland-rights.json`
- `massachusetts-rights.json`
- `michigan-rights.json`
- `minnesota-rights.json`
- `mississippi-rights.json`
- `missouri-rights.json`
- `montana-rights.json`
- `nebraska-rights.json`
- `nevada-rights.json`
- `new_hampshire-rights.json`
- `new_jersey-rights.json`
- `new_mexico-rights.json`
- `north_carolina-rights.json`
- `north_dakota-rights.json`
- `ohio-rights.json`
- `oklahoma-rights.json`
- `oregon-rights.json`
- `pennsylvania-rights.json`
- `rhode_island-rights.json`
- `south_carolina-rights.json`
- `south_dakota-rights.json`
- `tennessee-rights.json`
- `utah-rights.json`
- `vermont-rights.json`
- `virginia-rights.json`
- `west_virginia-rights.json`
- `wisconsin-rights.json`
- `wyoming-rights.json`

**Each template contains 15 standardized rights (660 total template rights)**

## File Structure

Each JSON file follows this structure:

```json
{
  "jurisdiction": {
    "slug": "state_name",
    "name": "State Name"
  },
  "rights_of_access": [
    {
      "category": "Proactive Disclosure | Technology Rights | Enhanced Access Rights | etc.",
      "subcategory": "Specific right type",
      "statute_citation": "State Code § X.XX",
      "description": "Detailed explanation of the right",
      "conditions": "Circumstances under which right applies",
      "applies_to": "Who can exercise this right",
      "implementation_notes": "Practical guidance for using this right",
      "request_tips": "Language to include in FOIA requests"
    }
  ],
  "validation_metadata": {
    "parsed_date": "YYYY-MM-DD",
    "source_url": "Official .gov source URL",
    "source_verified": true/false,
    "primary_sources": ["List of official sources consulted"],
    "verification_notes": "Details about verification process",
    "rights_count": 15,
    "categories_covered": ["List of right categories"],
    "requires_verification": true/false,
    "verification_status": "verified | UNVERIFIED TEMPLATE"
  }
}
```

## Template Rights Categories

### 15 Core Rights (in templates)

1. **Proactive Disclosure**
   - Presumption of Openness
   - Public Records Officer

2. **Timeliness Rights**
   - Response Deadline
   - Timeline Requirements

3. **Fee Waiver**
   - Fee Limitations
   - Fee Waiver Criteria

4. **Technology Rights**
   - Electronic Format
   - Database Access

5. **Inspection Rights**
   - In-Person Inspection

6. **Enhanced Access Rights**
   - Segregability Requirement
   - Written Denial with Justification
   - Proper Redaction Standards

7. **Appeal Rights**
   - Administrative Appeal
   - Attorney Fee Recovery
   - Judicial Enforcement

8. **Requester-Specific Rights**
   - No ID/Purpose Requirement
   - No Residency Requirement

## Verification Requirements

### ⚠️ CRITICAL: Templates Must Be Verified

Before importing template files to the database:

1. **Verify Statutory Citations**: Replace generic § numbers with actual state code citations
2. **Confirm Rights Exist**: Verify all 15 rights actually exist in state law
3. **Update Descriptions**: Match exact statutory language
4. **Add State-Specific Rights**: Include unique rights not in template
5. **Remove Non-Applicable Rights**: Delete any that don't exist in that state
6. **Update Metadata**: Set `source_verified: true` and document sources
7. **Document Sources**: List official .gov sources consulted

### Acceptable Sources

**ONLY use official .gov sources:**
- State legislature websites (e.g., leginfo.legislature.ca.gov)
- Official state code databases (e.g., revisor.mn.gov)
- State attorney general FOIA guidance
- State archives/records offices

**NEVER use:**
- Perplexity AI or any AI summaries
- Wikipedia or collaborative wikis
- Legal blogs or commentary
- Third-party law firm summaries
- News articles

## Import Process

After verification, import to Neon database:

```bash
node dev/scripts/import-rights-neon.js data/v0.12/rights/{jurisdiction-slug}-rights.json
```

Example:
```bash
node dev/scripts/import-rights-neon.js data/v0.12/rights/alabama-rights.json
```

## Documentation

- [Rights Template Generation Report](../../documentation/v0.12-RIGHTS_TEMPLATE_GENERATION.md)
- [Rights Generation Summary](../../documentation/v0.12-RIGHTS_GENERATION_SUMMARY.md)
- [Rights of Access Design](../../documentation/v0.12-RIGHTS_OF_ACCESS_DESIGN.md)
- [v0.12 Completion Status](../../documentation/v0.12-COMPLETION_STATUS.md)

## Questions?

For verification guidance:
1. Review verified jurisdictions (federal-rights.json, california-rights.json)
2. Consult official state code websites
3. Reference state AG FOIA guidance
4. Compare similar states

---

**Generated**: 2025-10-07  
**Status**: 8 verified, 44 pending verification  
**Total**: 52 jurisdictions
