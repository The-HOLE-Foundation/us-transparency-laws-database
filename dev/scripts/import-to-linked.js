#!/usr/bin/env node
/**
 * Import data to currently linked Supabase project
 * Reads from releases/v0.11.0/jurisdictions/*.json
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Vercel-connected production project credentials
const SUPABASE_URL = process.env.SUPABASE_URL || 'https://rggwmedruufdbuifxbov.supabase.co';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJnZ3dtZWRydXVmZGJ1aWZ4Ym92Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTgxNTY5MiwiZXhwIjoyMDc1MzkxNjkyfQ.rBtfHxgXDeKdseV91w1qJnkaKwgF40p2ABYE1DEqXBM';

console.log('================================================================================');
console.log('IMPORTING DATA TO LINKED SUPABASE PROJECT');
console.log('================================================================================');
console.log(`Target: ${SUPABASE_URL}\n`);

const RELEASE_DIR = path.join(__dirname, '../../releases/v0.11.0/jurisdictions');

async function importJurisdiction(filePath) {
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

  // Import jurisdiction (matching actual schema: slug, name, jurisdiction_type only)
  const jurisdictionData = {
    slug: data.jurisdiction.slug,
    name: data.jurisdiction.name,
    jurisdiction_type: data.jurisdiction.type
  };

  try {
    const jResp = await fetch(`${SUPABASE_URL}/rest/v1/jurisdictions`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: JSON.stringify(jurisdictionData)
    });

    if (!jResp.ok) {
      const error = await jResp.text();
      throw new Error(`POST jurisdictions failed: ${error}`);
    }

    const [jurisdiction] = await jResp.json();

    // Import transparency_laws (schema: name, statute_citation, effective_date, last_amended, official_resources, validation_metadata)
    const lawData = {
      jurisdiction_id: jurisdiction.id,
      name: data.transparency_law.statute_name,
      statute_citation: data.transparency_law.statute_citation,
      effective_date: data.transparency_law.effective_date || null,
      last_amended: data.transparency_law.last_amended || null,
      official_resources: {
        primary_statute_url: data.transparency_law.statute_url || null,
        scope: data.transparency_law.scope || null
      },
      validation_metadata: data.transparency_law.validation_metadata || {}
    };

    const lawResp = await fetch(`${SUPABASE_URL}/rest/v1/transparency_laws`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: JSON.stringify(lawData)
    });

    if (!lawResp.ok) throw new Error(`POST transparency_laws failed`);
    const [law] = await lawResp.json();

    // Import response_requirements
    const respData = {
      transparency_law_id: law.id,
      initial_response_days: data.transparency_law.response_requirements.initial_response_days,
      initial_response_type: data.transparency_law.response_requirements.initial_response_type,
      extension_allowed: data.transparency_law.response_requirements.extension_allowed || false,
      extension_max_days: data.transparency_law.response_requirements.extension_max_days || null,
      tolling_provisions: data.transparency_law.response_requirements.tolling_provisions || null
    };

    await fetch(`${SUPABASE_URL}/rest/v1/response_requirements`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(respData)
    });

    // Import fee_structures
    const feeData = {
      transparency_law_id: law.id,
      search_fee_allowed: data.transparency_law.fee_structure?.search_fee_allowed || false,
      search_fee_amount: data.transparency_law.fee_structure?.search_fee_amount || null,
      copy_fee_allowed: data.transparency_law.fee_structure?.copy_fee_allowed || false,
      copy_fee_amount: data.transparency_law.fee_structure?.copy_fee_amount || null,
      waiver_criteria: data.transparency_law.fee_structure?.waiver_criteria || null
    };

    await fetch(`${SUPABASE_URL}/rest/v1/fee_structures`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(feeData)
    });

    // Import exemptions
    if (data.transparency_law.exemptions && data.transparency_law.exemptions.length > 0) {
      for (const exemption of data.transparency_law.exemptions) {
        const exemptionData = {
          transparency_law_id: law.id,
          jurisdiction_slug: jurisdiction.slug,
          jurisdiction_name: jurisdiction.name,
          category: exemption.category,
          statute_citation: exemption.statute_citation || null,
          description: exemption.description || null
        };

        await fetch(`${SUPABASE_URL}/rest/v1/exemptions`, {
          method: 'POST',
          headers: {
            'apikey': SUPABASE_SERVICE_KEY,
            'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(exemptionData)
        });
      }
    }

    // Import appeal_processes
    const appealData = {
      transparency_law_id: law.id,
      administrative_appeal_available: data.transparency_law.appeal_process?.administrative_appeal_available || false,
      administrative_appeal_days: data.transparency_law.appeal_process?.administrative_appeal_days || null,
      judicial_review_available: data.transparency_law.appeal_process?.judicial_review_available || false,
      judicial_review_days: data.transparency_law.appeal_process?.judicial_review_days || null,
      appeal_authority: data.transparency_law.appeal_process?.appeal_authority || null
    };

    await fetch(`${SUPABASE_URL}/rest/v1/appeal_processes`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(appealData)
    });

    // Import requester_requirements
    const reqData = {
      transparency_law_id: law.id,
      identity_required: data.transparency_law.requester_requirements?.identity_required || false,
      residency_required: data.transparency_law.requester_requirements?.residency_required || false,
      purpose_statement_required: data.transparency_law.requester_requirements?.purpose_statement_required || false,
      eligibility_restrictions: data.transparency_law.requester_requirements?.eligibility_restrictions || null
    };

    await fetch(`${SUPABASE_URL}/rest/v1/requester_requirements`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(reqData)
    });

    // Import agency_obligations
    const agencyData = {
      transparency_law_id: law.id,
      must_provide_reason_for_denial: data.transparency_law.agency_obligations?.must_provide_reason_for_denial || false,
      must_cite_exemption: data.transparency_law.agency_obligations?.must_cite_exemption || false,
      must_notify_requester: data.transparency_law.agency_obligations?.must_notify_requester || false,
      penalties_for_noncompliance: data.transparency_law.agency_obligations?.penalties_for_noncompliance || null
    };

    await fetch(`${SUPABASE_URL}/rest/v1/agency_obligations`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(agencyData)
    });

    // Import oversight_bodies
    if (data.transparency_law.oversight_body) {
      const oversightData = {
        transparency_law_id: law.id,
        name: data.transparency_law.oversight_body.name || null,
        website: data.transparency_law.oversight_body.website || null,
        enforcement_authority: data.transparency_law.oversight_body.enforcement_authority || null
      };

      await fetch(`${SUPABASE_URL}/rest/v1/oversight_bodies`, {
        method: 'POST',
        headers: {
          'apikey': SUPABASE_SERVICE_KEY,
          'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(oversightData)
      });
    }

    return { success: true };

  } catch (error) {
    return { success: false, error: error.message };
  }
}

async function main() {
  const files = fs.readdirSync(RELEASE_DIR).filter(f => f.endsWith('.json'));

  console.log(`Found ${files.length} jurisdiction files to import\n`);

  let successCount = 0;
  let failCount = 0;

  for (const file of files) {
    const filePath = path.join(RELEASE_DIR, file);
    const result = await importJurisdiction(filePath);
    const name = file.replace('.json', '');

    if (result.success) {
      console.log(`✅ ${name}`);
      successCount++;
    } else {
      console.log(`❌ ${name} - ${result.error}`);
      failCount++;
    }
  }

  console.log('\n' + '='.repeat(80));
  console.log(`Import complete: ${successCount} succeeded, ${failCount} failed`);
  console.log('='.repeat(80));
}

main().catch(console.error);
