#!/usr/bin/env node
/**
 * Inspect Supabase database to see what tables and data currently exist
 */

const SUPABASE_URL = 'https://ctxhmgmeflnemjfzyabr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0eGhtZ21lZmxuZW1qZnp5YWJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM0NDEwMTMsImV4cCI6MjA0OTAxNzAxM30.n_Qk7eGUSKnE39kOOvw8jQ_HjXVhIan';

const tables = [
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
];

async function checkTable(tableName) {
  try {
    const response = await fetch(
      `${SUPABASE_URL}/rest/v1/${tableName}?select=count&limit=1`,
      {
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          'Prefer': 'count=exact'
        }
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      if (errorText.includes('does not exist') || errorText.includes('relation')) {
        return { exists: false, count: 0 };
      }
      throw new Error(errorText);
    }

    const count = response.headers.get('content-range')?.split('/')[1] || 0;
    return { exists: true, count: parseInt(count) };
  } catch (error) {
    return { exists: false, error: error.message };
  }
}

async function main() {
  console.log('=' .repeat(80));
  console.log('SUPABASE DATABASE INSPECTION');
  console.log('='.repeat(80));
  console.log(`\nConnecting to: ${SUPABASE_URL}\n`);

  console.log('🔍 Checking for existing tables...\n');

  const results = [];

  for (const table of tables) {
    const result = await checkTable(table);
    results.push({ table, ...result });

    if (result.exists) {
      console.log(`✅ ${table.padEnd(30)} - ${result.count} records`);
    } else {
      console.log(`❌ ${table.padEnd(30)} - table does not exist`);
    }
  }

  console.log('\n' + '='.repeat(80));
  console.log('SUMMARY');
  console.log('='.repeat(80) + '\n');

  const existingTables = results.filter(r => r.exists);

  if (existingTables.length > 0) {
    console.log(`Found ${existingTables.length} existing tables:`);
    existingTables.forEach(({ table, count }) => {
      console.log(`  - ${table}: ${count} records`);
    });
    console.log('\n💡 RECOMMENDATION:');
    console.log('   Since tables exist, you have two options:');
    console.log('   1. WIPE: Drop all tables and start fresh with v0.11.0 schema');
    console.log('   2. KEEP: Migrate existing data to new schema (if compatible)');
  } else {
    console.log('✨ Database is empty - perfect for fresh v0.11.0 import!');
    console.log('\n💡 RECOMMENDATION:');
    console.log('   Run migrations and import v0.11.0 data from releases/');
  }

  console.log('\n' + '='.repeat(80));
}

main().catch(console.error);
