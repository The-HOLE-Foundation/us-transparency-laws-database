/**
 * Import transparency map data to Supabase
 *
 * Usage:
 *   node import-to-supabase.js
 *
 * Environment variables required:
 *   SUPABASE_URL - Your Supabase project URL
 *   SUPABASE_KEY - Your Supabase service role key
 */

const fs = require('fs');
const path = require('path');

// Note: Install @supabase/supabase-js first: npm install @supabase/supabase-js
const { createClient } = require('@supabase/supabase-js');

// Configuration
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY; // Use service role key for admin operations
const DATA_FILE = path.join(__dirname, 'transparency-map-data-v0.11.json');

// Initialize Supabase client
if (!SUPABASE_URL || !SUPABASE_KEY) {
    console.error('❌ Missing required environment variables:');
    console.error('   - SUPABASE_URL');
    console.error('   - SUPABASE_KEY');
    process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

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
 * Transform jurisdiction data for Supabase
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
        response_timeline_factors: jurisdiction.response_timeline_factors || [],
        response_timeline_extension: jurisdiction.response_timeline_extension || {},

        public_record_categories: jurisdiction.public_record_categories || [],
        fee_structure: jurisdiction.fee_structure || {},
        fee_waiver_available: jurisdiction.fee_structure?.fee_waiver_available || false,

        appeal_process: jurisdiction.appeal_process || {},
        attorney_fees_available: jurisdiction.appeal_process?.attorney_fees_available || false,

        key_features_tags: jurisdiction.key_features_tags || [],

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
async function clearExistingData() {
    console.log('\n🗑️  Clearing existing data...');

    try {
        const { error } = await supabase
            .from('transparency_map_jurisdictions')
            .delete()
            .neq('jurisdiction_code', ''); // Delete all records

        if (error) {
            console.warn('⚠️  Warning clearing data:', error.message);
        } else {
            console.log('✅ Existing data cleared');
        }
    } catch (err) {
        console.warn('⚠️  Warning during clear:', err.message);
    }
}

/**
 * Import jurisdictions in batches
 */
async function importJurisdictions(jurisdictions) {
    console.log(`\n📥 Importing ${jurisdictions.length} jurisdictions...`);

    const batchSize = 10;
    let imported = 0;
    let errors = 0;

    for (let i = 0; i < jurisdictions.length; i += batchSize) {
        const batch = jurisdictions.slice(i, i + batchSize);
        const transformedBatch = batch.map(transformJurisdictionData);

        try {
            const { data, error } = await supabase
                .from('transparency_map_jurisdictions')
                .insert(transformedBatch)
                .select();

            if (error) {
                console.error(`❌ Error importing batch ${i / batchSize + 1}:`, error.message);
                errors += batch.length;
            } else {
                imported += data.length;
                console.log(`✅ Imported batch ${i / batchSize + 1}: ${data.length} records`);
            }
        } catch (err) {
            console.error(`❌ Exception importing batch ${i / batchSize + 1}:`, err.message);
            errors += batch.length;
        }
    }

    return { imported, errors };
}

/**
 * Verify import
 */
async function verifyImport(expected) {
    console.log('\n🔍 Verifying import...');

    try {
        const { data, error, count } = await supabase
            .from('transparency_map_jurisdictions')
            .select('*', { count: 'exact', head: true });

        if (error) {
            console.error('❌ Error verifying:', error.message);
            return false;
        }

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
async function displaySamples() {
    console.log('\n📋 Sample records:');

    try {
        const { data, error } = await supabase
            .from('transparency_map_jurisdictions')
            .select('jurisdiction_code, jurisdiction_name, statute_abbreviation, response_timeline_days')
            .limit(5);

        if (error) {
            console.error('❌ Error fetching samples:', error.message);
            return;
        }

        data.forEach(record => {
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
    console.log('TRANSPARENCY MAP DATA IMPORT TO SUPABASE');
    console.log('=' .repeat(80));

    try {
        // Load data
        const dataset = loadData();

        // Clear existing data (optional - comment out if you want to keep existing data)
        // await clearExistingData();

        // Import jurisdictions
        const { imported, errors } = await importJurisdictions(dataset.jurisdictions);

        console.log('\n' + '='.repeat(80));
        console.log('IMPORT SUMMARY');
        console.log('='.repeat(80));
        console.log(`Total jurisdictions: ${dataset.jurisdictions.length}`);
        console.log(`Successfully imported: ${imported}`);
        console.log(`Errors: ${errors}`);

        // Verify import
        const verified = await verifyImport(dataset.jurisdictions.length);

        // Display samples
        if (verified) {
            await displaySamples();
        }

        console.log('\n✅ Import complete!');
        console.log('\nNext steps:');
        console.log('1. Verify data in Supabase dashboard');
        console.log('2. Test queries using the provided views');
        console.log('3. Configure Row Level Security policies');
        console.log('4. Set up API keys for frontend access');

    } catch (error) {
        console.error('\n❌ Fatal error:', error.message);
        console.error(error.stack);
        process.exit(1);
    }
}

// Run import
main();