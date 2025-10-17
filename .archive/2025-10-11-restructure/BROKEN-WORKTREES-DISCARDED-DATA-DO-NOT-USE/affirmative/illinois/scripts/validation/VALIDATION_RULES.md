# Data Integrity Validation Rules Configuration

## Critical Fields (Block Merge on Mismatch)

These fields MUST match ground truth exactly. Any deviation will prevent merge.

```yaml
critical_fields:
  # Response Timeline
  - field: response_timeline_days
    data_type: integer
    allow_deviation: false
    requires_statute_citation: true
    
  - field: response_timeline_type
    data_type: enum
    allowed_values: [business_days, calendar_days, working_days]
    allow_deviation: false
    
  # Statute References
  - field: statute_citation
    data_type: string
    allow_deviation: false
    requires_source_url: true
    
  # Appeal Process
  - field: appeal_deadline_days
    data_type: integer
    allow_deviation: false
    
  # Fee Structure
  - field: fee_structure.standard_copy_fee
    data_type: string
    allow_deviation: false
    requires_statute_citation: true
    
  - field: fee_structure.search_time_fee
    data_type: string
    allow_deviation: false
```

## Review Fields (Flag for Manual Review)

These fields can differ but will generate warnings for manual review.

```yaml
review_fields:
  - field: agency_contact
    data_type: object
    reason: "Contact information may change"
    auto_approve: false
    
  - field: request_portal_url
    data_type: string
    reason: "Portal URLs may update"
    auto_approve: false
    verify_url_accessible: true
    
  - field: official_resources
    data_type: array
    reason: "Resources may be added"
    auto_approve: false
```

## Ignore Fields (No Validation)

These fields are excluded from validation.

```yaml
ignore_fields:
  - last_updated
  - data_version
  - validation_audit.verification_date
  - validation_audit.validator_notes
  - metadata.created_at
  - metadata.modified_at
```

## Validation Rules Logic

### 1. Exact Match Required
Fields like `response_timeline_days` must match exactly:
```
Ground Truth: 10
New Value: 10 ✅ PASS
New Value: 20 ❌ FAIL - CRITICAL
```

### 2. Type Validation
Data types must match:
```
Ground Truth: 10 (integer)
New Value: "10" (string) ❌ FAIL - Type mismatch
New Value: 10 (integer) ✅ PASS
```

### 3. Citation Requirements
Legal fields must have statute citations:
```
{
  "response_timeline_days": 10,
  "statute_citation": "Cal. Gov. Code § 6253(c)" ✅ PASS
}

{
  "response_timeline_days": 10
  // Missing statute_citation ❌ FAIL
}
```

## Conflict Resolution Workflow

When validation fails:

1. **Automatic Block** - Commit/merge is prevented
2. **Generate Report** - `.validation-conflicts.json` created
3. **Manual Review** - Developer reviews conflicts
4. **Resolution Options**:
   - Option A: Fix new data to match ground truth
   - Option B: Update ground truth (requires verification from official source)
   - Option C: Add exception rule (requires justification)

## Example Conflict Report

```json
{
  "validation_date": "2025-10-02",
  "total_conflicts": 1,
  "critical_conflicts": 1,
  "conflicts": [
    {
      "jurisdiction": "california",
      "field_path": "response_timeline_days",
      "ground_truth_value": 10,
      "new_value": 20,
      "severity": "CRITICAL",
      "ground_truth_source": "https://leginfo.legislature.ca.gov/...",
      "reason": "Value mismatch: ground truth=10, new=20"
    }
  ]
}
```

## Override Mechanism

For legitimate changes (e.g., statute amendments):

```bash
# 1. Verify new value from official source
# 2. Update ground truth file
# 3. Document in commit message:

git commit -m "Update CA response timeline: 10→20 days

Official source: [URL]
Effective date: 2025-01-01
Verified by: [Your Name]
Statute citation: Cal. Gov. Code § 6253(c) (as amended 2024)
"
```

## Testing Validation

```bash
# Test single file
python3 scripts/validation/validate-against-ground-truth.py \
  --file data/states/california/agencies.json

# Test all staged files (pre-commit)
python3 scripts/validation/validate-against-ground-truth.py --staged

# Full database scan
python3 scripts/validation/validate-against-ground-truth.py --all
```
