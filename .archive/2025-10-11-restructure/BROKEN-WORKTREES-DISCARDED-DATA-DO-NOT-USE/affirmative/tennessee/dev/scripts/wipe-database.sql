-- ============================================================================
-- WIPE PRODUCTION DATABASE
-- ============================================================================
-- WARNING: This will drop ALL tables in the public schema
-- Backup saved to: archive/supabase-backups/2025-10-06/
-- ============================================================================

-- Drop all tables in public schema (CASCADE removes dependencies)
DO $$
DECLARE
    r RECORD;
BEGIN
    -- Drop all tables
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
        RAISE NOTICE 'Dropped table: %', r.tablename;
    END LOOP;

    -- Drop all functions
    FOR r IN (SELECT proname, oidvectortypes(proargtypes) as argtypes
              FROM pg_proc INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
              WHERE pg_namespace.nspname = 'public') LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS public.' || quote_ident(r.proname) || '(' || r.argtypes || ') CASCADE';
        RAISE NOTICE 'Dropped function: %', r.proname;
    END LOOP;

    -- Drop all views
    FOR r IN (SELECT viewname FROM pg_views WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP VIEW IF EXISTS public.' || quote_ident(r.viewname) || ' CASCADE';
        RAISE NOTICE 'Dropped view: %', r.viewname;
    END LOOP;

    -- Drop all sequences
    FOR r IN (SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'public') LOOP
        EXECUTE 'DROP SEQUENCE IF EXISTS public.' || quote_ident(r.sequence_name) || ' CASCADE';
        RAISE NOTICE 'Dropped sequence: %', r.sequence_name;
    END LOOP;
END $$;

-- Clean up migration history
TRUNCATE TABLE supabase_migrations.schema_migrations;

-- Verify empty
SELECT 'Tables remaining: ' || COUNT(*) FROM pg_tables WHERE schemaname = 'public';
SELECT 'Functions remaining: ' || COUNT(*) FROM pg_proc
    INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
    WHERE pg_namespace.nspname = 'public';
