# THE HOLE FOUNDATION - DEVELOPMENT STANDARDS
## Foundation-Wide Architecture & Development Guidelines
**Version**: v0.1.0-alpha  
**Created**: September 23, 2025  
**Authority**: The HOLE Foundation Technical Standards Board  

---

## TABLE OF CONTENTS

1. [Database Architecture Standards](#database-architecture-standards)
2. [Git Workflow Standards](#git-workflow-standards)
3. [Naming Conventions](#naming-conventions)
4. [Code Quality Standards](#code-quality-standards)
5. [Documentation Requirements](#documentation-requirements)
6. [AI Agent Standards](#ai-agent-standards)

---

## DATABASE ARCHITECTURE STANDARDS

### Schema Organization Principles

**All HOLE Foundation databases MUST follow this four-schema architecture:**

```sql
-- 1. LEGAL_REFERENCE - Static legal documents and statutes
--    USE: Wiki functionality, vector database source material
--    ACCESS: Public read, admin write

-- 2. TRANSPARENCY_DATA - Structured comparison data  
--    USE: Map interfaces, public comparisons, quick lookups
--    ACCESS: Public read, admin write

-- 3. STRATEGIC_INTELLIGENCE - Tactical knowledge and AI training data
--    USE: AI agent training, insider knowledge, strategic guidance
--    ACCESS: Authenticated read, admin write

-- 4. OPERATIONS - User application data
--    USE: User requests, profiles, sessions, operational data
--    ACCESS: User-specific CRUD operations
```

### Mandatory Table Elements

**Every table MUST include:**
- `id uuid PRIMARY KEY DEFAULT gen_random_uuid()`
- `created_at timestamptz DEFAULT now()`
- `updated_at timestamptz DEFAULT now()`
- Appropriate indexes for query performance
- RLS (Row Level Security) enabled with appropriate policies

### RLS Policy Standards

**Access Pattern Matrix:**
```
Schema                  | Public Read | Auth Read | Auth Write | Admin Write
------------------------|-------------|-----------|------------|------------
legal_reference        | ✅          | ✅        | ❌         | ✅
transparency_data       | ✅          | ✅        | ❌         | ✅  
strategic_intelligence  | ❌          | ✅        | ❌         | ✅
operations             | ❌          | User-Only | User-Only  | ✅
```

---

## GIT WORKFLOW STANDARDS

### Branch Structure (MANDATORY)

```
main (protected)
├── testing (protected, requires passing tests)  
├── development (active development)
└── feature/* (individual features)
```

### Version Numbering System

**Format**: `vMAJOR.MINOR.PATCH-STAGE`

**Examples:**
- `v0.1.0-alpha` - Initial alpha release
- `v0.1.1-alpha` - Alpha patch  
- `v0.2.0-beta` - Beta milestone
- `v1.0.0` - Production release

**Version Increments:**
- **MAJOR**: Breaking changes, new major features
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, small improvements
- **STAGE**: `alpha` → `beta` → `rc` → (none for stable)

### Branch Protection Requirements

**Main Branch Protection:**
- ✅ Require pull request reviews (minimum 1)
- ✅ Require status checks to pass  
- ✅ Require branches to be up to date
- ✅ Require signed commits
- ✅ Include administrators in restrictions

**Testing Branch Protection:**
- ✅ Require all tests to pass
- ✅ Require code quality checks
- ✅ Require security scans

---

## NAMING CONVENTIONS

### Database Objects

**Schemas**: `snake_case` descriptive names
```sql
legal_reference          -- ✅ Good
transparency_data        -- ✅ Good  
strategic_intelligence   -- ✅ Good
foia_operations         -- ✅ Good
```

**Tables**: `snake_case` plural nouns
```sql
state_profiles          -- ✅ Good
court_precedents        -- ✅ Good
obstruction_patterns    -- ✅ Good
```

**Columns**: `snake_case` descriptive names
```sql
state_code              -- ✅ Good
response_time_days      -- ✅ Good
success_rate_percentage -- ✅ Good
```

### Files and Directories

**Migration Files**: `NNNNN_descriptive_name.sql`
```
00001_create_foundation_architecture.sql  -- ✅ Good
00002_create_rls_policies.sql             -- ✅ Good
```

**Seed Files**: `NN_schema_name_seed.sql`
```
01_legal_reference_seed.sql    -- ✅ Good
02_transparency_data_seed.sql  -- ✅ Good
```

**Scripts**: `kebab-case` with action-object pattern
```
process-transparency-data.js   -- ✅ Good
validate-statute-text.js       -- ✅ Good
```

---

## CODE QUALITY STANDARDS

### SQL Standards

**Migration File Structure:**
```sql
-- ==========================================
-- PROJECT NAME - PURPOSE
-- Migration: Descriptive Name  
-- Version: vX.Y.Z-stage
-- Created: YYYY-MM-DD
-- ==========================================

-- Clear section headers
-- ==========================================
-- 1. SCHEMA CREATION
-- ==========================================

-- Descriptive comments for complex operations
CREATE TABLE schema.table_name (
    -- Primary key (MANDATORY)
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Business fields with constraints
    field_name varchar(100) NOT NULL CHECK (condition),
    
    -- Timestamps (MANDATORY)
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Success confirmation (MANDATORY)
SELECT 'Operation completed successfully' as status;
```

### JavaScript/Node.js Standards

**File Header Template:**
```javascript
/**
 * THE HOLE FOUNDATION - [Purpose]
 * [Detailed description]
 * Version: vX.Y.Z-stage
 * Created: YYYY-MM-DD
 */
```

**Class Structure:**
```javascript
class FoundationDataProcessor {
    constructor() {
        this.config = CONFIG;
        this.version = 'v0.1.0-alpha';
    }

    /**
     * Main processing function with clear documentation
     */
    async processData() {
        console.log('🏛️  THE HOLE FOUNDATION - [Tool Name] v' + this.version);
        // Implementation
    }
}
```

---

## DOCUMENTATION REQUIREMENTS

### README Structure (MANDATORY)

Every project MUST include:

```markdown
# Project Name
## The HOLE Foundation - [Project Purpose]

### Overview
Clear description of project purpose and scope.

### Architecture
Link to database schema and system architecture.

### Installation
Step-by-step setup instructions.

### Usage  
Clear examples of common operations.

### Development
Local development setup and contribution guidelines.

### License
The HOLE Foundation - All Rights Reserved
```

### Database Documentation

**Schema Documentation Template:**
```sql
-- Schema: [schema_name]
-- Purpose: [Clear description of use case]
-- Access Pattern: [Who can read/write]
-- Performance Notes: [Index strategy, query patterns]

COMMENT ON SCHEMA [schema_name] IS '[Detailed description]';
```

---

## AI AGENT STANDARDS

### Agent Development Guidelines

**When working with future AI agents, ALWAYS:**

1. **Reference these standards** - Link to this document
2. **Follow naming conventions** - Use exact patterns shown
3. **Maintain architecture** - Never deviate from schema design
4. **Document thoroughly** - Include purpose and rationale
5. **Test thoroughly** - Verify all functionality works

### Agent Handoff Requirements

**When completing work, ALWAYS provide:**
- ✅ Summary of changes made
- ✅ Files created/modified  
- ✅ Tests that should be run
- ✅ Next steps for continuation
- ✅ Reference to applicable standards sections

### Quality Assurance Checklist

**Before considering work complete:**
- [ ] All naming conventions followed
- [ ] Database architecture maintained
- [ ] RLS policies properly configured
- [ ] Documentation updated
- [ ] Version numbers incremented properly
- [ ] Migration files numbered sequentially
- [ ] Success/status messages included

---

## ENFORCEMENT

### Compliance Requirements

**ALL HOLE Foundation projects MUST:**
- Follow these standards without exception
- Update standards when improvements identified  
- Train new team members on these requirements
- Review compliance during code reviews

### Standard Updates

**Process for updating these standards:**
1. Identify improvement opportunity
2. Document proposed change with rationale
3. Test in pilot project
4. Update standards document
5. Communicate changes to all projects

---

## CONTACT

**The HOLE Foundation Technical Standards Board**  
Email: `development-standards@theholetruth.org`  
Version Control: `https://github.com/hole-foundation/development-standards`

**Document Revision History:**
- v0.1.0-alpha (2025-09-23): Initial standards creation

---

*These standards ensure consistent, high-quality development across all HOLE Foundation transparency and accountability projects.*
