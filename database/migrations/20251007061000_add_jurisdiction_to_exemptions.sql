-- ============================================================================
-- ADD JURISDICTION CONTEXT TO EXEMPTIONS TABLE
-- ============================================================================
-- Problem: Exemptions table requires complex joins to see which state they apply to
-- Solution: Add denormalized jurisdiction columns maintained by triggers
--
-- Uses trigger-based approach (GENERATED columns don't support subqueries):
-- - Values automatically populated on INSERT
-- - Updated automatically on UPDATE of transparency_law_id
-- - Maintains data integrity through triggers
-- ============================================================================

-- Add jurisdiction columns (nullable initially, will be populated by trigger)
ALTER TABLE exemptions
ADD COLUMN jurisdiction_name TEXT,
ADD COLUMN jurisdiction_slug TEXT,
ADD COLUMN jurisdiction_code TEXT;

-- Create function to populate jurisdiction columns
CREATE OR REPLACE FUNCTION populate_exemption_jurisdiction()
RETURNS TRIGGER AS $$
BEGIN
  -- Look up jurisdiction info from transparency_laws
  SELECT
    j.name,
    j.slug,
    UPPER(CASE
      WHEN j.name = 'Federal' THEN 'FED'
      WHEN j.name = 'District of Columbia' THEN 'DC'
      ELSE LEFT(REPLACE(j.slug, '-', ''), 2)
    END)
  INTO
    NEW.jurisdiction_name,
    NEW.jurisdiction_slug,
    NEW.jurisdiction_code
  FROM transparency_laws tl
  JOIN jurisdictions j ON j.id = tl.jurisdiction_id
  WHERE tl.id = NEW.transparency_law_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to populate on INSERT and UPDATE
CREATE TRIGGER set_exemption_jurisdiction
  BEFORE INSERT OR UPDATE OF transparency_law_id ON exemptions
  FOR EACH ROW
  EXECUTE FUNCTION populate_exemption_jurisdiction();

-- Add comments documenting the columns
COMMENT ON COLUMN exemptions.jurisdiction_name IS
'Auto-generated: Full jurisdiction name (e.g., "California"). Computed from transparency_law_id foreign key.';

COMMENT ON COLUMN exemptions.jurisdiction_slug IS
'Auto-generated: URL-friendly jurisdiction slug (e.g., "california"). Computed from transparency_law_id foreign key.';

COMMENT ON COLUMN exemptions.jurisdiction_code IS
'Auto-generated: 2-3 letter jurisdiction code (e.g., "CA", "FED", "DC"). Computed from transparency_law_id foreign key.';

-- Backfill existing records (populate jurisdiction columns for all existing exemptions)
UPDATE exemptions
SET jurisdiction_name = j.name,
    jurisdiction_slug = j.slug,
    jurisdiction_code = UPPER(CASE
      WHEN j.name = 'Federal' THEN 'FED'
      WHEN j.name = 'District of Columbia' THEN 'DC'
      ELSE LEFT(REPLACE(j.slug, '-', ''), 2)
    END)
FROM transparency_laws tl
JOIN jurisdictions j ON j.id = tl.jurisdiction_id
WHERE exemptions.transparency_law_id = tl.id;

-- Create indexes for common query patterns
CREATE INDEX idx_exemptions_jurisdiction_name
  ON exemptions(jurisdiction_name);

CREATE INDEX idx_exemptions_jurisdiction_slug
  ON exemptions(jurisdiction_slug);

CREATE INDEX idx_exemptions_category_jurisdiction
  ON exemptions(category, jurisdiction_name);

-- Example queries now possible:
-- 1. All California exemptions:
--    SELECT category, description FROM exemptions WHERE jurisdiction_name = 'California';
--
-- 2. Personal Privacy exemptions by state:
--    SELECT jurisdiction_name, description FROM exemptions WHERE category = 'Personal Privacy';
--
-- 3. Count exemptions per jurisdiction:
--    SELECT jurisdiction_name, COUNT(*) FROM exemptions GROUP BY jurisdiction_name;

COMMENT ON TABLE exemptions IS
'Records exemptions from disclosure. Now includes auto-generated jurisdiction columns for easy filtering without joins.';
