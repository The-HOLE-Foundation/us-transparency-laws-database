-- ============================================================================
-- ADD FLEXIBLE JSONB COLUMNS FOR JURISDICTION-SPECIFIC VARIATIONS
-- ============================================================================
-- v0.11.0 data has inconsistent field names across 52 jurisdictions.
-- Adding additional_fields JSONB columns to capture all variations without
-- data loss.
-- ============================================================================

-- Add additional_fields to response_requirements
ALTER TABLE response_requirements
ADD COLUMN additional_fields JSONB NOT NULL DEFAULT '{}'::jsonb;

COMMENT ON COLUMN response_requirements.additional_fields IS
'JSONB: Captures jurisdiction-specific fields like deemed_denial, initial_response_description, final_response_notes, etc.';

-- Add additional_fields to fee_structures
ALTER TABLE fee_structures
ADD COLUMN additional_fields JSONB NOT NULL DEFAULT '{}'::jsonb;

COMMENT ON COLUMN fee_structures.additional_fields IS
'JSONB: Captures jurisdiction-specific fee variations and notes';

-- Add additional_fields to appeal_processes
ALTER TABLE appeal_processes
ADD COLUMN additional_fields JSONB NOT NULL DEFAULT '{}'::jsonb;

COMMENT ON COLUMN appeal_processes.additional_fields IS
'JSONB: Captures jurisdiction-specific appeal process variations';

-- Add additional_fields to requester_requirements
ALTER TABLE requester_requirements
ADD COLUMN additional_fields JSONB NOT NULL DEFAULT '{}'::jsonb;

COMMENT ON COLUMN requester_requirements.additional_fields IS
'JSONB: Captures jurisdiction-specific requester requirement variations';

-- Add additional_fields to agency_obligations
ALTER TABLE agency_obligations
ADD COLUMN additional_fields JSONB NOT NULL DEFAULT '{}'::jsonb;

COMMENT ON COLUMN agency_obligations.additional_fields IS
'JSONB: Captures jurisdiction-specific agency obligation variations';

-- Add GIN indexes for efficient JSONB queries
CREATE INDEX idx_response_requirements_additional ON response_requirements USING GIN (additional_fields);
CREATE INDEX idx_fee_structures_additional ON fee_structures USING GIN (additional_fields);
CREATE INDEX idx_appeal_processes_additional ON appeal_processes USING GIN (additional_fields);
CREATE INDEX idx_requester_requirements_additional ON requester_requirements USING GIN (additional_fields);
CREATE INDEX idx_agency_obligations_additional ON agency_obligations USING GIN (additional_fields);
