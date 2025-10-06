# Data Integrity Validation System - Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DATA INTEGRITY GUARDIAN SYSTEM                   │
│                                                                     │
│  Prevents inaccurate legal data from entering the database by      │
│  validating all changes against verified ground truth sources      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         GROUND TRUTH LAYER                          │
│                    (Single Source of Truth)                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  data/ground-truth/canonical-values.json                           │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │ {                                                             │ │
│  │   "california": {                                             │ │
│  │     "response_timeline_days": 10,                             │ │
│  │     "statute_citation": "Cal. Gov. Code § 6253(c)",           │ │
│  │     "verified_date": "2024-09-15",                            │ │
│  │     "source_url": "https://leginfo.legislature.ca.gov/...",   │ │
│  │     "confidence_level": "high"                                │ │
│  │   }                                                            │ │
│  │ }                                                              │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ✅ Verified from official sources only                            │
│  ✅ Includes statute citations                                     │
│  ✅ Documents verification dates                                   │
│  ✅ One canonical value per jurisdiction per field                 │
└─────────────────────────────────────────────────────────────────────┘
                                  ▲
                                  │
                                  │ Validates Against
                                  │
┌─────────────────────────────────┴───────────────────────────────────┐
│                      VALIDATION ENGINE LAYER                        │
│                 (Automated Integrity Checker)                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  scripts/validation/validate-against-ground-truth.py               │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Validation Logic                          │  │
│  │                                                              │  │
│  │  1. Extract jurisdiction from file                          │  │
│  │  2. Load ground truth for that jurisdiction                 │  │
│  │  3. Compare critical fields:                                │  │
│  │     • response_timeline_days                                │  │
│  │     • statute_citation                                      │  │
│  │     • fee_structure                                         │  │
│  │     • appeal_deadline_days                                  │  │
│  │  4. Detect conflicts                                        │  │
│  │  5. Generate conflict report                                │  │
│  │  6. Block commit if conflicts found                         │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  Conflict Severity Levels:                                         │
│  ❌ CRITICAL: Blocks merge (legal accuracy issue)                  │
│  ⚠️  WARNING: Flags for review (informational change)              │
│  ℹ️  INFO: Logged only (metadata update)                           │
└─────────────────────────────────────────────────────────────────────┘
                                  ▲
                                  │
                                  │ Triggered By
                                  │
┌─────────────────────────────────┴───────────────────────────────────┐
│                        GIT HOOK LAYER                               │
│                     (Automated Gatekeeper)                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  .git/hooks/pre-commit                                             │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Developer runs: git commit -m "Update CA data"             │  │
│  │         ↓                                                    │  │
│  │  Hook triggers automatically BEFORE commit                  │  │
│  │         ↓                                                    │  │
│  │  Runs: validate-against-ground-truth.py --staged            │  │
│  │         ↓                                                    │  │
│  │  ┌────────────────────┐                                     │  │
│  │  │ Validation Result? │                                     │  │
│  │  └────────────────────┘                                     │  │
│  │      ↙           ↘                                           │  │
│  │   PASS          FAIL                                         │  │
│  │     ↓             ↓                                          │  │
│  │  ✅ Allow     ❌ Block                                       │  │
│  │   Commit      Commit                                         │  │
│  │                  ↓                                           │  │
│  │              Generate                                        │  │
│  │              Report                                          │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  Installation: ./scripts/validation/install-pre-commit-hook.sh     │
└─────────────────────────────────────────────────────────────────────┘
                                  ▲
                                  │
                                  │ Validates
                                  │
┌─────────────────────────────────┴───────────────────────────────────┐
│                         DATA FILES LAYER                            │
│                    (Working Data Files)                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  data/states/california/agencies.json                              │
│  data/federal/agencies.json                                        │
│  Consolidated-Datasets/*.json                                      │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ {                                                            │  │
│  │   "jurisdiction_info": {                                     │  │
│  │     "jurisdiction_name": "california"                        │  │
│  │   },                                                         │  │
│  │   "response_requirements": {                                 │  │
│  │     "response_timeline_days": 10  ← Must match ground truth │  │
│  │   },                                                         │  │
│  │   "statute_details": {                                       │  │
│  │     "statute_citation": "..."  ← Must match ground truth    │  │
│  │   }                                                          │  │
│  │ }                                                            │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  These files CANNOT deviate from ground truth for critical fields  │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                      CONFLICT REPORT OUTPUT                         │
│                  (When Validation Fails)                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  .validation-conflicts.json                                        │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ {                                                            │  │
│  │   "validation_date": "2025-10-02",                          │  │
│  │   "total_conflicts": 1,                                     │  │
│  │   "conflicts": [                                            │  │
│  │     {                                                       │  │
│  │       "jurisdiction": "california",                         │  │
│  │       "field_path": "response_timeline_days",               │  │
│  │       "ground_truth_value": 10,                             │  │
│  │       "new_value": 20,                                      │  │
│  │       "severity": "CRITICAL",                               │  │
│  │       "ground_truth_source": "https://...",                 │  │
│  │       "reason": "Value mismatch"                            │  │
│  │     }                                                       │  │
│  │   ]                                                         │  │
│  │ }                                                            │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  Developer reviews report and resolves conflicts                   │
└─────────────────────────────────────────────────────────────────────┘
```

## Data Flow Example: Successful Commit

```
Developer                Git                 Validator              Ground Truth
    │                    │                       │                      │
    │  Edit file         │                       │                      │
    │  (CA: 10 days)     │                       │                      │
    │─────────────────>  │                       │                      │
    │                    │                       │                      │
    │  git add           │                       │                      │
    │─────────────────>  │                       │                      │
    │                    │                       │                      │
    │  git commit        │                       │                      │
    │─────────────────>  │                       │                      │
    │                    │                       │                      │
    │                    │  Run pre-commit hook  │                      │
    │                    │──────────────────────>│                      │
    │                    │                       │                      │
    │                    │                       │  Check CA deadline   │
    │                    │                       │─────────────────────>│
    │                    │                       │                      │
    │                    │                       │  Return: 10 days     │
    │                    │                       │<─────────────────────│
    │                    │                       │                      │
    │                    │                       │  Compare: 10 == 10   │
    │                    │                       │  ✅ MATCH!           │
    │                    │                       │                      │
    │                    │  Validation PASSED    │                      │
    │                    │<──────────────────────│                      │
    │                    │                       │                      │
    │  ✅ Commit allowed │                       │                      │
    │<───────────────────│                       │                      │
```

## Data Flow Example: Blocked Commit (Conflict)

```
Developer                Git                 Validator              Ground Truth
    │                    │                       │                      │
    │  Edit file         │                       │                      │
    │  (CA: 20 days)     │                       │                      │
    │─────────────────>  │                       │                      │
    │                    │                       │                      │
    │  git add           │                       │                      │
    │─────────────────>  │                       │                      │
    │                    │                       │                      │
    │  git commit        │                       │                      │
    │─────────────────>  │                       │                      │
    │                    │                       │                      │
    │                    │  Run pre-commit hook  │                      │
    │                    │──────────────────────>│                      │
    │                    │                       │                      │
    │                    │                       │  Check CA deadline   │
    │                    │                       │─────────────────────>│
    │                    │                       │                      │
    │                    │                       │  Return: 10 days     │
    │                    │                       │<─────────────────────│
    │                    │                       │                      │
    │                    │                       │  Compare: 20 != 10   │
    │                    │                       │  ❌ CONFLICT!        │
    │                    │                       │                      │
    │                    │                       │  Generate report     │
    │                    │                       │  .validation-        │
    │                    │                       │  conflicts.json      │
    │                    │                       │                      │
    │                    │  Validation FAILED    │                      │
    │                    │<──────────────────────│                      │
    │                    │                       │                      │
    │  ❌ Commit blocked │                       │                      │
    │<───────────────────│                       │                      │
    │                    │                       │                      │
    │  Review report     │                       │                      │
    │  Fix data OR       │                       │                      │
    │  Update ground     │                       │                      │
    │  truth             │                       │                      │
    │                    │                       │                      │
    │  Try again         │                       │                      │
    │─────────────────>  │                       │                      │
```

## Critical Fields Protected

```
┌─────────────────────────────────────────────────────────────┐
│                 CRITICAL FIELDS                             │
│         (Must match ground truth exactly)                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✓ response_timeline_days        [Integer]                 │
│     The number of days to respond                           │
│                                                             │
│  ✓ response_timeline_type        [Enum]                    │
│     business_days | calendar_days | working_days            │
│                                                             │
│  ✓ statute_citation              [String]                  │
│     Exact legal citation                                    │
│                                                             │
│  ✓ appeal_deadline_days          [Integer]                 │
│     Days to file an appeal                                  │
│                                                             │
│  ✓ fee_structure                 [Object]                  │
│     - standard_copy_fee                                     │
│     - search_time_fee                                       │
│     - electronic_fee                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Any deviation = ❌ COMMIT BLOCKED
```

## Validation Rules Hierarchy

```
                    ┌─────────────────┐
                    │  All Data Files │
                    └────────┬────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
         ┌──────▼──────┐          ┌──────▼──────┐
         │   Critical  │          │   Review    │
         │   Fields    │          │   Fields    │
         └──────┬──────┘          └──────┬──────┘
                │                         │
         Must Match Exactly        Flag for Review
         ❌ Block on Mismatch      ⚠️  Warn but Allow
                │                         │
         ┌──────▼──────────────────────────▼──────┐
         │                                         │
         │  • response_timeline_days               │
         │  • statute_citation                     │
         │  • fee_structure                        │
         │  • appeal_deadline_days                 │
         │                                         │
         │  These determine legal accuracy         │
         │  Cannot be wrong!                       │
         └─────────────────────────────────────────┘
```

## Implementation Files

```
scripts/validation/
├── validate-against-ground-truth.py    ← Core validation engine
├── install-pre-commit-hook.sh          ← Hook installer
├── test-validation-system.py           ← Test suite
├── README.md                           ← Full documentation
├── QUICK_START.md                      ← 5-minute setup guide
└── VALIDATION_RULES.md                 ← Rules configuration

data/ground-truth/
└── canonical-values.json               ← Single source of truth

.git/hooks/
└── pre-commit                          ← Auto-runs validation
```

---

**The system ensures that inaccurate legal data cannot enter the database, protecting the integrity of your AI training ground truth.**
