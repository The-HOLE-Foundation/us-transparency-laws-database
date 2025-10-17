#!/usr/bin/env node

/**
 * Import Rights of Access data to Neon database
 *
 * Usage:
 *   node scripts/import-rights-to-neon.js data/jurisdictions/states/pennsylvania/rights.json
 *
 * Environment Variables:
 *   DATABASE_URL_UNPOOLED - Direct Neon connection (for writes)
 */

import { Client } from 'pg';
import fs from 'fs/promises';
import path from 'path';

// Database connection
const DATABASE_URL = process.env.DATABASE_URL_UNPOOLED || process.env.DATABASE_URL;

if (!DATABASE_URL) {
  console.error('❌ ERROR: DATABASE_URL_UNPOOLED or DATABASE_URL environment variable required');
  console.error('   Run: export DATABASE_URL_UNPOOLED="postgresql://..."');
  console.error('   Or: vercel env pull .env.development.local');
  process.exit(1);
}

/**
 * Import rights from JSON file to database
 */
async function importRights(filePath) {
  console.log(`\n🔄 Importing rights from: ${filePath}`);

  // Validate file exists
  try {
    await fs.access(filePath);
  } catch (error) {
    console.error(`❌ File not found: ${filePath}`);
    process.exit(1);
  }

  // Read and parse JSON
  const fileContent = await fs.readFile(filePath, 'utf-8');
  let data;
  try {
    data = JSON.parse(fileContent);
  } catch (error) {
    console.error(`❌ Invalid JSON in file: ${error.message}`);
    process.exit(1);
  }

  // Validate structure
  if (!data.jurisdiction || !data.rights || !Array.isArray(data.rights)) {
    console.error('❌ Invalid file structure. Expected: { jurisdiction: {...}, rights: [...] }');
    process.exit(1);
  }

  const jurisdictionSlug = data.jurisdiction.slug || data.jurisdiction.id;
  const rightsCount = data.rights.length;

  console.log(`\n📊 Import Summary:`);
  console.log(`   Jurisdiction: ${data.jurisdiction.name} (${jurisdictionSlug})`);
  console.log(`   Rights to import: ${rightsCount}`);

  if (data.metadata) {
    console.log(`   Source: ${data.metadata.source_url || 'Not specified'}`);
    console.log(`   Statute: ${data.metadata.statute_name || 'Not specified'}`);
    console.log(`   Verified: ${data.metadata.last_verified || 'Not verified'}`);
  }

  // Connect to database
  const client = new Client({
    connectionString: DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log(`\n✅ Connected to Neon database`);

    // Look up jurisdiction ID
    const jurisdictionQuery = `
      SELECT id FROM jurisdictions WHERE id = $1 OR slug = $1
    `;
    const jurisdictionResult = await client.query(jurisdictionQuery, [jurisdictionSlug]);

    if (jurisdictionResult.rows.length === 0) {
      console.error(`❌ Jurisdiction not found in database: ${jurisdictionSlug}`);
      console.error(`   Available jurisdictions can be queried with: SELECT id FROM jurisdictions;`);
      await client.end();
      process.exit(1);
    }

    const jurisdictionId = jurisdictionResult.rows[0].id;
    console.log(`   Found jurisdiction ID: ${jurisdictionId}`);

    // Check for existing rights (warn about duplicates)
    const existingQuery = `
      SELECT COUNT(*) as count FROM rights_of_access WHERE jurisdiction_id = $1
    `;
    const existingResult = await client.query(existingQuery, [jurisdictionId]);
    const existingCount = parseInt(existingResult.rows[0].count);

    if (existingCount > 0) {
      console.log(`\n⚠️  WARNING: ${existingCount} rights already exist for ${jurisdictionId}`);
      console.log(`   This import will ADD ${rightsCount} more rights (no deduplication)`);
      console.log(`   Press Ctrl+C to cancel, or wait 5 seconds to continue...`);
      await new Promise(resolve => setTimeout(resolve, 5000));
    }

    // Import each right
    console.log(`\n🔄 Importing ${rightsCount} rights...`);
    let imported = 0;
    let skipped = 0;
    let errors = 0;

    for (const right of data.rights) {
      try {
        // Validate required fields
        if (!right.right_name || !right.right_category || !right.statutory_citation) {
          console.warn(`⚠️  Skipping right (missing required fields): ${right.right_name || 'unnamed'}`);
          skipped++;
          continue;
        }

        // Map JSON fields to database columns
        const insertQuery = `
          INSERT INTO rights_of_access (
            jurisdiction_id,
            right_category,
            right_name,
            short_description,
            full_description,
            statutory_citation,
            statutory_text,
            conditions,
            priority,
            assertion_language,
            verification_status,
            last_verified,
            verification_source
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
          RETURNING id
        `;

        const values = [
          jurisdictionId,
          right.right_category,
          right.right_name,
          right.short_description || '',
          right.full_description || right.short_description || '',
          right.statutory_citation,
          right.statutory_text || null,
          right.conditions ? JSON.stringify(right.conditions) : '{}',
          right.priority || 'medium',
          right.assertion_language || null,
          data.metadata?.verification_status || 'unverified',
          data.metadata?.last_verified || null,
          data.metadata?.verification_source || data.metadata?.source_url || null
        ];

        const result = await client.query(insertQuery, values);
        imported++;

        if (imported % 5 === 0) {
          process.stdout.write(`.`);
        }
      } catch (error) {
        console.error(`\n❌ Error importing right "${right.right_name}": ${error.message}`);
        errors++;
      }
    }

    console.log(`\n\n✅ Import complete!`);
    console.log(`   Imported: ${imported}`);
    console.log(`   Skipped: ${skipped}`);
    console.log(`   Errors: ${errors}`);

    // Verify final count
    const finalCount = await client.query(existingQuery, [jurisdictionId]);
    console.log(`   Total rights for ${jurisdictionId}: ${finalCount.rows[0].count}`);

    await client.end();
    console.log(`\n✅ Database connection closed`);

  } catch (error) {
    console.error(`\n❌ Database error: ${error.message}`);
    await client.end();
    process.exit(1);
  }
}

// Main execution
const filePath = process.argv[2];

if (!filePath) {
  console.error(`
Usage: node scripts/import-rights-to-neon.js <file-path>

Example:
  node scripts/import-rights-to-neon.js data/jurisdictions/states/pennsylvania/rights.json

Environment:
  DATABASE_URL_UNPOOLED - Direct Neon connection (required)
  `);
  process.exit(1);
}

importRights(filePath).catch(error => {
  console.error(`\n❌ Fatal error: ${error.message}`);
  process.exit(1);
});
