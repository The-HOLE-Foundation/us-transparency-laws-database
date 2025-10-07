-- ============================================================================
-- ALLOW NULL VALUES FOR RESPONSE REQUIREMENT FIELDS
-- ============================================================================
-- Many jurisdictions in v0.11.0 have incomplete deadline data
-- Make response time fields nullable to prevent data loss during import
-- ============================================================================

ALTER TABLE response_requirements
ALTER COLUMN initial_response_time DROP NOT NULL,
ALTER COLUMN initial_response_unit DROP NOT NULL,
ALTER COLUMN final_response_time DROP NOT NULL,
ALTER COLUMN final_response_unit DROP NOT NULL;

COMMENT ON COLUMN response_requirements.initial_response_time IS
'Number of time units for initial response. NULL if not specified by statute.';

COMMENT ON COLUMN response_requirements.final_response_time IS
'Number of time units for final response. NULL if not specified by statute.';
