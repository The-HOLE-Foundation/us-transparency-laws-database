#!/usr/bin/env node
/**
 * Smart import: Standard fields go to columns, extras go to additional_fields JSONB
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const SUPABASE_URL = 'https://rggwmedruufdbuifxbov.supabase.co';
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJnZ3dtZWRydXVmZGJ1aWZ4Ym92Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTgxNTY5MiwiZXhwIjoyMDc1MzkxNjkyfQ.rBtfHxgXDeKdseV91w1qJnkaKwgF40p2ABYE1DEqXBM';

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

async function supabaseFetch(endpoint, method, body) {
  const url = `${SUPABASE_URL}/rest/v1/${endpoint}`;

  const response = await fetch(url, {
    method,
    headers: {
      'apikey': SUPABASE_SERVICE_KEY,
      'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    },
    body: JSON.stringify(body)
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`${method} ${endpoint} failed: ${error}`);
  }

  return await response.json();
}

async function importJurisdiction(data) {
  const jurisdictionName = data.jurisdiction;
  const tLaw = data.transparency_law;

  // 1. Insert jurisdiction
  const [jurisdiction] = await supabaseFetch('jurisdictions', 'POST', {
    slug: createSlug(jurisdictionName),
    name: jurisdictionName,
    jurisdiction_type: getJurisdictionType(jurisdictionName)
  });

  const jurisdictionId = jurisdiction.id;

  // 2. Insert transparency_law
  // Handle date fields - convert year-only strings to null (e.g., "2024" -> null)
  const effective_date = tLaw.effective_date && tLaw.effective_date.length > 4 ? tLaw.effective_date : null;
  const last_amended = tLaw.last_amended && tLaw.last_amended.length > 4 ? tLaw.last_amended : null;

  const [transparencyLaw] = await supabaseFetch('transparency_laws', 'POST', {
    jurisdiction_id: jurisdictionId,
    name: tLaw.name,
    statute_citation: tLaw.statute_citation,
    effective_date,
    last_amended,
    official_resources: tLaw.official_resources || {},
    validation_metadata: tLaw.validation_metadata || {}
  });

  const lawId = transparencyLaw.id;

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
    await supabaseFetch('response_requirements', 'POST', {
      transparency_law_id: lawId,
      ...standard,
      additional_fields: additional
    });
  }

  // 4. Insert fee_structure
  if (tLaw.fee_structure) {
    const { standard, additional } = separateFields(tLaw.fee_structure, 'fee_structures');
    await supabaseFetch('fee_structures', 'POST', {
      transparency_law_id: lawId,
      ...standard,
      additional_fields: additional
    });
  }

  // 5. Insert exemptions (no additional_fields needed - has its own structure)
  if (tLaw.exemptions && Array.isArray(tLaw.exemptions)) {
    for (const exemption of tLaw.exemptions) {
      // Normalize scope: "variable" -> "moderate" (schema only allows narrow/moderate/broad)
      let scope = exemption.scope;
      if (scope === 'variable') {
        scope = 'moderate';
      }

      await supabaseFetch('exemptions', 'POST', {
        transparency_law_id: lawId,
        category: exemption.category,
        citation: exemption.citation,
        description: exemption.description,
        scope: scope || null
      });
    }
  }

  // 6. Insert appeal_process
  if (tLaw.appeal_process) {
    const { standard, additional } = separateFields(tLaw.appeal_process, 'appeal_processes');
    await supabaseFetch('appeal_processes', 'POST', {
      transparency_law_id: lawId,
      ...standard,
      additional_fields: additional
    });
  }

  // 7. Insert requester_requirements
  if (tLaw.requester_requirements) {
    const { standard, additional } = separateFields(tLaw.requester_requirements, 'requester_requirements');
    await supabaseFetch('requester_requirements', 'POST', {
      transparency_law_id: lawId,
      ...standard,
      additional_fields: additional
    });
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
    await supabaseFetch('agency_obligations', 'POST', {
      transparency_law_id: lawId,
      ...standard,
      additional_fields: additional
    });
  }

  // 9. Insert oversight_body (skip if empty - not all jurisdictions have oversight bodies)
  if (tLaw.oversight_body && (tLaw.oversight_body.name || tLaw.oversight_body.role)) {
    const { standard, additional } = separateFields(tLaw.oversight_body, 'oversight_bodies');
    await supabaseFetch('oversight_bodies', 'POST', {
      transparency_law_id: lawId,
      ...standard,
      additional_fields: additional
    });
  }

  return jurisdictionId;
}

async function main() {
  console.log('='.repeat(80));
  console.log('SMART IMPORT: v0.11.0 DATA WITH FLEXIBLE FIELD HANDLING');
  console.log('='.repeat(80));
  console.log(`\nData source: ${DATA_DIR}`);
  console.log(`Target: ${SUPABASE_URL}\n`);

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
      await importJurisdiction(data);
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
}

main().catch(console.error);
