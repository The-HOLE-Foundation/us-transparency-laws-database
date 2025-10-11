#!/usr/bin/env node
/**
 * Smart import for Neon: Standard fields go to columns, extras go to additional_fields JSONB
 *
 * Converted from smart-import.js to use Neon PostgreSQL instead of Supabase
 * Uses native pg library and environment variables for configuration
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { Client } from 'pg';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Use environment variables for Neon connection
const DATABASE_URL = process.env.DATABASE_URL_UNPOOLED || process.env.DATABASE_URL;

if (!DATABASE_URL) {
  console.error('❌ Error: DATABASE_URL or DATABASE_URL_UNPOOLED must be set');
  console.error('   Add to .env.production or set as environment variable');
  console.error('');
  console.error('Example:');
  console.error('DATABASE_URL_UNPOOLED=postgresql://neondb_owner:...@ep-dark-smoke-adkcd3h4.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require');
  process.exit(1);
}

const DATA_DIR = 'releases/v0.11.0/jurisdictions';

// Define standard fields for each table (these go to columns)
// Fields that exist as columns in the database schema
// All other fields will go to additional_fields JSONB
const STANDARD_FIELDS = {
  response_requirements: [
    'initial_response_time', 'initial_response_unit',
    'final_response_time', 'final_response_unit',
    'extension_allowed', 'extension_max_days', 'extension_conditions',
    'tolling_allowed', 'tolling_notes'
  ],
  fee_structures: [
    'search_fee', 'search_fee_statutory_cite',
    'copy_fee_per_page', 'copy_fee_cite', 'copy_fee_notes',
    'electronic_fee', 'fee_waiver_available', 'fee_waiver_criteria',
    'fee_waiver_cite', 'fee_protection_notes'
  ],
  appeal_processes: [
    'first_level', 'first_level_deadline_days', 'first_level_deadline_notes', 'first_level_cite',
    'second_level', 'second_level_deadline_days', 'second_level_deadline_notes', 'second_level_cite',
    'attorney_fees_recoverable', 'attorney_fees_cite', 'attorney_fees_notes'
  ],
  requester_requirements: [
    'identification_required', 'purpose_statement_required',
    'residency_requirement', 'request_format_notes', 'specific_format'
  ],
  agency_obligations: [
    'records_officer_required', 'records_officer_title',
    'business_hours_access', 'electronic_submission_accepted',
    'electronic_submission_required', 'response_format_options',
    'annual_reporting_required', 'public_liaison_required'
  ],
  oversight_bodies: [
    'name', 'role', 'contact_info', 'oversight_url'
  ]
};

function createSlug(name) {
  return name.toLowerCase().replace(/\s+/g, '-');
}

function getJurisdictionType(name) {
  if (name === 'Federal') return 'federal';
  if (name === 'District of Columbia') return 'district';
  return 'state';
}

// Separate data into standard fields and additional fields
function separateFields(data, tableName) {
  const standard = {};
  const additional = {};
  const standardFieldsList = STANDARD_FIELDS[tableName] || [];

  for (const [key, value] of Object.entries(data)) {
    if (standardFieldsList.includes(key)) {
      standard[key] = value;
    } else {
      additional[key] = value;
    }
  }

  return { standard, additional };
}

async function importJurisdiction(client, data) {
  const jurisdictionName = data.jurisdiction;
  const tLaw = data.transparency_law;

  // 1. Insert jurisdiction
  const jurisdictionResult = await client.query(
    `INSERT INTO jurisdictions (slug, name, jurisdiction_type)
     VALUES ($1, $2, $3)
     RETURNING id`,
    [createSlug(jurisdictionName), jurisdictionName, getJurisdictionType(jurisdictionName)]
  );

  const jurisdictionId = jurisdictionResult.rows[0].id;

  // 2. Insert transparency_law
  // Handle date fields - convert year-only strings to null (e.g., "2024" -> null)
  const effective_date = tLaw.effective_date && tLaw.effective_date.length > 4 ? tLaw.effective_date : null;
  const last_amended = tLaw.last_amended && tLaw.last_amended.length > 4 ? tLaw.last_amended : null;

  const transparencyLawResult = await client.query(
    `INSERT INTO transparency_laws (
      jurisdiction_id, name, statute_citation, effective_date, last_amended,
      official_resources, validation_metadata
    ) VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING id`,
    [
      jurisdictionId,
      tLaw.name,
      tLaw.statute_citation,
      effective_date,
      last_amended,
      JSON.stringify(tLaw.official_resources || {}),
      JSON.stringify(tLaw.validation_metadata || {})
    ]
  );

  const lawId = transparencyLawResult.rows[0].id;

  // 3. Insert response_requirements with field separation
  if (tLaw.response_requirements) {
    const { standard, additional } = separateFields(tLaw.response_requirements, 'response_requirements');

    // Set defaults for boolean fields that are NULL in source data
    if (standard.extension_allowed === null || standard.extension_allowed === undefined) {
      standard.extension_allowed = false;
    }
    if (standard.tolling_allowed === null || standard.tolling_allowed === undefined) {
      standard.tolling_allowed = false;
    }

    await client.query(
      `INSERT INTO response_requirements (
        transparency_law_id, initial_response_time, initial_response_unit,
        final_response_time, final_response_unit, extension_allowed,
        extension_max_days, extension_conditions, tolling_allowed,
        tolling_notes, additional_fields
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
      [
        lawId,
        standard.initial_response_time,
        standard.initial_response_unit,
        standard.final_response_time,
        standard.final_response_unit,
        standard.extension_allowed,
        standard.extension_max_days,
        standard.extension_conditions,
        standard.tolling_allowed,
        standard.tolling_notes,
        JSON.stringify(additional)
      ]
    );
  }

  // 4. Insert fee_structure
  if (tLaw.fee_structure) {
    const { standard, additional } = separateFields(tLaw.fee_structure, 'fee_structures');

    const fields = Object.keys(standard);
    const values = Object.values(standard);
    const placeholders = values.map((_, i) => `$${i + 2}`).join(', ');

    await client.query(
      `INSERT INTO fee_structures (transparency_law_id, ${fields.join(', ')}, additional_fields)
       VALUES ($1, ${placeholders}, $${values.length + 2})`,
      [lawId, ...values, JSON.stringify(additional)]
    );
  }

  // 5. Insert exemptions (no additional_fields needed - has its own structure)
  if (tLaw.exemptions && Array.isArray(tLaw.exemptions)) {
    for (const exemption of tLaw.exemptions) {
      // Normalize scope: "variable" -> "moderate" (schema only allows narrow/moderate/broad)
      let scope = exemption.scope;
      if (scope === 'variable') {
        scope = 'moderate';
      }

      await client.query(
        `INSERT INTO exemptions (transparency_law_id, category, citation, description, scope)
         VALUES ($1, $2, $3, $4, $5)`,
        [lawId, exemption.category, exemption.citation, exemption.description, scope || null]
      );
    }
  }

  // 6. Insert appeal_process
  if (tLaw.appeal_process) {
    const { standard, additional } = separateFields(tLaw.appeal_process, 'appeal_processes');

    const fields = Object.keys(standard);
    const values = Object.values(standard);
    const placeholders = values.map((_, i) => `$${i + 2}`).join(', ');

    await client.query(
      `INSERT INTO appeal_processes (transparency_law_id, ${fields.join(', ')}, additional_fields)
       VALUES ($1, ${placeholders}, $${values.length + 2})`,
      [lawId, ...values, JSON.stringify(additional)]
    );
  }

  // 7. Insert requester_requirements
  if (tLaw.requester_requirements) {
    const { standard, additional } = separateFields(tLaw.requester_requirements, 'requester_requirements');

    const fields = Object.keys(standard);
    const values = Object.values(standard);
    const placeholders = values.map((_, i) => `$${i + 2}`).join(', ');

    await client.query(
      `INSERT INTO requester_requirements (transparency_law_id, ${fields.join(', ')}, additional_fields)
       VALUES ($1, ${placeholders}, $${values.length + 2})`,
      [lawId, ...values, JSON.stringify(additional)]
    );
  }

  // 8. Insert agency_obligations
  if (tLaw.agency_obligations) {
    const { standard, additional } = separateFields(tLaw.agency_obligations, 'agency_obligations');

    // Set defaults for boolean fields that are NULL in source data
    if (standard.electronic_submission_accepted === null || standard.electronic_submission_accepted === undefined) {
      standard.electronic_submission_accepted = false;
    }
    if (standard.annual_reporting_required === null || standard.annual_reporting_required === undefined) {
      standard.annual_reporting_required = false;
    }
    if (standard.public_liaison_required === null || standard.public_liaison_required === undefined) {
      standard.public_liaison_required = false;
    }

    const fields = Object.keys(standard);
    const values = Object.values(standard);
    const placeholders = values.map((_, i) => `$${i + 2}`).join(', ');

    await client.query(
      `INSERT INTO agency_obligations (transparency_law_id, ${fields.join(', ')}, additional_fields)
       VALUES ($1, ${placeholders}, $${values.length + 2})`,
      [lawId, ...values, JSON.stringify(additional)]
    );
  }

  // 9. Insert oversight_body (skip if empty - not all jurisdictions have oversight bodies)
  if (tLaw.oversight_body && (tLaw.oversight_body.name || tLaw.oversight_body.role)) {
    const { standard, additional } = separateFields(tLaw.oversight_body, 'oversight_bodies');

    const fields = Object.keys(standard);
    const values = Object.values(standard);
    const placeholders = values.map((_, i) => `$${i + 2}`).join(', ');

    await client.query(
      `INSERT INTO oversight_bodies (transparency_law_id, ${fields.join(', ')}, additional_fields)
       VALUES ($1, ${placeholders}, $${values.length + 2})`,
      [lawId, ...values, JSON.stringify(additional)]
    );
  }

  return jurisdictionId;
}

async function main() {
  console.log('='.repeat(80));
  console.log('SMART IMPORT: v0.11.0 DATA WITH FLEXIBLE FIELD HANDLING (NEON)');
  console.log('='.repeat(80));
  console.log(`\nData source: ${DATA_DIR}`);
  console.log(`Target: Neon PostgreSQL\n`);

  const client = new Client({
    connectionString: DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log('✅ Connected to Neon database\n');

    const files = fs.readdirSync(DATA_DIR)
      .filter(f => f.endsWith('.json'))
      .sort();

    console.log(`Found ${files.length} jurisdiction files\n`);

    let imported = 0;
    let failed = 0;
    const errors = [];

    for (const file of files) {
      const filePath = path.join(DATA_DIR, file);
      const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

      try {
        await importJurisdiction(client, data);
        console.log(`✅ ${data.jurisdiction.padEnd(25)} - Imported successfully`);
        imported++;
      } catch (error) {
        console.log(`❌ ${data.jurisdiction.padEnd(25)} - FAILED`);
        errors.push({ jurisdiction: data.jurisdiction, error: error.message });
        failed++;
      }
    }

    console.log('\n' + '='.repeat(80));
    console.log('IMPORT SUMMARY');
    console.log('='.repeat(80));
    console.log(`✅ Successfully imported: ${imported}/${files.length}`);

    if (failed > 0) {
      console.log(`❌ Failed: ${failed}\n`);
      console.log('First 5 errors:');
      errors.slice(0, 5).forEach(e => {
        console.log(`\n${e.jurisdiction}:`);
        console.log(`  ${e.error.substring(0, 200)}`);
      });
    }

    console.log('\n🎉 Import complete!\n');

  } catch (error) {
    console.error('❌ Fatal error:', error.message);
    console.error(error.stack);
    process.exit(1);
  } finally {
    await client.end();
  }
}

main().catch(console.error);
