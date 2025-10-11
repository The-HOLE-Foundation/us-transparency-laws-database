#!/usr/bin/env node
/**
 * Import Jurisdiction Data to Neon Database
 *
 * NEW SIMPLIFIED STRUCTURE (Post-Restructure)
 *
 * Usage: node database/scripts/import-jurisdiction-to-neon.js alabama
 * Or:    node database/scripts/import-jurisdiction-to-neon.js federal
 * Or:    node database/scripts/import-jurisdiction-to-neon.js --all
 *
 * Reads from: data/jurisdictions/{federal|states}/{jurisdiction}/
 * - metadata.json (basic info)
 * - rights.json (affirmative rights)
 * - exemptions.json (if exists - extracted from metadata for now)
 * - statute-full-text.txt (full statutory text)
 */

import { Client } from 'pg';
import { readFile } from 'fs/promises';
import { resolve } from 'path';

const DATABASE_URL = process.env.DATABASE_URL_UNPOOLED || process.env.DATABASE_URL;

if (!DATABASE_URL) {
  console.error('❌ Error: DATABASE_URL must be set');
  console.error('   export DATABASE_URL="postgresql://..."');
  process.exit(1);
}

async function importJurisdiction(jurisdiction) {
  const client = new Client({
    connectionString: DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log(`\n📊 Importing ${jurisdiction}...`);

    // Determine path (federal vs states)
    const basePath = jurisdiction === 'federal'
      ? `data/jurisdictions/federal`
      : `data/jurisdictions/states/${jurisdiction}`;

    // Read rights.json
    const rightsPath = resolve(basePath, 'rights.json');
    const rightsData = JSON.parse(await readFile(rightsPath, 'utf-8'));

    console.log(`✓ Found ${rightsData.rights_of_access?.length || 0} rights`);

    // Get jurisdiction_id from database
    const jurisdictionId = jurisdiction === 'federal' ? 'federal' : jurisdiction;

    // Check if jurisdiction exists
    const checkResult = await client.query(
      'SELECT id, name FROM jurisdictions WHERE id = $1',
      [jurisdictionId]
    );

    if (checkResult.rows.length === 0) {
      console.error(`❌ Jurisdiction '${jurisdictionId}' not found in database`);
      console.error(`   Make sure jurisdiction exists in Neon first`);
      process.exit(1);
    }

    console.log(`✓ Found jurisdiction: ${checkResult.rows[0].name}`);

    // Delete existing rights for this jurisdiction
    const deleteResult = await client.query(
      'DELETE FROM rights_of_access WHERE jurisdiction_id = $1',
      [jurisdictionId]
    );

    if (deleteResult.rowCount > 0) {
      console.log(`✓ Deleted ${deleteResult.rowCount} existing rights`);
    }

    // Import each right
    let imported = 0;
    for (const right of rightsData.rights_of_access || []) {
      const rightCategory = transformCategory(right.category);
      const rightName = createRightName(right.category, right.subcategory);
      const { short, full } = splitDescription(right.description);

      // Determine priority
      let priority = 'medium';
      if (right.category.includes('Timeliness') || right.category.includes('Fee')) {
        priority = 'high';
      } else if (right.category.includes('Proactive')) {
        priority = 'critical';
      }

      // Build conditions JSONB
      const conditions = {};
      if (right.conditions) conditions.requirements = right.conditions;
      if (right.applies_to) conditions.applies_to = right.applies_to;
      if (right.implementation_notes) conditions.implementation_notes = right.implementation_notes;

      await client.query(`
        INSERT INTO rights_of_access (
          jurisdiction_id, right_category, right_name, short_description,
          full_description, statutory_citation, assertion_language,
          verification_status, conditions, priority
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      `, [
        jurisdictionId,
        rightCategory,
        rightName,
        short,
        full,
        right.statute_citation,
        right.request_tips || null,
        'verified',
        Object.keys(conditions).length > 0 ? JSON.stringify(conditions) : null,
        priority
      ]);

      imported++;
    }

    console.log(`✅ Imported ${imported} rights for ${jurisdiction}`);

    // Verify
    const verifyResult = await client.query(
      'SELECT COUNT(*) FROM rights_of_access WHERE jurisdiction_id = $1',
      [jurisdictionId]
    );

    console.log(`✓ Verified: ${verifyResult.rows[0].count} rights in database\n`);

  } catch (error) {
    console.error(`❌ Import failed: ${error.message}`);
    throw error;
  } finally {
    await client.end();
  }
}

// Helper functions
function transformCategory(category) {
  const map = {
    'Proactive Disclosure': 'proactive_disclosure',
    'Enhanced Access Rights': 'enhanced_access',
    'Technology Rights': 'technology_format',
    'Requester-Specific Rights': 'requester_specific',
    'Inspection Rights': 'inspection_rights',
    'Timeliness Rights': 'timeliness_rights'
  };
  return map[category] || category.toLowerCase().replace(/\s+/g, '_');
}

function createRightName(category, subcategory) {
  return subcategory ? `${category}: ${subcategory}` : category;
}

function splitDescription(description) {
  const maxShort = 250;
  if (!description || description.length <= maxShort) {
    return { short: description || '', full: null };
  }

  let breakPoint = description.lastIndexOf('. ', maxShort);
  if (breakPoint === -1 || breakPoint < 150) {
    breakPoint = description.lastIndexOf(' ', maxShort);
  }
  if (breakPoint === -1) breakPoint = maxShort;
  else breakPoint += 1;

  return {
    short: description.substring(0, breakPoint).trim(),
    full: description.trim()
  };
}

// Main execution
const arg = process.argv[2];

if (!arg) {
  console.error('Usage: node database/scripts/import-jurisdiction-to-neon.js <jurisdiction>');
  console.error('   or: node database/scripts/import-jurisdiction-to-neon.js --all');
  console.error('\nExamples:');
  console.error('  node database/scripts/import-jurisdiction-to-neon.js federal');
  console.error('  node database/scripts/import-jurisdiction-to-neon.js alabama');
  console.error('  node database/scripts/import-jurisdiction-to-neon.js --all');
  process.exit(1);
}

if (arg === '--all') {
  console.log('Importing all jurisdictions...');
  // Import all (to be implemented)
  console.log('⚠️  --all not yet implemented. Import one at a time for now.');
} else {
  importJurisdiction(arg).catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}
