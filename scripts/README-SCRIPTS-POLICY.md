---
DATE: 2025-10-16
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Scripts Directory - Usage Policy
VERSION: v0.12
---

# Scripts Directory - Usage Policy

## ⚠️ CRITICAL: What Scripts Are FORBIDDEN ⚠️

### DO NOT CREATE scripts that:

❌ **Extract affirmative rights from statutory text**
- No parsing of statute files to find rights
- No pattern matching for right patterns
- No AI/LLM-based extraction
- No "smart" text analysis
- No automated categorization of rights

❌ **Automate legal analysis**
- No interpretation of statutory language
- No determination of what constitutes a "right"
- No automated classification into categories
- No condition/applicability detection

❌ **Bulk process statutory text**
- No batch extraction across jurisdictions
- No one-size-fits-all extraction logic
- No template-based extraction

### Why These Scripts Don't Work

**Evidence from 2025-10-16 audit**:
- Manual extraction (California): 25 comprehensive rights ✅
- Automated extraction (Wyoming): 10 superficial rights ⚠️
- Missing 50%+ of actual rights due to automation

**Fundamental incompatibility**:
- Statutory language varies wildly between jurisdictions
- Rights are often implicit in procedural language
- Legal nuance requires human understanding
- "Shall" vs "may" distinctions are critical
- Context and cross-references must be understood

See `AFFIRMATIVE_RIGHTS_EXTRACTION_AUDIT.md` for full analysis.

---

## ✅ What Scripts ARE ALLOWED ✅

### Data Import/Export Scripts

✅ **Import human-extracted data to database**
- `import-rights-to-neon.js` - Imports validated JSON to Neon
- `batch-import-all-rights.sh` - Batch imports multiple files
- `convert-file-to-db-format.js` - Format conversion

✅ **Export data from database**
- Any script that queries Neon and exports results
- Data transformation for display purposes

### Validation Scripts

✅ **Format/structure validation**
- `layer2-simple-validation.py` - Checks JSON structure
- `validate-statute-names.py` - Verifies naming conventions
- `check-all-jurisdictions.py` - Completeness checks

✅ **Source verification**
- Scripts that check URLs are valid .gov domains
- Scripts that verify citation formats
- Scripts that test database connectivity

### Progress Tracking Scripts

✅ **Status monitoring**
- `check-rights-progress.js` - Shows completion statistics
- Any script that counts/tracks completed jurisdictions
- Dashboard generation scripts

### Utility Scripts

✅ **Development helpers**
- Database connection testing
- Environment setup
- Migration scripts
- Backup/restore utilities

---

## Script Categories

### Category 1: SAFE - Use Freely

These scripts work with human-extracted data:
- `import-rights-to-neon.js` ✅
- `batch-import-all-rights.sh` ✅
- `check-rights-progress.js` ✅
- `convert-file-to-db-format.js` ✅

### Category 2: VALIDATION - Use With Caution

These validate format, not content:
- `layer2-simple-validation.py` ✅ (structure only)
- `validate-statute-names.py` ✅ (naming only)
- `check-all-jurisdictions.py` ✅ (presence only)

### Category 3: FORBIDDEN - Never Create

These attempt to extract/analyze:
- ❌ Any statute parsing script
- ❌ Any rights extraction script
- ❌ Any automated legal analysis
- ❌ Any AI-based extraction

---

## Creating New Scripts - Checklist

Before creating any new script, ask:

1. **Does it extract rights from statutory text?**
   - If YES → STOP. Use manual extraction instead.

2. **Does it interpret legal language?**
   - If YES → STOP. Requires human legal understanding.

3. **Does it automate any part of the extraction workflow?**
   - If YES → STOP. Extraction must be 100% manual.

4. **Does it work with ALREADY EXTRACTED data?**
   - If YES → Probably OK. Proceed with caution.

5. **Does it only validate FORMAT (not content)?**
   - If YES → OK. Format validation is allowed.

6. **Does it track progress or generate reports?**
   - If YES → OK. Status tracking is allowed.

---

## What To Do Instead

### Instead of: "Create script to extract rights from statutes"
**DO**: Follow manual extraction workflow in `workflows/v0.12-populate-rights-of-access.md`

### Instead of: "Automate rights categorization"
**DO**: Read statute line-by-line with legal understanding per `AFFIRMATIVE_RIGHTS_EXTRACTION_CHECKLIST.md`

### Instead of: "Batch process all 52 jurisdictions"
**DO**: Extract each jurisdiction manually, then batch IMPORT with `batch-import-all-rights.sh`

### Instead of: "Use AI to find rights in text"
**DO**: Human reads statute, identifies rights, documents in JSON, THEN imports

---

## Current Scripts Inventory

### Import/Export (SAFE)
- `import-rights-to-neon.js` - Import validated JSON to database
- `batch-import-all-rights.sh` - Batch import multiple jurisdictions
- `convert-file-to-db-format.js` - Format conversion for database

### Validation (SAFE - format only)
- `layer2-simple-validation.py` - JSON structure validation
- `validate-statute-names.py` - Naming convention checks
- `check-all-jurisdictions.py` - Completeness verification
- `validate-against-ground-truth.py` - Compare to verified data

### Progress Tracking (SAFE)
- `check-rights-progress.js` - Show extraction progress
- `worktree-cycle.sh` - Development workflow helper

### Data Migration (SAFE)
- `complete_migration.py` - Database migration utilities
- `migrate_data_files.sh` - File organization
- `extract_map_data.py` - Export for map visualization

### Development (SAFE)
- `create-all-worktrees.sh` - Git worktree setup
- Various maintenance scripts

---

## Red Flags

If you see or are tempted to create:

🚩 Script named `extract-rights.py` or similar
🚩 Script using NLP/AI libraries for text analysis
🚩 Script with "parse statute" in description
🚩 Script that "automatically finds rights"
🚩 Script that "categorizes legal provisions"
🚩 Script with regex patterns for legal terms

**→ STOP and review this policy**

---

## Emergency Override

If you believe a script for automated extraction IS appropriate:

1. Read `AFFIRMATIVE_RIGHTS_EXTRACTION_AUDIT.md` first
2. Review California (25 rights) vs Wyoming (10 rights) comparison
3. Understand why automation failed
4. Reconsider your approach
5. If still convinced, document your reasoning and get approval

**Spoiler**: Automation won't work. The audit proves it.

---

## Questions?

- **"Can I script the formatting of extracted data?"** → YES, after human extraction
- **"Can I validate the JSON structure?"** → YES, format validation is fine
- **"Can I import multiple files at once?"** → YES, batch import is allowed
- **"Can I parse the statute to find rights?"** → NO, absolutely not
- **"Can I use AI to help categorize?"** → NO, categorization requires legal understanding
- **"But won't automation save time?"** → NO, it produces incomplete data (see audit)

---

## Enforcement

Any script violating this policy will be:
1. Marked with `DO-NOT-USE` prefix
2. Documented in audit trail
3. Moved to archive with explanation
4. Referenced as example of what not to do

Repeated violations indicate misunderstanding of the fundamental requirement for human legal analysis in this project.

---

**Remember**: Scripts are tools for managing human-extracted data, not replacements for human extraction.
