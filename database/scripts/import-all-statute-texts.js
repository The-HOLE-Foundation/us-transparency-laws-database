#!/usr/bin/env node
/**
 * Import All Statutory Texts to Neon Database
 *
 * Reads full statute text files from data/jurisdictions/ and imports to statute_texts table
 * Automatically calculates word count, sections, and creates search vectors
 */

import { Client } from 'pg';
import { readFile, readdir } from 'fs/promises';
import { resolve } from 'path';

const DATABASE_URL = process.env.DATABASE_URL_UNPOOLED || process.env.DATABASE_URL;

if (!DATABASE_URL) {
  console.error('❌ DATABASE_URL must be set');
  process.exit(1);
}

async function importAllStatutes() {
  const client = new Client({
    connectionString: DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  });

  await client.connect();
  console.log('✅ Connected to Neon\n');

  let imported = 0;
  let failed = 0;

  try {
    // Import Federal
    await importStatute(client, 'federal', 'federal');
    imported++;

    // Import all states
    const statesDir = 'data/jurisdictions/states';
    const states = await readdir(statesDir);

    for (const state of states) {
      try {
        await importStatute(client, 'states', state);
        imported++;
      } catch (error) {
        console.error(`❌ ${state}: ${error.message}`);
        failed++;
      }
    }

    console.log(`\n${'='.repeat(60)}`);
    console.log(`✅ Import Complete:`);
    console.log(`   Imported: ${imported}/52`);
    console.log(`   Failed: ${failed}`);
    console.log(`${'='.repeat(60)}\n`);

  } finally {
    await client.end();
  }
}

async function importStatute(client, level, jurisdiction) {
  const basePath = level === 'federal'
    ? `data/jurisdictions/federal`
    : `data/jurisdictions/${level}/${jurisdiction}`;

  // Read statute text
  const statutePath = resolve(basePath, 'statute-full-text.txt');
  const fullText = await readFile(statutePath, 'utf-8');

  // Read metadata for citation info
  const metadataPath = resolve(basePath, 'metadata.json');
  const metadata = JSON.parse(await readFile(metadataPath, 'utf-8'));

  // Convert folder name (hyphens) to database ID (underscores)
  const jurisdictionId = level === 'federal' ? 'federal' : jurisdiction.replace(/-/g, '_');

  // Extract statute citation from metadata
  const statuteCitation = metadata.transparency_law?.statute_citation ||
                          metadata.statute_citation ||
                          'Citation not found';

  // Handle date fields - convert year-only strings to null
  let effectiveDate = metadata.transparency_law?.effective_date || null;
  let lastAmended = metadata.transparency_law?.last_amended || null;

  // If date is just a year (e.g., "2024"), set to null to avoid SQL errors
  if (effectiveDate && effectiveDate.length === 4) effectiveDate = null;
  if (lastAmended && lastAmended.length === 4) lastAmended = null;

  // Calculate statistics
  const wordCount = fullText.split(/\s+/).length;
  const characterCount = fullText.length;

  // Count sections (rough estimate - lines starting with §)
  const sectionMatches = fullText.match(/§\s*\d+/g) || [];
  const totalSections = sectionMatches.length;

  // Get official source URL
  const sourceUrl = metadata.transparency_law?.official_resources?.primary_statute_url ||
                    metadata.official_resources?.primary_statute_url ||
                    metadata.validation_metadata?.source_url ||
                    'https://source-not-documented';

  // Delete existing if present
  await client.query(
    'DELETE FROM statute_texts WHERE jurisdiction_id = $1',
    [jurisdictionId]
  );

  // Insert statute text
  await client.query(`
    INSERT INTO statute_texts (
      jurisdiction_id,
      full_text,
      statute_citation,
      effective_date,
      last_amended,
      total_sections,
      word_count,
      character_count,
      official_source_url,
      retrieved_date,
      verified_date,
      verified_by
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
  `, [
    jurisdictionId,
    fullText,
    statuteCitation,
    effectiveDate,
    lastAmended,
    totalSections,
    wordCount,
    characterCount,
    sourceUrl,
    metadata.validation_metadata?.parsed_date || '2025-10-11',
    metadata.validation_metadata?.last_verified_date || '2025-10-11',
    'Claude Code AI Assistant'
  ]);

  console.log(`✓ ${jurisdiction.padEnd(25)} ${wordCount.toString().padStart(6)} words, ${totalSections.toString().padStart(3)} sections`);
}

// Execute
importAllStatutes().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
