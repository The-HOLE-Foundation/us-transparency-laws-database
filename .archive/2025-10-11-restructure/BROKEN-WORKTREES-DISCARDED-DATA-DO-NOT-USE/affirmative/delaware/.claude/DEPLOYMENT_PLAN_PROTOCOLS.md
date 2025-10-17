---
DATE: 2025-10-08
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - Organization-Wide Standards
PURPOSE: Deploy session management and versioning protocols across all repositories
---

# Protocol Deployment Plan

## Overview

Deploy two critical protocols organization-wide:
1. **Session Document Management Protocol** - Prevent repository clutter, preserve knowledge
2. **Versioning Guidelines** - Ensure consistency across all artifacts

## Deployment Strategy

### Tier 1: Foundation-Wide Standards (foundation-meta)
**Location**: `/Volumes/HOLE-RAID-DRIVE/HOLE/Github/foundation-meta/.claude/`

**Purpose**: Central source of truth for all HOLE Foundation projects

**Files to Create**:
- `.claude/SESSION_DOCUMENT_MANAGEMENT_PROTOCOL.md` (master copy)
- `.claude/VERSIONING_GUIDELINES.md` (master copy)
- `.claude/STANDARDS_INDEX.md` (new - index of all org standards)

**Updates Required**:
- `foundation-meta/README.md` - Add protocols section
- Create `.claude/` directory if doesn't exist

### Tier 2: Global User Configuration
**Location**: `/Users/jth/.claude/CLAUDE.md`

**Purpose**: Apply to ALL projects user works on

**Updates**:
- Add "Session End Protocol" section
- Add "Versioning Standards" reference
- Link to foundation-meta for full protocols

### Tier 3: Project-Specific Implementation
**Repositories**:
1. `us-transparency-laws-database` (current) ✅ Already has protocols
2. `THEHOLETRUTH.ORG` (platform)
3. `Theholefoundation.org` (marketing site)

**For Each Repo**:
- Create `.claude/` directory
- Copy protocols from foundation-meta
- Customize for project specifics (if needed)
- Update project CLAUDE.md with protocol references

## Implementation Steps

### Step 1: Foundation-Meta (Master Repository)
```bash
cd /Volumes/HOLE-RAID-DRIVE/HOLE/Github/foundation-meta

# Create .claude directory
mkdir -p .claude

# Copy protocols from us-transparency-laws-database
cp ../us-transparency-laws-database/.claude/SESSION_DOCUMENT_MANAGEMENT_PROTOCOL.md .claude/
cp ../us-transparency-laws-database/.claude/VERSIONING_GUIDELINES.md .claude/

# Create standards index
# (to be generated)
```

### Step 2: Global CLAUDE.md
```bash
# Update /Users/jth/.claude/CLAUDE.md with:
# - Session end protocol section
# - Versioning standards reference
# - Link to foundation-meta protocols
```

### Step 3: THEHOLETRUTH.ORG
```bash
cd /Volumes/HOLE-RAID-DRIVE/HOLE/Projects/THEHOLETRUTH.ORG

# Create .claude directory
mkdir -p .claude

# Symlink to foundation-meta (keeps protocols in sync)
ln -s /Volumes/HOLE-RAID-DRIVE/HOLE/Github/foundation-meta/.claude/SESSION_DOCUMENT_MANAGEMENT_PROTOCOL.md .claude/
ln -s /Volumes/HOLE-RAID-DRIVE/HOLE/Github/foundation-meta/.claude/VERSIONING_GUIDELINES.md .claude/

# Or copy if symlinks not preferred
```

### Step 4: Theholefoundation.org
```bash
cd /Volumes/HOLE-RAID-DRIVE/HOLE/Github/Theholefoundation.org

# Same as THEHOLETRUTH.ORG
```

## File Placement Matrix

| Protocol | foundation-meta | Global CLAUDE.md | Project Repos | Purpose |
|----------|----------------|------------------|---------------|---------|
| SESSION_DOCUMENT_MANAGEMENT_PROTOCOL.md | ✅ Full protocol | 📝 Summary only | 🔗 Symlink/Copy | Master copy |
| VERSIONING_GUIDELINES.md | ✅ Full protocol | 📝 Reference only | 🔗 Symlink/Copy | Master copy |
| STANDARDS_INDEX.md | ✅ Create new | ❌ Not needed | ❌ Not needed | Central index |

## Global CLAUDE.md Integration

### Section to Add: "Session End Protocol"

```markdown
## Session End Protocol (Organization-Wide Standard)

When ending any work session, follow The HOLE Foundation's standard protocol:

### Automatic Session Cleanup
1. **Generate Session ID**: `S-YYYYMMDD-HHMM-TYPE`
   - TYPE: PLAN, DATA, CODE, DEBUG, REVIEW, DOCS, CLEANUP

2. **Classify Documents**:
   - **PERMANENT**: Keep forever (workflows, schemas, verified data)
   - **SESSION**: Extract → Delete (session summaries, decision logs)
   - **WORKING**: Integrate → Delete (drafts, proposals)
   - **VERIFICATION**: Verify → Delete (test outputs, validation reports)
   - **TEMPLATES**: Keep until verified version exists

3. **Extract to Permanent Records**:
   - Decisions → `CHANGELOG.md`
   - Timelines → `ROADMAP.md`
   - Lessons → `CLAUDE.md`
   - Metrics → Tracking system

4. **Cleanup**:
   - Delete session summaries after extraction
   - Delete working documents after integration
   - Keep repository clean and organized

### Full Protocol
See: `/Volumes/HOLE-RAID-DRIVE/HOLE/Github/foundation-meta/.claude/SESSION_DOCUMENT_MANAGEMENT_PROTOCOL.md`

### Versioning Standards
All templates, schemas, and workflows must follow versioning guidelines.
See: `/Volumes/HOLE-RAID-DRIVE/HOLE/Github/foundation-meta/.claude/VERSIONING_GUIDELINES.md`
```

## Foundation-Meta Standards Index

### New File: foundation-meta/.claude/STANDARDS_INDEX.md

```markdown
---
DATE: 2025-10-08
AUTHOR: The HOLE Foundation
PROJECT: Organization-Wide Standards
VERSION: 1.0
---

# The HOLE Foundation - Engineering Standards Index

## Purpose
Central registry of all engineering standards, protocols, and best practices used across HOLE Foundation projects.

## Core Protocols

### 1. Session Document Management
**File**: `SESSION_DOCUMENT_MANAGEMENT_PROTOCOL.md`
**Version**: 1.0
**Applies To**: All repositories
**Purpose**: Prevent document clutter, preserve knowledge, maintain clean repositories

**Key Concepts**:
- Session ID system: `S-YYYYMMDD-HHMM-TYPE`
- Document lifecycle management
- Extraction to permanent records
- Cleanup procedures

### 2. Versioning Guidelines
**File**: `VERSIONING_GUIDELINES.md`
**Version**: 1.0
**Applies To**: All repositories
**Purpose**: Consistent versioning across templates, schemas, workflows, and data files

**Key Concepts**:
- Version naming: `vMAJOR.MINOR`
- File naming standards
- Version compatibility matrix
- Migration procedures

## Repository-Specific Standards

### us-transparency-laws-database
- Data validation: 100% accuracy requirement
- Source verification: Official .gov sites only
- Git worktree workflow for parallel work

### THEHOLETRUTH.ORG
- Component standards (to be documented)
- API integration patterns (to be documented)

### Theholefoundation.org
- Marketing site standards (to be documented)

## Global Workflows

### DOCUMENT → PLAN → IMPLEMENT
**Source**: `/Users/jth/.claude/CLAUDE.md`
**Applies To**: All projects

1. **DOCUMENT**: Update project documentation first
2. **PLAN**: Create implementation plan
3. **IMPLEMENT**: Execute with audit trail

## Adding New Standards

To add a new organization-wide standard:

1. Create protocol document in `foundation-meta/.claude/`
2. Add entry to this index
3. Update affected project repositories
4. Reference in global CLAUDE.md if applicable
5. Communicate to team

## Maintenance

**Review Schedule**: Quarterly
**Owner**: Engineering lead
**Last Updated**: 2025-10-08
**Next Review**: 2026-01-08
```

## Benefits of This Deployment

### Organization-Wide
- ✅ Consistent practices across all projects
- ✅ Reduced onboarding time for new projects
- ✅ Institutional knowledge preservation
- ✅ Clean, maintainable repositories

### Developer Experience
- ✅ Clear guidelines for session cleanup
- ✅ No ambiguity on versioning
- ✅ Automatic protocol application via global CLAUDE.md
- ✅ Easy reference to master protocols

### Repository Health
- ✅ No accumulation of temporary documents
- ✅ Clear version tracking
- ✅ Consistent structure across repos
- ✅ Easier code reviews and audits

## Migration Path for Existing Projects

### For Projects Without .claude/ Directory
1. Create `.claude/` directory
2. Symlink or copy protocols from foundation-meta
3. Update project CLAUDE.md with protocol references
4. Run one-time cleanup of existing session documents

### For Projects With Existing Standards
1. Review existing standards for conflicts
2. Merge with foundation-meta protocols
3. Document project-specific variations
4. Update foundation-meta if broadly applicable

## Success Metrics

### Immediate (Week 1)
- [ ] foundation-meta protocols created
- [ ] Global CLAUDE.md updated
- [ ] All 3 main repos have protocols

### Short-term (Month 1)
- [ ] Zero session documents older than 1 week
- [ ] All new templates properly versioned
- [ ] Standards index maintained

### Long-term (Quarter 1)
- [ ] 100% protocol compliance across repos
- [ ] Protocols referenced in code reviews
- [ ] New team members trained on standards

## Implementation Order

1. ✅ **foundation-meta** (master copy - FIRST)
2. ✅ **Global CLAUDE.md** (applies to all projects)
3. **THEHOLETRUTH.ORG** (highest priority project)
4. **us-transparency-laws-database** (already has protocols, just link to master)
5. **Theholefoundation.org** (marketing site)
6. Any future projects

## Next Steps

Execute in this order:
1. Create foundation-meta/.claude/ with protocols
2. Create STANDARDS_INDEX.md
3. Update global CLAUDE.md
4. Deploy to THEHOLETRUTH.ORG
5. Link us-transparency-laws-database to master
6. Deploy to Theholefoundation.org
7. Document completion and notify team

---

**Status**: Ready for implementation
**Estimated Time**: 1-2 hours
**Priority**: High (prevents future technical debt)
