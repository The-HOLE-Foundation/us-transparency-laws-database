---
DATE: 2025-10-06
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Supabase Schema Design
VERSION: v0.11.1
---

# Supabase Database Schema Design

## Overview

This document describes the PostgreSQL database schema for the US Transparency Laws Database, designed to store structured transparency law data from all 52 jurisdictions (Federal + 50 States + DC).

**Schema Version**: v0.11.1
**Data Source**: releases/v0.11.0/jurisdictions/*.json
**Target Platform**: Supabase (PostgreSQL 15+)

## Design Principles

1. **Normalized Structure**: Separate tables for related data to minimize redundancy
2. **Type Safety**: Use appropriate PostgreSQL types (JSONB, ENUM, etc.)
3. **Query Performance**: Indexes on commonly queried fields
4. **Data Integrity**: Foreign keys and constraints to maintain relationships
5. **Flexibility**: JSONB for semi-structured nested data
6. **Auditability**: Timestamps and versioning metadata

## Schema Diagram

```
jurisdictions (52 records)
    ├─→ transparency_laws (52 records, 1:1)
    │       ├─→ response_requirements (52 records, 1:1)
    │       ├─→ fee_structures (52 records, 1:1)
    │       ├─→ exemptions (many records, 1:many)
    │       ├─→ appeal_processes (52 records, 1:1)
    │       ├─→ requester_requirements (52 records, 1:1)
    │       ├─→ agency_obligations (52 records, 1:1)
    │       └─→ oversight_bodies (52 records, 1:1)
    └─→ agencies (0 records currently, future v0.12)
```

## Table Definitions

### 1. `jurisdictions`

Core table for jurisdiction metadata.

```sql
CREATE TABLE jurisdictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT NOT NULL UNIQUE,  -- 'federal', 'california', etc.
    name TEXT NOT NULL,          -- 'Federal', 'California', etc.
    jurisdiction_type TEXT NOT NULL CHECK (jurisdiction_type IN ('federal', 'state', 'district')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Indexes**:
- Primary key on `id`
- Unique index on `slug` (for URL-friendly lookups)

**Sample Data**:
```sql
INSERT INTO jurisdictions (slug, name, jurisdiction_type) VALUES
('federal', 'Federal', 'federal'),
('california', 'California', 'state'),
('district-of-columbia', 'District of Columbia', 'district');
```

### 2. `transparency_laws`

Main transparency law information for each jurisdiction.

```sql
CREATE TABLE transparency_laws (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    jurisdiction_id UUID NOT NULL REFERENCES jurisdictions(id) ON DELETE CASCADE,

    -- Basic statute information
    name TEXT NOT NULL,                    -- 'Freedom of Information Act', 'California Public Records Act', etc.
    statute_citation TEXT NOT NULL,        -- '5 U.S.C. § 552', 'Cal. Gov. Code §§ 7920.000-7931.000'
    effective_date DATE,                   -- Original enactment date
    last_amended DATE,                     -- Most recent amendment

    -- Official resources (JSONB for flexibility)
    official_resources JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Validation metadata
    validation_metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT one_law_per_jurisdiction UNIQUE (jurisdiction_id)
);
```

**Indexes**:
- Primary key on `id`
- Unique index on `jurisdiction_id` (1:1 relationship)
- GIN index on `official_resources` for JSONB queries
- GIN index on `validation_metadata` for JSONB queries

**JSONB Structure for `official_resources`**:
```json
{
    "primary_statute_url": "https://...",
    "agency_handbook_url": "https://...",
    "request_portal_url": "https://...",
    "oversight_url": "https://..."
}
```

**JSONB Structure for `validation_metadata`**:
```json
{
    "parsed_date": "2025-10-02",
    "confidence_level": "high",
    "source_url": "https://...",
    "source_verified": true,
    "primary_sources": ["...", "..."],
    "verification_notes": "..."
}
```

### 3. `response_requirements`

Response timeline and extension rules.

```sql
CREATE TABLE response_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transparency_law_id UUID NOT NULL REFERENCES transparency_laws(id) ON DELETE CASCADE,

    -- Initial response
    initial_response_time INTEGER NOT NULL,
    initial_response_unit TEXT NOT NULL CHECK (initial_response_unit IN ('business_days', 'calendar_days', 'working_days')),

    -- Final response
    final_response_time INTEGER NOT NULL,
    final_response_unit TEXT NOT NULL CHECK (final_response_unit IN ('business_days', 'calendar_days', 'working_days')),

    -- Extensions
    extension_allowed BOOLEAN NOT NULL DEFAULT false,
    extension_max_days INTEGER,
    extension_conditions TEXT,

    -- Tolling
    tolling_allowed BOOLEAN NOT NULL DEFAULT false,
    tolling_notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT one_response_per_law UNIQUE (transparency_law_id)
);
```

**Indexes**:
- Primary key on `id`
- Unique index on `transparency_law_id` (1:1 relationship)

### 4. `fee_structures`

Fee schedules, waivers, and payment rules.

```sql
CREATE TABLE fee_structures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transparency_law_id UUID NOT NULL REFERENCES transparency_laws(id) ON DELETE CASCADE,

    -- Search fees
    search_fee TEXT,
    search_fee_statutory_cite TEXT,

    -- Copy fees
    copy_fee_per_page DECIMAL(10,2),       -- Dollar amount or NULL
    copy_fee_cite TEXT,
    copy_fee_notes TEXT,

    -- Electronic fees
    electronic_fee TEXT,

    -- Fee waivers
    fee_waiver_available BOOLEAN NOT NULL DEFAULT false,
    fee_waiver_criteria TEXT,
    fee_waiver_cite TEXT,
    fee_protection_notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT one_fee_structure_per_law UNIQUE (transparency_law_id)
);
```

**Indexes**:
- Primary key on `id`
- Unique index on `transparency_law_id` (1:1 relationship)

### 5. `exemptions`

Transparency law exemptions (one-to-many relationship).

```sql
CREATE TABLE exemptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transparency_law_id UUID NOT NULL REFERENCES transparency_laws(id) ON DELETE CASCADE,

    -- Exemption details
    category TEXT NOT NULL,                -- 'National Security', 'Personal Privacy', etc.
    citation TEXT NOT NULL,                -- Statutory citation
    description TEXT NOT NULL,             -- Full description
    scope TEXT NOT NULL CHECK (scope IN ('narrow', 'moderate', 'broad')),

    -- Optional subcategories
    subcategories TEXT,

    -- Display order
    display_order INTEGER NOT NULL DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Indexes**:
- Primary key on `id`
- Index on `transparency_law_id` for efficient joins
- Index on `(transparency_law_id, display_order)` for ordered retrieval

### 6. `appeal_processes`

Administrative and judicial appeal procedures.

```sql
CREATE TABLE appeal_processes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transparency_law_id UUID NOT NULL REFERENCES transparency_laws(id) ON DELETE CASCADE,

    -- First level (administrative)
    first_level TEXT NOT NULL,
    first_level_deadline_days INTEGER,
    first_level_deadline_notes TEXT,
    first_level_cite TEXT,

    -- Second level (judicial)
    second_level TEXT NOT NULL,
    second_level_deadline_days INTEGER,
    second_level_deadline_notes TEXT,
    second_level_cite TEXT,

    -- Attorney fees
    attorney_fees_recoverable BOOLEAN NOT NULL DEFAULT false,
    attorney_fees_cite TEXT,
    attorney_fees_notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT one_appeal_process_per_law UNIQUE (transparency_law_id)
);
```

**Indexes**:
- Primary key on `id`
- Unique index on `transparency_law_id` (1:1 relationship)

### 7. `requester_requirements`

Requirements for submitting transparency requests.

```sql
CREATE TABLE requester_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transparency_law_id UUID NOT NULL REFERENCES transparency_laws(id) ON DELETE CASCADE,

    -- Requirements
    identification_required BOOLEAN NOT NULL DEFAULT false,
    purpose_statement_required BOOLEAN NOT NULL DEFAULT false,
    residency_requirement BOOLEAN NOT NULL DEFAULT false,

    -- Format and notes
    request_format_notes TEXT,
    specific_format TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT one_requester_requirements_per_law UNIQUE (transparency_law_id)
);
```

**Indexes**:
- Primary key on `id`
- Unique index on `transparency_law_id` (1:1 relationship)

### 8. `agency_obligations`

Agency duties and requirements.

```sql
CREATE TABLE agency_obligations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transparency_law_id UUID NOT NULL REFERENCES transparency_laws(id) ON DELETE CASCADE,

    -- Records officer
    records_officer_required BOOLEAN NOT NULL DEFAULT false,
    records_officer_title TEXT,

    -- Access and submission
    business_hours_access BOOLEAN NOT NULL DEFAULT false,
    electronic_submission_accepted BOOLEAN NOT NULL DEFAULT false,
    electronic_submission_required TEXT,

    -- Response format
    response_format_options TEXT,

    -- Reporting and liaison
    annual_reporting_required BOOLEAN NOT NULL DEFAULT false,
    public_liaison_required BOOLEAN NOT NULL DEFAULT false,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT one_agency_obligations_per_law UNIQUE (transparency_law_id)
);
```

**Indexes**:
- Primary key on `id`
- Unique index on `transparency_law_id` (1:1 relationship)

### 9. `oversight_bodies`

Oversight and ombudsman entities.

```sql
CREATE TABLE oversight_bodies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transparency_law_id UUID NOT NULL REFERENCES transparency_laws(id) ON DELETE CASCADE,

    -- Oversight body details
    name TEXT NOT NULL,
    role TEXT NOT NULL,
    contact_info TEXT,
    oversight_url TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT one_oversight_body_per_law UNIQUE (transparency_law_id)
);
```

**Indexes**:
- Primary key on `id`
- Unique index on `transparency_law_id` (1:1 relationship)

### 10. `agencies` (Future v0.12)

Agency contact information (currently empty, planned for v0.12).

```sql
CREATE TABLE agencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    jurisdiction_id UUID NOT NULL REFERENCES jurisdictions(id) ON DELETE CASCADE,

    -- Agency details
    name TEXT NOT NULL,
    agency_type TEXT,
    contact_info JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- FOIA contact
    foia_officer_name TEXT,
    foia_officer_email TEXT,
    foia_submission_url TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Note**: This table structure is ready but will remain empty until v0.12 agency data collection.

## Row-Level Security (RLS)

For public read access with restricted write access:

```sql
-- Enable RLS on all tables
ALTER TABLE jurisdictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE transparency_laws ENABLE ROW LEVEL SECURITY;
ALTER TABLE response_requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE fee_structures ENABLE ROW LEVEL SECURITY;
ALTER TABLE exemptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE appeal_processes ENABLE ROW LEVEL SECURITY;
ALTER TABLE requester_requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE agency_obligations ENABLE ROW LEVEL SECURITY;
ALTER TABLE oversight_bodies ENABLE ROW LEVEL SECURITY;
ALTER TABLE agencies ENABLE ROW LEVEL SECURITY;

-- Public read access (all tables)
CREATE POLICY "Public read access" ON jurisdictions FOR SELECT USING (true);
CREATE POLICY "Public read access" ON transparency_laws FOR SELECT USING (true);
CREATE POLICY "Public read access" ON response_requirements FOR SELECT USING (true);
CREATE POLICY "Public read access" ON fee_structures FOR SELECT USING (true);
CREATE POLICY "Public read access" ON exemptions FOR SELECT USING (true);
CREATE POLICY "Public read access" ON appeal_processes FOR SELECT USING (true);
CREATE POLICY "Public read access" ON requester_requirements FOR SELECT USING (true);
CREATE POLICY "Public read access" ON agency_obligations FOR SELECT USING (true);
CREATE POLICY "Public read access" ON oversight_bodies FOR SELECT USING (true);
CREATE POLICY "Public read access" ON agencies FOR SELECT USING (true);

-- Admin write access (authenticated users with admin role)
-- Note: Adjust based on your authentication setup
```

## Data Migration Strategy

### Phase 1: Schema Creation
1. Run initial migration to create all tables
2. Set up RLS policies
3. Create indexes

### Phase 2: Data Import
1. Import 52 jurisdiction records from `releases/v0.11.0/jurisdictions/*.json`
2. Use transaction-safe batching for large datasets
3. Validate data integrity after import

### Phase 3: Verification
1. Confirm 52 jurisdictions imported correctly
2. Verify all relationships (foreign keys)
3. Run query performance tests

## TypeScript Type Generation

After schema creation, generate TypeScript types:

```bash
npx supabase gen types typescript --local > src/types/database.types.ts
```

This creates type-safe interfaces for querying the database from the platform.

## Query Examples

### Get all jurisdictions with their transparency laws
```typescript
const { data, error } = await supabase
  .from('jurisdictions')
  .select(`
    *,
    transparency_law:transparency_laws(*)
  `);
```

### Get jurisdiction with full nested data
```typescript
const { data, error } = await supabase
  .from('jurisdictions')
  .select(`
    *,
    transparency_law:transparency_laws(
      *,
      response_requirements(*),
      fee_structure:fee_structures(*),
      exemptions(*),
      appeal_process:appeal_processes(*),
      requester_requirements(*),
      agency_obligations(*),
      oversight_body:oversight_bodies(*)
    )
  `)
  .eq('slug', 'california')
  .single();
```

### Search exemptions across all jurisdictions
```typescript
const { data, error } = await supabase
  .from('exemptions')
  .select(`
    *,
    transparency_law:transparency_laws(
      jurisdiction:jurisdictions(name, slug)
    )
  `)
  .ilike('category', '%Privacy%');
```

## Performance Considerations

1. **Indexes**: All foreign keys have indexes for efficient joins
2. **JSONB Indexes**: GIN indexes on JSONB columns for fast queries
3. **Pagination**: Use `.range()` for large result sets
4. **Caching**: Leverage Supabase's built-in caching for static data
5. **Prepared Statements**: Use query builder for automatic statement preparation

## Next Steps

1. ✅ Schema design complete (this document)
2. ⏳ Create initial migration SQL file
3. ⏳ Write data import script (JSON → PostgreSQL)
4. ⏳ Generate TypeScript types
5. ⏳ Test queries from platform
6. ⏳ Deploy to production Supabase instance

---

**Schema Version**: v0.11.1
**Status**: Design Complete, Ready for Implementation
**Next**: Create `supabase/migrations/00000000000001_initial_schema.sql`
