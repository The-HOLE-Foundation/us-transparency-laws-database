-- ============================================================================
-- CREATE TRANSPARENCY MAP VIEW FOR INTERACTIVE MAP INTERFACE
-- ============================================================================
-- Optimized view that flattens normalized data structure into format needed
-- for the interactive US transparency map on theholetruth.org
--
-- Based on transparency_map_jurisdictions schema from Transparency-Map-Dataset/
-- Provides single-query access to all map display data
-- ============================================================================

CREATE OR REPLACE VIEW transparency_map_display AS
SELECT
  -- Jurisdiction identification
  j.id as jurisdiction_id,
  j.slug as jurisdiction_code,
  j.name as jurisdiction_name,
  j.jurisdiction_type,

  -- Statute information
  tl.id as transparency_law_id,
  tl.name as statute_abbreviation,
  tl.statute_citation as statute_full_name,
  tl.effective_date,
  tl.last_amended,

  -- Core principle (from validation_metadata JSONB)
  COALESCE(
    tl.validation_metadata->>'core_principle',
    'Public access to government records'
  ) as core_principle,

  -- Recent changes (from validation_metadata)
  tl.validation_metadata->>'recent_changes_2024_2025' as recent_changes_2024_2025,

  -- Response timeline
  COALESCE(rr.initial_response_time, -1) as response_timeline_days,
  CASE
    WHEN rr.initial_response_unit = 'business_days' THEN 'business'
    WHEN rr.initial_response_unit = 'calendar_days' THEN 'calendar'
    WHEN rr.initial_response_unit = 'working_days' THEN 'business'
    WHEN rr.initial_response_unit = 'variable' THEN 'flexible'
    ELSE 'unspecified'
  END as response_timeline_type,

  -- Additional response details from additional_fields
  COALESCE(
    rr.additional_fields->>'initial_response_description',
    CASE
      WHEN rr.initial_response_time IS NOT NULL
      THEN rr.initial_response_time::text || ' ' || rr.initial_response_unit
      ELSE 'Timeline not specified in statute'
    END
  ) as response_timeline_description,

  -- Extension information
  jsonb_build_object(
    'extension_allowed', rr.extension_allowed,
    'extension_max_days', rr.extension_max_days,
    'extension_conditions', rr.extension_conditions
  ) as response_timeline_extension,

  -- Fee structure as consolidated JSONB
  jsonb_build_object(
    'standard_copying',
      CASE
        WHEN fs.copy_fee_per_page IS NOT NULL
        THEN '$' || fs.copy_fee_per_page::text || ' per page'
        ELSE COALESCE(fs.copy_fee_notes, 'Actual cost of reproduction')
      END,
    'copy_fee_per_page', fs.copy_fee_per_page,
    'search_fees', fs.search_fee,
    'electronic_fee', fs.electronic_fee,
    'fee_waiver_available', fs.fee_waiver_available,
    'fee_waiver_criteria', fs.fee_waiver_criteria,
    'additional_fees', fs.additional_fields
  ) as fee_structure,

  fs.fee_waiver_available,

  -- Appeal process as consolidated JSONB
  jsonb_build_object(
    'type', COALESCE(ap.first_level, 'Not specified'),
    'first_level', ap.first_level,
    'first_level_deadline_days', ap.first_level_deadline_days,
    'first_level_notes', ap.first_level_deadline_notes,
    'second_level', ap.second_level,
    'second_level_deadline_days', ap.second_level_deadline_days,
    'attorney_fees_available', ap.attorney_fees_recoverable,
    'attorney_fees_notes', ap.attorney_fees_notes,
    'additional_details', ap.additional_fields
  ) as appeal_process,

  ap.attorney_fees_recoverable as attorney_fees_available,

  -- Public record categories (aggregated from exemptions - inverse logic)
  (
    SELECT jsonb_agg(DISTINCT category)
    FROM exemptions e
    WHERE e.transparency_law_id = tl.id
  ) as exemption_categories,

  -- Key features tags (derived from data)
  ARRAY_REMOVE(ARRAY[
    CASE WHEN ap.attorney_fees_recoverable THEN 'Attorney Fees Available' END,
    CASE WHEN rr.initial_response_unit = 'variable' THEN 'Flexible Timeline' END,
    CASE WHEN rr.initial_response_time <= 5 THEN 'Fast Response' END,
    CASE WHEN fs.fee_waiver_available THEN 'Fee Waivers Available' END,
    CASE WHEN ob.name IS NOT NULL THEN 'Oversight Body' END,
    CASE WHEN rr.extension_allowed THEN 'Extensions Allowed' END
  ], NULL) as key_features_tags,

  -- Official resources
  jsonb_build_object(
    'statute_url', tl.official_resources->>'statute_url',
    'ag_page_url', tl.official_resources->>'ag_page_url',
    'request_portal_url', tl.official_resources->>'request_portal_url'
  ) as official_resources,

  -- Oversight body information
  jsonb_build_object(
    'name', ob.name,
    'role', ob.role,
    'contact_info', ob.contact_info,
    'url', ob.oversight_url
  ) as oversight_body,

  -- Metadata
  tl.validation_metadata->>'version' as version,
  (tl.validation_metadata->>'verification_date')::date as verification_date,
  tl.validation_metadata->>'primary_sources' as primary_sources,

  -- Timestamps
  j.created_at,
  j.updated_at

FROM jurisdictions j
JOIN transparency_laws tl ON tl.jurisdiction_id = j.id
LEFT JOIN response_requirements rr ON rr.transparency_law_id = tl.id
LEFT JOIN fee_structures fs ON fs.transparency_law_id = tl.id
LEFT JOIN appeal_processes ap ON ap.transparency_law_id = tl.id
LEFT JOIN oversight_bodies ob ON ob.transparency_law_id = tl.id

ORDER BY j.name;

-- Add comment
COMMENT ON VIEW transparency_map_display IS
'Optimized view for transparency map interface. Flattens normalized data into single-row-per-jurisdiction format with JSONB for complex structures.';

-- Create index on underlying tables to speed up view queries
CREATE INDEX IF NOT EXISTS idx_transparency_laws_jurisdiction
  ON transparency_laws(jurisdiction_id);

CREATE INDEX IF NOT EXISTS idx_response_requirements_law
  ON response_requirements(transparency_law_id);

CREATE INDEX IF NOT EXISTS idx_fee_structures_law
  ON fee_structures(transparency_law_id);

CREATE INDEX IF NOT EXISTS idx_appeal_processes_law
  ON appeal_processes(transparency_law_id);

CREATE INDEX IF NOT EXISTS idx_oversight_bodies_law
  ON oversight_bodies(transparency_law_id);

-- Grant SELECT permission on view
GRANT SELECT ON transparency_map_display TO anon;
GRANT SELECT ON transparency_map_display TO authenticated;
