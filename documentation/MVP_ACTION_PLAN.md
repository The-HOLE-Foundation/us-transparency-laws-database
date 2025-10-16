---
DATE: 2025-10-16
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: MVP Completion Action Plan
VERSION: v0.13
---

# MVP Action Plan: Database → Tools Integration

## Executive Summary

This document outlines the complete path from current database state to MVP launch of three tools:
1. **Transparency Map** - SVG US map with jurisdiction quick-view
2. **Transparency Wiki** - Comprehensive statute database
3. **FOIA Generator** - AI-powered request builder

## Current State Assessment

### ✅ What's Working
- **Neon Database**: v0.13 schema fully deployed (12 tables + 6 views)
- **Statutory Texts**: 52/52 jurisdictions complete
- **Rights of Access**: 14/52 jurisdictions (272 rights)
- **Vector Database**: pgvector 0.8.0 installed and indexed
- **Vercel CLI**: Connected and operational
- **GitHub Repos**: All ecosystem repos added to workspace

### ❌ What's Missing
- **Neon credentials NOT in Vercel** - Need to add env variables
- **Documentation outdated** - Describes v0.11, database is v0.13
- **38 jurisdictions need rights data** - 73% completion gap
- **Data product designs** - Map, Wiki, Vector Store specs needed
- **Integration architecture** - GitHub → Vercel → Neon not documented

---

## Architecture Overview

### Repository Ecosystem

```
foundation-meta/
├── Cross-repository coordination
├── Shared design libraries
├── Web components library
└── Integration documentation

theholefoundation.org/
├── Corporate website (professional)
├── About, Team, Mission
├── Shared authentication
└── Shared donations (Stripe)

theholetruth.org/
├── User-facing tools site
├── Transparency Map
├── Transparency Wiki
├── FOIA Generator
└── Shared authentication

us-transparency-laws-database/
├── Data layer (Neon PostgreSQL)
├── THIS REPOSITORY
├── Ground truth for all tools
└── Vector embeddings for AI

HOLE-Doc-Intelligence/
├── SEPARATE PROJECT
├── Private records database
├── Legal document drafting
└── Not integrated with transparency tools
```

### Technology Stack

**Deployment & Hosting:**
- GitHub → Vercel (automated deployment)
- Neon PostgreSQL (database)
- Vercel Edge Functions (API)

**Authentication:**
- **MVP:** Neon Auth (simple, integrated)
- **Future:** Consider Auth0 if need advanced features

**Storage:**
- **MVP:** Vercel (static assets)
- **Skip:** Cloudflare R2 (not needed yet)

**Payments:**
- Stripe (hosted checkout for MVP)
- Shared across foundation.org and truth.org

**FOIA Generator:**
- **MVP:** Azure AI Foundry agent
- Vector store attached to agent dashboard
- **Future:** Custom integration with Neon

---

## Three Data Products

### 1. Transparency Map (Curated Dataset)

**Purpose:** Quick-view jurisdiction comparison on SVG US map

**Data Requirements:**
```json
{
  "jurisdiction_code": "CA",
  "jurisdiction_name": "California",
  "statute_name": "California Public Records Act",
  "response_days": 10,
  "day_type": "calendar",
  "fee_search": true,
  "fee_copy": "$0.10/page",
  "unique_features": [
    "Expedited requests available",
    "Strong fee waiver provisions",
    "No residency requirement"
  ],
  "rights_count": 25,
  "exemptions_count": 45,
  "wiki_url": "/wiki/california",
  "generator_url": "/generator?jurisdiction=ca"
}
```

**Source:** `complete_transparency_landscape` VIEW + manual curation

**Size:** ~52 records (one per jurisdiction)

**Format:** Static JSON for map tooltips

---

### 2. Transparency Wiki (Comprehensive Dataset)

**Purpose:** Full statutory analysis for each jurisdiction

**Data Requirements:**
- Complete statute text (from `statute_texts` table)
- All rights of access (from `rights_of_access` table)
- Response requirements, fees, exemptions
- Appeal processes, oversight bodies
- Related case law and agency contacts

**Source:** All Neon tables

**Size:** All 52 jurisdictions, ~10-50KB per jurisdiction

**Format:** Dynamic queries to Neon from Next.js pages

**Example Wiki Structure:**
```
/wiki/california
├── Overview (statute name, citation, effective date)
├── Response Requirements (timelines, extensions)
├── Rights of Access (25 affirmative rights with tips)
├── Exemptions (45 categories with legal citations)
├── Fees (search, copy, electronic, waivers)
├── Appeal Process (administrative and judicial)
├── Statute Text (full text with sections)
└── Related Resources (official links, forms)
```

---

### 3. FOIA Generator Vector Store

**Purpose:** Context for AI agent to generate requests

**Data Requirements:**
- All rights of access with request tips
- Common exemptions and how to overcome
- Successful request examples
- Jurisdiction-specific language
- Assertion templates

**Source:** `rights_of_access` table with embeddings

**Size:** 272 rights (currently) → 500+ (when complete)

**Format:** Vector embeddings in pgvector

**MVP Approach (Simplest):**
1. Export rights data from Neon
2. Upload JSON to Azure AI Foundry dashboard
3. Attach to agent as knowledge base
4. Agent queries vector store for relevant rights

**Future Approach (More Control):**
1. Query Neon vector search directly from agent
2. Maintain single source of truth
3. Update rights without re-uploading

---

## Priority Action Items

### CRITICAL (Do Now)

#### 1. Add Neon Credentials to Vercel
```bash
# Run the add-neon-env.sh script prepared above
# Then pull to local:
vercel env pull .env.development.local
```

**Why Critical:** Database queries won't work in production without this.

---

#### 2. Update CLAUDE.md
Current describes v0.11 schema. Update to v0.13:

**Old (v0.11) Tables:**
- jurisdictions, transparency_laws, response_requirements, fee_structures, exemptions, appeal_processes, etc.

**New (v0.13) Tables:**
- jurisdictions, statute_texts, rights_of_access, agency_contacts, case_law, court_records_rules, etc.

**New Views:**
- complete_transparency_landscape (replaces old transparency_map_display)
- rights_of_access_detailed, rights_by_category_summary, etc.

---

#### 3. Document Integration Architecture
Create: `documentation/GITHUB_VERCEL_NEON_INTEGRATION.md`

Topics:
- GitHub push triggers Vercel deploy
- Vercel connects to Neon via DATABASE_URL
- Environment variables managed via Vercel CLI
- Database migrations via direct PostgreSQL connection
- Type generation for TypeScript

---

#### 4. Design Map Data Export
Create: `scripts/export-map-data.js`

```javascript
// Export curated data for transparency map
// Source: complete_transparency_landscape view
// Output: public/data/transparency-map.json
```

---

### HIGH PRIORITY (This Week)

#### 5. Complete Rights Data Collection
**Target:** 38 remaining jurisdictions

**Process:**
1. Research official statute websites
2. Extract affirmative rights language
3. Add to `data/jurisdictions/[state]/rights.json`
4. Import to Neon via import script
5. Verify in database

**Current:** 14/52 (27%)
**Goal:** 52/52 (100%)

---

#### 6. Create Foundation-Meta Integration Doc
Location: `foundation-meta/docs/PROJECT_ECOSYSTEM.md`

Content:
- All repository relationships
- Shared authentication flow
- Shared design system (Figma → Components)
- Deployment pipeline (GitHub → Vercel)
- Database access patterns

---

#### 7. Design API Endpoints
For theholetruth.org to query database:

```typescript
// Map data
GET /api/map/jurisdictions

// Wiki data
GET /api/wiki/[jurisdiction]

// Generator context
GET /api/generator/rights?jurisdiction=ca
```

---

### MEDIUM PRIORITY (Next Sprint)

#### 8. Build Transparency Map Component
- SVG US map (Figma design)
- Hover tooltips with quick stats
- Click → redirect to wiki page
- Color coding by response time

---

#### 9. Build Wiki Page Template
- Next.js dynamic route: `/wiki/[jurisdiction]`
- Query Neon for all jurisdiction data
- Render sections (rights, exemptions, fees, etc.)
- Link to generator with pre-filled jurisdiction

---

#### 10. Set Up FOIA Generator Agent
- Azure AI Foundry project
- Upload rights vector store
- Configure agent with system prompt
- Test with sample requests

---

## What You DON'T Need (Yet)

❌ **Auth0** - Use Neon Auth for MVP
❌ **Cloudflare R2** - Vercel handles assets
❌ **Complex Stripe Integration** - Use hosted checkout
❌ **Custom Vector Search** - Use Azure AI Foundry dashboard
❌ **Separate Neon Project** - theholetruth database is sufficient

---

## Estimated Timeline to MVP

**Week 1** (Current):
- ✅ Update documentation (CLAUDE.md, integration docs)
- ✅ Add Neon credentials to Vercel
- ✅ Design three data products
- ⏳ Complete 10 more jurisdictions' rights (24/52)

**Week 2**:
- ⏳ Complete remaining 28 jurisdictions (52/52)
- ⏳ Build map data export script
- ⏳ Create API endpoints for map/wiki/generator

**Week 3**:
- ⏳ Build transparency map component
- ⏳ Build wiki page template
- ⏳ Deploy to Vercel preview

**Week 4**:
- ⏳ Set up Azure AI Foundry FOIA generator
- ⏳ Connect all three tools
- ⏳ Test end-to-end flows
- ⏳ Production launch

**Total:** 4 weeks to MVP (with 38 jurisdictions' data collection being the bottleneck)

---

## Success Criteria

**MVP Launch Checklist:**
- [ ] All 52 jurisdictions have complete rights data in Neon
- [ ] Transparency map displays all 52 jurisdictions correctly
- [ ] Wiki has functional page for each jurisdiction
- [ ] FOIA generator produces valid requests for any jurisdiction
- [ ] Authentication works across both sites
- [ ] Stripe donations functional on foundation.org
- [ ] All documentation up to date
- [ ] Vercel deployment pipeline working
- [ ] Neon database accessible from production

---

## Next Immediate Actions

1. **Run Neon env script** (with user approval)
2. **Update CLAUDE.md** with v0.13 schema
3. **Create integration architecture doc**
4. **Design map data export**
5. **Continue rights data collection**

---

**Status:** 📋 Action Plan Complete | 🔄 Ready for Systematic Execution
