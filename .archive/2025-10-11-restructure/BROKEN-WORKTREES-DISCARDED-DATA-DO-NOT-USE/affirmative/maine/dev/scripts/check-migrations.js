#!/usr/bin/env node
/**
 * Check which migrations are recorded as applied
 */

const SUPABASE_URL = 'https://ctxhmgmeflnemjfzyabr.supabase.co';
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0eGhtZ21lZmxuZW1qZnp5YWJyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczMzQ0MTAxMywiZXhwIjoyMDQ5MDE3MDEzfQ.g514q99y5JzPao41EAaR1NtLg_HjXVhIan9iEiq';

async function checkMigrations() {
  try {
    // Query supabase_migrations.schema_migrations to see applied migrations
    const response = await fetch(
      `${SUPABASE_URL}/rest/v1/rpc/get_migrations`,
      {
        method: 'POST',
        headers: {
          'apikey': SUPABASE_SERVICE_KEY,
          'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      }
    );

    const text = await response.text();
    console.log('Migrations check:', text);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

checkMigrations();
