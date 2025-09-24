# State Transparency Law Validation Methodology

## Critical Accuracy Requirements
This database serves as ground truth for AI training - 100% accuracy is mandatory. NO third-party sources like Perplexity, Wikipedia, or legal summary sites can be trusted.

## Primary Source Validation Rules

### ONLY ACCEPTABLE SOURCES:
1. **Official State Legislature Websites** (e.g., legis.state.xx.us)
2. **Official State Code/Statute Databases** (e.g., revisor.mn.gov, codes.ohio.gov)
3. **Official State Attorney General Offices** (for FOIA guidance)
4. **Official State Archives/Records Offices** (for procedural guidance)
5. **Official Agency FOIA Pages** (.gov domains only)

### PROHIBITED SOURCES:
- Perplexity AI or any AI summarization
- Wikipedia or collaborative wikis
- Legal blog posts or commentary
- Third-party law firm summaries
- Commercial legal databases (unless official state partnership)
- News articles or media summaries

## Validation Steps for Each State

### Step 1: Statute Identification
- [ ] Find official state legislature website
- [ ] Locate current statutory code
- [ ] Identify exact citation for transparency/FOIA law
- [ ] Verify statute is current (not repealed/superseded)
- [ ] Document official URL to statute text

### Step 2: Response Time Verification
- [ ] Extract exact language from statute about timeframes
- [ ] Note business days vs calendar days
- [ ] Identify any extension provisions
- [ ] Check for recent amendments affecting timing
- [ ] Cross-reference with official agency guidance

### Step 3: Appeal Process Verification
- [ ] Identify statutory appeal mechanism
- [ ] Verify appeal timeframes and procedures
- [ ] Determine if administrative exhaustion required
- [ ] Identify court jurisdiction for judicial review
- [ ] Check for special appeal bodies (ombudsman, etc.)

### Step 4: Fee Structure Verification
- [ ] Extract exact fee language from statute
- [ ] Identify any fee schedules or caps
- [ ] Check for waiver provisions
- [ ] Verify electronic vs paper fee differences
- [ ] Note any search time charges

### Step 5: Exemption Verification
- [ ] List all statutory exemptions with exact citations
- [ ] Check for privacy exemptions
- [ ] Identify law enforcement exemptions
- [ ] Note deliberative process protections
- [ ] Verify commercial information protections

### Step 6: Official Resources Verification
- [ ] Test all URLs for accessibility
- [ ] Verify government domain (.gov, .state.xx.us, etc.)
- [ ] Check for official FOIA forms or portals
- [ ] Identify oversight bodies
- [ ] Confirm contact information current

## Documentation Requirements

For each state, document:
1. **Primary Sources Consulted** (exact URLs)
2. **Statute Citations Verified** (specific sections)
3. **Cross-References Checked** (agency guidance, court rules)
4. **Verification Date** (when sources were accessed)
5. **Any Discrepancies Found** (conflicting information)
6. **Confidence Level** (high/medium/low with justification)

## Quality Control Checkpoints

### Red Flags Requiring Re-verification:
- Information that seems "too convenient" or overly simplified
- Identical language across multiple states (copy-paste errors)
- Missing or vague fee information
- Unrealistic response times (too fast or too slow)
- Circular references in sources

### Cross-State Consistency Checks:
- Similar states should have similar approaches
- Unusual provisions require extra documentation
- Fee structures should align with state's general approach
- Appeal processes should match state's administrative law structure

## Error Documentation

When errors are found:
1. Document the incorrect information
2. Identify the source of the error
3. Provide correct information with new source
4. Update validation confidence rating
5. Flag for systematic review of similar errors

## Validation Confidence Levels

**HIGH**: Multiple official sources confirm identical information
**MEDIUM**: Single official source with supporting evidence
**LOW**: Limited sources or conflicting information found
**UNVERIFIED**: Insufficient official sources to confirm

## Audit Trail Requirements

Each state entry must include:
```json
"validation_audit": {
  "primary_sources": ["URL1", "URL2", "URL3"],
  "statute_sections_verified": ["Section X", "Section Y"],
  "verification_date": "YYYY-MM-DD",
  "validator_notes": "Specific verification steps taken",
  "confidence_level": "high|medium|low",
  "known_issues": ["Any limitations or concerns"],
  "last_statutory_update": "Date if known"
}
```