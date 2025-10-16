# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Document Standards (GLOBAL REQUIREMENT)

**Every document generated must include the following header:**

```
---
DATE: [YYYY-MM-DD]
AUTHOR: [Author Name or "Claude Code AI Assistant"]
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: [Specific component, e.g., "Neon Schema Design", "Data Validation", "Process Maps"]
VERSION: v0.11 or v0.12 (depending on context)
---
```

This applies to all markdown files, documentation, reports, schemas, and any other documents created for this project.

## Project Overview

This repository is a comprehensive database of US transparency laws (FOIA and public records laws) for all 52 jurisdictions (50 states + DC + Federal).

**Current Status**:
- **v0.12-alpha**: IN PROGRESS - Neon database with 272 rights across 14 jurisdictions (27% complete)
- **Target v0.12**: Rights of Access for all 52 jurisdictions
- **Schema**: v0.12-alpha deployed (12 tables + 6 views), data collection ongoing

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

### Data Architecture (v0.12-alpha)

1. **Raw Statutory Data** (Database: `statute_texts` table)
   - Full statute text for all 52 jurisdictions
   - Official statutory citations
   - Ground truth from official sources only
   - Stored in Neon database with vector embeddings ready

2. **Neon PostgreSQL Database** (**v0.12-alpha DEPLOYED**)
   - **12 Core Tables**: jurisdictions, statute_texts, rights_of_access, agency_contacts, case_law, court_records_rules, donation_subscriptions, donations, payment_methods, privacy_statutes, record_types_excluded, rights_exemptions_conflicts
   - **6 Optimized Views**: complete_transparency_landscape, rights_of_access_detailed, rights_by_category_summary, agency_contacts_detailed, donation_summary, active_subscriptions_summary
   - **52 jurisdictions** with statute texts
   - **272 rights** across 14 jurisdictions (27% complete)
   - **pgvector 0.8.0** installed for semantic search
   - Vector embeddings in rights_of_access table (vector(1536))

3. **File System Data** (`data/jurisdictions/`)
   - Rights data for 10 jurisdictions (S-W alphabetically)
   - 123 rights in JSON files
   - Being synced to database progressively
   - 41 jurisdictions have empty template files

4. **Three Data Products** (See detailed section below)
   - **Transparency Map**: Curated dataset from `complete_transparency_landscape` VIEW
   - **Transparency Wiki**: Comprehensive access via all tables
   - **FOIA Generator**: Vector store from `rights_of_access` embeddings

### Key Database Tables (v0.12-alpha)

**Core Tables (12 total)**:
- **`jurisdictions`** (52 records): id, slug, name, jurisdiction_type
- **`statute_texts`** (52 records): Full statutory text with vector embeddings ready
- **`rights_of_access`** (272 records): Affirmative rights across 14 jurisdictions (27% complete)
  - Fields: jurisdiction_id, right_category, right_name, short_description, full_description, statutory_citation, conditions (JSONB), embedding (vector(1536))
  - Categories: proactive_disclosure, enhanced_access, technology_format, requester_specific, inspection_rights, timeliness_rights, fee_waiver, aggregation_rights, privacy_protection, appeal_rights
  - **Purpose**: Enable FOIA Generator to assert specific statutory rights in requests
  - **Status**: 14/52 jurisdictions populated (California: 25, New York: 20, Texas: 20, etc.)
- **`agency_contacts`**: Agency-specific contact information
- **`case_law`**: Relevant court decisions and precedents
- **`court_records_rules`**: Specialized rules for court record access
- **`donation_subscriptions`**: Recurring donation tracking
- **`donations`**: One-time and recurring donations
- **`payment_methods`**: Stripe payment method storage
- **`privacy_statutes`**: Privacy laws that may limit access
- **`record_types_excluded`**: Specific record types excluded from access
- **`rights_exemptions_conflicts`**: Mapping of rights vs exemptions conflicts

**Optimized Views (6 total)**:
- **`complete_transparency_landscape`** (52 records): Combines rights, exemptions, and statutory data for comprehensive jurisdiction analysis
- **`rights_of_access_detailed`**: Enriched rights data with jurisdiction context
- **`rights_by_category_summary`**: Aggregated statistics by right category
- **`agency_contacts_detailed`**: Agency contacts with jurisdiction information
- **`donation_summary`**: Donation analytics and reporting
- **`active_subscriptions_summary`**: Active recurring donation tracking

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

**Development Branch**: `https://befpnwcokngtrljxskfz.neon.co`

All 52 jurisdictions are now deployed to Neon. Use these patterns:

**JavaScript/TypeScript (Neon Client)**
```javascript
import { createClient } from '@neon/neon-js'

const neon = createClient(
  'https://befpnwcokngtrljxskfz.neon.co',
  'YOUR_ANON_KEY'
)

// Get all jurisdictions for transparency map
const { data: jurisdictions } = await neon
  .from('transparency_map_display')
  .select('jurisdiction_name, jurisdiction_code, response_timeline_days, key_features_tags')

// Get California exemptions (no joins needed!)
const { data: exemptions } = await neon
  .from('exemptions')
  .select('category, description, legal_cite')
  .eq('jurisdiction_name', 'California')

// Get jurisdiction details
const { data: california } = await neon
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

- **`dev/scripts/smart-import.js`**: Import v0.11.0 JSON to Neon with flexible schema handling
- **`dev/scripts/verify-schema.js`**: Verify all 10 tables deployed correctly
- **`scripts/complete_migration.py`**: Python script for data processing and validation

### Version Naming Convention

- **v0.11.0**: JSON data release (52 jurisdictions, process maps) - **COMPLETE**
- **v0.11.1**: Neon integration with flexible schema - **CURRENT VERSION**
- **v0.12.0+**: Agency data, templates, AI training (future)

## Integration Points

### Project Ecosystem

This repository is the **data layer** for The HOLE Foundation's transparency tools ecosystem:

**Repository Structure:**
```
foundation-meta/              # Cross-repository coordination, shared standards
theholefoundation.org/        # Corporate website (professional presentation)
theholetruth.org/            # User-facing tools (Map, Wiki, Generator)
us-transparency-laws-database/ # THIS REPOSITORY (data layer)
HOLE-Doc-Intelligence/        # Separate project (private records)
```

**Technology Stack:**
- **Database**: Neon PostgreSQL (AWS us-east-1)
- **Deployment**: GitHub → Vercel (automated)
- **Environment Variables**: Managed via Vercel CLI (`vercel env pull`)
- **Authentication**: Neon Auth (MVP), shared across both sites
- **Payments**: Stripe (hosted checkout), shared donations

### Three Data Products

This database powers three distinct tools on theholetruth.org:

#### 1. Transparency Map (Curated Dataset)
**Purpose**: Quick-view jurisdiction comparison on SVG US map

**Data Source**: `complete_transparency_landscape` VIEW (52 records)

**Use Case**: User clicks state → sees tooltip with:
- Response timeline (business/calendar days)
- Fee structure summary
- Unique features
- Links to Wiki and Generator

**Format**: Static JSON export for map tooltips

#### 2. Transparency Wiki (Comprehensive Dataset)
**Purpose**: Full statutory analysis for each jurisdiction

**Data Source**: All Neon tables (dynamic queries)

**Wiki Page Structure** (`/wiki/[jurisdiction]`):
- Overview (statute name, citation, effective date)
- Statutory Text (full text with sections)
- Rights of Access (affirmative rights with request tips)
- Response Requirements (timelines, extensions)
- Fees (search, copy, electronic, waivers)
- Exemptions (categories with legal citations)
- Appeal Process (administrative and judicial)
- Related Resources (official links, forms)

**Format**: Next.js dynamic routes querying Neon

#### 3. FOIA Generator Vector Store
**Purpose**: Context for AI agent to generate jurisdiction-specific requests

**Data Source**: `rights_of_access` table with vector embeddings

**Current Approach (MVP)**:
1. Export rights data from Neon
2. Upload JSON to Azure AI Foundry dashboard
3. Attach to agent as knowledge base
4. Agent queries vector store for relevant rights

**Future Approach**:
1. Query Neon vector search directly from agent
2. Maintain single source of truth
3. Update rights without re-uploading

**Vector Database**: pgvector 0.8.0 installed, embeddings ready in `rights_of_access.embedding` column (vector(1536))

### Versioning Strategy

**Database (this repo)**: Semantic versioning based on schema/data
- `v0.12-alpha`: Current (rights collection 27% complete)
- `v0.12`: When 52/52 jurisdictions have rights data
- `v0.13`: When vector embeddings actively used
- `v1.0`: Production ready (all data complete)

**Frontend sites**: Independent versioning
- `theholetruth.org v0.1.0-beta`: MVP launch
- `theholefoundation.org v0.1.0-beta`: MVP launch
- Can iterate independently from database version

**Example**: Database at v0.12, Frontend at v0.1.0 ← Different versions OK!

### Deployment Architecture

```
GitHub (push) → Vercel (build) → Production
                    ↓
              Neon Database (query)
                    ↓
              Environment Variables (Vercel keystore)
```

**Environment Management:**
```bash
# Pull credentials from Vercel
vercel env pull .env.development.local

# Credentials stored in Vercel project:
# - DATABASE_URL (pooled connection)
# - DATABASE_URL_UNPOOLED (migrations)
# - POSTGRES_URL (Vercel alias)
# - POSTGRES_PRISMA_URL (Prisma-specific)
```

## Development Commands

### Neon Database Management (v0.12+)
```bash
# Direct PostgreSQL connection (for migrations and admin)
psql "$DATABASE_URL_UNPOOLED"

# Apply migration to Neon
psql "$DATABASE_URL_UNPOOLED" -f neon/migrations/YOUR_MIGRATION.sql

# Query database
psql "$DATABASE_URL" -c "SELECT * FROM jurisdictions;"

# Import v0.12 rights data to Neon
node dev/scripts/import-rights-neon.js data/v0.12/rights/federal-rights.json

# Verify schema deployment
psql "$DATABASE_URL" -c "\dt public.*"
psql "$DATABASE_URL" -c "SELECT * FROM transparency_landscape LIMIT 5;"
```

**Note**: We migrated from Neon to Neon in October 2025. See `documentation/NEON_MIGRATION.md` for details.

### Data Validation (v0.11.1)
```bash
# Verify all 10 tables deployed
node dev/scripts/verify-schema.js

# Check data completeness
# See documentation/DATA_COMPLETENESS_AUDIT_v0.11.1.md

# Validate migration integrity
npx neon migration list --linked
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

# Check Neon compatibility
scripts/check_neon.sh
```

## Architecture Overview

### Database Design
- **Neon Backend**: Full Neon integration with TypeScript types generated from schema
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
4. **Integration**: Sync with Neon schema using `pnpm generate:types`
5. **Quality Checks**: All PRs require Claude Code review and custom validation scripts

## Important Notes

- README.md describes the repository as "production ready" but this reflects the template structure, not data completeness
- Current state: All data files are empty templates awaiting verified data
- Priority jurisdictions: Federal (priority 1), major states including CA, FL, IL, NY, TX (priority 2), all others (priority 3)
- Target: 51 total jurisdictions (50 states + DC + Federal)
- **Package Manager**: Use `pnpm` (required by Neon setup, engines requirement: pnpm >=10.16)

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
- All tools consume data from this repository via Neon
- Authentication: Neon

**This Repository** (us-transparency-laws-database)
- Ground truth data source for TheHoleTruth.org
- 100% accuracy requirement for legal data
- Neon-compatible JSON structure
- Serves both map visualization and wiki content

### Integration Architecture
```
Official .gov Sources
        ↓
This Database (Ground Truth)
        ↓
Neon Backend
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
- **Neon Schema Changes**: Database structure modifications
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

### `/sync-neon`
Synchronizes database schema with current JSON structure:
1. Analyzes JSON templates
2. Generates/updates Neon migrations
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
- Confirms Neon connectivity
- Tests data schema compatibility
- Validates API endpoints
- Reports any integration issues

---

## Integration Workflows

### Workflow 1: Notion → Claude Code → GitHub → Neon

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

**Deployment** (Neon)
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
- Connect to Neon backend
- Implement with this database
- Deploy to production

### Workflow 3: Platform Integration

**THEHOLETRUTH.ORG Platform Integration**
- Three tools: Map, Wiki, FOIA Generator
- All consume data from this repository
- Integration via Neon backend

**Integration Pattern**:
1. Dataset updates committed to this repo
2. Neon schema synced with dataset structure
3. Platform tools query Neon for data
4. TypeScript types generated from schema
5. Platform deployed with latest data
6. Continuous integration pipeline

---

## MCP Server Configuration

Following Anthropic security best practices, use MCP servers instead of direct CLI access:

### Neon MCP Server (Recommended)
Instead of using Neon CLI directly:
```bash
# NOT RECOMMENDED: Direct CLI
neon db push

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
- Monitors Neon sync status
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

## Autonomous Work Mode

### Activation

When user uses ANY of these phrases:
- "continue until complete"
- "work all night"
- "don't stop until done"
- "finish everything"
- "complete all tasks"
- "do them all"
- "work autonomously"
- "keep going"

**→ AUTONOMOUS MODE IS ACTIVATED**

A hook will inject a reminder, but you must follow these rules regardless.

### Autonomous Mode Rules

**✅ DO:**
- Work through entire task list without stopping
- Mark tasks complete using TodoWrite as you go
- Move IMMEDIATELY to next task after completing previous
- Log brief progress updates ("✅ X done, moving to Y...")
- Create comprehensive final report at END
- Make reasonable assumptions when guidance exists in CLAUDE.md

**❌ DON'T:**
- Ask "want me to continue?" between tasks
- Ask "should I move to next item?"
- Stop to report interim progress as if waiting for response
- Wait for approval to proceed to next task
- Stop after completing just one subtask in a sequence

**⚠️ ONLY STOP IF:**
- All tasks complete (report results comprehensively)
- Critical error blocking all progress
- Genuinely ambiguous requirement with no guidance in documentation

### Progress Reporting Format

**✅ Good (keeps momentum):**
```
✅ Federal validation complete (1/4). Moving to California...
✅ California validation complete (2/4). Moving to Texas...
```

**❌ Bad (breaks momentum):**
```
Federal validation complete. Ready for California?
I've finished Federal. Should I continue to California?
```

### Exiting Autonomous Mode

**Auto-exit when:**
- All tasks in todo list marked complete
- Critical error requires user decision
- User sends new message with "stop", "pause", "wait"

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
1. **Check Neon status**: Is database accessible?
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
- **Phase 2**: Neon schema finalization and migration
- **Phase 3**: THEHOLETRUTH.ORG platform integration
- **Phase 4**: Interactive map, wiki, and FOIA generator deployment
- **Phase 5**: Monitoring, analytics, and maintenance automation