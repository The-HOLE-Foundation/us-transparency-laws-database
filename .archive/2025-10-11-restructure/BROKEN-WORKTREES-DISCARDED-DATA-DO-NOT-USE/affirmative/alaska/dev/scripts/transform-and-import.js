#!/usr/bin/env node
/**
 * Transform v0.11.0 nested JSON to normalized schema and import to Supabase
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const SUPABASE_URL = 'https://befpnwcokngtrljxskfz.supabase.co';
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJlZnBud2Nva25ndHJsanhza2Z6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTc4MDc2MCwiZXhwIjoyMDc1MzU2NzYwfQ.gLO-Zlt4aeU3xFMe9iBo99JKtQ6CKSraOf9X57Wcbc0';

const DATA_DIR = 'releases/v0.11.0/jurisdictions';

// Helper to create slug from jurisdiction name
function createSlug(name) {
  return name.toLowerCase().replace(/\s+/g, '-');
}

// Helper to determine jurisdiction type
function getJurisdictionType(name) {
  if (name === 'Federal') return 'federal';
  if (name === 'District of Columbia') return 'district';
  return 'state';
}

// Fetch helper with error handling
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

// Transform and import a single jurisdiction
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
  const [transparencyLaw] = await supabaseFetch('transparency_laws', 'POST', {
    jurisdiction_id: jurisdictionId,
    name: tLaw.name,
    statute_citation: tLaw.statute_citation,
    effective_date: tLaw.effective_date,
    last_amended: tLaw.last_amended,
    official_resources: tLaw.official_resources || {},
    validation_metadata: tLaw.validation_metadata || {}
  });

  const lawId = transparencyLaw.id;

  // 3. Insert response_requirements
  if (tLaw.response_requirements) {
    await supabaseFetch('response_requirements', 'POST', {
      transparency_law_id: lawId,
      ...tLaw.response_requirements
    });
  }

  // 4. Insert fee_structure
  if (tLaw.fee_structure) {
    await supabaseFetch('fee_structures', 'POST', {
      transparency_law_id: lawId,
      ...tLaw.fee_structure
    });
  }

  // 5. Insert exemptions (array)
  if (tLaw.exemptions && Array.isArray(tLaw.exemptions)) {
    for (const exemption of tLaw.exemptions) {
      await supabaseFetch('exemptions', 'POST', {
        transparency_law_id: lawId,
        ...exemption
      });
    }
  }

  // 6. Insert appeal_process
  if (tLaw.appeal_process) {
    await supabaseFetch('appeal_processes', 'POST', {
      transparency_law_id: lawId,
      ...tLaw.appeal_process
    });
  }

  // 7. Insert requester_requirements
  if (tLaw.requester_requirements) {
    await supabaseFetch('requester_requirements', 'POST', {
      transparency_law_id: lawId,
      ...tLaw.requester_requirements
    });
  }

  // 8. Insert agency_obligations
  if (tLaw.agency_obligations) {
    await supabaseFetch('agency_obligations', 'POST', {
      transparency_law_id: lawId,
      ...tLaw.agency_obligations
    });
  }

  // 9. Insert oversight_body
  if (tLaw.oversight_body) {
    await supabaseFetch('oversight_bodies', 'POST', {
      transparency_law_id: lawId,
      ...tLaw.oversight_body
    });
  }

  // Note: agencies table remains empty for v0.11 (deferred to v0.12)

  return jurisdictionId;
}

async function main() {
  console.log('='.repeat(80));
  console.log('TRANSFORM & IMPORT v0.11.0 DATA TO NORMALIZED SCHEMA');
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
    console.log('Errors:');
    errors.forEach(e => {
      console.log(`  - ${e.jurisdiction}: ${e.error.substring(0, 100)}`);
    });
  }

  console.log('\n🎉 Import complete!\n');
}

main().catch(console.error);
