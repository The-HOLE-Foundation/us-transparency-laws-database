#!/usr/bin/env node
/**
 * Identify Jurisdictions with Incomplete Data
 *
 * Queries the Supabase database to find which jurisdictions
 * are missing critical fields for map display and wiki functionality.
 */

const SUPABASE_URL = 'https://befpnwcokngtrljxskfz.supabase.co';
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJlZnBud2Nva25ndHJsanhza2Z6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTc4MDc2MCwiZXhwIjoyMDc1MzU2NzYwfQ.gLO-Zlt4aeU3xFMe9iBo99JKtQ6CKSraOf9X57Wcbc0';

async function supabaseFetch(table, params = '') {
  const response = await fetch(
    `${SUPABASE_URL}/rest/v1/${table}?${params}`,
    {
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`
      }
    }
  );

  if (!response.ok) {
    throw new Error(`Failed to fetch ${table}: ${response.statusText}`);
  }

  return await response.json();
}

function calculateCompleteness(record) {
  let total = 0;
  let complete = 0;

  // Count non-null fields
  for (const [key, value] of Object.entries(record)) {
    // Skip metadata and ID fields
    if (['id', 'created_at', 'updated_at', 'transparency_law_id', 'jurisdiction_id'].includes(key)) {
      continue;
    }

    total++;
    if (value !== null && value !== '' && value !== '{}' && value !== '[]') {
      complete++;
    }
  }

  return total > 0 ? Math.round((complete / total) * 100) : 100;
}

async function analyzeJurisdictions() {
  console.log('================================================================================');
  console.log('JURISDICTION DATA COMPLETENESS ANALYSIS');
  console.log('================================================================================\n');

  // Get all jurisdictions with related data
  const jurisdictions = await supabaseFetch(
    'jurisdictions',
    'select=*,transparency_laws(*,response_requirements(*),fee_structures(*),appeal_processes(*),oversight_bodies(*))'
  );

  const analysis = [];

  for (const j of jurisdictions) {
    const tLaw = j.transparency_laws[0];
    if (!tLaw) {
      analysis.push({
        name: j.name,
        slug: j.slug,
        completeness: 0,
        criticalIssues: ['Missing transparency_law record'],
        warnings: []
      });
      continue;
    }

    const rr = tLaw.response_requirements[0];
    const fs = tLaw.fee_structures[0];
    const ap = tLaw.appeal_processes[0];
    const ob = tLaw.oversight_bodies[0];

    const criticalIssues = [];
    const warnings = [];

    // CRITICAL: Initial response time (needed for map)
    if (!rr || rr.initial_response_time === null) {
      criticalIssues.push('Missing initial_response_time');
    }

    // CRITICAL: Effective date (important for credibility)
    if (!tLaw.effective_date) {
      criticalIssues.push('Missing effective_date');
    }

    // WARNING: Final response time
    if (!rr || rr.final_response_time === null) {
      warnings.push('Missing final_response_time');
    }

    // WARNING: Copy fee
    if (!fs || fs.copy_fee_per_page === null) {
      warnings.push('Missing copy_fee_per_page');
    }

    // WARNING: First level appeal deadline
    if (!ap || ap.first_level_deadline_days === null) {
      warnings.push('Missing first_level_deadline_days');
    }

    // WARNING: Oversight body contact
    if (ob && (!ob.contact_info || !ob.oversight_url)) {
      warnings.push('Oversight body missing contact_info or URL');
    }

    // Calculate overall completeness
    const completeness = [
      calculateCompleteness(tLaw),
      rr ? calculateCompleteness(rr) : 0,
      fs ? calculateCompleteness(fs) : 0,
      ap ? calculateCompleteness(ap) : 0
    ].reduce((a, b) => a + b, 0) / 4;

    analysis.push({
      name: j.name,
      slug: j.slug,
      completeness: Math.round(completeness),
      criticalIssues,
      warnings
    });
  }

  // Sort by completeness (lowest first)
  analysis.sort((a, b) => a.completeness - b.completeness);

  console.log('🔴 JURISDICTIONS WITH CRITICAL ISSUES (Response Time or Effective Date Missing):\n');
  const critical = analysis.filter(a => a.criticalIssues.length > 0);
  if (critical.length > 0) {
    for (const j of critical) {
      console.log(`${j.name} (${j.completeness}% complete)`);
      j.criticalIssues.forEach(issue => console.log(`  🔴 ${issue}`));
      j.warnings.forEach(warning => console.log(`  ⚠️  ${warning}`));
      console.log();
    }
  } else {
    console.log('✅ No critical issues found!\n');
  }

  console.log('⚠️  JURISDICTIONS WITH WARNINGS (Other Missing Fields):\n');
  const warningsOnly = analysis.filter(a => a.criticalIssues.length === 0 && a.warnings.length > 0);
  if (warningsOnly.length > 0) {
    for (const j of warningsOnly.slice(0, 10)) {
      console.log(`${j.name} (${j.completeness}% complete)`);
      j.warnings.forEach(warning => console.log(`  ⚠️  ${warning}`));
      console.log();
    }
    if (warningsOnly.length > 10) {
      console.log(`... and ${warningsOnly.length - 10} more jurisdictions with warnings\n`);
    }
  } else {
    console.log('✅ No warnings!\n');
  }

  console.log('✅ HIGH COMPLETENESS JURISDICTIONS (90%+):\n');
  const highQuality = analysis.filter(a => a.completeness >= 90);
  for (const j of highQuality) {
    console.log(`${j.name} (${j.completeness}% complete)`);
  }

  console.log('\n================================================================================');
  console.log('SUMMARY');
  console.log('================================================================================\n');
  console.log(`Total Jurisdictions: ${analysis.length}`);
  console.log(`With Critical Issues: ${critical.length} (${Math.round(critical.length / analysis.length * 100)}%)`);
  console.log(`With Warnings Only: ${warningsOnly.length} (${Math.round(warningsOnly.length / analysis.length * 100)}%)`);
  console.log(`High Quality (90%+): ${highQuality.length} (${Math.round(highQuality.length / analysis.length * 100)}%)`);
  console.log(`\nAverage Completeness: ${Math.round(analysis.reduce((sum, j) => sum + j.completeness, 0) / analysis.length)}%`);
}

analyzeJurisdictions().catch(console.error);
