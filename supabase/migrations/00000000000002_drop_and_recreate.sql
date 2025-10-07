-- ============================================================================
-- Drop all existing tables and recreate schema
-- ============================================================================

-- Drop all tables in reverse dependency order
DROP TABLE IF EXISTS agencies CASCADE;
DROP TABLE IF EXISTS oversight_bodies CASCADE;
DROP TABLE IF EXISTS agency_obligations CASCADE;
DROP TABLE IF EXISTS requester_requirements CASCADE;
DROP TABLE IF EXISTS appeal_processes CASCADE;
DROP TABLE IF EXISTS exemptions CASCADE;
DROP TABLE IF EXISTS fee_structures CASCADE;
DROP TABLE IF EXISTS response_requirements CASCADE;
DROP TABLE IF EXISTS transparency_laws CASCADE;
DROP TABLE IF EXISTS jurisdictions CASCADE;

-- Drop update trigger function
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- Now create everything fresh from original migration
-- (Content copied from 00000000000001_initial_schema.sql)

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Function for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Now run the rest of the schema from the first migration inline...
