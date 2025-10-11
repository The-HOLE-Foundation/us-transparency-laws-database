---
DATE: 2025-10-08
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
PROTOCOL_TYPE: Session Document Management and Cleanup
VERSION: 1.0
PURPOSE: Prevent document clutter, preserve valuable information, maintain clean repository
---

# Session Document Management Protocol

## Purpose

This protocol ensures that:
1. All session work is tracked and analyzable
2. Valuable information is preserved in permanent records
3. Temporary documents are identified and cleaned up
4. Repository stays organized without accumulating clutter
5. Every document has a clear lifecycle and disposition

## Session ID System

### Format

**Session ID**: `S-YYYYMMDD-HHMM-{TYPE}`

Where:
- `YYYYMMDD`: Date of session (e.g., 20251008)
- `HHMM`: Start time in 24-hour format (e.g., 1257 for 12:57 PM)
- `{TYPE}`: Session type code (see below)

**Session Type Codes**:
- `PLAN`: Planning and strategy sessions
- `DATA`: Data collection or entry work
- `CODE`: Code development
- `DEBUG`: Debugging and fixes
- `REVIEW`: Code review or verification
- `DOCS`: Documentation updates
- `CLEANUP`: Repository maintenance

**Example**: `S-20251008-1257-PLAN` (Today's session: Planning, started 12:57 PM)

### Applying Session IDs

**All temporary documents created in a session must include session ID in filename**:

```
GOOD:
- S-20251008-1257-PLAN_session-summary.md
- S-20251008-1257-PLAN_decision-log.md
- S-20251008-1257-PLAN_worker-analysis.md

BAD:
- session-summary.md (no session ID)
- notes-oct-8.md (non-standard format)
- temp.md (no context)
```

**Permanent documents do NOT include session ID**:
```
PERMANENT (no session ID):
- CHANGELOG.md
- ROADMAP.md
- workflows/v0.12-AFFIRMATIVE_RIGHTS_WORKFLOW.md
- schemas/v0.12-agencies-simplified-schema.json
```

## Document Classification System

### Category 1: PERMANENT RECORDS (Keep Forever)

**Definition**: Documents that are part of the project's permanent knowledge base

**Examples**:
- `README.md`
- `CHANGELOG.md`
- `ROADMAP.md`
- `CLAUDE.md`
- `schemas/*.json`
- `workflows/*.md`
- `documentation/*.md` (verified documentation)
- `data/**/*.json` (verified data)
- `scripts/**/*.py` (production scripts)

**Lifecycle**: Created → Updated → Never Deleted

**Naming**: No session ID, descriptive purpose-based names

### Category 2: SESSION SUMMARIES (Temporary → Extract → Delete)

**Definition**: Documents that capture session work but are not permanent

**Examples**:
- `S-{ID}_session-summary.md`
- `S-{ID}_decision-log.md`
- `S-{ID}_worker-analysis.md`
- `S-{ID}_audit-report.md`

**Lifecycle**:
1. Created during session with session ID
2. Reviewed at session end
3. Key information extracted to permanent records
4. **Deleted after extraction**

**Extraction Targets**:
- Action items → `ROADMAP.md`
- Decisions → `CHANGELOG.md` (decision log section)
- Lessons learned → `CLAUDE.md` (continuous improvement)
- Metrics → Project tracking spreadsheet/database

### Category 3: WORKING DOCUMENTS (Temporary → Integrate → Delete)

**Definition**: Documents created as part of development but not final deliverables

**Examples**:
- `S-{ID}_draft-workflow.md` (becomes permanent workflow)
- `S-{ID}_schema-proposal.json` (becomes permanent schema)
- `S-{ID}_test-extraction.json` (proof of concept)
- `S-{ID}_analysis-notes.md` (becomes section in documentation)

**Lifecycle**:
1. Created during session with session ID
2. Refined and finalized
3. **Content integrated** into permanent document
4. **Deleted after integration**

**Integration Process**:
- Draft → Final: Rename, remove session ID, commit as permanent
- Notes → Documentation: Copy content to appropriate doc, delete original
- Test → Example: Move to examples/, remove session ID

### Category 4: VERIFICATION ARTIFACTS (Temporary → Verify → Delete)

**Definition**: Documents created to verify work but not needed after verification

**Examples**:
- `S-{ID}_validation-results.txt`
- `S-{ID}_test-output.log`
- `S-{ID}_comparison-report.md`
- `S-{ID}_quality-check.md`

**Lifecycle**:
1. Created during verification
2. Used to confirm quality/correctness
3. Result noted in permanent record (CHANGELOG or commit message)
4. **Deleted after verification complete**

### Category 5: TEMPLATES (Permanent Until Completed)

**Definition**: Unverified templates awaiting data

**Examples**:
- `data/states/{state}/agencies-TEMPLATE.json`
- `data/v0.12/rights/{state}-rights-TEMPLATE.json`

**Lifecycle**:
1. Created from template generator
2. Assigned to worker
3. Worker fills in verified data
4. **Renamed** (remove -TEMPLATE suffix) when complete
5. Original template deleted, completed file committed

**Special Handling**:
- Keep template until verified replacement exists
- Mark clearly as UNVERIFIED in filename
- Delete only after verified version committed

## Session End Workflow

### Phase 1: Document Inventory (Automated)

At session end, Claude Code generates inventory by searching for:

```bash
# Find all documents with today's session ID
find . -name "S-20251008-*" -type f

# Find all documents modified in this session
find . -type f -mmin -120  # Files modified in last 2 hours

# Find all TEMPLATE files
find . -name "*-TEMPLATE.*" -type f

# Find all UNVERIFIED files
find . -name "*UNVERIFIED*" -type f
```

### Phase 2: Classification Analysis

**For each document found, Claude Code determines**:

1. **Category**: Permanent / Session Summary / Working / Verification / Template
2. **Disposition**: Keep / Extract & Delete / Integrate & Delete / Delete / Rename
3. **Extraction Target**: Where information should go (CHANGELOG, ROADMAP, etc.)
4. **Action Required**: What user must do

### Phase 3: Session Cleanup Report

**Generated automatically at session end**:

```markdown
# SESSION CLEANUP REPORT
Session ID: S-20251008-1257-PLAN
Session Duration: 2 hours
Documents Created: 9
Documents Modified: 3

## PERMANENT RECORDS CREATED (Keep)
✅ workflows/v0.12-AFFIRMATIVE_RIGHTS_WORKFLOW.md
✅ workflows/v0.12-AGENCIES_SIMPLIFIED_WORKFLOW.md
✅ workflows/AGENT_INSTRUCTIONS_AGENCIES_DATA_COLLECTION.md
✅ schemas/v0.12-agencies-simplified-schema.json
✅ dev/scripts/extract-affirmative-rights.py
✅ dev/scripts/generate-agency-templates.py

Action: Commit these files ✓

## SESSION SUMMARY (Extract → Delete)
📄 SESSION_SUMMARY_2025-10-08.md

Extract to:
- CHANGELOG.md (decisions section)
  * Task separation: affirmative rights vs comprehensive research
  * Agencies scope limited to 15-25 main state agencies
  * Git worktree strategy adopted
  * Template standardization implemented

- ROADMAP.md (update Phase 1 timeline)
  * Affirmative rights: 2-3 weeks for 4 jurisdictions
  * Agencies: 6-8 weeks for 4 jurisdictions
  * Full rollout: 20-27 weeks for all 52 jurisdictions

- CLAUDE.md (lessons learned)
  * Precise instructions prevent scope creep
  * Templates ensure consistency
  * Verification required before acceptance
  * Maintenance protocols documented upfront

Action after extraction:
→ git add CHANGELOG.md ROADMAP.md CLAUDE.md
→ git commit -m "docs: Update from session S-20251008-1257-PLAN"
→ rm SESSION_SUMMARY_2025-10-08.md ✓

## TEMPLATES CREATED (Keep Until Verified)
📋 data/states/*/agencies-TEMPLATE.json (52 files)

Action: Keep until workers complete verified versions
Status: UNVERIFIED - do not commit to main branch
Disposition: Delete after verified agencies.json created

## WORKING DOCUMENTS (Already Integrated)
✅ data/v0.12/affirmative-rights/texas-affirmative-rights-UNVERIFIED.json

Status: Example extraction, demonstrates workflow
Disposition: Keep as example until Texas verified version created

## VERIFICATION ARTIFACTS (None This Session)
No verification artifacts created.

## RECOMMENDED ACTIONS

1. COMMIT permanent records:
   git add workflows/*.md schemas/*.json dev/scripts/*.py
   git commit -m "feat(v0.12): Add simplified workflows and templates

   - Affirmative rights extraction workflow (1hr/jurisdiction)
   - Agencies simplified workflow (15-25 main agencies only)
   - Precise agent instructions with templates
   - Automated extraction and template generation scripts

   Related: S-20251008-1257-PLAN"

2. EXTRACT session summary to permanent records:
   - Update CHANGELOG.md with decisions
   - Update ROADMAP.md with timelines
   - Update CLAUDE.md with lessons learned

3. DELETE session summary after extraction:
   rm SESSION_SUMMARY_2025-10-08.md

4. VERIFY templates before next session:
   - Review one template for accuracy
   - Test agent instructions clarity
   - Prepare for worker assignment

## CLEANUP COMMANDS

```bash
# After extracting to CHANGELOG/ROADMAP/CLAUDE.md:
rm SESSION_SUMMARY_2025-10-08.md

# Total disk space recovered: ~50KB
```

## REPOSITORY STATE AFTER CLEANUP
- Permanent records: 6 new files committed
- Session summaries: 0 (cleaned up)
- Templates: 52 (awaiting workers)
- Repository size increase: ~200KB (all permanent)
- Clutter prevented: 1 session summary removed after extraction
```

## Integration Targets for Common Session Types

### Planning Sessions (TYPE=PLAN)

**Extract From**:
- Session summaries
- Decision logs
- Strategy documents

**Extract To**:
- `CHANGELOG.md` → Decisions Made section
- `ROADMAP.md` → Updated milestones and timelines
- `CLAUDE.md` → Workflow improvements, lessons learned
- `documentation/ARCHITECTURE.md` → System design changes

### Data Collection Sessions (TYPE=DATA)

**Extract From**:
- Worker completion reports
- Verification audits
- Data quality analyses

**Extract To**:
- `CHANGELOG.md` → Data added/updated
- `documentation/DATA_COMPLETENESS.md` → Current status
- Database imports (execute then delete reports)

### Code Development Sessions (TYPE=CODE)

**Extract From**:
- Implementation notes
- Test results
- Performance benchmarks

**Extract To**:
- Commit messages (detailed)
- `CHANGELOG.md` → Features added
- Code comments (inline documentation)
- Delete temporary notes after commit

### Debugging Sessions (TYPE=DEBUG)

**Extract From**:
- Bug reports
- Debug logs
- Fix verification

**Extract To**:
- `CHANGELOG.md` → Bugs fixed
- GitHub issues (close with fix details)
- Delete debug artifacts after fix verified

## Permanent Record Update Protocol

### CHANGELOG.md Format

```markdown
# Changelog

## [Unreleased]

### Added (Session S-20251008-1257-PLAN)
- Affirmative rights extraction workflow - simplified from 14-22hrs to 1hr per jurisdiction
- Agencies simplified workflow - limited to 15-25 main state agencies (not all agencies)
- Precise agent task instructions with templated data collection
- Automated statutory text extraction script
- Git worktree strategy for parallel verification

### Changed (Session S-20251008-1257-PLAN)
- Task separation: affirmative rights extraction (v0.12) vs comprehensive research (v0.13+)
- Agencies scope: main state agencies only, excluding local governments
- Template standardization: 52 identical templates with bracketed placeholders

### Decisions Made (Session S-20251008-1257-PLAN)
- Extract affirmative rights directly from statutory text files (not deep research)
- Limit agencies to 15-25 main state agencies per jurisdiction
- Use git worktrees for parallel verification without contamination
- Require source_verified field on all data before production
- Implement maintenance protocols from the start

### Deprecated
- Multi-worker bulk generation approach (produced unverified data with errors)
- "Get all agencies" interpretation (too broad, unmaintainable)
```

### ROADMAP.md Format

```markdown
# Roadmap

## Current Phase: v0.12 Data Collection

### Updated Timelines (from Session S-20251008-1257-PLAN)

#### Phase 1: Proof of Concept (Weeks 1-3)
- [ ] Federal affirmative rights verification (1 week)
- [ ] Texas agencies complete (1 week)
- [ ] California, Illinois initial work (1 week)
- Timeline: 2-3 weeks

#### Phase 2: Priority States (Weeks 4-11)
- [ ] 12 additional states affirmative rights
- [ ] 12 additional states agencies
- Timeline: 8 weeks

#### Phase 3: Full Rollout (Weeks 12-27)
- [ ] Remaining 36 jurisdictions
- Timeline: 16 weeks

**Total to completion: 20-27 weeks** (revised from previous estimate)

### New Approaches (from Session S-20251008-1257-PLAN)
- Git worktree workflow for parallel verification
- Template-based data collection (eliminate formatting variations)
- Maintenance protocols integrated from start
```

### CLAUDE.md Format

```markdown
## Lessons Learned

### Session S-20251008-1257-PLAN (October 8, 2025)

#### What Worked
- ✅ **Precise task definitions**: Eliminated "get all agencies" ambiguity with exact list
- ✅ **Template standardization**: 52 identical templates prevent formatting variations
- ✅ **Git worktrees**: Enable parallel work without main branch contamination
- ✅ **User clarification**: Asking for specifics revealed overcomplications

#### What Didn't Work Before
- ❌ **Vague requirements**: "Get rights" interpreted 5 different ways by workers
- ❌ **No scope limits**: "Get agencies" led to collecting thousands of local governments
- ❌ **Trust without verification**: 1.6% error rate in supposedly verified data
- ❌ **No maintenance plan**: Data would become stale without update protocol

#### Process Improvements Implemented
1. **Task Separation**: Distinguish extraction (simple) from research (complex)
2. **Scope Limitation**: Specify exact count (15-25 agencies, not "all")
3. **Template Enforcement**: Workers fill blanks only, no structural decisions
4. **Verification Requirements**: source_verified field mandatory with documentation
5. **Maintenance Protocol**: Term tracking, source documentation, update schedules

#### Patterns to Reuse
- When scope unclear, provide exact list of what to collect
- When consistency needed, use templates with bracketed placeholders
- When data changes over time, build maintenance protocol from start
- When isolating work, use git worktrees instead of branches
- When unsure, ask user to clarify before proceeding

#### Patterns to Avoid
- Broad task definitions without specific constraints
- Trusting AI-generated content without primary source verification
- Allowing workers to make formatting/structure decisions
- Deferring maintenance planning until after data collection
```

## Automation Script for Session Cleanup

```bash
#!/bin/bash
# .claude/scripts/session-cleanup.sh

SESSION_ID="$1"  # e.g., S-20251008-1257-PLAN

if [ -z "$SESSION_ID" ]; then
  echo "Usage: ./session-cleanup.sh S-YYYYMMDD-HHMM-TYPE"
  exit 1
fi

echo "=== SESSION CLEANUP: $SESSION_ID ==="
echo ""

echo "📋 Documents created this session:"
find . -name "${SESSION_ID}*" -type f

echo ""
echo "📝 Modified documents (last 2 hours):"
find . -type f -mmin -120 | grep -v ".git"

echo ""
echo "⚠️  TEMPLATE files (pending verification):"
find . -name "*-TEMPLATE.*" -type f

echo ""
echo "⚠️  UNVERIFIED files:"
find . -name "*UNVERIFIED*" -type f

echo ""
echo "=== CLEANUP CHECKLIST ==="
echo "1. Extract session summary to CHANGELOG.md, ROADMAP.md, CLAUDE.md"
echo "2. Commit permanent records"
echo "3. Delete session summaries: rm ${SESSION_ID}_*.md"
echo "4. Review templates: keep until verified versions created"
echo ""
echo "Run: git add CHANGELOG.md ROADMAP.md CLAUDE.md"
echo "     git commit -m 'docs: Update from session ${SESSION_ID}'"
```

## Session End Checklist Template

```markdown
# SESSION END CHECKLIST: {SESSION_ID}

## 1. Document Inventory
- [ ] List all files created with session ID
- [ ] List all files modified in session
- [ ] Identify templates created
- [ ] Identify unverified artifacts

## 2. Extraction
- [ ] Extract decisions to CHANGELOG.md
- [ ] Extract timelines to ROADMAP.md
- [ ] Extract lessons to CLAUDE.md
- [ ] Extract metrics to tracking system

## 3. Commit Permanent Records
- [ ] git add all permanent files
- [ ] Write descriptive commit message with session ID
- [ ] git commit

## 4. Cleanup
- [ ] Delete session summaries (after extraction verified)
- [ ] Delete working documents (after integration verified)
- [ ] Delete verification artifacts (after verification complete)
- [ ] Keep templates until verified replacements exist

## 5. Verification
- [ ] CHANGELOG.md updated correctly
- [ ] ROADMAP.md reflects current state
- [ ] CLAUDE.md includes lessons learned
- [ ] No session-ID files remain except templates
- [ ] Repository is clean and organized

## 6. Handoff
- [ ] Next session priorities documented
- [ ] Blockers identified in ROADMAP.md
- [ ] Clear starting point for next work
```

---

## Implementation

### Add to .claude/hooks/session-end.sh

```bash
#!/bin/bash
# Automatically run at session end

# Generate session ID
SESSION_DATE=$(date +%Y%m%d)
SESSION_TIME=$(date +%H%M)
SESSION_TYPE="PLAN"  # Can be parameterized
SESSION_ID="S-${SESSION_DATE}-${SESSION_TIME}-${SESSION_TYPE}"

# Run cleanup script
.claude/scripts/session-cleanup.sh "$SESSION_ID"

# Generate cleanup report
echo ""
echo "=== SESSION CLEANUP REPORT ==="
echo "Session: $SESSION_ID"
echo "Generated: $(date)"
echo ""
echo "Review checklist and confirm extractions before deleting session documents."
```

### Add to CLAUDE.md

```markdown
## End of Session Protocol

When user says "we're done" or "end session":

1. **Generate Session ID**: S-YYYYMMDD-HHMM-TYPE
2. **Inventory documents**: Find all session-ID and recently modified files
3. **Classify each document**: Permanent / Extract / Integrate / Delete
4. **Generate cleanup report**: Show user what to extract/delete
5. **Provide extraction guidance**: Specific text for CHANGELOG/ROADMAP/CLAUDE.md
6. **Execute cleanup commands**: After user confirms extraction complete

Example:
User: "We're done for today"
Claude: [Generates session cleanup report with specific actions]
User: "I've updated CHANGELOG and ROADMAP"
Claude: "Confirmed. Deleting session summaries..." [executes cleanup]
```

---

**Protocol Version**: 1.0
**Created**: 2025-10-08
**Next Review**: After 3 sessions to refine based on usage
