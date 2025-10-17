#!/usr/bin/env node
/**
 * Import all 52 jurisdictions from v0.11.0 release data into Supabase
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const SUPABASE_URL = 'https://befpnwcokngtrljxskfz.supabase.co';
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJlZnBud2Nva25ndHJsanhza2Z6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTc4MDc2MCwiZXhwIjoyMDc1MzU2NzYwfQ.gLO-Zlt4aeU3xFMe9iBo99JKtQ6CKSraOf9X57Wcbc0';

const DATA_DIR = 'releases/v0.11.0/jurisdictions';

async function insertJurisdiction(data) {
  const url = `${SUPABASE_URL}/rest/v1/jurisdictions`;

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'apikey': SUPABASE_SERVICE_KEY,
      'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    },
    body: JSON.stringify(data)
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to insert ${data.jurisdiction}: ${error}`);
  }

  return await response.json();
}

async function main() {
  console.log('='.repeat(80));
  console.log('IMPORT 52 JURISDICTIONS TO SUPABASE');
  console.log('='.repeat(80));
  console.log(`\nData source: ${DATA_DIR}`);
  console.log(`Target: ${SUPABASE_URL}\n`);

  const files = fs.readdirSync(DATA_DIR)
    .filter(f => f.endsWith('.json'))
    .sort();

  console.log(`Found ${files.length} jurisdiction files\n`);

  let imported = 0;
  let failed = 0;

  for (const file of files) {
    const filePath = path.join(DATA_DIR, file);
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

    try {
      await insertJurisdiction(data);
      console.log(`✅ ${data.jurisdiction.padEnd(25)} - Imported successfully`);
      imported++;
    } catch (error) {
      console.log(`❌ ${data.jurisdiction.padEnd(25)} - FAILED: ${error.message}`);
      failed++;
    }
  }

  console.log('\n' + '='.repeat(80));
  console.log('IMPORT SUMMARY');
  console.log('='.repeat(80));
  console.log(`✅ Successfully imported: ${imported}/${files.length}`);
  if (failed > 0) {
    console.log(`❌ Failed: ${failed}`);
  }
  console.log('\n🎉 Import complete!\n');
}

main().catch(console.error);
