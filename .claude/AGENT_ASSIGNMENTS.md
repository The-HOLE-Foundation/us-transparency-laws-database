---
DATE: 2025-10-08
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Agent Assignment Instructions for v0.12 Affirmative Rights Collection
VERSION: v0.12
---

# Agent Assignment Instructions

## Mission

Collect **affirmative rights of access** from transparency law statutes for your assigned jurisdiction. These rights will power the FOIA Generator tool to help citizens assert specific statutory rights in their requests.

## Your Assignment

**Jurisdiction:** [TO BE ASSIGNED]
**Worktree:** `worktrees/affirmative/[jurisdiction]`
**Branch:** `verification/[jurisdiction]-affirmative`
**Output File:** `data/v0.12/rights/[jurisdiction]-rights.json`

## What Are "Affirmative Rights"?

Affirmative rights are **specific statutory provisions that give requesters explicit rights** beyond just "you can request records." Examples:

✅ **Good Examples:**
- Right to inspect records in person before paying for copies
- Right to receive records in specific formats (CSV, PDF, etc.)
- Right to expedited processing in certain circumstances
- Statutory requirement for agencies to proactively post certain records online
- Right to appeal denials to an oversight body
- Protection from retaliation for making requests

❌ **Not Affirmative Rights:**
- General exemptions (these are restrictions, not rights)
- Agency obligations that don't give requesters specific rights
- Fee structures (unless there's a right to fee waivers)
- General "you can request records" statements

## Categories to Collect

Organize rights into these categories:

### 1. Proactive Disclosure
Rights related to records that must be posted online or made available without request:
- Budget documents
- Meeting minutes
- Contracts
- Salaries
- Campaign finance

### 2. Enhanced Access Rights
Rights that go beyond basic request-and-receive:
- Right to inspect before copying
- Right to electronic delivery
- Right to specific formats
- Right to fastest method of delivery
- Right to receive indexes or catalogs

### 3. Technology Rights
Rights specific to electronic records:
- Right to database queries
- Right to receive metadata
- Right to CSV/structured formats
- Right to automated systems access
- Protection from format manipulation

### 4. Requester-Specific Rights
Special rights for certain types of requesters:
- Media access rights
- Researcher access rights
- Non-profit access rights
- Fee waiver rights for certain requesters

### 5. Inspection Rights
Rights to physically inspect or review records:
- Right to view before copying
- Right to take notes/photos
- Right to inspect at agency location
- Right to reasonable access times

### 6. Timeliness Rights
Rights related to response deadlines:
- Right to expedited processing
- Right to interim responses
- Right to specific deadlines
- Penalties for agency delays

## Your Workflow

### Step 1: Navigate to Your Worktree

```bash
cd worktrees/affirmative/[jurisdiction]
```

Verify you're on the right branch:
```bash
git branch --show-current
# Should show: verification/[jurisdiction]-affirmative
```

### Step 2: Find Official Statute

**ONLY use official government sources:**

1. Go to the state legislature website (e.g., `legis.state.[xx].us`)
2. Search for the transparency law by official name (see `templates/json/tracking.json` for statute names)
3. Read the FULL statute text (not summaries!)
4. Look for sections that grant specific rights to requesters

**Official Source Examples:**
- Federal: https://www.govinfo.gov/content/pkg/USCODE-2021-title5/html/USCODE-2021-title5-partI-chap5-subchapII-sec552.htm
- California: https://leginfo.legislature.ca.gov/faces/codes.xhtml
- Texas: https://statutes.capitol.texas.gov/
- Illinois: https://www.ilga.gov/legislation/ilcs/ilcs.asp

### Step 3: Extract Affirmative Rights

For each right you find:

**Required Information:**
- **Category:** Which of the 6 categories above?
- **Subcategory:** More specific classification (e.g., "Electronic Format Rights")
- **Statute Citation:** Exact section (e.g., "5 U.S.C. § 552(a)(3)(B)")
- **Description:** Clear, accurate description using statutory language
- **Conditions:** Any conditions or limitations on the right
- **Applies To:** Who can invoke this right (all requesters, media only, etc.)
- **Implementation Notes:** How to assert this right in a request
- **Request Tips:** Practical advice for invoking the right

**Example:**
```json
{
  "category": "Enhanced Access Rights",
  "subcategory": "Format Selection",
  "statute_citation": "5 U.S.C. § 552(a)(3)(B)",
  "description": "Requester may specify the format in which they wish to receive records, and agency must provide records in that format if readily reproducible.",
  "conditions": "Format must be readily reproducible by the agency",
  "applies_to": "All requesters",
  "implementation_notes": "State preferred format in initial request. Common formats: PDF, CSV, native electronic format.",
  "request_tips": "Request 'native electronic format' for databases and spreadsheets to preserve full functionality."
}
```

### Step 4: Create the Output File

Create: `data/v0.12/rights/[jurisdiction]-rights.json`

**Use this structure:**
```json
{
  "jurisdiction": "[Jurisdiction Name]",
  "jurisdiction_slug": "[jurisdiction-slug]",
  "transparency_law_name": "[Official Statute Name]",
  "primary_statute_citation": "[Main Citation]",
  "last_updated": "2025-10-08",
  "verified_by": "Claude Code AI Assistant",
  "data_model_version": "v0.12",

  "official_sources": [
    {
      "type": "statute",
      "url": "[Official .gov URL]",
      "title": "[Statute Title]",
      "accessed_date": "2025-10-08"
    }
  ],

  "rights_of_access": [
    {
      "category": "Enhanced Access Rights",
      "subcategory": "Format Selection",
      "statute_citation": "...",
      "description": "...",
      "conditions": "...",
      "applies_to": "...",
      "implementation_notes": "...",
      "request_tips": "..."
    }
    // ... more rights ...
  ],

  "validation_metadata": {
    "sources_verified": true,
    "citations_checked": true,
    "last_verification_date": "2025-10-08",
    "verification_notes": "All citations verified from official statute text"
  }
}
```

### Step 5: Commit Your Work

```bash
git add data/v0.12/rights/[jurisdiction]-rights.json
git commit -m "feat(v0.12): Add [jurisdiction] affirmative rights

- Collected [X] rights of access from official statute
- Categories: [list categories found]
- All citations verified from [official source URL]

🤖 Generated with Claude Code (https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 6: Signal Completion

Message: "I've completed [jurisdiction] affirmative rights data collection. Ready for review."

## Quality Standards (CRITICAL)

### ✅ DO:
- Use ONLY official .gov sources
- Quote statutory language exactly
- Provide complete citations
- Test that URLs work
- Focus on rights that help requesters
- Include practical implementation guidance

### ❌ DON'T:
- Use AI summaries or Perplexity
- Use Wikipedia or legal blogs
- Paraphrase statutory language (quote it!)
- Include exemptions (those are restrictions, not rights)
- Include general agency obligations (only include if they give requesters specific rights)
- Guess at citations or URLs

## Common Rights to Look For

**Proactive Disclosure:**
- Budgets must be posted online
- Meeting minutes must be available
- Salary databases must be public
- Contracts over $X must be posted

**Format Rights:**
- Right to specify format
- Right to electronic delivery
- Right to database queries
- Right to structured data

**Inspection Rights:**
- Right to view before paying
- Right to take notes
- Right to photograph records
- Right to reasonable access times

**Speed Rights:**
- Right to expedited processing
- Statutory deadlines
- Penalties for delays
- Right to interim responses

**Appeal Rights:**
- Right to administrative appeal
- Right to judicial review
- Right to attorney fees if prevail
- Right to oversight body review

**Protection Rights:**
- Protection from retaliation
- Protection from identity disclosure
- Protection from purpose discrimination
- Protection from excessive fees

## If You Get Stuck

**Can't find the statute?**
- Check `templates/json/tracking.json` for official statute name
- Search state legislature website by statute name
- Look for "Open Records", "FOIA", "Public Records", "Sunshine Law"

**Not sure if something is an affirmative right?**
- Ask: "Does this give requesters a specific action they can take?"
- Ask: "Can this be asserted in a FOIA request?"
- If yes → it's probably an affirmative right
- If no → skip it

**Statute is really long?**
- Focus on sections about "rights of access", "requester rights", "procedures"
- Skip exemptions sections (we already collected those in v0.11)
- Skip agency obligations unless they create requester rights

**Need an example?**
- Look at `data/v0.12/rights/federal-rights.json` (when available)
- Look at completed jurisdictions for patterns

## Inspector Review Process

After you signal completion:

1. **Inspector reviews your work** in your worktree
2. **If corrections needed:** Inspector tells you what to fix
3. **Make corrections** in same worktree, commit again
4. **Signal ready for re-review**
5. **If approved:** Inspector merges to main, you're done!

## Keep Your Worktree

**DO NOT delete your worktree** after merge! It will be kept for:
- Future statute amendments
- Annual review cycles
- Updates to existing rights
- New rights added by legislature

## Questions?

If you need clarification on:
- Whether something is an affirmative right
- How to categorize a right
- How to cite something unusual
- Anything else

Just ask! Better to ask than guess.

---

## Quick Checklist Before Signaling Completion

- [ ] Output file created at `data/v0.12/rights/[jurisdiction]-rights.json`
- [ ] All citations from official .gov sources
- [ ] All URLs tested and working
- [ ] Rights organized into correct categories
- [ ] Implementation notes included for each right
- [ ] Request tips included for practical use
- [ ] Validation metadata completed
- [ ] Changes committed to git
- [ ] Ready for inspector review

---

**Remember:** This database is ground truth for AI training. **100% accuracy is mandatory.** When in doubt, cite the statute exactly and let the inspector review.
