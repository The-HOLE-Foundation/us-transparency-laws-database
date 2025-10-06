#!/usr/bin/env python3
"""
Inspect existing Supabase database to see what tables and data exist.
This helps decide whether to keep or wipe the database.
"""

import os
from supabase import create_client, Client

# Supabase credentials
SUPABASE_URL = "https://ctxhmgmeflnemjfzyabr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0eGhtZ21lZmxuZW1qZnp5YWJyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczMzQ0MTAxMywiZXhwIjoyMDQ5MDE3MDEzfQ.g514q99y5JzPao41EAaR1NtLg_HjXVhIan9iEiq"

def main():
    print("=" * 80)
    print("SUPABASE DATABASE INSPECTION")
    print("=" * 80)
    print(f"\nConnecting to: {SUPABASE_URL}")
    print()

    # Create Supabase client
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

    # Query for existing tables
    print("📊 Querying database schema...")
    print()

    # Get list of tables from information_schema
    try:
        result = supabase.table('_realtime.schema').select('*').execute()
        print(f"✅ Connected successfully")
        print()
    except Exception as e:
        print(f"⚠️  Could not query schema via Supabase client")
        print(f"Error: {e}")
        print()
        print("This is normal - we need to use PostgreSQL to query information_schema")
        print()

    # Try to list any existing tables by querying common table names
    common_tables = [
        'jurisdictions',
        'transparency_laws',
        'response_requirements',
        'fee_structures',
        'exemptions',
        'appeal_processes',
        'requester_requirements',
        'agency_obligations',
        'oversight_bodies',
        'agencies'
    ]

    print("🔍 Checking for existing tables...")
    print()

    found_tables = []
    for table_name in common_tables:
        try:
            result = supabase.table(table_name).select('*', count='exact').limit(1).execute()
            count = result.count if hasattr(result, 'count') else len(result.data)
            found_tables.append((table_name, count))
            print(f"✅ {table_name:30} - {count} records")
        except Exception as e:
            error_msg = str(e)
            if 'does not exist' in error_msg or 'relation' in error_msg:
                print(f"❌ {table_name:30} - table does not exist")
            else:
                print(f"⚠️  {table_name:30} - error: {error_msg[:50]}...")

    print()
    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print()

    if found_tables:
        print(f"Found {len(found_tables)} existing tables:")
        for table, count in found_tables:
            print(f"  - {table}: {count} records")
        print()
        print("💡 RECOMMENDATION:")
        print("   Since tables exist, you have two options:")
        print("   1. WIPE: Drop all tables and start fresh with v0.11.0 schema")
        print("   2. KEEP: Migrate existing data to new schema (if compatible)")
        print()
    else:
        print("✨ Database is empty - perfect for fresh v0.11.0 import!")
        print()
        print("💡 RECOMMENDATION:")
        print("   Run migrations and import v0.11.0 data from releases/")
        print()

    print("=" * 80)

if __name__ == "__main__":
    main()
