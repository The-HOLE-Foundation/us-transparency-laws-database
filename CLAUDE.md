# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Document Standards (GLOBAL REQUIREMENT)

**Every document generated must include the following header:**

```
---
DATE: [YYYY-MM-DD]
AUTHOR: [Author Name or "Claude Code AI Assistant"]
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: [Specific component, e.g., "Supabase Schema Design", "Data Validation", "Process Maps"]
VERSION: v0.11 or v0.12 (depending on context)
---
```

This applies to all markdown files, documentation, reports, schemas, and any other documents created for this project.

## Project Overview

This repository is a comprehensive database of US transparency laws (FOIA and public records laws) for all 52 jurisdictions (50 states + DC + Federal).

**Current Status**:
- **v0.11.1**: PRODUCTION READY - Supabase database deployed with 52 jurisdictions, 365 exemptions
- **v0.12**: IN DEVELOPMENT - Rights of Access table to complement exemptions

**Critical**: This database serves as ground truth for AI training. **100% accuracy is mandatory**. All data must be verified from official government sources only (state legislature websites, official state code databases, official AG offices, official agency .gov sites).

## Repository Structure

```
us-transparency-laws-database/
├── templates/                          # v0.11 templates for all data types
│   ├── json/                          # JSON templates (jurisdictions, agencies, databases)
│   ├── markdown/                      # Process map templates
│   ├── statutory-text_template-v0.11.txt
│   └── state-agencies_template-v0.11.json
├── data/
│   ├── federal/                       # Federal FOIA data (jurisdiction-data.json, templates.json)
│   ├── states/                        # 50 state directories, each with jurisdiction-data.json
│   └── consolidated/                  # Master database and tracking table
├── consolidated-transparency-data/
│   ├── verified-process-maps/         # Jurisdiction-specific process maps
│   └── statutory-text-files/          # Full statutory text (currently empty)
├── documentation/                      # Validation methodology, verification guides
├── statutory-data/                     # Ground truth data organized by version
├── schemas/                           # Data validation schemas (currently empty)
└── scripts/                           # Migration scripts (Python and shell)
```

## Data Architecture

### Four-Layer Data Model (v0.11.1)

1. **Raw Statutory Data** (`statutory-data/`, `releases/v0.11.0/`)
   - Full statute text files
   - Official statutory citations
   - Ground truth from official sources only
   - v0.11.0: Complete JSON files for all 52 jurisdictions

2. **Supabase PostgreSQL Database** (`supabase/` - **PRODUCTION READY**)
   - **10 Core Tables**: jurisdictions, transparency_laws, response_requirements, fee_structures, exemptions, appeal_processes, requester_requirements, agency_obligations, oversight_bodies, agencies
   - **1 Optimized View**: `transparency_map_display` for interactive map
   - **365 exemptions** with automatic jurisdiction context
   - **52 jurisdictions** fully imported (Federal + 50 States + DC)
   - **JSONB additional_fields** preserves jurisdiction-specific variations
   - **7 migrations** successfully deployed to development branch

3. **Structured Source Data** (`releases/v0.11.0/jurisdictions/`)
   - 52 JSON files (one per jurisdiction)
   - Nested structure with transparency_law object
   - Source of truth for Supabase imports
   - Each file contains: response_requirements, fee_structure, exemptions, appeal_process, requester_requirements, agency_obligations, oversight_body, validation_metadata

4. **Transparency Map Dataset** (`Transparency-Map-Dataset/`)
   - Curated 181KB JSON optimized for map display
   - Timeline code system (negative integers for flexible deadlines)
   - Now superseded by `transparency_map_display` VIEW in database

### Key Database Tables (v0.11.1)

**Core Tables**:
- **`jurisdictions`** (52 records): id, slug, name, jurisdiction_type
- **`transparency_laws`** (52 records): jurisdiction_id, name, statute_citation, effective_date, last_amended, official_resources (JSONB), validation_metadata (JSONB)
- **`response_requirements`** (52 records): transparency_law_id, initial_response_time, initial_response_unit, final_response_time, final_response_unit, extension_allowed, extension_max_days, extension_conditions, tolling_allowed, tolling_notes, **additional_fields (JSONB)**
- **`fee_structures`** (52 records): transparency_law_id, search_fee, copy_fee_per_page, electronic_fee, fee_waiver_available, fee_waiver_criteria, **additional_fields (JSONB)**
- **`exemptions`** (365 records): transparency_law_id, category, citation, description, scope, **jurisdiction_name, jurisdiction_slug, jurisdiction_code** (auto-populated via trigger)
- **`appeal_processes`** (52 records): transparency_law_id, first_level, first_level_deadline_days, second_level, attorney_fees_recoverable, **additional_fields (JSONB)**
- **`requester_requirements`** (52 records): transparency_law_id, identification_required, purpose_statement_required, residency_requirement, **additional_fields (JSONB)**
- **`agency_obligations`** (52 records): transparency_law_id, records_officer_required, business_hours_access, electronic_submission_accepted, **additional_fields (JSONB)**
- **`oversight_bodies`** (38 records): transparency_law_id, name, role, contact_info, oversight_url, **additional_fields (JSONB)**
- **`agencies`** (0 records): Deferred to v0.12

**v0.12 New Table (In Development)**:
- **`rights_of_access`** (0 records - to be populated): Affirmative rights to public records
  - Fields: transparency_law_id, jurisdiction_slug, jurisdiction_name, category, subcategory, statute_citation, description, conditions, applies_to, implementation_notes, request_tips
  - Categories: Proactive Disclosure, Enhanced Access Rights, Technology Rights, Requester-Specific Rights, Inspection Rights, Timeliness Rights
  - **Purpose**: Enable FOIA Generator to assert specific statutory rights in requests
  - **Documentation**: See [v0.12-RIGHTS_OF_ACCESS_DESIGN.md](documentation/v0.12-RIGHTS_OF_ACCESS_DESIGN.md)

**Optimized Views**:
- **`transparency_map_display`** (v0.11.1): Single-query access to all map data, flattens normalized schema, auto-generates key_features_tags
- **`transparency_landscape`** (v0.12): Combines rights_of_access and exemptions for complete transparency picture across all jurisdictions

### Querying the Database

**Example 1: Get all jurisdictions for map**
```sql
SELECT jurisdiction_name, jurisdiction_code, response_timeline_days, key_features_tags
FROM transparency_map_display
ORDER BY jurisdiction_name;
```

**Example 2: Get California exemptions (no joins!)**
```sql
SELECT category, description FROM exemptions WHERE jurisdiction_name = 'California';
```

**Example 3: Count exemptions by jurisdiction**
```sql
SELECT jurisdiction_name, COUNT(*) FROM exemptions GROUP BY jurisdiction_name ORDER BY COUNT(*) DESC;
```

**Example 4 (v0.12): Get California's proactive disclosure rights**
```sql
SELECT category, description, statute_citation, request_tips
FROM rights_of_access
WHERE jurisdiction_slug = 'california' AND category = 'Proactive Disclosure'
ORDER BY subcategory;
```

**Example 5 (v0.12): Compare rights vs exemptions for all states**
```sql
SELECT jurisdiction_name, total_rights, total_exemptions, transparency_ratio, data_status
FROM transparency_landscape
ORDER BY transparency_ratio DESC;
```

**Example 6 (v0.12): Get all technology rights across jurisdictions**
```sql
SELECT jurisdiction_name, description, statute_citation
FROM rights_of_access
WHERE category = 'Technology Rights'
ORDER BY jurisdiction_name;
```

## Data Validation Rules (CRITICAL)

### ONLY Acceptable Sources:
1. Official State Legislature Websites (e.g., legis.state.xx.us)
2. Official State Code/Statute Databases (e.g., revisor.mn.gov, codes.ohio.gov)
3. Official State Attorney General Offices (for FOIA guidance)
4. Official State Archives/Records Offices (for procedural guidance)
5. Official Agency FOIA Pages (.gov domains only)

### PROHIBITED Sources:
- Perplexity AI or any AI summarization
- Wikipedia or collaborative wikis
- Legal blog posts or commentary
- Third-party law firm summaries
- News articles or media summaries

### Data Quality Standards:
- All legal citations must be verified from official sources
- Response timelines must distinguish between business days and calendar days
- Fee structures must reflect exact statutory language
- All URLs must link directly to official .gov sites
- Validation metadata must document verification date and primary sources

## Working with This Repository

### Querying v0.11.1 Database (Current)

**Development Branch**: `https://befpnwcokngtrljxskfz.supabase.co`

All 52 jurisdictions are now deployed to Supabase. Use these patterns:

**JavaScript/TypeScript (Supabase Client)**
```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://befpnwcokngtrljxskfz.supabase.co',
  'YOUR_ANON_KEY'
)

// Get all jurisdictions for transparency map
const { data: jurisdictions } = await supabase
  .from('transparency_map_display')
  .select('jurisdiction_name, jurisdiction_code, response_timeline_days, key_features_tags')

// Get California exemptions (no joins needed!)
const { data: exemptions } = await supabase
  .from('exemptions')
  .select('category, description, legal_cite')
  .eq('jurisdiction_name', 'California')

// Get jurisdiction details
const { data: california } = await supabase
  .from('jurisdictions')
  .select(`
    *,
    transparency_laws(*),
    response_requirements(*),
    fee_structures(*),
    appeal_processes(*)
  `)
  .eq('slug', 'california')
  .single()
```

**Direct SQL Access**
```sql
-- Get states with fast response times
SELECT jurisdiction_name, response_timeline_days
FROM transparency_map_display
WHERE response_timeline_days <= 5 AND response_timeline_days > 0
ORDER BY response_timeline_days;

-- Find jurisdictions with attorney fee recovery
SELECT j.name, ap.attorney_fees_notes
FROM jurisdictions j
JOIN transparency_laws tl ON tl.jurisdiction_id = j.id
JOIN appeal_processes ap ON ap.transparency_law_id = tl.id
WHERE ap.attorney_fees_recoverable = true;

-- Analyze exemption categories across all jurisdictions
SELECT category, COUNT(*) as count, ARRAY_AGG(DISTINCT jurisdiction_name)
FROM exemptions
GROUP BY category
ORDER BY count DESC;
```

### Adding New Jurisdiction Data (Future Updates)

1. Update source JSON in `releases/v0.11.0/jurisdictions/{jurisdiction-slug}.json`
2. Verify data against official .gov sources only
3. Run import script: `node dev/scripts/smart-import.js`
4. Validate with: `node dev/scripts/verify-schema.js`
5. Update process map in `releases/v0.11.0/process-maps/`

### Data Migration Tools

- **`dev/scripts/smart-import.js`**: Import v0.11.0 JSON to Supabase with flexible schema handling
- **`dev/scripts/verify-schema.js`**: Verify all 10 tables deployed correctly
- **`scripts/complete_migration.py`**: Python script for data processing and validation

### Version Naming Convention

- **v0.11.0**: JSON data release (52 jurisdictions, process maps) - **COMPLETE**
- **v0.11.1**: Supabase integration with flexible schema - **CURRENT VERSION**
- **v0.12.0+**: Agency data, templates, AI training (future)

## Integration Points

This repository is part of the HOLE Foundation ecosystem:
- **theholetruth-platform**: React application consuming this database via Supabase
- **foundation-meta**: Central coordination repository
- **Supabase Backend**: PostgreSQL database with PostgREST API (Development: befpnwcokngtrljxskfz)
- **Authentication**: Supabase Auth (to be configured for theholetruth.org and theholefoundation.org)

## Development Commands

### Supabase Database Management (v0.11.1)
```bash
# Link to development branch
npx supabase link --project-ref befpnwcokngtrljxskfz

# View migration status
npx supabase migration list --linked

# Push migrations to development
npx supabase db push --linked

# Generate TypeScript types
npx supabase gen types typescript --linked > types/supabase.ts

# Verify schema deployment
node dev/scripts/verify-schema.js

# Import v0.11.0 data to Supabase
node dev/scripts/smart-import.js
```

### Data Validation (v0.11.1)
```bash
# Verify all 10 tables deployed
node dev/scripts/verify-schema.js

# Check data completeness
# See documentation/DATA_COMPLETENESS_AUDIT_v0.11.1.md

# Validate migration integrity
npx supabase migration list --linked
python3 scripts/find_duplicates.py

# Extract and process map data
python3 scripts/extract_map_data.py

# Rename files to v0.11 convention
python3 scripts/rename_to_v0_11.py
```

### Data Validation (Required for PR approval)
```bash
# Verify all 51 jurisdictions present
scripts/verify_jurisdictions.sh

# Validate JSON schema compliance
scripts/validate_data.py

# Check Supabase compatibility
scripts/check_supabase.sh
```

## Architecture Overview

### Database Design
- **Supabase Backend**: Full Supabase integration with TypeScript types generated from schema
- **Three-Layer Architecture**: Raw statutory → Structured jurisdiction → Consolidated resources
- **Cross-Repository Integration**: Designed to serve theholetruth-platform React application

### Code Quality Gates
- Minimum 80% test coverage required
- Maximum complexity score of 10
- TypeScript definitions required for all data structures
- Naming conventions enforced per .github/claude-code.yml

### Development Workflow
1. **Data Entry**: Start with templates in `templates/json/`
2. **Validation**: Use official government sources only (see validation rules)
3. **Migration**: Run migration scripts to organize data
4. **Integration**: Sync with Supabase schema using `pnpm generate:types`
5. **Quality Checks**: All PRs require Claude Code review and custom validation scripts

## Important Notes

- README.md describes the repository as "production ready" but this reflects the template structure, not data completeness
- Current state: All data files are empty templates awaiting verified data
- Priority jurisdictions: Federal (priority 1), major states including CA, FL, IL, NY, TX (priority 2), all others (priority 3)
- Target: 51 total jurisdictions (50 states + DC + Federal)
- **Package Manager**: Use `pnpm` (required by Supabase setup, engines requirement: pnpm >=10.16)

---

## Mission Context & Project Ecosystem

### The HOLE Foundation Structure
This database is one component of a coordinated ecosystem supporting government transparency:

**The HOLE Foundation** (theholefoundation.org)
- 501(c)(3) nonprofit organization
- Mission: Democratize access to government transparency information
- Seeking Candid.org Seal of Transparency
- Content: About foundation, team, funding, mission, current projects
- Links to: TheHoleTruth.org as primary project

**TheHoleTruth.org Platform** (separate repository: `THEHOLETRUTH.ORG`)
- Public-facing transparency tools
- **Transparency Map**: Interactive US map powered by this database
- **Transparency Wiki**: Full statutory analysis for all 51 jurisdictions
- **FOIA Generator**: AI-powered request generation tool
- All tools consume data from this repository via Supabase
- Authentication: Supabase

**This Repository** (us-transparency-laws-database)
- Ground truth data source for TheHoleTruth.org
- 100% accuracy requirement for legal data
- Supabase-compatible JSON structure
- Serves both map visualization and wiki content

### Integration Architecture
```
Official .gov Sources
        ↓
This Database (Ground Truth)
        ↓
Supabase Backend
        ↓
TheHoleTruth.org React Platform (THEHOLETRUTH.ORG repo)
        ├─→ Interactive US Map
        ├─→ Transparency Wiki
        └─→ FOIA Generator
```

**Note**: All application code including the FOIA Generator is maintained in the `THEHOLETRUTH.ORG` repository at `/Volumes/HOLE-RAID-DRIVE/HOLE/Projects/THEHOLETRUTH.ORG/`. This repository contains only verified legal data.

---

## Claude Code Workflow Patterns

### Task Classification System

Following Anthropic best practices, tasks are classified to determine the appropriate level of autonomy:

#### 1. AUTONOMOUS TASKS (Auto-Accept Mode Appropriate)
These tasks can run with `shift+tab` auto-accept enabled:
- **Data Validation Scripts**: Running existing validation tools
- **JSON Template Population**: Filling templates with verified data (after source verification)
- **Process Map Generation**: Creating maps from standard templates
- **Statutory Text Formatting**: Standardizing format of verified legal text
- **Documentation Updates**: Routine doc improvements
- **Test Generation**: Writing unit tests for validation scripts
- **Repetitive Refactoring**: Rename operations, file reorganization

**Key Pattern**: Start from clean git state, commit checkpoints frequently, ready to rollback if needed.

#### 2. SUPERVISED TASKS (Real-Time Oversight Required)
These require monitoring during execution:
- **Supabase Schema Changes**: Database structure modifications
- **Authentication Implementation**: Security-sensitive code
- **React Component Integration**: UI components connecting to database
- **Map Visualization Logic**: Interactive map functionality
- **Cross-Repository Coordination**: Changes affecting multiple repos
- **API Integration**: External service connections
- **Data Migration Scripts**: Moving/transforming existing data

**Key Pattern**: Work synchronously with Claude, provide detailed prompts, monitor in real-time.

#### 3. CRITICAL TASKS (Manual Review/Approval Required)
These require human verification before execution:
- **Legal Statute Verification**: Confirming data from official sources
- **Data Accuracy Validation**: Final review of legal information
- **Security/Privacy Implementations**: Anything touching sensitive data
- **Production Deployment Steps**: Going live with changes
- **Source Verification**: Confirming .gov authenticity
- **Breaking Changes**: Modifications that affect downstream systems

**Key Pattern**: Claude proposes solution, you review thoroughly before accepting.

### Workflow Execution Patterns

#### Pattern 1: Checkpoint-Heavy Development
For autonomous work on peripheral features:
```bash
# Before starting
git add . && git commit -m "checkpoint: starting [task-name]"

# Let Claude work autonomously (shift+tab)
# If successful → keep changes
# If unsuccessful → git reset --hard HEAD && retry with different approach
```

#### Pattern 2: Visual-First Prototyping
For UI/UX work (map, wiki interface):
1. Paste Figma mockup screenshots into Claude Code
2. Claude generates interactive React prototype
3. Iterate based on visual feedback
4. Engineers implement production version from prototype

#### Pattern 3: Plain-Text Workflow Automation
Create executable markdown workflows (see `workflows/` directory):
- Write workflow once in plain language
- Execute by saying: "Run workflows/[workflow-name].md"
- Claude handles all steps autonomously
- Great for repetitive multi-step processes

#### Pattern 4: End-of-Session Documentation
At the end of EVERY work session, ask:
```
"Summarize this session, suggest improvements to CLAUDE.md or workflow files,
and identify patterns we should document for future work."
```
This creates continuous improvement in development efficiency.

#### Pattern 5: Parallel Instance Management
Run multiple Claude Code instances for different aspects:
- **Instance 1**: This database (data work)
- **Instance 2**: theholetruth-platform (React development)
- **Instance 3**: theholefoundation.org (marketing site)
- **Instance 4**: Legal research/documentation

Each maintains independent context, allowing seamless context switching.

---

## Custom Slash Commands

Specialized commands for common workflows in this project:

### `/verify-sources [jurisdiction]`
Validates that all data for a jurisdiction comes from approved .gov sources.
Checks URLs, reports any non-compliant sources.

### `/add-jurisdiction [state-name]`
Executes complete workflow to add new state transparency law data:
1. Copies STANDARD_JURISDICTION_TEMPLATE
2. Prompts for official statute URL
3. Creates directory structure
4. Updates master_tracking_table.json
5. Prepares validation checklist

### `/sync-supabase`
Synchronizes database schema with current JSON structure:
1. Analyzes JSON templates
2. Generates/updates Supabase migrations
3. Updates TypeScript types
4. Runs validation tests

### `/validate-accuracy [jurisdiction]`
Runs comprehensive accuracy validation:
1. Checks all citations against official sources
2. Verifies business day vs calendar day specifications
3. Validates fee structures against statutory language
4. Confirms all URLs are .gov domains
5. Generates validation report

### `/update-tracking [jurisdiction] [field] [value]`
Updates master_tracking_table.json with completion status:
- Statute collection status
- Agency data collection status
- Template creation status
- Verification completion

### `/generate-process-map [jurisdiction]`
Creates standardized process map from template:
1. Loads template
2. Fills with jurisdiction-specific data
3. Validates against schema
4. Saves to verified-process-maps/

### `/verify-integration`
Checks integration status with THEHOLETRUTH.ORG platform:
- Confirms Supabase connectivity
- Tests data schema compatibility
- Validates API endpoints
- Reports any integration issues

---

## Integration Workflows

### Workflow 1: Notion → Claude Code → GitHub → Supabase

**Planning Phase** (Notion)
- Document requirements and research
- Plan data structure changes
- Track progress on jurisdiction completion

**Development Phase** (Claude Code)
- Implement features based on Notion specs
- Generate code, tests, documentation
- Run validation scripts

**Version Control** (GitHub)
- Commit with descriptive messages
- Create PRs for review
- Maintain change history

**Deployment** (Supabase)
- Sync database schema
- Update TypeScript types
- Deploy to production

### Workflow 2: Figma → Claude Code → React

**Design Phase** (Figma)
- Create mockups for map interface
- Design wiki layouts
- Prototype user flows

**Prototyping Phase** (Claude Code)
- Paste Figma screenshots
- Generate interactive prototypes
- Iterate based on feedback
- Create React components

**Implementation Phase** (React Platform)
- Integrate components into theholetruth-platform
- Connect to Supabase backend
- Implement with this database
- Deploy to production

### Workflow 3: Platform Integration

**THEHOLETRUTH.ORG Platform Integration**
- Three tools: Map, Wiki, FOIA Generator
- All consume data from this repository
- Integration via Supabase backend

**Integration Pattern**:
1. Dataset updates committed to this repo
2. Supabase schema synced with dataset structure
3. Platform tools query Supabase for data
4. TypeScript types generated from schema
5. Platform deployed with latest data
6. Continuous integration pipeline

---

## MCP Server Configuration

Following Anthropic security best practices, use MCP servers instead of direct CLI access:

### Supabase MCP Server (Recommended)
Instead of using Supabase CLI directly:
```bash
# NOT RECOMMENDED: Direct CLI
supabase db push

# RECOMMENDED: MCP Server
# Configure MCP server with controlled access
# Maintains audit logs
# Better security for sensitive data
```

**Benefits**:
- Audit trail of all database operations
- Fine-grained access control
- Better handling of sensitive data
- Privacy compliance support

### Custom MCP Servers for This Project

#### 1. Legal Source Validator MCP
- Verifies URLs are official .gov sites
- Checks statute authenticity
- Maintains approved source registry

#### 2. Data Quality MCP
- Runs validation scripts
- Checks accuracy against templates
- Generates quality reports

#### 3. Integration Status MCP
- Monitors Supabase sync status
- Tracks platform deployment status
- Reports data freshness and version

---

## Best Practices from Anthropic Teams

### 1. Write Detailed CLAUDE.md Files
The better you document workflows, tools, and expectations in this file, the better Claude Code performs. Update this file regularly based on session learnings.

### 2. Create Self-Sufficient Validation Loops
Set up Claude to verify its own work:
- Run builds automatically
- Execute tests after changes
- Run validation scripts
- Catch mistakes early

### 3. Develop Task Classification Intuition
Learn which tasks work well autonomously vs. needing supervision:
- **Autonomous**: Peripheral features, data processing, documentation
- **Supervised**: Core business logic, integration code, schema changes
- **Manual**: Legal verification, security, production deployment

### 4. Form Clear, Detailed Prompts
When components have similar names or functions, be extremely specific:
- Use exact file paths
- Reference specific functions/variables
- Include context about which system you're working in
- Prevents Claude from modifying wrong parts of codebase

### 5. Break Complex Workflows into Sub-Agents
For complex multi-step processes:
- Create specialized workflow files for each major task
- Have Claude execute workflows autonomously
- Easier debugging and maintenance
- Reusable across similar tasks

### 6. Plan Extensively Before Coding
Use Claude.ai for brainstorming and planning:
1. Flesh out entire approach in Claude.ai
2. Ask Claude to create comprehensive prompt
3. Copy prompt to Claude Code for execution
4. Work step-by-step rather than one-shot

### 7. Work Incrementally and Visually
For UI work:
- Use screenshots liberally
- Implement one component at a time
- Visual feedback is faster than text descriptions
- Iterate based on what you see

### 8. Share Progress Despite Imperfection
Don't wait for polish:
- Share prototypes early
- Get feedback on working demos
- Iterate based on real usage
- Perfect is enemy of done

---

## Continuous Improvement System

### Session Summary Template
At end of each session, ask Claude:
```
Generate session summary including:
1. What we accomplished
2. What worked well
3. What could be improved
4. Suggested CLAUDE.md updates
5. New workflow patterns to document
6. Next session priorities
```

### Metrics to Track
Following Anthropic's impact measurements:
- **Time Savings**: Jurisdiction research → deployed data time
- **Accuracy Rate**: Validation pass rate (target: 100%)
- **Parallel Productivity**: Progress on multiple projects
- **Documentation Quality**: Session success rate after CLAUDE.md updates

### Regular Reviews
Weekly review of:
- CLAUDE.md effectiveness
- Workflow automation success
- Integration pipeline health
- Data accuracy metrics

---

## Emergency Procedures

### If Claude Goes Off Track
1. **Stop immediately**: Don't let it continue if it's clearly wrong
2. **Revert to checkpoint**: `git reset --hard HEAD` to last known good state
3. **Analyze what went wrong**: Was prompt unclear? Missing context?
4. **Update CLAUDE.md**: Document the issue to prevent recurrence
5. **Try again with better guidance**: More specific prompt, more context

### If Validation Fails
1. **Don't deploy**: Never push data that fails validation
2. **Identify source**: Which jurisdiction/data point failed?
3. **Re-verify sources**: Go back to official .gov site
4. **Update validation rules**: If new edge case discovered
5. **Document the issue**: Add to validation methodology

### If Integration Breaks
1. **Check Supabase status**: Is database accessible?
2. **Verify API endpoints**: Are connections working?
3. **Review recent changes**: What changed before break?
4. **Roll back if needed**: Return to working state
5. **Fix forward with tests**: Add tests to prevent recurrence

---

## Future Enhancements

### Planned Additions
- Automated data refresh system (checking for statute updates)
- AI-powered source monitoring (detect when laws change)
- Expanded jurisdiction coverage (territories, tribal nations)
- Multi-language support (Spanish translations)
- API versioning and documentation

### Integration Roadmap
- **Phase 1**: Complete v0.11 dataset population (in progress)
- **Phase 2**: Supabase schema finalization and migration
- **Phase 3**: THEHOLETRUTH.ORG platform integration
- **Phase 4**: Interactive map, wiki, and FOIA generator deployment
- **Phase 5**: Monitoring, analytics, and maintenance automation