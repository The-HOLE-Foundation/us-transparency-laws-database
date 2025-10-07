-- ============================================================================
-- FIX RESPONSE UNITS AND ADD OVERSIGHT ADDITIONAL_FIELDS
-- ============================================================================
-- 1. Allow "variable" as response unit for jurisdictions with flexible timelines
-- 2. Allow NULL units when time is NULL
-- 3. Add missing additional_fields to oversight_bodies
-- ============================================================================

-- Drop existing check constraints on response units
ALTER TABLE response_requirements
DROP CONSTRAINT IF EXISTS response_requirements_initial_response_unit_check,
DROP CONSTRAINT IF EXISTS response_requirements_final_response_unit_check;

-- Recreate with "variable" option
ALTER TABLE response_requirements
ADD CONSTRAINT response_requirements_initial_response_unit_check
  CHECK (initial_response_unit IN ('business_days', 'calendar_days', 'working_days', 'variable') OR initial_response_unit IS NULL),
ADD CONSTRAINT response_requirements_final_response_unit_check
  CHECK (final_response_unit IN ('business_days', 'calendar_days', 'working_days', 'variable') OR final_response_unit IS NULL);

-- Add additional_fields to oversight_bodies (was missing from previous migration)
ALTER TABLE oversight_bodies
ADD COLUMN IF NOT EXISTS additional_fields JSONB NOT NULL DEFAULT '{}'::jsonb;

COMMENT ON COLUMN oversight_bodies.additional_fields IS
'JSONB: Captures jurisdiction-specific oversight body variations';

-- Add GIN index for oversight_bodies additional_fields
CREATE INDEX IF NOT EXISTS idx_oversight_bodies_additional ON oversight_bodies USING GIN (additional_fields);
