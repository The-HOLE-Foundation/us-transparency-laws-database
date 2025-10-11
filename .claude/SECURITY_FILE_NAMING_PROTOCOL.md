---
DATE: 2025-10-08
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - Security Standards
CLASSIFICATION: PUBLIC
VERSION: 1.0
PURPOSE: Prevent accidental exposure of confidential materials through file naming conventions
---

# Security-Conscious File Naming Protocol

## Mission Context

**The HOLE Foundation's Mission**: Shine light where democracy goes dark

**Security Reality**: As a transparency organization, we are a natural target for:
- Government entities seeking to prevent exposure
- Powerful individuals with vested interests in opacity
- Organizations opposed to transparency
- Adversarial actors seeking to compromise our work

**Protection Strategy**: Defense in depth through automated security controls embedded in file naming conventions.

---

## Classification System

### Four Security Levels (Embedded in Filenames)

We use **subtle, natural-looking** suffixes that don't advertise security classifications but are machine-detectable:

| Level | Suffix Pattern | Git Behavior | Examples | Use Cases |
|-------|---------------|--------------|----------|-----------|
| **PUBLIC** | No suffix | ✅ Tracked | `workflow.md`, `schema.json` | Public documentation, open source code |
| **INTERNAL** | `-INTERNAL` | ⚠️ Tracked (team only repos) | `meeting-notes-INTERNAL.md` | Team discussions, internal planning |
| **CONFIDENTIAL** | `-CONF` | ❌ NEVER tracked | `donor-list-CONF.xlsx`, `strategy-CONF.md` | Donor info, legal strategy, sensitive contacts |
| **RESTRICTED** | `-RESTRICTED` | ❌ NEVER tracked | `source-interview-RESTRICTED.md` | Whistleblower contacts, source protection |

### Additional Security Markers

**Work-in-Progress Protection**:
- `-DRAFT-CONF` - Confidential drafts
- `-NOTES-RESTRICTED` - Restricted research notes
- `-WIP-INTERNAL` - Internal work in progress

**Temporary Files**:
- `-TEMP-CONF` - Temporary confidential files
- `-SCRATCH-RESTRICTED` - Scratch notes (restricted)

**Backup Protection**:
- `backup-CONF/` - Confidential backup directories
- `archive-RESTRICTED/` - Restricted archives

---

## File Naming Standards

### General Pattern

```
{descriptive-name}-{CLASSIFICATION}.{ext}
```

**Examples**:
- ✅ `board-meeting-agenda-INTERNAL.md` (tracked in private repos only)
- ✅ `whistleblower-contact-protocol-RESTRICTED.md` (NEVER tracked)
- ✅ `donor-database-CONF.xlsx` (NEVER tracked)
- ✅ `public-transparency-map-data.json` (no suffix = public, tracked)

### Directory Naming

Entire directories can be classified:

```
/confidential-CONF/          # Never tracked
/restricted-sources-RESTRICTED/  # Never tracked
/internal-planning-INTERNAL/     # Tracked in private repos only
/public-docs/                    # Tracked (no suffix = public)
```

### Special Cases

**Database Credentials**:
```
.env-CONF
database-credentials-CONF.json
api-keys-RESTRICTED.txt
```

**Source Protection**:
```
source-{codename}-RESTRICTED.md
interview-transcript-{date}-RESTRICTED.txt
contact-info-RESTRICTED.xlsx
```

**Legal Strategy**:
```
litigation-strategy-CONF.md
attorney-correspondence-CONF.pdf
settlement-discussions-RESTRICTED.md
```

**Donor Information**:
```
donor-list-CONF.csv
fundraising-strategy-CONF.md
grant-application-INTERNAL.pdf
```

---

## .gitignore Implementation

### Master .gitignore Template

```gitignore
#########################################
# THE HOLE FOUNDATION - SECURITY GITIGNORE
# Purpose: Prevent accidental exposure of confidential materials
# Version: 1.0
# Date: 2025-10-08
#########################################

#########################################
# CLASSIFICATION-BASED EXCLUSIONS
# CRITICAL: These patterns protect against accidental commits
#########################################

# CONFIDENTIAL Files (donor info, legal strategy, sensitive contacts)
*-CONF.*
*-CONF/
*-confidential.*
*-confidential/
confidential-*/
CONF-*

# RESTRICTED Files (source protection, whistleblowers, high-risk contacts)
*-RESTRICTED.*
*-RESTRICTED/
*-restricted.*
*-restricted/
restricted-*/
RESTRICTED-*

# Hybrid Classifications
*-DRAFT-CONF.*
*-NOTES-RESTRICTED.*
*-WIP-CONF.*
*-TEMP-RESTRICTED.*

#########################################
# INTERNAL Files (tracked in private repos only)
# WARNING: Only use INTERNAL in truly private repositories
#########################################

# Uncomment for PUBLIC repositories:
# *-INTERNAL.*
# *-INTERNAL/
# internal-*/

#########################################
# CREDENTIAL & SECRET PATTERNS
# These are ALWAYS excluded regardless of naming
#########################################

# Environment files with secrets
.env*
*.env
.env-*
*.env.*

# Credential files
*credentials*
*-creds.*
*-keys.*
*api-key*
*secret*
*password*

# Database connection strings
*connection-string*
*db-url*
*database-url*

#########################################
# SOURCE PROTECTION PATTERNS
#########################################

# Source/Whistleblower files
*source-*-RESTRICTED.*
*whistleblower*
*interview-transcript*-RESTRICTED.*
*contact-info*-RESTRICTED.*
source-contacts/
whistleblower-docs/

#########################################
# LEGAL & STRATEGY PATTERNS
#########################################

# Legal strategy & correspondence
*litigation*-CONF.*
*legal-strategy*-CONF.*
*attorney-*-CONF.*
*settlement*-RESTRICTED.*

#########################################
# DONOR & FUNDRAISING PATTERNS
#########################################

# Donor information
*donor*-CONF.*
*donor-list*
*fundraising*-CONF.*
donor-database/

#########################################
# COMMON SENSITIVE FILE TYPES
#########################################

# Financial records
*financial-records*
*tax-returns*
*budget-detailed*-CONF.*

# Personnel files
*hr-records*-CONF.*
*employee-*-CONF.*
*personnel-file*

#########################################
# BACKUP & ARCHIVE PROTECTION
#########################################

# Classified backups
backup-CONF/
backup-RESTRICTED/
archive-CONF/
archive-RESTRICTED/
*-backup-CONF.*

#########################################
# PLATFORM-SPECIFIC EXCLUSIONS
#########################################

# MacOS
.DS_Store
.AppleDouble
.LSOverride

# Windows
Thumbs.db
Desktop.ini

# Linux
*~
.directory

# Editor backups
*.swp
*.swo
*.bak
*.tmp

#########################################
# DEVELOPMENT EXCLUSIONS
#########################################

# Dependencies (always exclude - contain vulnerabilities)
node_modules/
vendor/
.pnp
.pnp.js

# Build outputs
dist/
build/
*.log

# IDE files
.vscode/
.idea/
*.sublime-*

#########################################
# SESSION DOCUMENTS (from Session Protocol)
#########################################

# Temporary session files (extract to permanent records first)
S-*-PLAN_*.md
S-*-DATA_*.md
S-*-CODE_*.md
S-*-DEBUG_*.md
*-SESSION-SUMMARY.md

#########################################
# VERIFICATION & AUDIT
# Use these commands to verify gitignore is working:
#
# Check what would be committed:
#   git status
#
# Test if file would be ignored:
#   git check-ignore -v filename.md
#
# List all ignored files:
#   git status --ignored
#
# Find confidential files NOT ignored (SECURITY CHECK):
#   find . -name "*-CONF.*" -o -name "*-RESTRICTED.*" | while read f; do git check-ignore -q "$f" || echo "WARNING: $f NOT IGNORED"; done
#########################################

#########################################
# END OF SECURITY GITIGNORE
# Review quarterly: 2026-01-08
#########################################
```

---

## Implementation Guide

### Step 1: Deploy to All Repositories

```bash
# Copy master .gitignore to each repo
cp foundation-meta/.gitignore-SECURITY-TEMPLATE /path/to/repo/.gitignore

# Or append to existing .gitignore
cat foundation-meta/.gitignore-SECURITY-TEMPLATE >> /path/to/repo/.gitignore

# Verify it works
cd /path/to/repo
touch test-file-CONF.md
git status  # Should NOT show test-file-CONF.md
git check-ignore -v test-file-CONF.md  # Should show which rule matched
rm test-file-CONF.md
```

### Step 2: Audit Existing Files

```bash
# Find files that SHOULD be classified but aren't
find . -type f \( -name "*donor*" -o -name "*source*" -o -name "*whistleblower*" \) \
  ! -name "*-CONF.*" ! -name "*-RESTRICTED.*" \
  -exec echo "UNCLASSIFIED SENSITIVE FILE: {}" \;

# Check if any CONF/RESTRICTED files are tracked (SECURITY AUDIT)
git ls-files | grep -E '(CONF|RESTRICTED)' && echo "⚠️  SECURITY BREACH: Confidential files tracked!" || echo "✅ No confidential files tracked"
```

### Step 3: Rename Sensitive Files

```bash
# Rename existing sensitive files to include classification
mv donor-list.xlsx donor-list-CONF.xlsx
mv source-contacts.md source-contacts-RESTRICTED.md

# Then verify git ignores them
git status  # Should NOT show renamed files
```

### Step 4: Set Up Pre-Commit Hook (Advanced)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Pre-commit security check

echo "🔒 Running security pre-commit check..."

# Check for unclassified sensitive keywords
SENSITIVE_PATTERNS=(
  "donor"
  "whistleblower"
  "source.*contact"
  "credential"
  "api.*key"
  "password"
  "secret"
)

STAGED_FILES=$(git diff --cached --name-only)

for file in $STAGED_FILES; do
  for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    if echo "$file" | grep -iE "$pattern" > /dev/null; then
      if ! echo "$file" | grep -E '(CONF|RESTRICTED|INTERNAL)' > /dev/null; then
        echo "⚠️  WARNING: File '$file' contains sensitive keyword but lacks classification suffix"
        echo "   Consider renaming to: ${file%.*}-CONF.${file##*.}"
        echo ""
        echo "Continue commit anyway? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
          echo "❌ Commit aborted. Please classify sensitive files."
          exit 1
        fi
      fi
    fi
  done
done

echo "✅ Security check passed"
exit 0
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

---

## Security Best Practices

### DO:
✅ Always classify files at creation time
✅ Use RESTRICTED for source protection
✅ Use CONF for donor/legal/strategy info
✅ Test .gitignore with `git check-ignore -v filename`
✅ Run quarterly security audits
✅ Document why files are classified (in separate INTERNAL notes)

### DON'T:
❌ Never commit files with CONF or RESTRICTED suffixes
❌ Never rename classified files to remove classification
❌ Never override .gitignore for classified files
❌ Never use classification suffixes as a joke or test
❌ Never assume .gitignore is enough (verify!)

---

## Threat Scenarios & Protections

### Scenario 1: Accidental Commit
**Threat**: Developer commits `donor-list.xlsx` without classification
**Protection**:
- Pre-commit hook warns about unclassified sensitive file
- Security audit script finds unclassified sensitive files
- Quarterly reviews catch persistent issues

### Scenario 2: Renamed File Exposure
**Threat**: File renamed from `strategy-CONF.md` to `strategy.md` to "fix" git issues
**Protection**:
- Git history audit would show suspicious renames
- Security audit looks for sensitive keywords without classification
- Team training emphasizes never removing classification

### Scenario 3: Directory Upload
**Threat**: Entire `sources/` directory committed
**Protection**:
- Directory naming standard: `sources-RESTRICTED/`
- .gitignore matches directory patterns
- `git status --ignored` verification

### Scenario 4: Cloud Sync Exposure
**Threat**: Dropbox/Google Drive syncs confidential files to cloud
**Protection**:
- Keep CONF/RESTRICTED files in separate, non-synced locations
- Use encrypted volumes for classified materials
- Document safe storage locations (separate protocol)

### Scenario 5: Repository Fork
**Threat**: Public fork of private repo exposes INTERNAL files
**Protection**:
- INTERNAL suffix commented out in public repos
- Separate public/private repository strategy
- Never use INTERNAL in repos that might be forked publicly

---

## Classification Decision Tree

```
Is this file sensitive?
│
├─ NO → Use descriptive name, no suffix (public, tracked)
│
└─ YES → What type of sensitivity?
    │
    ├─ General team business, planning, internal discussions
    │   └─ Use: -INTERNAL (tracked in private repos only)
    │
    ├─ Donor info, legal strategy, financial details, contracts
    │   └─ Use: -CONF (NEVER tracked)
    │
    └─ Source protection, whistleblowers, high-risk contacts, litigation targets
        └─ Use: -RESTRICTED (NEVER tracked, highest protection)
```

---

## Integration with Other Protocols

### Session Document Management
- Session summaries may contain sensitive info
- Use: `S-20251008-1430-PLAN-CONF.md` for confidential sessions
- Extract only non-sensitive content to permanent records

### Versioning Guidelines
- Templates: `template-CONF-v0.12.json`
- Schemas: `v0.12-sensitive-data-schema-INTERNAL.json`
- Classification comes BEFORE version number

### Git Workflow
- Create `confidential-CONF/` branches for sensitive work
- Never merge CONF/RESTRICTED branches to public repos
- Use separate private repositories for classified work

---

## Quarterly Security Audit Checklist

Run this every quarter (January, April, July, October):

```bash
#!/bin/bash
# Quarterly Security Audit Script

echo "=== THE HOLE FOUNDATION - QUARTERLY SECURITY AUDIT ==="
echo "Date: $(date)"
echo ""

# 1. Check for tracked confidential files (CRITICAL)
echo "1. Checking for tracked confidential files..."
TRACKED_CONF=$(git ls-files | grep -E '(CONF|RESTRICTED)')
if [ -n "$TRACKED_CONF" ]; then
  echo "⚠️  CRITICAL: Confidential files are tracked:"
  echo "$TRACKED_CONF"
else
  echo "✅ No confidential files tracked"
fi
echo ""

# 2. Find unclassified sensitive files
echo "2. Checking for unclassified sensitive files..."
find . -type f \( \
  -iname "*donor*" -o \
  -iname "*source*" -o \
  -iname "*whistleblower*" -o \
  -iname "*credential*" -o \
  -iname "*secret*" -o \
  -iname "*password*" \
) ! -iname "*-CONF.*" ! -iname "*-RESTRICTED.*" ! -path "*/node_modules/*" \
  -exec echo "⚠️  UNCLASSIFIED: {}" \;
echo ""

# 3. Verify .gitignore exists and is current
echo "3. Checking .gitignore status..."
if [ -f .gitignore ]; then
  if grep -q "CLASSIFICATION-BASED EXCLUSIONS" .gitignore; then
    echo "✅ Security .gitignore present and current"
  else
    echo "⚠️  WARNING: .gitignore missing security patterns"
  fi
else
  echo "❌ CRITICAL: No .gitignore file found"
fi
echo ""

# 4. Check git history for accidentally committed secrets
echo "4. Scanning git history for exposed secrets (basic check)..."
git log --all --full-history -- "*-CONF.*" "*-RESTRICTED.*" 2>/dev/null \
  && echo "⚠️  WARNING: Confidential files found in git history" \
  || echo "✅ No confidential files in git history"
echo ""

echo "=== AUDIT COMPLETE ==="
echo "Next audit due: $(date -v+3m +%Y-%m-%d)"
```

---

## Training & Awareness

### For All Team Members

**Classification at Creation**:
- When creating ANY file, ask: "Is this sensitive?"
- If yes, add appropriate suffix IMMEDIATELY
- Never "plan to add it later"

**Recognition Patterns**:
- Donor names/info → CONF
- Source contacts → RESTRICTED
- Legal strategy → CONF
- Financial details → CONF
- Whistleblower communications → RESTRICTED
- Internal planning → INTERNAL (private repos)

**Verification Habit**:
- Before `git add`, run `git status`
- Check that sensitive files are NOT listed
- If sensitive file appears, STOP and classify it

### For Developers

**Pre-Commit Checklist**:
1. `git status` - Check what's being committed
2. Scan file list for sensitive keywords
3. Verify all sensitive files have classification suffixes
4. Verify classified files are NOT in staging area
5. Run `git status --ignored` occasionally to see what's protected

---

## Emergency Procedures

### If Confidential File Accidentally Committed

**IMMEDIATE STEPS**:

```bash
# 1. DO NOT PUSH if you haven't yet
# 2. Remove from last commit
git reset HEAD~1
git add [only safe files]
git commit -m "Your message"

# 3. Classify the sensitive file
mv sensitive-file.md sensitive-file-CONF.md

# 4. Verify it's now ignored
git status  # Should NOT show the file
```

**IF ALREADY PUSHED TO REMOTE**:

```bash
# ⚠️  THIS IS SERIOUS - Contact security lead immediately

# 1. Alert team - do not let anyone else pull
# 2. Remove from history (DESTRUCTIVE)
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch path/to/sensitive-file.md' \
  --prune-empty --tag-name-filter cat -- --all

# 3. Force push (requires everyone to re-clone)
git push origin --force --all

# 4. Notify all team members to delete and re-clone

# 5. Consider the data compromised - take appropriate action:
#    - Change credentials if exposed
#    - Notify affected parties if contact info exposed
#    - Consult legal if source protection compromised
```

**IF PUSHED TO PUBLIC REPOSITORY**:

```bash
# ⚠️  CRITICAL INCIDENT

# 1. Assume data is permanently exposed (GitHub/GitLab cache forever)
# 2. Immediately change all credentials/keys if exposed
# 3. Notify legal counsel
# 4. Notify affected parties (donors, sources, etc.)
# 5. File incident report
# 6. Review and strengthen protocols
```

---

## Storage Recommendations

### File System Organization

```
/work/
├── public/                          # Public repos, no classified files
│   ├── us-transparency-laws-database/
│   └── THEHOLETRUTH.ORG/
│
├── private-repos/                   # Private GitHub repos, INTERNAL allowed
│   ├── foundation-meta/
│   └── internal-tools/
│
└── classified/                      # NEVER in git, encrypted volume
    ├── confidential-CONF/           # Donor, legal, financial
    │   ├── donor-database-CONF.xlsx
    │   └── legal-strategy-CONF.md
    │
    └── restricted-RESTRICTED/       # Source protection, highest security
        ├── source-contacts-RESTRICTED.md
        └── whistleblower-comms-RESTRICTED/
```

### Encryption

**For RESTRICTED materials**:
- Use encrypted disk images (macOS: Disk Utility)
- Use VeraCrypt volumes (cross-platform)
- Use full-disk encryption (FileVault, BitLocker)
- Consider hardware security keys for access

**For CONF materials**:
- Minimum: Encrypted volume
- Recommended: Separate encrypted external drive
- Keep offline when not in use

---

## Compliance & Legal

### Records Retention
- CONF files: Retain per legal requirements (7 years typical)
- RESTRICTED files: Retain until source protection no longer needed
- INTERNAL files: Retain per organizational policy

### Access Logging
- Log who accesses RESTRICTED files (if possible)
- Quarterly review of access logs
- Investigate unusual access patterns

### Audit Trail
- Document why files are classified (in separate notes)
- Keep classification decisions in INTERNAL meeting notes
- Review classifications annually

---

## Version History

**v1.0** (2025-10-08): Initial protocol
- Classification system defined
- .gitignore template created
- Security audit procedures established
- Emergency procedures documented

**Next Review**: 2026-01-08

---

## Related Protocols

- Session Document Management Protocol (may contain confidential session notes)
- Versioning Guidelines (classification integrated with versioning)
- Standards Index (security protocol registered)

---

**Classification of This Document**: PUBLIC
**Reason**: Contains no confidential information, describes public security practices
**Review Date**: 2026-01-08
