# Statutory Validation Checklist

## Overview
This checklist ensures 100% accuracy for statutory transparency law data used as AI training ground truth. **NO exceptions to this process are permitted.**

## Pre-Validation Requirements

### ✅ Source Requirements
- [ ] Official state legislature website (.gov domain)
- [ ] Current statutory database (not archived versions)
- [ ] Direct access to statute text (not summaries)
- [ ] Recent update verification capability

### ❌ Prohibited Sources
- [ ] Perplexity AI or any AI summarization tools
- [ ] Wikipedia or collaborative wikis  
- [ ] Legal blog posts or commentary
- [ ] Third-party law firm summaries
- [ ] Commercial legal databases (unless official state partnership)
- [ ] News articles or media summaries

## Step-by-Step Validation Process

### Step 1: Official Statute Access
1. **Identify Official Website**
   - [ ] Locate state legislature website (format: `legislature.[state].gov` or `[state].gov/legislature`)
   - [ ] Verify .gov domain authenticity
   - [ ] Access current statutory compilation

2. **Download/Access Statute Text**
   - [ ] Find transparency/FOIA law by official name
   - [ ] Access complete current text (not excerpts)
   - [ ] Note exact statutory citation
   - [ ] Verify currency date of compilation

3. **Extract Key Information**
   - [ ] Response timeframes (initial and maximum)
   - [ ] Extension provisions and conditions
   - [ ] Appeal procedures and deadlines
   - [ ] Fee structures and waiver criteria
   - [ ] Exemption categories
   - [ ] Official oversight bodies

### Step 2: Recent Legislative Cross-Reference

1. **Search Recent Legislative Activity**
   - [ ] Use official law name (e.g., "Texas Public Information Act")
   - [ ] Search timeframe: 2023-2025
   - [ ] Look for HB (House Bills) and SB (Senate Bills)
   - [ ] Check for Public Acts or Session Laws

2. **Identify Amendments**
   - [ ] Bill numbers and effective dates
   - [ ] Nature of changes (procedural vs. substantive)
   - [ ] Impact on core response timeframes
   - [ ] Status (enacted, pending, failed)

3. **Cross-Reference Consistency**
   - [ ] Verify statute text matches recent amendments
   - [ ] Identify any discrepancies
   - [ ] Note pending changes with effective dates
   - [ ] Document any conflicts or unclear provisions

### Step 3: Documentation Requirements

1. **Primary Sources Documentation**
   - [ ] Exact URL of official statute
   - [ ] Statutory section numbers verified
   - [ ] Official website contact verification
   - [ ] Download/access date recorded

2. **Legislative Update Documentation**
   - [ ] Bill numbers and years
   - [ ] Official legislative website URLs
   - [ ] Amendment effective dates
   - [ ] Current vs. pending law status

3. **Validation Confidence Assessment**
   - [ ] **HIGH**: Multiple official sources confirm
   - [ ] **MEDIUM**: Single official source with supporting evidence  
   - [ ] **LOW**: Limited sources or conflicts found
   - [ ] **CRITICAL PENDING**: Major changes identified

## Quality Control Checkpoints

### Red Flags Requiring Re-verification
- [ ] Information seems "too convenient" or simplified
- [ ] Identical language across multiple states (copy-paste errors)
- [ ] Missing or vague fee information
- [ ] Unrealistic response times (too fast/slow)
- [ ] Circular references in sources
- [ ] Recent amendments not reflected in current law

### Cross-State Consistency Checks  
- [ ] Similar states have similar approaches
- [ ] Unusual provisions have extra documentation
- [ ] Fee structures align with state's general approach
- [ ] Appeal processes match state's administrative law

## Documentation Template

```json
{
  "validation_metadata": {
    "verification_date": "YYYY-MM-DD",
    "source_verified": true,
    "primary_sources": [
      "Exact URL 1",
      "Exact URL 2"
    ],
    "recent_legislative_updates": [
      "Bill Number (Year): Description - STATUS"
    ],
    "verification_notes": "Key findings and critical issues",
    "confidence_level": "high|medium|low",
    "critical_pending_changes": {
      "bill": "Bill number if applicable", 
      "status": "Current status",
      "effective_date": "When changes take effect",
      "impact": "Description of impact"
    }
  }
}
```

## Error Handling

### When Errors Are Found
1. **Document Incorrect Information**
   - [ ] Record what was wrong
   - [ ] Identify source of error
   - [ ] Note impact on database accuracy

2. **Provide Corrected Information**
   - [ ] Official source URL for correction
   - [ ] Exact corrected language
   - [ ] Effective date of correct information

3. **Update Confidence Rating**
   - [ ] Lower confidence if multiple errors found
   - [ ] Flag for systematic review
   - [ ] Document lessons learned

## Final Validation Requirements

### Before Marking as "Validated"
- [ ] Official statute accessed and verified
- [ ] Recent legislative updates cross-referenced
- [ ] No conflicts between sources found
- [ ] All documentation complete
- [ ] Confidence level assigned
- [ ] Critical pending changes noted

### Special Attention Required For
- [ ] **New York**: Major pending changes (S2520A)
- [ ] States with very recent amendments
- [ ] States with unusual response time standards
- [ ] States with pending comprehensive reforms

## Maintenance Schedule

### Regular Reviews Required
- [ ] **Quarterly**: Check for new legislative activity
- [ ] **Annually**: Full re-validation of all entries
- [ ] **Ad-hoc**: When major legislation identified
- [ ] **Pre-deployment**: Before any AI training use

---

**CRITICAL REMINDER**: This database serves as ground truth for AI training. 100% accuracy is non-negotiable. When in doubt, mark confidence as "low" and flag for additional review.