---
-- Supabase Database Schema for Transparency Map Dataset
-- Version: v0.11
-- Created: 2025-09-29
-- Author: Claude Code AI Assistant
-- Project: The HOLE Foundation - US Transparency Laws Database
--
-- This schema supports the interactive transparency map interface
-- on theholetruth.org with optimized queries and data structure.
---

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE 1: timeline_code_reference
-- Reference table for negative timeline codes
-- ============================================================================

CREATE TABLE timeline_code_reference (
    code INTEGER PRIMARY KEY CHECK (code < 0),
    name VARCHAR(50) NOT NULL UNIQUE,
    display_text VARCHAR(100) NOT NULL,
    display_short VARCHAR(20) NOT NULL,
    description TEXT NOT NULL,
    typical_range VARCHAR(50),
    common_factors JSONB DEFAULT '[]'::jsonb,
    applies_to TEXT,
    map_display_note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE timeline_code_reference IS 'Reference table for flexible response timeline codes (negative integers)';
COMMENT ON COLUMN timeline_code_reference.code IS 'Negative integer code (-1, -2, -3, -4)';
COMMENT ON COLUMN timeline_code_reference.name IS 'Internal name (e.g., REASONABLE_TIME)';
COMMENT ON COLUMN timeline_code_reference.display_text IS 'Full text for display (e.g., "Reasonable time")';
COMMENT ON COLUMN timeline_code_reference.display_short IS 'Short text for compact display (e.g., "Varies")';

-- Insert reference data
INSERT INTO timeline_code_reference (code, name, display_text, display_short, description, typical_range, common_factors, applies_to, map_display_note) VALUES
(-1, 'REASONABLE_TIME', 'Reasonable time', 'Varies', 'No fixed statutory deadline. Agency must respond within a reasonable time based on circumstances.', '3-30 days', '["Request complexity", "Volume of records", "Agency resources"]', 'Full requests', 'Show tooltip: No fixed deadline - varies by request'),
(-2, 'PROMPTLY', 'Promptly', 'Prompt', 'Agency must respond promptly but without a specific day count mandated by statute.', '5-10 days', '["Nature of records", "Urgency", "Accessibility"]', 'Standard requests', 'Show tooltip: Prompt response required - typically within days'),
(-3, 'IMMEDIATE', 'Immediate', 'Now', 'Certain records must be made available immediately without delay.', 'Same day', '["Record type", "Public safety", "Real-time records"]', 'Specific record types only', 'Show tooltip: Certain records available immediately'),
(-4, 'VARIABLE_BY_TYPE', 'Varies by request type', 'Varies', 'Response timeline varies based on request type, complexity, or track assignment.', '3-30 days', '["Request track", "Volume", "Consultation needs"]', 'Depends on classification', 'Show tooltip: Timeline varies by request type');

-- ============================================================================
-- TABLE 2: transparency_map_jurisdictions
-- Main table containing all jurisdiction data for the map
-- ============================================================================

CREATE TABLE transparency_map_jurisdictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    jurisdiction_code VARCHAR(3) NOT NULL UNIQUE CHECK (jurisdiction_code ~ '^[A-Z]{2,3}$'),
    jurisdiction_name VARCHAR(100) NOT NULL UNIQUE,
    statute_abbreviation VARCHAR(20) NOT NULL,
    statute_full_name VARCHAR(300) NOT NULL,

    -- Core information
    core_principle TEXT NOT NULL CHECK (char_length(core_principle) >= 20),
    recent_changes_2024_2025 TEXT,

    -- Response timeline (integer can be positive for fixed days or negative for codes)
    response_timeline_days INTEGER NOT NULL,
    response_timeline_type VARCHAR(20) CHECK (response_timeline_type IN ('business', 'calendar', 'flexible', 'unspecified')),
    response_timeline_description VARCHAR(300),
    response_timeline_factors JSONB DEFAULT '[]'::jsonb,
    response_timeline_extension JSONB DEFAULT '{}'::jsonb,

    -- Public record categories
    public_record_categories JSONB NOT NULL DEFAULT '[]'::jsonb,

    -- Fee structure (stored as JSONB for flexibility)
    fee_structure JSONB NOT NULL DEFAULT '{}'::jsonb,
    fee_waiver_available BOOLEAN DEFAULT FALSE,

    -- Appeal process
    appeal_process JSONB NOT NULL DEFAULT '{}'::jsonb,
    attorney_fees_available BOOLEAN DEFAULT FALSE,

    -- Quick reference tags
    key_features_tags TEXT[] DEFAULT ARRAY[]::TEXT[],

    -- Official resources
    statute_url TEXT,
    ag_page_url TEXT,
    request_portal_url TEXT,

    -- Metadata
    version VARCHAR(10) DEFAULT 'v0.11',
    verification_date DATE DEFAULT CURRENT_DATE,
    last_statutory_update VARCHAR(100),
    process_map_source VARCHAR(200),
    extraction_date DATE DEFAULT CURRENT_DATE,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Foreign key to timeline codes (for negative values)
    CONSTRAINT fk_timeline_code FOREIGN KEY (response_timeline_days)
        REFERENCES timeline_code_reference(code)
        ON DELETE RESTRICT
        DEFERRABLE INITIALLY DEFERRED
);

COMMENT ON TABLE transparency_map_jurisdictions IS 'Main table for transparency map data - contains curated information for all 51 US jurisdictions';
COMMENT ON COLUMN transparency_map_jurisdictions.jurisdiction_code IS 'Two or three letter code (e.g., CA, TX, FED)';
COMMENT ON COLUMN transparency_map_jurisdictions.response_timeline_days IS 'Positive = fixed days, Negative = code from timeline_code_reference';
COMMENT ON COLUMN transparency_map_jurisdictions.fee_structure IS 'JSON object containing fee details';
COMMENT ON COLUMN transparency_map_jurisdictions.appeal_process IS 'JSON object containing appeal process details';

-- Disable foreign key constraint for positive values (they won't be in reference table)
ALTER TABLE transparency_map_jurisdictions DROP CONSTRAINT fk_timeline_code;
ALTER TABLE transparency_map_jurisdictions ADD CONSTRAINT fk_timeline_code_check
    CHECK (
        response_timeline_days > 0 OR
        response_timeline_days IN (SELECT code FROM timeline_code_reference)
    );

-- ============================================================================
-- TABLE 3: jurisdiction_2025_amendments
-- Detailed tracking of 2025 legislative changes
-- ============================================================================

CREATE TABLE jurisdiction_2025_amendments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    jurisdiction_id UUID NOT NULL REFERENCES transparency_map_jurisdictions(id) ON DELETE CASCADE,
    bill_number VARCHAR(50) NOT NULL,
    effective_date DATE,
    impact_level VARCHAR(20) CHECK (impact_level IN ('major', 'moderate', 'minor', 'technical')),
    summary TEXT NOT NULL,
    key_changes JSONB DEFAULT '[]'::jsonb,
    affected_sections TEXT[],
    verification_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE jurisdiction_2025_amendments IS 'Detailed tracking of 2024-2025 legislative amendments to transparency laws';

CREATE INDEX idx_amendments_jurisdiction ON jurisdiction_2025_amendments(jurisdiction_id);
CREATE INDEX idx_amendments_impact ON jurisdiction_2025_amendments(impact_level);
CREATE INDEX idx_amendments_effective_date ON jurisdiction_2025_amendments(effective_date);

-- ============================================================================
-- INDEXES for performance optimization
-- ============================================================================

-- Primary search indexes
CREATE INDEX idx_jurisdiction_code ON transparency_map_jurisdictions(jurisdiction_code);
CREATE INDEX idx_jurisdiction_name ON transparency_map_jurisdictions(jurisdiction_name);
CREATE INDEX idx_statute_abbrev ON transparency_map_jurisdictions(statute_abbreviation);

-- Timeline indexes for filtering
CREATE INDEX idx_timeline_days ON transparency_map_jurisdictions(response_timeline_days);
CREATE INDEX idx_timeline_type ON transparency_map_jurisdictions(response_timeline_type);

-- Feature flags for filtering
CREATE INDEX idx_fee_waiver ON transparency_map_jurisdictions(fee_waiver_available);
CREATE INDEX idx_attorney_fees ON transparency_map_jurisdictions(attorney_fees_available);

-- JSONB indexes for complex queries
CREATE INDEX idx_fee_structure_gin ON transparency_map_jurisdictions USING GIN (fee_structure);
CREATE INDEX idx_appeal_process_gin ON transparency_map_jurisdictions USING GIN (appeal_process);
CREATE INDEX idx_public_categories_gin ON transparency_map_jurisdictions USING GIN (public_record_categories);

-- Array index for tags
CREATE INDEX idx_key_features_gin ON transparency_map_jurisdictions USING GIN (key_features_tags);

-- Full text search index
CREATE INDEX idx_fulltext_search ON transparency_map_jurisdictions USING GIN (
    to_tsvector('english',
        coalesce(jurisdiction_name, '') || ' ' ||
        coalesce(statute_full_name, '') || ' ' ||
        coalesce(core_principle, '') || ' ' ||
        coalesce(recent_changes_2024_2025, '')
    )
);

-- ============================================================================
-- VIEWS for common queries
-- ============================================================================

-- View 1: Map display view (optimized for map interface)
CREATE VIEW transparency_map_display AS
SELECT
    j.jurisdiction_code,
    j.jurisdiction_name,
    j.statute_abbreviation,
    j.statute_full_name,
    j.response_timeline_days,
    CASE
        WHEN j.response_timeline_days > 0 THEN
            j.response_timeline_days::TEXT || ' ' ||
            COALESCE(j.response_timeline_type, 'days')
        WHEN j.response_timeline_days < 0 THEN
            tcr.display_text
        ELSE 'Unknown'
    END AS response_timeline_display,
    j.fee_waiver_available,
    j.attorney_fees_available,
    j.key_features_tags,
    j.recent_changes_2024_2025 IS NOT NULL AND
        j.recent_changes_2024_2025 ~ '2025' AS has_2025_amendments,
    j.statute_url,
    j.ag_page_url
FROM transparency_map_jurisdictions j
LEFT JOIN timeline_code_reference tcr ON j.response_timeline_days = tcr.code
ORDER BY j.jurisdiction_name;

COMMENT ON VIEW transparency_map_display IS 'Optimized view for map interface display with formatted timeline text';

-- View 2: Fixed deadline jurisdictions
CREATE VIEW fixed_deadline_jurisdictions AS
SELECT
    jurisdiction_code,
    jurisdiction_name,
    statute_abbreviation,
    response_timeline_days,
    response_timeline_type,
    response_timeline_description,
    key_features_tags
FROM transparency_map_jurisdictions
WHERE response_timeline_days > 0
ORDER BY response_timeline_days, jurisdiction_name;

COMMENT ON VIEW fixed_deadline_jurisdictions IS 'Jurisdictions with fixed statutory response deadlines';

-- View 3: Flexible deadline jurisdictions
CREATE VIEW flexible_deadline_jurisdictions AS
SELECT
    j.jurisdiction_code,
    j.jurisdiction_name,
    j.statute_abbreviation,
    j.response_timeline_days,
    tcr.name AS timeline_code_name,
    tcr.display_text,
    j.response_timeline_factors,
    j.key_features_tags
FROM transparency_map_jurisdictions j
JOIN timeline_code_reference tcr ON j.response_timeline_days = tcr.code
ORDER BY j.jurisdiction_name;

COMMENT ON VIEW flexible_deadline_jurisdictions IS 'Jurisdictions with flexible response timelines (reasonable time, promptly, etc.)';

-- View 4: 2025 amendments summary
CREATE VIEW jurisdictions_with_2025_amendments AS
SELECT
    jurisdiction_code,
    jurisdiction_name,
    statute_abbreviation,
    recent_changes_2024_2025,
    last_statutory_update
FROM transparency_map_jurisdictions
WHERE recent_changes_2024_2025 IS NOT NULL
    AND recent_changes_2024_2025 ~ '2025'
ORDER BY last_statutory_update DESC NULLS LAST, jurisdiction_name;

COMMENT ON VIEW jurisdictions_with_2025_amendments IS 'Jurisdictions with 2024-2025 legislative amendments';

-- ============================================================================
-- FUNCTIONS for common operations
-- ============================================================================

-- Function 1: Get formatted timeline display
CREATE OR REPLACE FUNCTION get_timeline_display(jurisdiction_code_param VARCHAR(3))
RETURNS TEXT AS $$
DECLARE
    timeline_days INTEGER;
    timeline_type VARCHAR(20);
    display_text VARCHAR(100);
BEGIN
    SELECT
        j.response_timeline_days,
        j.response_timeline_type
    INTO timeline_days, timeline_type
    FROM transparency_map_jurisdictions j
    WHERE j.jurisdiction_code = jurisdiction_code_param;

    IF timeline_days IS NULL THEN
        RETURN 'Unknown';
    END IF;

    IF timeline_days > 0 THEN
        RETURN timeline_days::TEXT || ' ' || COALESCE(timeline_type, 'days');
    ELSE
        SELECT tcr.display_text INTO display_text
        FROM timeline_code_reference tcr
        WHERE tcr.code = timeline_days;
        RETURN COALESCE(display_text, 'Flexible');
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION get_timeline_display IS 'Returns formatted timeline text for display (e.g., "10 business days" or "Reasonable time")';

-- Function 2: Search jurisdictions
CREATE OR REPLACE FUNCTION search_jurisdictions(search_term TEXT)
RETURNS TABLE (
    jurisdiction_code VARCHAR(3),
    jurisdiction_name VARCHAR(100),
    statute_full_name VARCHAR(300),
    relevance REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        j.jurisdiction_code,
        j.jurisdiction_name,
        j.statute_full_name,
        ts_rank(
            to_tsvector('english',
                coalesce(j.jurisdiction_name, '') || ' ' ||
                coalesce(j.statute_full_name, '') || ' ' ||
                coalesce(j.core_principle, '')
            ),
            plainto_tsquery('english', search_term)
        ) AS relevance
    FROM transparency_map_jurisdictions j
    WHERE to_tsvector('english',
            coalesce(j.jurisdiction_name, '') || ' ' ||
            coalesce(j.statute_full_name, '') || ' ' ||
            coalesce(j.core_principle, '')
        ) @@ plainto_tsquery('english', search_term)
    ORDER BY relevance DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION search_jurisdictions IS 'Full-text search across jurisdictions';

-- ============================================================================
-- TRIGGERS for updated_at timestamps
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_transparency_map_jurisdictions_updated_at
    BEFORE UPDATE ON transparency_map_jurisdictions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_timeline_code_reference_updated_at
    BEFORE UPDATE ON timeline_code_reference
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_jurisdiction_2025_amendments_updated_at
    BEFORE UPDATE ON jurisdiction_2025_amendments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) Policies
-- ============================================================================

-- Enable RLS
ALTER TABLE transparency_map_jurisdictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE timeline_code_reference ENABLE ROW LEVEL SECURITY;
ALTER TABLE jurisdiction_2025_amendments ENABLE ROW LEVEL SECURITY;

-- Public read access (all data is public)
CREATE POLICY "Public read access" ON transparency_map_jurisdictions
    FOR SELECT TO PUBLIC USING (true);

CREATE POLICY "Public read access" ON timeline_code_reference
    FOR SELECT TO PUBLIC USING (true);

CREATE POLICY "Public read access" ON jurisdiction_2025_amendments
    FOR SELECT TO PUBLIC USING (true);

-- Admin write access (requires authentication)
CREATE POLICY "Admin full access" ON transparency_map_jurisdictions
    FOR ALL TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Admin full access" ON timeline_code_reference
    FOR ALL TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Admin full access" ON jurisdiction_2025_amendments
    FOR ALL TO authenticated
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- SAMPLE QUERIES for frontend development
-- ============================================================================

-- Query 1: Get all jurisdictions for map display
-- SELECT * FROM transparency_map_display;

-- Query 2: Get specific jurisdiction details
-- SELECT * FROM transparency_map_jurisdictions WHERE jurisdiction_code = 'CA';

-- Query 3: Get all jurisdictions with fixed deadlines
-- SELECT * FROM fixed_deadline_jurisdictions;

-- Query 4: Get all jurisdictions with fee waivers
-- SELECT jurisdiction_code, jurisdiction_name, fee_structure->'waiver_criteria'
-- FROM transparency_map_jurisdictions WHERE fee_waiver_available = true;

-- Query 5: Get jurisdictions by response time range
-- SELECT jurisdiction_code, jurisdiction_name, response_timeline_days
-- FROM transparency_map_jurisdictions
-- WHERE response_timeline_days BETWEEN 5 AND 15
-- ORDER BY response_timeline_days;

-- Query 6: Search for specific text
-- SELECT * FROM search_jurisdictions('attorney fees');

-- Query 7: Get timeline code explanation
-- SELECT * FROM timeline_code_reference WHERE code = -1;

-- ============================================================================
-- GRANTS (adjust based on your Supabase setup)
-- ============================================================================

-- Grant read access to anonymous users
GRANT SELECT ON transparency_map_jurisdictions TO anon;
GRANT SELECT ON timeline_code_reference TO anon;
GRANT SELECT ON jurisdiction_2025_amendments TO anon;
GRANT SELECT ON transparency_map_display TO anon;
GRANT SELECT ON fixed_deadline_jurisdictions TO anon;
GRANT SELECT ON flexible_deadline_jurisdictions TO anon;
GRANT SELECT ON jurisdictions_with_2025_amendments TO anon;

-- Grant execute on functions
GRANT EXECUTE ON FUNCTION get_timeline_display TO anon;
GRANT EXECUTE ON FUNCTION search_jurisdictions TO anon;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================