-- ============================================================================
-- v0.13 Migration: Add Full Statutory Texts and Interconnections
-- ============================================================================
-- Project: The HOLE Foundation - US Transparency Laws Database
-- Version: v0.13
-- Date: 2025-10-11
-- Description: Creates comprehensive interconnected legal knowledge graph
--              - Full statutory texts table
--              - Record types excluded (police files, court records, etc.)
--              - Court records special rules
--              - Rights-exemptions conflict mappings
--              - Case law supporting rights
-- ============================================================================

-- ============================================================================
-- TABLE: statute_texts
-- ============================================================================
-- Full text of transparency law statutes
-- Referenced from jurisdictions table
-- ============================================================================

CREATE TABLE statute_texts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    jurisdiction_id VARCHAR(50) NOT NULL UNIQUE REFERENCES jurisdictions(id) ON DELETE CASCADE,

    -- Full statutory text
    full_text TEXT NOT NULL,

    -- Metadata
    statute_citation TEXT NOT NULL,
    effective_date DATE,
    last_amended DATE,

    -- Text statistics
    total_sections INT,
    word_count INT,
    character_count INT,

    -- Source verification
    official_source_url TEXT NOT NULL,
    retrieved_date DATE NOT NULL DEFAULT CURRENT_DATE,
    verified_date DATE,
    verified_by TEXT,

    -- Search
    text_vector tsvector,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_statute_texts_jurisdiction ON statute_texts(jurisdiction_id);
CREATE INDEX idx_statute_texts_search ON statute_texts USING GIN (text_vector);
CREATE INDEX idx_statute_texts_amended ON statute_texts(last_amended);

-- Auto-update text_vector for full-text search
CREATE OR REPLACE FUNCTION update_statute_text_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.text_vector = to_tsvector('english', NEW.full_text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER statute_texts_vector_update
    BEFORE INSERT OR UPDATE OF full_text ON statute_texts
    FOR EACH ROW EXECUTE FUNCTION update_statute_text_vector();

-- ============================================================================
-- TABLE: record_types_excluded
-- ============================================================================
-- Specific categories of records explicitly excluded from public access
-- Examples: "police personnel files", "court sealed records", "student records"
-- ============================================================================

CREATE TABLE record_types_excluded (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    jurisdiction_id VARCHAR(50) NOT NULL REFERENCES jurisdictions(id) ON DELETE CASCADE,

    -- Record type details
    record_type_name TEXT NOT NULL,              -- e.g., "Police Personnel Files"
    record_category TEXT NOT NULL,                -- e.g., "Law Enforcement", "Court Records", "Educational"

    -- Legal basis
    statutory_citation TEXT NOT NULL,
    exclusion_type TEXT NOT NULL,                 -- 'absolute', 'conditional', 'discretionary'

    -- Description
    description TEXT NOT NULL,
    conditions TEXT,                              -- When exclusion applies
    exceptions TEXT,                              -- When records might still be accessible

    -- Specific examples
    specific_examples TEXT[],                     -- e.g., ["Officer disciplinary files", "Internal affairs investigations"]

    -- Cross-references
    related_exemption_ids UUID[],                 -- Links to exemptions table
    overrides_rights BOOLEAN DEFAULT true,        -- Does this override general rights of access?

    -- Verification
    verified BOOLEAN DEFAULT false,
    verification_source TEXT,
    last_verified DATE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_record_exclusions_jurisdiction ON record_types_excluded(jurisdiction_id);
CREATE INDEX idx_record_exclusions_category ON record_types_excluded(record_category);
CREATE INDEX idx_record_exclusions_type ON record_types_excluded(exclusion_type);
CREATE INDEX idx_record_exclusions_search ON record_types_excluded USING GIN (to_tsvector('english', record_type_name || ' ' || description));

-- ============================================================================
-- TABLE: court_records_rules
-- ============================================================================
-- Special rules for court documents (often different from general FOIA)
-- ============================================================================

CREATE TABLE court_records_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    jurisdiction_id VARCHAR(50) NOT NULL REFERENCES jurisdictions(id) ON DELETE CASCADE,

    -- Court level
    court_level TEXT NOT NULL,                    -- 'supreme', 'appellate', 'trial', 'municipal', 'all'
    court_name TEXT,                              -- Specific court if applicable

    -- Access rules
    governed_by TEXT NOT NULL,                    -- 'FOIA', 'court_rules', 'separate_statute', 'hybrid'
    access_procedure TEXT NOT NULL,               -- How to request court records

    -- Statutory references
    primary_citation TEXT NOT NULL,
    court_rule_citation TEXT,                     -- If governed by court rules

    -- Differences from general FOIA
    differs_from_foia BOOLEAN DEFAULT false,
    key_differences TEXT[],                       -- e.g., ["Shorter timeline", "Different fees", "Judicial approval required"]

    -- Sealed/confidential records
    sealed_records_standard TEXT,                 -- When records can be sealed
    unsealing_process TEXT,                       -- How to unseal

    -- Special categories
    juvenile_records_rules TEXT,
    family_court_rules TEXT,
    criminal_records_rules TEXT,
    civil_records_rules TEXT,

    -- Public access
    public_access_hours TEXT,
    remote_access_available BOOLEAN,
    electronic_filing_system_url TEXT,

    -- Notes
    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_court_rules_jurisdiction ON court_records_rules(jurisdiction_id);
CREATE INDEX idx_court_rules_level ON court_records_rules(court_level);
CREATE INDEX idx_court_rules_governed_by ON court_records_rules(governed_by);

-- ============================================================================
-- TABLE: case_law
-- ============================================================================
-- Court cases interpreting transparency laws
-- Linked to specific rights or exemptions
-- ============================================================================

CREATE TABLE case_law (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    jurisdiction_id VARCHAR(50) NOT NULL REFERENCES jurisdictions(id) ON DELETE CASCADE,

    -- Case identification
    case_name TEXT NOT NULL,                      -- e.g., "Smith v. Department of Public Safety"
    case_citation TEXT NOT NULL UNIQUE,           -- e.g., "123 F.3d 456 (5th Cir. 2020)"
    court_name TEXT NOT NULL,
    decision_date DATE NOT NULL,

    -- Legal issue
    legal_issue TEXT NOT NULL,                    -- What the case decided
    holding TEXT NOT NULL,                        -- Court's ruling
    significance TEXT,                            -- Why this case matters

    -- Connections to our data
    related_right_ids UUID[],                     -- Links to rights_of_access
    related_exemption_ids UUID[],                 -- Links to exemptions

    -- Case type
    case_type TEXT NOT NULL,                      -- 'interpretation', 'application', 'constitutional', 'procedural'
    still_good_law BOOLEAN DEFAULT true,          -- Has it been overruled?
    superseded_by TEXT,                           -- If overruled, what replaced it?

    -- Full opinion
    opinion_url TEXT,                             -- Link to full opinion
    key_quotes TEXT[],                            -- Important quotes from opinion

    -- Practical impact
    practical_impact TEXT,                        -- How this affects FOIA requests
    requester_guidance TEXT,                      -- How to use this case in requests

    -- Verification
    verified BOOLEAN DEFAULT false,
    verification_source TEXT,
    last_verified DATE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_case_law_jurisdiction ON case_law(jurisdiction_id);
CREATE INDEX idx_case_law_date ON case_law(decision_date DESC);
CREATE INDEX idx_case_law_type ON case_law(case_type);
CREATE INDEX idx_case_law_good_law ON case_law(still_good_law) WHERE still_good_law = true;
CREATE INDEX idx_case_law_search ON case_law USING GIN (to_tsvector('english', case_name || ' ' || legal_issue || ' ' || holding));

-- ============================================================================
-- TABLE: rights_exemptions_conflicts
-- ============================================================================
-- Maps when exemptions override rights (and vice versa)
-- The "maze of interconnected rules" you described
-- ============================================================================

CREATE TABLE rights_exemptions_conflicts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    jurisdiction_id VARCHAR(50) NOT NULL REFERENCES jurisdictions(id) ON DELETE CASCADE,

    -- What's conflicting
    right_id UUID REFERENCES rights_of_access(id) ON DELETE CASCADE,
    exemption_category TEXT,                      -- From exemptions table

    -- How they interact
    conflict_type TEXT NOT NULL,                  -- 'exemption_overrides_right', 'right_prevails', 'balancing_required', 'unclear'

    -- Legal basis
    statutory_basis TEXT NOT NULL,                -- Which statute section governs the conflict
    resolution_standard TEXT,                     -- How conflicts are resolved (e.g., "public interest balancing test")

    -- Practical guidance
    resolution_description TEXT NOT NULL,
    common_scenarios TEXT[],                      -- When this conflict arises
    requester_strategy TEXT,                      -- How to navigate this conflict

    -- Supporting authority
    supporting_case_law_ids UUID[],               -- Links to case_law table

    -- Examples
    real_world_examples TEXT[],                   -- Actual situations where this conflict occurred

    -- Priority/frequency
    frequency TEXT,                               -- 'very_common', 'common', 'rare', 'very_rare'
    importance TEXT,                              -- 'critical', 'important', 'moderate', 'minor'

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_conflicts_jurisdiction ON rights_exemptions_conflicts(jurisdiction_id);
CREATE INDEX idx_conflicts_right ON rights_exemptions_conflicts(right_id);
CREATE INDEX idx_conflicts_type ON rights_exemptions_conflicts(conflict_type);
CREATE INDEX idx_conflicts_frequency ON rights_exemptions_conflicts(frequency);

-- ============================================================================
-- TABLE: privacy_statutes
-- ============================================================================
-- State privacy laws that supersede transparency laws
-- HIPAA equivalents, student privacy, etc.
-- ============================================================================

CREATE TABLE privacy_statutes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    jurisdiction_id VARCHAR(50) NOT NULL REFERENCES jurisdictions(id) ON DELETE CASCADE,

    -- Statute identification
    statute_name TEXT NOT NULL,                   -- e.g., "California Consumer Privacy Act"
    statute_citation TEXT NOT NULL,
    statute_type TEXT NOT NULL,                   -- 'medical', 'educational', 'financial', 'personal', 'other'

    -- Scope
    records_protected TEXT[] NOT NULL,            -- What types of records this protects
    entities_covered TEXT[],                      -- Who must comply

    -- Interaction with FOIA
    supersedes_foia BOOLEAN DEFAULT true,
    interaction_description TEXT NOT NULL,        -- How it interacts with transparency law

    -- Exceptions
    foia_exemption_reference TEXT,                -- Which FOIA exemption incorporates this
    circumstances_where_disclosed TEXT,           -- When can records still be released?

    -- Full text reference
    full_statute_url TEXT,

    -- Practical impact
    common_foia_scenarios TEXT[],                 -- How this affects FOIA requests
    requester_workarounds TEXT,                   -- Legal ways to still get information

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_privacy_statutes_jurisdiction ON privacy_statutes(jurisdiction_id);
CREATE INDEX idx_privacy_statutes_type ON privacy_statutes(statute_type);
CREATE INDEX idx_privacy_statutes_supersedes ON privacy_statutes(supersedes_foia);

-- ============================================================================
-- MODIFY: rights_of_access table
-- ============================================================================
-- Add fields for interconnections
-- ============================================================================

ALTER TABLE rights_of_access ADD COLUMN IF NOT EXISTS related_statute_section_id UUID REFERENCES statute_texts(id);
ALTER TABLE rights_of_access ADD COLUMN IF NOT EXISTS supporting_case_law_ids UUID[];
ALTER TABLE rights_of_access ADD COLUMN IF NOT EXISTS conflicting_exemptions TEXT[];
ALTER TABLE rights_of_access ADD COLUMN IF NOT EXISTS overridden_by_privacy_laws UUID[];

-- ============================================================================
-- MODIFY: Add record_types fields
-- ============================================================================

-- Add to rights_of_access (already has record_types_covered, record_types_excluded)
-- Verify they exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'rights_of_access' AND column_name = 'record_types_covered'
    ) THEN
        ALTER TABLE rights_of_access ADD COLUMN record_types_covered TEXT[];
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'rights_of_access' AND column_name = 'record_types_excluded'
    ) THEN
        ALTER TABLE rights_of_access ADD COLUMN record_types_excluded TEXT[];
    END IF;
END $$;

-- ============================================================================
-- VIEW: complete_transparency_landscape
-- ============================================================================
-- Brings together everything - rights, exemptions, exclusions, case law
-- ============================================================================

CREATE OR REPLACE VIEW complete_transparency_landscape AS
SELECT
    j.id as jurisdiction_id,
    j.name as jurisdiction_name,
    j.type as jurisdiction_type,

    -- Statutory text
    st.statute_citation,
    st.last_amended,
    st.word_count as statute_word_count,

    -- Rights counts
    COUNT(DISTINCT r.id) as total_rights,
    COUNT(DISTINCT r.id) FILTER (WHERE r.right_category = 'proactive_disclosure') as proactive_rights,
    COUNT(DISTINCT r.id) FILTER (WHERE r.right_category = 'enhanced_access') as enhanced_rights,
    COUNT(DISTINCT r.id) FILTER (WHERE r.right_category = 'technology_format') as technology_rights,

    -- Exclusions
    COUNT(DISTINCT rte.id) as total_record_exclusions,
    COUNT(DISTINCT rte.id) FILTER (WHERE rte.record_category = 'Law Enforcement') as police_exclusions,
    COUNT(DISTINCT rte.id) FILTER (WHERE rte.record_category = 'Court Records') as court_exclusions,

    -- Case law
    COUNT(DISTINCT cl.id) as total_case_law,
    COUNT(DISTINCT cl.id) FILTER (WHERE cl.still_good_law = true) as good_law_cases,

    -- Privacy statutes
    COUNT(DISTINCT ps.id) as privacy_statutes_count,

    -- Conflicts
    COUNT(DISTINCT rec.id) as total_conflicts,
    COUNT(DISTINCT rec.id) FILTER (WHERE rec.conflict_type = 'exemption_overrides_right') as exemption_wins,
    COUNT(DISTINCT rec.id) FILTER (WHERE rec.conflict_type = 'right_prevails') as right_wins,

    -- Court rules
    COUNT(DISTINCT crr.id) as court_rules_count,
    BOOL_OR(crr.differs_from_foia) as has_different_court_rules,

    -- Complexity score (higher = more complex/nuanced law)
    (
        COUNT(DISTINCT rec.id) * 2 +                    -- Conflicts are complex
        COUNT(DISTINCT rte.id) +                         -- Exclusions add complexity
        COUNT(DISTINCT ps.id) * 3 +                      -- Privacy laws add lots of complexity
        COUNT(DISTINCT crr.id) FILTER (WHERE crr.differs_from_foia) * 2  -- Different court rules = complex
    ) as complexity_score

FROM jurisdictions j
LEFT JOIN statute_texts st ON st.jurisdiction_id = j.id
LEFT JOIN rights_of_access r ON r.jurisdiction_id = j.id
LEFT JOIN record_types_excluded rte ON rte.jurisdiction_id = j.id
LEFT JOIN case_law cl ON cl.jurisdiction_id = j.id
LEFT JOIN privacy_statutes ps ON ps.jurisdiction_id = j.id
LEFT JOIN rights_exemptions_conflicts rec ON rec.jurisdiction_id = j.id
LEFT JOIN court_records_rules crr ON crr.jurisdiction_id = j.id
GROUP BY j.id, j.name, j.type, st.statute_citation, st.last_amended, st.word_count
ORDER BY complexity_score DESC;

COMMENT ON VIEW complete_transparency_landscape IS
'v0.13: Complete interconnected view of transparency law landscape including rights, exemptions, exclusions, case law, privacy statutes, and conflicts. Complexity score helps identify most nuanced jurisdictions.';

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE statute_texts IS
'v0.13: Full text of transparency law statutes. One record per jurisdiction. Supports full-text search and statutory analysis.';

COMMENT ON TABLE record_types_excluded IS
'v0.13: Specific categories of records explicitly excluded from public access (e.g., police personnel files, sealed court records). Maps the exceptions to general rights.';

COMMENT ON TABLE court_records_rules IS
'v0.13: Special rules for accessing court documents, which often differ from general FOIA procedures. Captures jurisdiction-specific court access requirements.';

COMMENT ON TABLE case_law IS
'v0.13: Court decisions interpreting transparency laws. Linked to specific rights and exemptions. Includes practical guidance for requesters.';

COMMENT ON TABLE rights_exemptions_conflicts IS
'v0.13: Maps when exemptions override rights and vice versa. The "maze of interconnected rules" - captures how different provisions interact and conflict.';

COMMENT ON TABLE privacy_statutes IS
'v0.13: State privacy laws (HIPAA equivalents, student privacy, etc.) that supersede transparency laws for certain records.';

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE statute_texts ENABLE ROW LEVEL SECURITY;
ALTER TABLE record_types_excluded ENABLE ROW LEVEL SECURITY;
ALTER TABLE court_records_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE case_law ENABLE ROW LEVEL SECURITY;
ALTER TABLE rights_exemptions_conflicts ENABLE ROW LEVEL SECURITY;
ALTER TABLE privacy_statutes ENABLE ROW LEVEL SECURITY;

-- All data is public (read-only)
CREATE POLICY "Statute texts viewable by everyone" ON statute_texts FOR SELECT USING (true);
CREATE POLICY "Record exclusions viewable by everyone" ON record_types_excluded FOR SELECT USING (true);
CREATE POLICY "Court rules viewable by everyone" ON court_records_rules FOR SELECT USING (true);
CREATE POLICY "Case law viewable by everyone" ON case_law FOR SELECT USING (true);
CREATE POLICY "Conflicts viewable by everyone" ON rights_exemptions_conflicts FOR SELECT USING (true);
CREATE POLICY "Privacy statutes viewable by everyone" ON privacy_statutes FOR SELECT USING (true);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

CREATE TRIGGER update_statute_texts_updated_at
    BEFORE UPDATE ON statute_texts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_record_exclusions_updated_at
    BEFORE UPDATE ON record_types_excluded
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_court_rules_updated_at
    BEFORE UPDATE ON court_records_rules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_case_law_updated_at
    BEFORE UPDATE ON case_law
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conflicts_updated_at
    BEFORE UPDATE ON rights_exemptions_conflicts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_privacy_statutes_updated_at
    BEFORE UPDATE ON privacy_statutes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- VERIFICATION
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'v0.13 migration completed successfully';
    RAISE NOTICE 'Created tables:';
    RAISE NOTICE '  - statute_texts (full statutory texts)';
    RAISE NOTICE '  - record_types_excluded (police files, court records, etc.)';
    RAISE NOTICE '  - court_records_rules (special court access procedures)';
    RAISE NOTICE '  - case_law (supporting court decisions)';
    RAISE NOTICE '  - rights_exemptions_conflicts (interaction mappings)';
    RAISE NOTICE '  - privacy_statutes (HIPAA, FERPA equivalents)';
    RAISE NOTICE 'Created view: complete_transparency_landscape';
    RAISE NOTICE 'Ready for comprehensive data population';
END $$;
