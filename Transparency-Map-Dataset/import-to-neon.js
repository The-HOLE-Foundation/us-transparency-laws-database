#!/usr/bin/env node
/**
 * Import transparency map data to Neon PostgreSQL Database
 *
 * Usage:
 *   node import-to-neon.js
 *
 * Environment variables required:
 *   DATABASE_URL - Neon PostgreSQL connection string (pooled)
 *   DATABASE_URL_UNPOOLED - Neon direct connection (for migrations)
 *
 * Converted from import-to-supabase.js for Neon compatibility
 * Uses native PostgreSQL client instead of Supabase SDK
 */

import { Client } from 'pg';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configuration - use Neon connection
const DATABASE_URL = process.env.DATABASE_URL_UNPOOLED || process.env.DATABASE_URL;
const DATA_FILE = path.join(__dirname, 'transparency-map-data-v0.11.json');

// Validate environment
if (!DATABASE_URL) {
    console.error('❌ Missing required environment variable:');
    console.error('   - DATABASE_URL or DATABASE_URL_UNPOOLED');
    console.error('');
    console.error('Set in .env.production:');
    console.error('DATABASE_URL=postgresql://neondb_owner:...@ep-dark-smoke-adkcd3h4-pooler.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require');
    process.exit(1);
}

/**
 * Load JSON data from file
 */
function loadData() {
    console.log(`\n📂 Loading data from: ${DATA_FILE}`);
    const rawData = fs.readFileSync(DATA_FILE, 'utf8');
    const data = JSON.parse(rawData);
    console.log(`✅ Loaded ${data.jurisdictions.length} jurisdictions`);
    return data;
}

/**
 * Transform jurisdiction data for Neon database
 */
function transformJurisdictionData(jurisdiction) {
    return {
        jurisdiction_code: jurisdiction.jurisdiction_code,
        jurisdiction_name: jurisdiction.jurisdiction_name,
        statute_abbreviation: jurisdiction.statute_abbreviation,
        statute_full_name: jurisdiction.statute_full_name,
        core_principle: jurisdiction.core_principle,
        recent_changes_2024_2025: jurisdiction.recent_changes_2024_2025 || null,

        response_timeline_days: jurisdiction.response_timeline_days,
        response_timeline_type: jurisdiction.response_timeline_type || null,
        response_timeline_description: jurisdiction.response_timeline_description || null,
        response_timeline_factors: JSON.stringify(jurisdiction.response_timeline_factors || []),
        response_timeline_extension: JSON.stringify(jurisdiction.response_timeline_extension || {}),

        public_record_categories: JSON.stringify(jurisdiction.public_record_categories || []),
        fee_structure: JSON.stringify(jurisdiction.fee_structure || {}),
        fee_waiver_available: jurisdiction.fee_structure?.fee_waiver_available || false,

        appeal_process: JSON.stringify(jurisdiction.appeal_process || {}),
        attorney_fees_available: jurisdiction.appeal_process?.attorney_fees_available || false,

        key_features_tags: JSON.stringify(jurisdiction.key_features_tags || []),

        statute_url: jurisdiction.official_resources?.statute_url || null,
        ag_page_url: jurisdiction.official_resources?.ag_page_url || null,
        request_portal_url: jurisdiction.official_resources?.request_portal_url || null,

        version: jurisdiction.metadata?.version || 'v0.11',
        verification_date: jurisdiction.metadata?.verification_date || null,
        last_statutory_update: jurisdiction.metadata?.last_statutory_update || null,
        process_map_source: jurisdiction.metadata?.process_map_source || null,
        extraction_date: jurisdiction.metadata?.extraction_date || null
    };
}

/**
 * Clear existing data
 */
async function clearExistingData(client) {
    console.log('\n🗑️  Clearing existing data...');

    try {
        await client.query('DELETE FROM transparency_map_jurisdictions');
        console.log('✅ Existing data cleared');
    } catch (err) {
        console.warn('⚠️  Warning during clear:', err.message);
    }
}

/**
 * Import jurisdictions in batches
 */
async function importJurisdictions(client, jurisdictions) {
    console.log(`\n📥 Importing ${jurisdictions.length} jurisdictions...`);

    const batchSize = 10;
    let imported = 0;
    let errors = 0;

    for (let i = 0; i < jurisdictions.length; i += batchSize) {
        const batch = jurisdictions.slice(i, i + batchSize);

        for (const jurisdiction of batch) {
            const data = transformJurisdictionData(jurisdiction);

            try {
                const query = `
                    INSERT INTO transparency_map_jurisdictions (
                        jurisdiction_code, jurisdiction_name, statute_abbreviation,
                        statute_full_name, core_principle, recent_changes_2024_2025,
                        response_timeline_days, response_timeline_type,
                        response_timeline_description, response_timeline_factors,
                        response_timeline_extension, public_record_categories,
                        fee_structure, fee_waiver_available, appeal_process,
                        attorney_fees_available, key_features_tags, statute_url,
                        ag_page_url, request_portal_url, version, verification_date,
                        last_statutory_update, process_map_source, extraction_date
                    ) VALUES (
                        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
                        $11, $12, $13, $14, $15, $16, $17, $18,
                        $19, $20, $21, $22, $23, $24, $25
                    )
                `;

                await client.query(query, [
                    data.jurisdiction_code, data.jurisdiction_name, data.statute_abbreviation,
                    data.statute_full_name, data.core_principle, data.recent_changes_2024_2025,
                    data.response_timeline_days, data.response_timeline_type,
                    data.response_timeline_description, data.response_timeline_factors,
                    data.response_timeline_extension, data.public_record_categories,
                    data.fee_structure, data.fee_waiver_available, data.appeal_process,
                    data.attorney_fees_available, data.key_features_tags, data.statute_url,
                    data.ag_page_url, data.request_portal_url, data.version,
                    data.verification_date, data.last_statutory_update,
                    data.process_map_source, data.extraction_date
                ]);

                imported++;
                console.log(`   ✓ ${data.jurisdiction_name}`);
            } catch (err) {
                console.error(`   ✗ ${jurisdiction.jurisdiction_name}: ${err.message}`);
                errors++;
            }
        }

        console.log(`✅ Batch ${Math.floor(i / batchSize) + 1} complete`);
    }

    return { imported, errors };
}

/**
 * Verify import
 */
async function verifyImport(client, expected) {
    console.log('\n🔍 Verifying import...');

    try {
        const result = await client.query(
            'SELECT COUNT(*) as total FROM transparency_map_jurisdictions'
        );

        const count = parseInt(result.rows[0].total);
        console.log(`✅ Total records in database: ${count}`);

        if (count === expected) {
            console.log('✅ Import verification successful!');
            return true;
        } else {
            console.warn(`⚠️  Expected ${expected} records, found ${count}`);
            return false;
        }
    } catch (err) {
        console.error('❌ Exception during verification:', err.message);
        return false;
    }
}

/**
 * Display sample records
 */
async function displaySamples(client) {
    console.log('\n📋 Sample records:');

    try {
        const result = await client.query(`
            SELECT jurisdiction_code, jurisdiction_name, statute_abbreviation, response_timeline_days
            FROM transparency_map_jurisdictions
            ORDER BY jurisdiction_name
            LIMIT 5
        `);

        result.rows.forEach(record => {
            console.log(`   ${record.jurisdiction_code} - ${record.jurisdiction_name} (${record.statute_abbreviation}) - ${record.response_timeline_days} days`);
        });
    } catch (err) {
        console.error('❌ Exception fetching samples:', err.message);
    }
}

/**
 * Main import function
 */
async function main() {
    console.log('=' .repeat(80));
    console.log('TRANSPARENCY MAP DATA IMPORT TO NEON DATABASE');
    console.log('=' .repeat(80));

    const client = new Client({
        connectionString: DATABASE_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        // Connect to Neon
        await client.connect();
        console.log('✅ Connected to Neon database');

        // Load data
        const dataset = loadData();

        // Clear existing data (optional - comment out if you want to keep existing data)
        // await clearExistingData(client);

        // Import jurisdictions
        const { imported, errors } = await importJurisdictions(client, dataset.jurisdictions);

        console.log('\n' + '='.repeat(80));
        console.log('IMPORT SUMMARY');
        console.log('='.repeat(80));
        console.log(`Total jurisdictions: ${dataset.jurisdictions.length}`);
        console.log(`Successfully imported: ${imported}`);
        console.log(`Errors: ${errors}`);

        // Verify import
        const verified = await verifyImport(client, dataset.jurisdictions.length);

        // Display samples
        if (verified) {
            await displaySamples(client);
        }

        console.log('\n✅ Import complete!');
        console.log('\nNext steps:');
        console.log('1. Verify data: psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM transparency_map_jurisdictions;"');
        console.log('2. Query data: psql "$DATABASE_URL" -c "SELECT * FROM transparency_map_jurisdictions LIMIT 5;"');
        console.log('3. Configure application to use Neon connection');
        console.log('4. Test frontend integration');

    } catch (error) {
        console.error('\n❌ Fatal error:', error.message);
        console.error(error.stack);
        process.exit(1);
    } finally {
        await client.end();
    }
}

// Run import
main();
