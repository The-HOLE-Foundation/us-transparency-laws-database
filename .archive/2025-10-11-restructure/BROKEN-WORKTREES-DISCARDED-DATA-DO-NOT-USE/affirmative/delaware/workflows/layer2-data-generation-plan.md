---
DATE: 2025-10-02
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Layer 2 Data Generation Strategy
VERSION: v0.12 (planned)
---

# Layer 2 Data Generation Strategy

## Overview

**Goal**: Populate Layer 2 (Structured Jurisdiction Data) for all 51 jurisdictions using AI-assisted automation

**Scope**:
- Structured law metadata (~800 data points)
- Agency contact databases (~5,000 agency records)
- Request templates (~500-1,000 examples)

**Timeline**: 6-12 months (with automation)

---

## Three-Phase Automated Approach

### Phase 1: Statutory Text → Structured Metadata
**Input**: Layer 1 statutory text files (already complete)
**Output**: Structured JSON with parsed law details
**Agent**: `code-development-expert`

### Phase 2: Web Scraping → Agency Databases
**Input**: Official state government websites
**Output**: Agency contact information
**Agent**: `python-autocoder`

### Phase 3: Template Generation → Training Examples
**Input**: Federal FOIA examples + state-specific laws
**Output**: Jurisdiction-specific request templates
**Agent**: `code-development-expert` + OpenAI fine-tuning

---

## Agent Task Breakdown

### Task 1: Statutory Parser Agent
**File**: `workflows/parse-statutory-text-to-json.md`

**Objective**: Parse all 51 statutory text files into structured JSON

**Input**: `consolidated-transparency-data/statutory-text-files/*.txt`

**Output**: `data/states/{state}/agencies.json` (transparency_law section populated)

**Automation Level**: 85% (AI-assisted, requires human verification)

**Agent Configuration**:
- Type: `code-development-expert`
- Tools: Python, OpenAI GPT-4, JSON schema validation
- Iterations: One jurisdiction at a time with checkpoints

**Key Challenges**:
- Response time variations (business days vs calendar days)
- Fee structures (complex statutory language)
- Exemption categories (requires legal interpretation)

**Success Criteria**:
- All 51 jurisdictions have populated `transparency_law` objects
- 100% schema compliance
- Human verification on 20% sample

---

### Task 2: Agency Database Collector Agent
**File**: `workflows/scrape-agency-contacts.md`

**Objective**: Collect agency contact information from official .gov sites

**Input**: State government official directories

**Output**: `data/states/{state}/agencies.json` (agencies array populated)

**Automation Level**: 70% (web scraping + manual verification)

**Agent Configuration**:
- Type: `python-autocoder`
- Tools: Selenium, BeautifulSoup, CSV export
- Iterations: State-by-state with validation checkpoints

**Key Challenges**:
- Website structure variations across states
- Contact information formats
- Email verification (avoid bounces)
- FOIA officer identification

**Success Criteria**:
- 50-200 agencies per state documented
- All contact info verified (email deliverability tested)
- FOIA submission methods documented

---

### Task 3: Template Generator Agent
**File**: `workflows/generate-foia-templates.md`

**Objective**: Create jurisdiction-specific FOIA request templates

**Input**: Federal FOIA examples + state statutory language

**Output**: Training examples for v0.12 AI Foundry fine-tuning

**Automation Level**: 75% (GPT-4 generation + legal review)

**Agent Configuration**:
- Type: `code-development-expert`
- Tools: OpenAI GPT-4, Template validation
- Iterations: Category-by-category (police, health, education, etc.)

**Key Challenges**:
- Jurisdiction-specific legal language
- Exemption avoidance strategies
- Success optimization

**Success Criteria**:
- 10-20 templates per jurisdiction
- Legal compliance verified
- Real-world testing (optional)

---

## Parallel vs Sequential Execution

### Recommended: **Parallel Execution**

**Rationale**: Tasks 1-3 are independent and can run simultaneously

**Parallel Strategy**:
```
Week 1-4: Launch all three agent tasks for Federal + Priority 1 states (6 jurisdictions)
  - Task 1 (Parsing): Federal, CA, FL, IL, NY, TX
  - Task 2 (Agencies): Federal, CA, FL, IL, NY, TX
  - Task 3 (Templates): Federal, CA, FL, IL, NY, TX

Week 5-8: Process next batch (Priority 2 states: 15 jurisdictions)
Week 9-16: Remaining states (30 jurisdictions)
Week 17-20: Validation, quality checks, corrections
```

**Benefits**:
- Faster completion (6-8 months vs 12+ months)
- Early deliverables for v0.12-alpha release
- Parallel learning (improvements apply to all tasks)

---

## Agent Task Specifications

### General Agent Instructions

**All agents should**:
1. Work on ONE jurisdiction at a time
2. Create checkpoint commits after each jurisdiction
3. Validate output against JSON schema
4. Document any edge cases or uncertainties
5. Flag items requiring human review

**Quality Standards**:
- 100% accuracy on legal citations
- All sources must be official .gov sites
- Response times must specify business/calendar days
- Contact information must be current (within 6 months)

---

## Automation Tools & Scripts

### Tool 1: Statutory Text Parser
**File**: `scripts/parse_statute_to_json.py`

**Functionality**:
- Load statutory text file
- Use GPT-4 to extract structured fields
- Validate against JSON schema
- Output to `data/states/{state}/agencies.json`

**Usage**:
```bash
python3 scripts/parse_statute_to_json.py --state maine --validate
```

### Tool 2: Agency Scraper
**File**: `scripts/scrape_state_agencies.py`

**Functionality**:
- Crawl official state government directories
- Extract agency names, FOIA contacts, emails, addresses
- Validate email deliverability
- Output to CSV → JSON conversion

**Usage**:
```bash
python3 scripts/scrape_state_agencies.py --state maine --verify-emails
```

### Tool 3: Template Generator
**File**: `scripts/generate_foia_templates.py`

**Functionality**:
- Load state statutory language
- Use GPT-4 to generate jurisdiction-specific templates
- Validate legal compliance
- Output training examples JSON

**Usage**:
```bash
python3 scripts/generate_foia_templates.py --state maine --category police
```

---

## Human Verification Workflow

### Sampling Strategy
- **Phase 1 (Parsing)**: 20% random sample per batch
- **Phase 2 (Agencies)**: 10% random sample + all flagged items
- **Phase 3 (Templates)**: 100% legal review for first 3 jurisdictions, then 30% sample

### Verification Checklist

**Statutory Metadata**:
- [ ] Response times match statute text
- [ ] Fee structures quote exact statutory language
- [ ] Exemptions cite correct statute sections
- [ ] Appeal process accurately described

**Agency Contacts**:
- [ ] Agency name matches official directory
- [ ] Email address tested (deliverable)
- [ ] Phone number format validated
- [ ] FOIA officer name verified (if available)

**Templates**:
- [ ] Legal language matches jurisdiction statute
- [ ] No prohibited exemption triggers
- [ ] Professional tone and formatting
- [ ] Success optimization strategies included

---

## Priority Sequencing

### Batch 1: Federal + Priority 1 (6 jurisdictions)
**Target**: Weeks 1-4
- Federal FOIA
- California
- Florida
- Illinois
- New York
- Texas

**Rationale**: High population coverage (~40% of US), diverse legal frameworks

### Batch 2: Priority 2 (15 jurisdictions)
**Target**: Weeks 5-8
- Georgia, Massachusetts, Michigan, New Jersey, North Carolina
- Ohio, Pennsylvania, Virginia, Washington, Arizona
- Colorado, Indiana, Maryland, Minnesota, Wisconsin

**Rationale**: Major metros, additional ~30% population coverage

### Batch 3: Remaining States (30 jurisdictions)
**Target**: Weeks 9-16
- All other states + DC

**Rationale**: Complete national coverage

### Batch 4: Validation & Corrections (Quality Assurance)
**Target**: Weeks 17-20
- Human review of flagged items
- Corrections and re-validation
- Final schema compliance checks
- Preparation for v0.12 release

---

## Success Metrics

### Quantitative
- [ ] 51/51 jurisdictions have complete Layer 2 data
- [ ] 100% JSON schema compliance
- [ ] 95%+ accuracy on statutory metadata (verified sample)
- [ ] 90%+ email deliverability for agency contacts
- [ ] 500+ training templates generated

### Qualitative
- [ ] Legal accuracy verified by domain expert
- [ ] No conflicting information across layers
- [ ] Templates demonstrate jurisdiction-specific optimization
- [ ] Data ready for v0.12 platform integration

---

## Risk Mitigation

### Risk 1: AI Hallucinations (Statutory Parsing)
**Mitigation**:
- Cross-reference all outputs with original statute text
- Flag uncertain extractions for human review
- Use confidence scores (high/medium/low)

### Risk 2: Website Changes (Agency Scraping)
**Mitigation**:
- Version control scraping scripts
- Document website structure changes
- Implement retry logic and alerts

### Risk 3: Legal Compliance (Template Generation)
**Mitigation**:
- Legal review on sample (first 3 jurisdictions)
- Conservative language (avoid aggressive tactics)
- Disclaimer about professional legal advice

---

## Deliverables Timeline

**Month 1-2**: Federal + Priority 1 states complete
- Early release: v0.12-alpha (6 jurisdictions)

**Month 3-4**: Priority 2 states complete
- Mid release: v0.12-beta (21 jurisdictions)

**Month 5-6**: Remaining states complete
- Final validation in progress

**Month 7-8**: Quality assurance, corrections
- Production release: v0.12-stable (51 jurisdictions)

---

## Next Steps

1. **Create agent task files** (3 workflow markdown files)
2. **Develop automation scripts** (3 Python scripts)
3. **Set up validation infrastructure** (JSON schemas, test suite)
4. **Launch Batch 1 agents** (Federal + Priority 1)
5. **Monitor progress and iterate**

**Ready to launch agents?** Review this plan and approve to proceed with agent task creation.
