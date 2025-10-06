-- ============================================================================
-- US Transparency Laws Database - Initial Schema
-- ============================================================================
-- Project: The HOLE Foundation - US Transparency Laws Database
-- Version: v0.11.1 (Supabase Integration)
-- Date: 2025-10-06
-- Description: Complete PostgreSQL schema for 52-jurisdiction transparency law database
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE: jurisdictions
-- ============================================================================
-- Core table for jurisdiction metadata (Federal + 50 States + DC)
-- ============================================================================

CREATE TABLE jurisdictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT NOT NULL UNIQUE,           -- URL-friendly identifier: 'federal', 'california', etc.
    name TEXT NOT NULL,                   -- Display name: 'Federal', 'California', etc.
    jurisdiction_type TEXT NOT NULL CHECK (jurisdiction_type IN ('federal', 'state', 'district')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE UNIQUE INDEX idx_jurisdictions_slug ON jurisdictions(slug);
CREATE INDEX idx_jurisdictions_type ON jurisdictions(jurisdiction_type);

-- Comments
COMMENT ON TABLE jurisdictions IS 'Core jurisdictions table (Federal + 50 States + DC = 52 total)';
COMMENT ON COLUMN jurisdictions.slug IS 'URL-friendly identifier for lookups (e.g., "california", "new-york")';
COMMENT ON COLUMN jurisdictions.jurisdiction_type IS 'Type: federal, state, or district (DC)';

-- ============================================================================
-- TABLE: transparency_laws
-- ============================================================================
-- Main transparency law information (one per jurisdiction)
-- ============================================================================

CREATE TABLE transparency_laws (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    jurisdiction_id UUID NOT NULL REFERENCES jurisdictions(id) ON DELETE CASCADE,

    -- Basic statute information
    name TEXT NOT NULL,                   -- 'Freedom of Information Act', 'California Public Records Act'
    statute_citation TEXT NOT NULL,       -- '5 U.S.C. § 552', 'Cal. Gov. Code §§ 7920.000-7931.000'
    effective_date DATE,                  -- Original enactment date
    last_amended DATE,                    -- Most recent amendment date

    -- Official resources (JSONB for flexibility)
    official_resources JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Validation metadata
    validation_metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT one_law_per_jurisdiction UNIQUE (jurisdiction_id)
);

-- Indexes
CREATE UNIQUE INDEX idx_transparency_laws_jurisdiction ON transparency_laws(jurisdiction_id);
CREATE INDEX idx_transparency_laws_name ON transparency_laws(name);
CREATE INDEX idx_transparency_laws_official_resources ON transparency_laws USING GIN (official_resources);
CREATE INDEX idx_transparency_laws_validation_metadata ON transparency_laws USING GIN (validation_metadata);

-- Comments
COMMENT ON TABLE transparency_laws IS 'Transparency law details for each jurisdiction (1:1 relationship)';
COMMENT ON COLUMN transparency_laws.official_resources IS 'JSONB: {primary_statute_url, agency_handbook_url, request_portal_url, oversight_url}';
COMMENT ON COLUMN transparency_laws.validation_metadata IS 'JSONB: {parsed_date, confidence_level, source_url, source_verified, primary_sources[], verification_notes}';

-- ============================================================================
-- TABLE: response_requirements
-- ============================================================================
-- Response timelines, extensions, and tolling rules
-- ============================================================================

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

-- Indexes
CREATE UNIQUE INDEX idx_response_requirements_law ON response_requirements(transparency_law_id);
CREATE INDEX idx_response_requirements_initial_time ON response_requirements(initial_response_time);

-- Comments
COMMENT ON TABLE response_requirements IS 'Response timelines and extension rules for each transparency law';
COMMENT ON COLUMN response_requirements.initial_response_unit IS 'business_days (excluding weekends/holidays), calendar_days, or working_days';

-- ============================================================================
-- TABLE: fee_structures
-- ============================================================================
-- Fee schedules, waivers, and payment rules
-- ============================================================================

CREATE TABLE fee_structures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transparency_law_id UUID NOT NULL REFERENCES transparency_laws(id) ON DELETE CASCADE,

    -- Search fees
    search_fee TEXT,
    search_fee_statutory_cite TEXT,

    -- Copy fees
    copy_fee_per_page DECIMAL(10,2),      -- Dollar amount or NULL if varies
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

-- Indexes
CREATE UNIQUE INDEX idx_fee_structures_law ON fee_structures(transparency_law_id);
CREATE INDEX idx_fee_structures_waiver ON fee_structures(fee_waiver_available);

-- Comments
COMMENT ON TABLE fee_structures IS 'Fee schedules and waiver criteria for each transparency law';
COMMENT ON COLUMN fee_structures.copy_fee_per_page IS 'Per-page cost in dollars (NULL if varies by agency/format)';

-- ============================================================================
-- TABLE: exemptions
-- ============================================================================
-- Transparency law exemptions (one-to-many relationship)
-- ============================================================================

CREATE TABLE exemptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transparency_law_id UUID NOT NULL REFERENCES transparency_laws(id) ON DELETE CASCADE,

    -- Exemption details
    category TEXT NOT NULL,               -- 'National Security', 'Personal Privacy', etc.
    citation TEXT NOT NULL,               -- Statutory citation
    description TEXT NOT NULL,            -- Full description of exemption
    scope TEXT NOT NULL CHECK (scope IN ('narrow', 'moderate', 'broad')),

    -- Optional subcategories
    subcategories TEXT,

    -- Display order for consistent presentation
    display_order INTEGER NOT NULL DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_exemptions_law ON exemptions(transparency_law_id);
CREATE INDEX idx_exemptions_law_order ON exemptions(transparency_law_id, display_order);
CREATE INDEX idx_exemptions_category ON exemptions(category);
CREATE INDEX idx_exemptions_scope ON exemptions(scope);

-- Comments
COMMENT ON TABLE exemptions IS 'Exemption categories for each transparency law (many per law)';
COMMENT ON COLUMN exemptions.scope IS 'narrow (rarely invoked), moderate (commonly used), broad (widely applied)';

-- ============================================================================
-- TABLE: appeal_processes
-- ============================================================================
-- Administrative and judicial appeal procedures
-- ============================================================================

CREATE TABLE appeal_processes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transparency_law_id UUID NOT NULL REFERENCES transparency_laws(id) ON DELETE CASCADE,

    -- First level (administrative appeal)
    first_level TEXT NOT NULL,
    first_level_deadline_days INTEGER,
    first_level_deadline_notes TEXT,
    first_level_cite TEXT,

    -- Second level (judicial appeal)
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

-- Indexes
CREATE UNIQUE INDEX idx_appeal_processes_law ON appeal_processes(transparency_law_id);
CREATE INDEX idx_appeal_processes_fees ON appeal_processes(attorney_fees_recoverable);

-- Comments
COMMENT ON TABLE appeal_processes IS 'Appeal procedures for denied or delayed requests';
COMMENT ON COLUMN appeal_processes.first_level IS 'Administrative appeal (agency head, FOIA officer, etc.)';
COMMENT ON COLUMN appeal_processes.second_level IS 'Judicial appeal (district court, superior court, etc.)';

-- ============================================================================
-- TABLE: requester_requirements
-- ============================================================================
-- Requirements for submitting transparency requests
-- ============================================================================

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

-- Indexes
CREATE UNIQUE INDEX idx_requester_requirements_law ON requester_requirements(transparency_law_id);
CREATE INDEX idx_requester_requirements_residency ON requester_requirements(residency_requirement);

-- Comments
COMMENT ON TABLE requester_requirements IS 'Who can request records and what information they must provide';
COMMENT ON COLUMN requester_requirements.residency_requirement IS 'TRUE if requesters must be residents/citizens';

-- ============================================================================
-- TABLE: agency_obligations
-- ============================================================================
-- Agency duties and requirements under transparency law
-- ============================================================================

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

-- Indexes
CREATE UNIQUE INDEX idx_agency_obligations_law ON agency_obligations(transparency_law_id);

-- Comments
COMMENT ON TABLE agency_obligations IS 'Agency responsibilities and requirements under transparency law';
COMMENT ON COLUMN agency_obligations.records_officer_required IS 'TRUE if agencies must designate FOIA/records officer';

-- ============================================================================
-- TABLE: oversight_bodies
-- ============================================================================
-- Oversight and ombudsman entities
-- ============================================================================

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

-- Indexes
CREATE UNIQUE INDEX idx_oversight_bodies_law ON oversight_bodies(transparency_law_id);

-- Comments
COMMENT ON TABLE oversight_bodies IS 'Government oversight entities for transparency law compliance';
COMMENT ON COLUMN oversight_bodies.role IS 'E.g., "FOIA ombudsman and mediation services"';

-- ============================================================================
-- TABLE: agencies (Future v0.12)
-- ============================================================================
-- Agency contact information (currently empty, planned for v0.12)
-- ============================================================================

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

-- Indexes
CREATE INDEX idx_agencies_jurisdiction ON agencies(jurisdiction_id);
CREATE INDEX idx_agencies_name ON agencies(name);
CREATE INDEX idx_agencies_contact_info ON agencies USING GIN (contact_info);

-- Comments
COMMENT ON TABLE agencies IS 'Agency contact information (Layer 4 - planned for v0.12)';
COMMENT ON COLUMN agencies.contact_info IS 'JSONB: {phone, fax, mailing_address, website, etc.}';

-- ============================================================================
-- ROW-LEVEL SECURITY (RLS)
-- ============================================================================
-- Enable public read access, restrict write access
-- ============================================================================

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

-- Public read access policies
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

-- ============================================================================
-- TRIGGERS: Automatic timestamp updates
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables
CREATE TRIGGER update_jurisdictions_updated_at BEFORE UPDATE ON jurisdictions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transparency_laws_updated_at BEFORE UPDATE ON transparency_laws
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_response_requirements_updated_at BEFORE UPDATE ON response_requirements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fee_structures_updated_at BEFORE UPDATE ON fee_structures
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_exemptions_updated_at BEFORE UPDATE ON exemptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appeal_processes_updated_at BEFORE UPDATE ON appeal_processes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_requester_requirements_updated_at BEFORE UPDATE ON requester_requirements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agency_obligations_updated_at BEFORE UPDATE ON agency_obligations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_oversight_bodies_updated_at BEFORE UPDATE ON oversight_bodies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agencies_updated_at BEFORE UPDATE ON agencies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- Next steps:
-- 1. Import data from releases/v0.11.0/jurisdictions/*.json
-- 2. Generate TypeScript types: npx supabase gen types typescript --local
-- 3. Test queries from platform
-- ============================================================================
