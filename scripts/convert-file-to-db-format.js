#!/usr/bin/env node

/**
 * Convert v0.12 file format rights to database format
 *
 * File format uses: category, subcategory, description
 * Database expects: right_category, right_name, short_description, full_description
 */

import fs from 'fs/promises';

// Category mapping from file format to database format
const CATEGORY_MAP = {
  'Proactive Disclosure': 'proactive_disclosure',
  'Enhanced Access Rights': 'enhanced_access',
  'Technology Rights': 'technology_format',
  'Requester-Specific Rights': 'requester_specific',
  'Inspection Rights': 'inspection_rights',
  'Timeliness Rights': 'timeliness_rights',
  'Fee Waiver': 'fee_waiver',
  'Aggregation Rights': 'aggregation_rights',
  'Privacy Protection': 'privacy_protection',
  'Appeal Rights': 'appeal_rights'
};

async function convert(inputPath, outputPath) {
  // Read input file
  const input = JSON.parse(await fs.readFile(inputPath, 'utf-8'));

  // Handle BOTH formats: jurisdiction_slug OR jurisdiction.slug
  let jurisdictionId, jurisdictionName;
  if (input.jurisdiction) {
    jurisdictionId = input.jurisdiction.slug || input.jurisdiction.id;
    jurisdictionName = input.jurisdiction.name;
  } else {
    jurisdictionId = input.jurisdiction_slug;
    jurisdictionName = input.jurisdiction_name;
  }

  // Normalize jurisdiction ID (replace hyphens with underscores for database)
  jurisdictionId = jurisdictionId.replace(/-/g, '_');

  // Get rights array (handle BOTH formats: rights_of_access OR rights)
  const rightsArray = input.rights_of_access || input.rights || [];

  // Convert to database-compatible format
  const output = {
    jurisdiction: {
      id: jurisdictionId,
      slug: jurisdictionId,
      name: jurisdictionName
    },
    metadata: {
      collected_date: input.last_updated || input.validation_metadata?.parsed_date || new Date().toISOString().split('T')[0],
      source_url: input.validation_metadata?.source_url || input.validation_metadata?.source_file || '',
      statute_name: input.jurisdiction?.transparency_law || input.validation_metadata?.primary_statute || '',
      primary_citation: input.validation_metadata?.primary_statute || '',
      verification_status: 'verified',
      verified_by: input.validation_metadata?.verified_by || 'Claude Code AI Assistant',
      last_verified: input.last_updated || input.validation_metadata?.parsed_date || new Date().toISOString().split('T')[0]
    },
    rights: rightsArray.map(right => ({
      right_name: right.subcategory || right.description?.substring(0, 50) || 'Unnamed Right',
      right_category: CATEGORY_MAP[right.category] || right.category?.toLowerCase().replace(/ /g, '_') || 'enhanced_access',
      short_description: right.description || '',
      full_description: right.description + (right.implementation_notes ? '\n\n' + right.implementation_notes : ''),
      statutory_citation: right.statute_citation || '',
      statutory_text: right.description || '',
      priority: 'medium', // Default priority - should be reviewed
      assertion_language: right.request_tips || right.assertion_language || `Pursuant to ${right.statute_citation}, I assert this right.`
    }))
  };

  // Write output
  await fs.writeFile(outputPath, JSON.stringify(output, null, 2));
  console.log(`✅ Converted ${input.rights.length} rights`);
  console.log(`   Input:  ${inputPath}`);
  console.log(`   Output: ${outputPath}`);
}

// Main
const inputPath = process.argv[2];
const outputPath = process.argv[3] || inputPath.replace('.json', '-db-format.json');

if (!inputPath) {
  console.error('Usage: node convert-file-to-db-format.js <input-file> [output-file]');
  process.exit(1);
}

convert(inputPath, outputPath);
