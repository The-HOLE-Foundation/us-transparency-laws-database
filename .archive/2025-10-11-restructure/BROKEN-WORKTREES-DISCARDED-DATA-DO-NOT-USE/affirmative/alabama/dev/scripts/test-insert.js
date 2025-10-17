#!/usr/bin/env node
/**
 * Test if we can insert data into jurisdictions table
 */

const SUPABASE_URL = 'https://ctxhmgmeflnemjfzyabr.supabase.co';
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0eGhtZ21lZmxuZW1qZnp5YWJyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczMzQ0MTAxMywiZXhwIjoyMDQ5MDE3MDEzfQ.g514q99y5JzPao41EAaR1NtLg_HjXVhIan9iEiq';

async function testInsert() {
  console.log('Testing INSERT into jurisdictions table...\n');

  try {
    const response = await fetch(
      `${SUPABASE_URL}/rest/v1/jurisdictions`,
      {
        method: 'POST',
        headers: {
          'apikey': SUPABASE_SERVICE_KEY,
          'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
          'Content-Type': 'application/json',
          'Prefer': 'return=representation'
        },
        body: JSON.stringify({
          slug: 'test-jurisdiction',
          name: 'Test Jurisdiction',
          jurisdiction_type: 'state'
        })
      }
    );

    const text = await response.text();

    if (response.ok) {
      console.log('✅ SUCCESS: Table exists and accepts data!');
      console.log('Inserted:', JSON.parse(text));
      console.log('\n🎉 Schema deployment CONFIRMED - tables are working!');
      return true;
    } else {
      console.log('❌ ERROR:', response.status, response.statusText);
      console.log('Response:', text);
      return false;
    }
  } catch (error) {
    console.error('❌ Exception:', error.message);
    return false;
  }
}

testInsert().then(success => process.exit(success ? 0 : 1));
