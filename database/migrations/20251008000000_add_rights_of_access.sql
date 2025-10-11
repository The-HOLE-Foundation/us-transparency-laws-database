-- ============================================================================
-- v0.12 Migration: Add Rights of Access Table
-- ============================================================================
-- Project: The HOLE Foundation - US Transparency Laws Database
-- Version: v0.12
-- Date: 2025-10-08
-- Description: Creates rights_of_access table to document affirmative access rights
--              This table mirrors exemptions structure but catalogs what requesters
--              CAN access rather than what they cannot.
-- ============================================================================

-- ============================================================================
-- TABLE: rights_of_access
-- ============================================================================
-- Documents affirmative rights of access to public records
-- Mirrors exemptions table structure for consistency
-- ============================================================================

CREATE TABLE rights_of_access (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transparency_law_id UUID NOT NULL REFERENCES transparency_laws(id) ON DELETE CASCADE,

    -- Jurisdiction denormalization (for efficient queries without joins)
    jurisdiction_slug TEXT NOT NULL,
    jurisdiction_name TEXT NOT NULL,

    -- Right classification
    category TEXT NOT NULL,              -- e.g., 'Proactive Disclosure', 'Enhanced Access', 'Technology Rights'
    subcategory TEXT,                    -- e.g., 'Meeting Records', 'Budget Documents', 'API Access'

    -- Legal foundation
    statute_citation TEXT,               -- Specific statutory citation granting this right
    description TEXT NOT NULL,           -- Clear description of what can be accessed

    -- Conditions and scope
    conditions TEXT,                     -- Conditions or requirements for exercising this right
    applies_to TEXT,                     -- Who can exercise this right (if limited)

    -- Implementation details
    implementation_notes TEXT,           -- How agencies typically implement this right
    request_tips TEXT,                   -- Tips for asserting this right in FOIA requests

    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX idx_rights_of_access_law ON rights_of_access(transparency_law_id);
CREATE INDEX idx_rights_of_access_jurisdiction ON rights_of_access(jurisdiction_slug);
CREATE INDEX idx_rights_of_access_category ON rights_of_access(category);
CREATE INDEX idx_rights_of_access_subcategory ON rights_of_access(subcategory);

-- Full-text search on descriptions
CREATE INDEX idx_rights_of_access_description ON rights_of_access USING GIN (to_tsvector('english', description));

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================
-- Rights of access are public information - anyone can read
-- ============================================================================

ALTER TABLE rights_of_access ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Rights of access are viewable by everyone"
    ON rights_of_access FOR SELECT
    USING (true);

-- ============================================================================
-- TRIGGERS
-- ============================================================================
-- Auto-update updated_at timestamp
-- ============================================================================

CREATE TRIGGER update_rights_of_access_updated_at
    BEFORE UPDATE ON rights_of_access
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE rights_of_access IS
'v0.12: Affirmative rights of access to public records by jurisdiction. Catalogs what requesters CAN access, complementing the exemptions table.';

COMMENT ON COLUMN rights_of_access.transparency_law_id IS
'Links to the transparency_laws table (one-to-many relationship)';

COMMENT ON COLUMN rights_of_access.jurisdiction_slug IS
'Denormalized jurisdiction identifier for efficient filtering';

COMMENT ON COLUMN rights_of_access.category IS
'Primary classification: Proactive Disclosure, Enhanced Access Rights, Technology Rights, Requester-Specific Rights, Inspection Rights, Timeliness Rights';

COMMENT ON COLUMN rights_of_access.subcategory IS
'Secondary classification for finer granularity (e.g., Meeting Records, API Access, Journalist Privileges)';

COMMENT ON COLUMN rights_of_access.description IS
'Clear, actionable description of what records or access this right provides';

COMMENT ON COLUMN rights_of_access.conditions IS
'Any conditions, requirements, or limitations for exercising this right';

COMMENT ON COLUMN rights_of_access.applies_to IS
'Specifies if right is limited to certain requesters (e.g., "journalists", "researchers", or "general public")';

COMMENT ON COLUMN rights_of_access.request_tips IS
'Practical guidance for asserting this right in FOIA requests. Used by FOIA Generator.';

-- ============================================================================
-- VIEW: transparency_landscape
-- ============================================================================
-- Combines rights and exemptions for complete transparency picture
-- ============================================================================

CREATE VIEW transparency_landscape AS
SELECT
    j.slug,
    j.name AS jurisdiction_name,
    j.jurisdiction_type,

    -- Rights counts
    COUNT(DISTINCT ra.id) AS total_rights,
    COUNT(DISTINCT ra.id) FILTER (WHERE ra.category = 'Proactive Disclosure') AS proactive_disclosure_rights,
    COUNT(DISTINCT ra.id) FILTER (WHERE ra.category = 'Technology Rights') AS technology_rights,
    COUNT(DISTINCT ra.id) FILTER (WHERE ra.category = 'Enhanced Access Rights') AS enhanced_access_rights,
    COUNT(DISTINCT ra.id) FILTER (WHERE ra.category = 'Requester-Specific Rights') AS requester_specific_rights,
    COUNT(DISTINCT ra.id) FILTER (WHERE ra.category = 'Inspection Rights') AS inspection_rights,
    COUNT(DISTINCT ra.id) FILTER (WHERE ra.category = 'Timeliness Rights') AS timeliness_rights,

    -- Exemptions counts
    COUNT(DISTINCT e.id) AS total_exemptions,
    COUNT(DISTINCT e.id) FILTER (WHERE e.category = 'Law Enforcement') AS law_enforcement_exemptions,
    COUNT(DISTINCT e.id) FILTER (WHERE e.category = 'Privacy') AS privacy_exemptions,

    -- Transparency ratio (rights vs exemptions)
    CASE
        WHEN COUNT(DISTINCT e.id) > 0
        THEN ROUND((COUNT(DISTINCT ra.id)::numeric / COUNT(DISTINCT e.id)::numeric), 2)
        ELSE NULL
    END AS transparency_ratio,

    -- Data completeness
    CASE
        WHEN COUNT(DISTINCT ra.id) > 0 AND COUNT(DISTINCT e.id) > 0
        THEN 'Complete'
        WHEN COUNT(DISTINCT e.id) > 0
        THEN 'Exemptions Only'
        WHEN COUNT(DISTINCT ra.id) > 0
        THEN 'Rights Only'
        ELSE 'No Data'
    END AS data_status

FROM jurisdictions j
LEFT JOIN transparency_laws tl ON tl.jurisdiction_id = j.id
LEFT JOIN rights_of_access ra ON ra.transparency_law_id = tl.id
LEFT JOIN exemptions e ON e.transparency_law_id = tl.id
GROUP BY j.slug, j.name, j.jurisdiction_type
ORDER BY total_rights DESC, total_exemptions ASC;

COMMENT ON VIEW transparency_landscape IS
'v0.12: Combined analysis view showing both rights and exemptions across all jurisdictions. Higher transparency_ratio indicates more documented rights relative to exemptions.';

-- ============================================================================
-- MIGRATION VERIFICATION
-- ============================================================================

DO $$
BEGIN
    -- Verify table exists
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'rights_of_access') THEN
        RAISE EXCEPTION 'Migration failed: rights_of_access table not created';
    END IF;

    -- Verify view exists
    IF NOT EXISTS (SELECT FROM pg_views WHERE schemaname = 'public' AND viewname = 'transparency_landscape') THEN
        RAISE EXCEPTION 'Migration failed: transparency_landscape view not created';
    END IF;

    RAISE NOTICE 'v0.12 migration completed successfully';
    RAISE NOTICE 'Created: rights_of_access table';
    RAISE NOTICE 'Created: transparency_landscape view';
    RAISE NOTICE 'Ready for data population';
END $$;
