#!/usr/bin/env node

/**
 * Check rights collection progress
 *
 * Shows which jurisdictions have rights data and which still need it
 */

import { Client } from 'pg';

const DATABASE_URL = process.env.DATABASE_URL || process.env.DATABASE_URL_UNPOOLED;

if (!DATABASE_URL) {
  console.error('❌ DATABASE_URL environment variable required');
  process.exit(1);
}

async function checkProgress() {
  const client = new Client({
    connectionString: DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();

    // Get all jurisdictions
    const allJurisdictions = await client.query(`
      SELECT id, name FROM jurisdictions ORDER BY name
    `);

    // Get jurisdictions with rights
    const withRights = await client.query(`
      SELECT jurisdiction_id, COUNT(*) as rights_count
      FROM rights_of_access
      GROUP BY jurisdiction_id
      ORDER BY rights_count DESC
    `);

    const rightsMap = new Map();
    withRights.rows.forEach(row => {
      rightsMap.set(row.jurisdiction_id, parseInt(row.rights_count));
    });

    // Calculate stats
    const total = allJurisdictions.rows.length;
    const complete = withRights.rows.length;
    const remaining = total - complete;
    const percentage = Math.round((complete / total) * 100);
    const totalRights = withRights.rows.reduce((sum, row) => sum + parseInt(row.rights_count), 0);

    console.log(`\n📊 Rights Collection Progress\n`);
    console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
    console.log(`  Jurisdictions: ${complete}/${total} (${percentage}%)`);
    console.log(`  Total Rights:  ${totalRights}`);
    console.log(`  Average:       ${Math.round(totalRights / complete)} rights per jurisdiction`);
    console.log(`  Remaining:     ${remaining} jurisdictions\n`);

    // Show completed jurisdictions
    console.log(`✅ COMPLETED (${complete} jurisdictions):\n`);
    const completed = allJurisdictions.rows.filter(j => rightsMap.has(j.id));
    completed.forEach(j => {
      const count = rightsMap.get(j.id);
      const bar = '█'.repeat(Math.min(count, 30));
      console.log(`   ${j.name.padEnd(20)} ${bar} ${count} rights`);
    });

    // Show remaining jurisdictions
    if (remaining > 0) {
      console.log(`\n❌ REMAINING (${remaining} jurisdictions):\n`);
      const incomplete = allJurisdictions.rows.filter(j => !rightsMap.has(j.id));

      // Group by priority tiers
      const tierStates = {
        tier1: ['pennsylvania', 'ohio', 'michigan', 'virginia', 'new_jersey', 'indiana', 'missouri', 'maryland', 'wisconsin', 'minnesota'],
        tier2: ['colorado', 'arizona', 'tennessee', 'south_carolina', 'alabama', 'kentucky', 'iowa', 'utah', 'nevada', 'kansas']
      };

      console.log(`   TIER 1 (High Priority - Large States):`);
      incomplete.filter(j => tierStates.tier1.includes(j.id)).forEach(j => {
        console.log(`   ⚡ ${j.name}`);
      });

      console.log(`\n   TIER 2 (Medium Priority):`);
      incomplete.filter(j => tierStates.tier2.includes(j.id)).forEach(j => {
        console.log(`   📍 ${j.name}`);
      });

      console.log(`\n   TIER 3 (Remaining):`);
      incomplete.filter(j => !tierStates.tier1.includes(j.id) && !tierStates.tier2.includes(j.id)).forEach(j => {
        console.log(`   📌 ${j.name}`);
      });
    }

    // Estimate completion timeline
    console.log(`\n⏱️  TIMELINE ESTIMATE:\n`);
    const avgRightsPerJurisdiction = Math.round(totalRights / complete);
    const estimatedTotalRights = avgRightsPerJurisdiction * total;
    const remainingRights = estimatedTotalRights - totalRights;

    console.log(`   Estimated rights remaining:  ~${remainingRights}`);
    console.log(`   At 5 jurisdictions/day:      ${Math.ceil(remaining / 5)} business days`);
    console.log(`   At 10 jurisdictions/day:     ${Math.ceil(remaining / 10)} business days`);

    if (complete === total) {
      console.log(`\n🎉 COMPLETE! Ready to promote to v0.12 (non-alpha)\n`);
    } else {
      console.log(`\n📋 Next Action: Start with highest priority Tier 1 state\n`);
    }

    await client.end();

  } catch (error) {
    console.error(`❌ Error: ${error.message}`);
    process.exit(1);
  }
}

checkProgress();
