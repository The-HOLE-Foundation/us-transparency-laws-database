---
DATE: 2025-10-16
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Affirmative Rights Extraction Quality Checklist
VERSION: v0.12
---

# Affirmative Rights Extraction - Quality Checklist

Use this checklist for EVERY jurisdiction extraction to ensure completeness and quality.

## Pre-Extraction Setup

- [ ] Locate full statute text file: `data/jurisdictions/{state}/statute-full-text.txt`
- [ ] Review California example: `data/jurisdictions/states/california/rights.json` (25 rights)
- [ ] Open blank rights template
- [ ] Review the 8 categories of affirmative rights (see below)
- [ ] Confirm NO automation scripts will be used

## Reading Phase (Line-by-Line)

- [ ] Read statute from beginning to end (no skimming)
- [ ] Mark every provision establishing a RIGHT (not exemption)
- [ ] Note provisions establishing:
  - [ ] What citizens CAN access
  - [ ] HOW citizens can exercise access
  - [ ] WHEN access must be granted
  - [ ] WHO can request access
  - [ ] Protections FOR requesters
  - [ ] Limits ON agency denials/fees

## Category Coverage (Must Check All 8)

### 1. Proactive Disclosure
- [ ] Meeting agendas/minutes requirements
- [ ] Budget/expenditure disclosure
- [ ] Contract publication requirements
- [ ] Salary database provisions
- [ ] Reading room requirements
- [ ] Automatic disclosure triggers

### 2. Enhanced Access Rights
- [ ] Segregability (must provide non-exempt portions)
- [ ] Burden of proof on agency
- [ ] Journalist/media privileges
- [ ] Academic/researcher access
- [ ] Legislative oversight rights
- [ ] Special requester categories

### 3. Technology Rights
- [ ] Electronic format delivery
- [ ] Machine-readable data
- [ ] Metadata preservation
- [ ] Use of own equipment to copy
- [ ] No proprietary format barriers
- [ ] API/bulk data access
- [ ] Open data portal provisions

### 4. Requester-Specific Rights
- [ ] No ID required
- [ ] No purpose statement required
- [ ] No residency requirement
- [ ] Privacy protections for requester
- [ ] Anonymous request allowed
- [ ] Attorney representation allowed

### 5. Inspection Rights
- [ ] On-site inspection allowed
- [ ] Business hours access
- [ ] Adequate facilities (space, lighting)
- [ ] Photography/scanning permissions
- [ ] Copy-on-demand
- [ ] Supervision limitations

### 6. Timeliness Rights
- [ ] Statutory response deadline
- [ ] Calendar vs business days specified
- [ ] Immediate release for ready records
- [ ] Extension limits and justification
- [ ] Interim response requirements
- [ ] Deemed-granted (silence = approval)
- [ ] Expedited/emergency access
- [ ] Penalties for delays

### 7. Fee Waiver/Limits
- [ ] Maximum fee caps
- [ ] Fee waiver criteria
- [ ] Free inspection (no fees)
- [ ] Electronic format cost savings
- [ ] No search/review time charges
- [ ] Public interest waivers
- [ ] Advance fee estimate required
- [ ] Fee dispute resolution

### 8. Appeal Rights
- [ ] Written denial requirement
- [ ] Must cite specific exemption
- [ ] Attorney fee recovery
- [ ] Burden of proof on agency
- [ ] Ombudsman/mediator access
- [ ] Judicial review procedures
- [ ] Expedited appeal process

## Extraction Quality

For EACH right extracted:

- [ ] Has clear, actionable description (not just statute quote)
- [ ] Has exact statutory citation
- [ ] Explains WHAT can be accessed or HOW to exercise
- [ ] Specifies conditions (when it applies)
- [ ] Identifies who can use this right
- [ ] Includes implementation notes (how agencies comply)
- [ ] Has practical "request tip" showing how to assert

## Completeness Validation

- [ ] **Minimum 15 rights documented** (flag if fewer)
- [ ] **Target 20-30 rights** (compare to California's 25)
- [ ] All 8 categories represented (where applicable)
- [ ] No category has 0 rights (unless state truly has none)
- [ ] Compared to similar state for consistency
- [ ] Cross-checked related rights for completeness

## Documentation Quality

- [ ] Descriptions are clear and actionable
- [ ] No legal jargon without explanation
- [ ] Request tips are practical and specific
- [ ] Citations are exact and verifiable
- [ ] Conditions are clearly stated
- [ ] Implementation notes help requesters understand

## Source Verification

- [ ] All rights verified from official .gov sources
- [ ] Source URL documented in validation_metadata
- [ ] Verification date recorded
- [ ] Primary statute citation confirmed
- [ ] Cross-references checked
- [ ] Effective date verified

## Format Validation

- [ ] JSON structure is valid
- [ ] All required fields present
- [ ] jurisdiction.name is correct
- [ ] jurisdiction.slug matches directory name
- [ ] validation_metadata is complete
- [ ] No placeholder text remains
- [ ] File saved as: `data/jurisdictions/{state}/rights.json`

## Final Review

- [ ] Read through all rights as if you were a requester
- [ ] Could you actually USE these rights in a FOIA request?
- [ ] Are request tips specific enough to cite?
- [ ] Would FOIA Generator be able to assert these rights?
- [ ] Compared to California quality standard?
- [ ] Compared to similar jurisdiction for consistency?

## Red Flags (Re-extract if ANY apply)

- ⚠️ Fewer than 15 rights extracted
- ⚠️ All rights in only 1-2 categories
- ⚠️ Descriptions are just statute quotes
- ⚠️ No request tips provided
- ⚠️ Most rights are "may" (discretionary) not "shall" (mandatory)
- ⚠️ No technology rights (almost every state has some)
- ⚠️ No timeliness rights (almost every state has deadlines)
- ⚠️ Rights are vague or general
- ⚠️ Used any automation or scripts
- ⚠️ Didn't read full statute text

## Sign-Off

Jurisdiction: ___________________
Extracted by: ___________________
Date: ___________________
Rights count: ___________________
Categories covered: ___ / 8
Quality standard met: [ ] Yes [ ] No

**Extraction method**: [ ] Manual line-by-line review
**Compared to California**: [ ] Yes
**Ready for database import**: [ ] Yes [ ] No (needs revision)

---

## Quick Reference: 8 Categories

1. **Proactive Disclosure** - What agencies MUST publish without request
2. **Enhanced Access** - Special advantages/requirements for requesters
3. **Technology Rights** - Electronic/digital access provisions
4. **Requester-Specific** - Based on who is requesting
5. **Inspection Rights** - Physical access provisions
6. **Timeliness Rights** - Speed of response guarantees
7. **Fee Waiver/Limits** - Cost protections
8. **Appeal Rights** - Enforcement mechanisms

## Quality Targets

- **Minimum**: 15 rights
- **Target**: 20-30 rights
- **Gold Standard**: California (25 rights)
- **Method**: 100% manual extraction
- **Coverage**: All 8 categories (where applicable)
