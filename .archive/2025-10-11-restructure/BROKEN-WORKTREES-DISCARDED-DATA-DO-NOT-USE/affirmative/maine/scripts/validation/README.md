# Data Integrity Validation System - Ground Truth Guardian

## Overview

The Data Integrity Validation System is an automated safeguard that prevents inaccurate legal information from entering the database. It validates all data changes against a canonical "ground truth" reference and blocks any conflicting changes until manually reconciled.

## The Problem It Solves

**Scenario**: Your database says California's FOIA response deadline is 10 days. Someone uploads a file saying it's 20 days. Without validation, this incorrect data could leak into production.

**Solution**: The system automatically detects the conflict, blocks the change, and requires you to verify which value is correct before allowing it to merge.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   DATA CHANGE FLOW                      │
└─────────────────────────────────────────────────────────┘

Developer Makes Change
         ↓
    git add file.json
         ↓
    git commit -m "..."
         ↓
┌─────────────────────┐
│  Pre-Commit Hook    │ ← Automatically triggered
│  (Validator Runs)   │
└─────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  Compare Against Ground Truth           │
│  - Check critical fields                │
│  - Verify data types                    │
│  - Validate statute citations           │
└─────────────────────────────────────────┘
         ↓
    ┌────────┐
    │ Match? │
    └────────┘
      ↙    ↘
    YES     NO
     ↓       ↓
  ✅ Allow  ❌ Block
  Commit    Commit
            ↓
        Generate
        Conflict
        Report
```

## Quick Start

### 1. Install the Pre-Commit Hook

```bash
cd /path/to/us-transparency-laws-database
chmod +x scripts/validation/install-pre-commit-hook.sh
./scripts/validation/install-pre-commit-hook.sh
```

This installs a Git hook that automatically runs validation before every commit.

### 2. Populate Ground Truth

Edit `data/ground-truth/canonical-values.json` with verified data for each jurisdiction:

```json
{
  "california": {
    "response_timeline_days": 10,
    "response_timeline_type": "calendar_days",
    "statute_citation": "Cal. Gov. Code § 6253(c)",
    "verified_date": "2024-09-15",
    "source_url": "https://leginfo.legislature.ca.gov/...",
    "confidence_level": "high"
  }
}
```

### 3. Normal Workflow

Make changes as usual. The validator runs automatically:

```bash
# Edit a data file
vim data/states/california/agencies.json

# Stage and commit
git add data/states/california/agencies.json
git commit -m "Update California agency contacts"

# Validation runs automatically
🔍 Running Data Integrity Validation...
✅ Validation passed - proceeding with commit
```

## What Gets Validated

### Critical Fields (Block on Mismatch)

These fields MUST match ground truth exactly:

- `response_timeline_days` - Response deadline in days
- `response_timeline_type` - Type (business/calendar/working days)
- `statute_citation` - Legal citation
- `appeal_deadline_days` - Appeal deadline
- `fee_structure.standard_copy_fee` - Standard fees

**Any deviation blocks the commit.**

### Review Fields (Warning Only)

These generate warnings but don't block:

- `agency_contact` - Contact info can change
- `request_portal_url` - URLs may update

### Ignored Fields

These are never validated:

- `last_updated`
- `validation_audit.verification_date`
- Metadata timestamps

## Handling Conflicts

### When Validation Fails

```bash
git commit -m "Update data"

🔍 Running Data Integrity Validation...
❌ VALIDATION FAILED - 1 conflict(s) detected

⚠️  DATA INTEGRITY CONFLICTS DETECTED
════════════════════════════════════════

[1] CRITICAL: california
    Field: response_timeline_days
    Ground Truth: 10
    New Value: 20
    Source: https://leginfo.legislature.ca.gov/...
    Reason: Value mismatch

📋 Conflict report saved to: .validation-conflicts.json
```

### Resolution Options

#### Option A: Fix Your Data (Most Common)

The ground truth is correct, you made an error:

```bash
# Fix the data file to match ground truth
vim data/states/california/agencies.json
# Change 20 back to 10

git add data/states/california/agencies.json
git commit -m "Fix: Correct CA response timeline to 10 days"
```

#### Option B: Update Ground Truth (Statute Changed)

Your data is correct, the law changed:

```bash
# 1. Verify from official source
# Visit California Legislature website, confirm change

# 2. Update ground truth
vim data/ground-truth/canonical-values.json
# Update value from 10 to 20
# Add verification details

# 3. Commit both files
git add data/ground-truth/canonical-values.json
git add data/states/california/agencies.json
git commit -m "Update CA FOIA timeline: 10→20 days (2025 amendment)

Official source: https://leginfo.legislature.ca.gov/...
Effective date: 2025-01-01
Statute citation: Cal. Gov. Code § 6253(c) (amended 2024)
Verified by: [Your Name]"
```

#### Option C: Bypass (⚠️ NOT RECOMMENDED)

Only use in emergencies:

```bash
git commit --no-verify -m "Emergency commit"
```

**WARNING**: This bypasses all validation. Use only when absolutely necessary and fix ASAP.

## Manual Testing

### Test Single File

```bash
python3 scripts/validation/validate-against-ground-truth.py \
  --file data/states/california/agencies.json
```

### Test All Staged Files

```bash
git add .
python3 scripts/validation/validate-against-ground-truth.py --staged
```

### Full Database Scan

```bash
python3 scripts/validation/validate-against-ground-truth.py --all
```

## Example Workflow: Adding New Jurisdiction

```bash
# 1. Verify statute from official source
# Visit official state legislature website

# 2. Add to ground truth
vim data/ground-truth/canonical-values.json
# Add verified data with sources

# 3. Create data file
vim data/states/new-york/agencies.json
# Use same values as ground truth

# 4. Commit (validation passes automatically)
git add data/ground-truth/canonical-values.json
git add data/states/new-york/agencies.json
git commit -m "Add New York transparency law data

Official sources:
- https://www.nysenate.gov/legislation/laws/PUB/...
Verified: 2025-10-02"
```

## Example Workflow: Statute Amendment

```bash
# Texas changes response deadline from 10 to 15 days effective 2025

# 1. Verify from official source
# Confirm at https://statutes.capitol.texas.gov/

# 2. Update ground truth FIRST
vim data/ground-truth/canonical-values.json
{
  "texas": {
    "response_timeline_days": 15,  // Changed from 10
    "statute_citation": "Tex. Gov't Code § 552.221 (amended 2025)",
    "verified_date": "2025-10-02",
    "source_url": "https://statutes.capitol.texas.gov/...",
    "last_amended": "2025"
  }
}

# 3. Update all data files referencing Texas
vim data/states/texas/agencies.json
vim Consolidated-Datasets/transparency-laws-database-v0.11.json
# Update timeline values to 15

# 4. Commit with detailed message
git add data/ground-truth/canonical-values.json
git add data/states/texas/agencies.json
git add Consolidated-Datasets/transparency-laws-database-v0.11.json
git commit -m "Update TX FOIA timeline: 10→15 days (HB 1234, 2025)

Official source: https://statutes.capitol.texas.gov/...
Bill: HB 1234 (89th Legislature)
Effective date: 2025-09-01
Verified by: [Your Name]
Impact: All Texas agency data updated"
```

## Conflict Report Format

`.validation-conflicts.json`:

```json
{
  "validation_date": "2025-10-02",
  "total_conflicts": 2,
  "critical_conflicts": 2,
  "conflicts": [
    {
      "jurisdiction": "california",
      "field_path": "response_timeline_days",
      "ground_truth_value": 10,
      "new_value": 20,
      "severity": "CRITICAL",
      "ground_truth_source": "https://leginfo.legislature.ca.gov/...",
      "reason": "Value mismatch: ground truth=10, new=20"
    },
    {
      "jurisdiction": "texas",
      "field_path": "statute_citation",
      "ground_truth_value": "Tex. Gov't Code § 552.221",
      "new_value": "Tex. Gov't Code § 552.222",
      "severity": "CRITICAL",
      "ground_truth_source": "https://statutes.capitol.texas.gov/...",
      "reason": "Value mismatch"
    }
  ]
}
```

## Customizing Validation Rules

Edit `scripts/validation/VALIDATION_RULES.md` to modify:

- Which fields are critical vs review
- Data type requirements
- Custom validation logic

Then update the validator code in `validate-against-ground-truth.py`.

## Troubleshooting

### Hook Not Running

```bash
# Check if hook is installed
ls -la .git/hooks/pre-commit

# Reinstall if missing
./scripts/validation/install-pre-commit-hook.sh
```

### False Positives

If you're getting conflicts that shouldn't exist:

```bash
# Check ground truth values
cat data/ground-truth/canonical-values.json | jq '.california'

# Check your data values
cat data/states/california/agencies.json | jq '.response_requirements'

# Compare manually
```

### Python Not Found

```bash
# Use python instead of python3 if needed
which python3
which python

# Update hook if necessary
vim .git/hooks/pre-commit
```

## Benefits

✅ **Prevents Data Corruption** - Inaccurate data can't enter the database  
✅ **Maintains Legal Accuracy** - Critical for AI training ground truth  
✅ **Automated Protection** - No manual checks needed  
✅ **Clear Resolution Path** - Conflicts are documented and actionable  
✅ **Audit Trail** - All changes tracked with verification sources  
✅ **Developer Friendly** - Runs automatically, minimal friction  

## Limitations

- Requires manual population of ground truth initially
- Only validates JSON files (not markdown, text)
- Pre-commit only (doesn't validate existing data retroactively)
- No automatic fetching from official sources (yet)

## Future Enhancements

- [ ] Web scraping validation from official sources
- [ ] Scheduled background validation of entire database
- [ ] GitHub Actions integration for PR validation
- [ ] Slack/email notifications for conflicts
- [ ] Visual diff tool for conflict resolution
- [ ] Automatic ground truth updates from verified amendments

## Support

For questions or issues:
1. Check conflict report: `.validation-conflicts.json`
2. Review validation rules: `scripts/validation/VALIDATION_RULES.md`
3. Test manually: `python3 scripts/validation/validate-against-ground-truth.py --help`

---

**Remember**: This system protects the integrity of legal data that people rely on. When in doubt, verify from official sources before overriding validation.
