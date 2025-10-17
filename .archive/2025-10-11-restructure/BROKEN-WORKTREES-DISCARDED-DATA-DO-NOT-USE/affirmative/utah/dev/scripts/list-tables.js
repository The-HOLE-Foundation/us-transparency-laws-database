#!/usr/bin/env node
/**
 * List ALL tables in the database using PostgreSQL system catalogs
 */

const SUPABASE_URL = 'https://ctxhmgmeflnemjfzyabr.supabase.co';
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0eGhtZ21lZmxuZW1qZnp5YWJyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczMzQ0MTAxMywiZXhwIjoyMDQ5MDE3MDEzfQ.g514q99y5JzPao41EAaR1NtLg_HjXVhIan9iEiq';

async function listAllTables() {
  try {
    // Query pg_tables to see all tables
    const response = await fetch(
      `${SUPABASE_URL}/rest/v1/rpc/pg_tables`,
      {
        method: 'POST',
        headers: {
          'apikey': SUPABASE_SERVICE_KEY,
          'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );

    console.log('Response status:', response.status);
    const text = await response.text();
    console.log('Response:', text);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

listAllTables();
