-- ============================================================================
-- ALLOW NULL VALUES FOR APPEAL PROCESS FIELDS
-- ============================================================================
-- Many jurisdictions have single-level appeal processes (no second level)
-- Make first_level and second_level nullable
-- ============================================================================

ALTER TABLE appeal_processes
ALTER COLUMN first_level DROP NOT NULL,
ALTER COLUMN second_level DROP NOT NULL;

COMMENT ON COLUMN appeal_processes.first_level IS
'First level of appeal (e.g., "Agency Head", "Court"). NULL if no appeal process exists.';

COMMENT ON COLUMN appeal_processes.second_level IS
'Second level of appeal (e.g., "Superior Court"). NULL if only one appeal level exists.';
