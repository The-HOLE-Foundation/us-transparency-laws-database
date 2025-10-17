---
TASK: Parse Statutory Text to Structured JSON
AGENT: code-development-expert
PRIORITY: High (blocking v0.12)
ESTIMATED TIME: 14-22 hours per jurisdiction
---

# Task 1: Parse Statutory Text to Structured JSON

## Objective

Convert raw statutory text files (Layer 1) into structured JSON metadata (Layer 2) for all 51 jurisdictions.

## Input Files

**Source**: `consolidated-transparency-data/statutory-text-files/`
- 51 `.txt` files with full statute text
- All verified from official .gov sources
- Complete as of v0.11

**Example**: `consolidated-transparency-data/statutory-text-files/maine_transparency_law-v0.11.txt`

## Output Files

**Target**: `data/states/{state-name}/jurisdiction-data.json`

**Structure**:
```json
{
  "jurisdiction": "Maine",
  "transparency_law": {
    "name": "Freedom of Access Act",
    "statute_citation": "1 M.R.S. §§ 401-410",
    "effective_date": "1976-01-01",
    "last_amended": "2023-06-15",
    "response_requirements": {
      "initial_response_time": 5,
      "initial_response_unit": "business_days",
      "final_response_time": 30,
      "final_response_unit": "business_days",
      "extension_allowed": true,
      "extension_max_days": 10,
      "extension_justification_required": true
    },
    "fee_structure": {
      "search_fee": "actual cost",
      "search_fee_statutory_cite": "1 M.R.S. § 408-A",
      "copy_fee_per_page": 0.10,
      "copy_fee_cite": "1 M.R.S. § 408-A(1)",
      "electronic_fee": "none",
      "fee_waiver_available": true,
      "fee_waiver_criteria": "public interest",
      "fee_waiver_cite": "1 M.R.S. § 408-A(6)"
    },
    "exemptions": [
      {
        "category": "Personal Privacy",
        "citation": "1 M.R.S. § 402(3)(A)",
        "description": "Personnel and medical files",
        "scope": "narrow",
        "common_use_cases": "Employee records, health information"
      }
    ],
    "appeal_process": {
      "first_level": "Agency head review",
      "first_level_deadline_days": 5,
      "first_level_cite": "1 M.R.S. § 409(1)",
      "second_level": "Superior Court",
      "second_level_deadline_days": 30,
      "second_level_cite": "1 M.R.S. § 409(2)",
      "attorney_fees_recoverable": true,
      "attorney_fees_cite": "1 M.R.S. § 409(4)"
    },
    "validation_metadata": {
      "parsed_date": "2025-10-02",
      "parser_version": "1.0",
      "confidence_level": "high",
      "verification_method": "AI-assisted + human review",
      "source_url": "https://legislature.maine.gov/statutes/1/title1ch13sec0.html",
      "notes": ""
    }
  },
  "agencies": []
}
```

## JSON Schema Reference

**Schema File**: `templates/json/STANDARD_JURISDICTION_TEMPLATE_template-v0.11.json`

**Validation**:
- All fields must match schema types
- Required fields cannot be null
- Statutory citations must include section numbers
- Dates must be ISO 8601 format (YYYY-MM-DD)

## Parsing Instructions

### Step 1: Read Statutory Text File

```python
with open(f'consolidated-transparency-data/statutory-text-files/{jurisdiction}_transparency_law-v0.11.txt', 'r') as f:
    statute_text = f.read()
```

### Step 2: Extract Structured Data (AI-Assisted)

Use OpenAI GPT-4 with this prompt template:

```
You are a legal document parser. Extract the following information from this transparency law statute:

STATUTE TEXT:
{statute_text}

EXTRACT (in JSON format):
1. Law name and official statute citation
2. Effective date and last amendment date
3. Response time requirements:
   - Initial response deadline (distinguish business days vs calendar days)
   - Final response deadline
   - Extension provisions
4. Fee structure:
   - Search fees (quote exact statutory language)
   - Copy fees per page
   - Electronic document fees
   - Fee waiver availability and criteria
5. Exemptions (list all major categories with citations)
6. Appeal process:
   - First level (agency review)
   - Second level (court review)
   - Attorney fee recovery provisions

CRITICAL RULES:
- Quote exact statutory citations (e.g., "1 M.R.S. § 408-A")
- Distinguish "business days" from "calendar days" explicitly
- Include section numbers for all fee and exemption citations
- Use "unknown" for any field you cannot confidently extract
- Flag uncertain extractions with confidence_level: "medium" or "low"
```

### Step 3: Validate Against Schema

```python
import json
import jsonschema

with open('templates/json/STANDARD_JURISDICTION_TEMPLATE_template-v0.11.json', 'r') as f:
    schema = json.load(f)

try:
    jsonschema.validate(instance=parsed_data, schema=schema)
    print(f"✅ {jurisdiction}: Schema valid")
except jsonschema.ValidationError as e:
    print(f"❌ {jurisdiction}: Schema error - {e.message}")
```

### Step 4: Human Verification Checkpoint

**Create verification report**:
```json
{
  "jurisdiction": "Maine",
  "parser_confidence": "high",
  "flagged_fields": [],
  "verification_needed": false,
  "notes": "All fields extracted with high confidence"
}
```

**Flag for human review if**:
- Confidence level < "high"
- Response time units unclear
- Fee structure complex or ambiguous
- Exemptions unclear or contradictory

### Step 5: Write Output File

```python
import json

output_path = f'data/states/{state_name}/jurisdiction-data.json'

output_data = {
    "jurisdiction": jurisdiction_name,
    "transparency_law": parsed_law_data,
    "agencies": []  # Keep empty for Task 2
}

with open(output_path, 'w') as f:
    json.dump(output_data, f, indent=2)
```

## Batch Processing Order

**Batch 1**: Federal + Priority 1 (Week 1-4)
- Federal, California, Florida, Illinois, New York, Texas

**Batch 2**: Priority 2 (Week 5-8)
- 15 additional states (see master plan)

**Batch 3**: Remaining (Week 9-16)
- 30 remaining states + DC

## Quality Checks

### Automated Checks
- [x] JSON schema validation passes
- [x] All required fields populated
- [x] Statutory citations include section numbers
- [x] Response times specify business/calendar days
- [x] Date fields in ISO 8601 format

### Manual Verification (20% sample)
- [ ] Response times match statute text exactly
- [ ] Fee structures quote exact statutory language
- [ ] Exemptions correctly categorized
- [ ] Appeal process accurately described
- [ ] Citations verified against official source

## Edge Cases to Handle

### Response Time Ambiguity
**Example**: "Reasonable time" or "As soon as practicable"
**Solution**: Use negative integers (-1 for "reasonable time", -2 for "promptly")

### Complex Fee Structures
**Example**: "First 100 pages free, then $0.10/page, max $50"
**Solution**: Store in notes field, use most common rate as primary value

### Multiple Exemption Categories
**Example**: Privacy exemptions with 15 subcategories
**Solution**: Group by major category, list specific subcategories in description

## Success Criteria

- [ ] All 51 jurisdictions have populated `transparency_law` object
- [ ] 100% JSON schema compliance
- [ ] 95%+ accuracy verified on 20% sample
- [ ] All flagged items reviewed by human
- [ ] Ready for integration into Supabase

## Deliverables

**Per Jurisdiction**:
1. Populated `jurisdiction-data.json` file (transparency_law section)
2. Verification report (JSON)
3. Git commit with clear message

**Aggregate**:
1. Master progress tracking table
2. Quality metrics report
3. List of flagged items for human review

## Agent Execution Command

```bash
# Launch code-development-expert agent
# Provide this file as context
# Agent should process one jurisdiction at a time
# Agent should commit after each jurisdiction
# Agent should flag uncertain extractions
```

**Note**: This is an AI-assisted task. Agent will use GPT-4 for parsing but should validate all outputs and flag uncertainties for human review.
