#!/usr/bin/env node
/**
 * Import Rights of Access Data to Neon Database
 *
 * Usage: node dev/scripts/import-rights-neon.js <path-to-rights-json>
 * Example: node dev/scripts/import-rights-neon.js data/v0.12/rights/federal-rights.json
 *
 * Maps our JSON structure to production schema:
 * - category → right_category (transformed to snake_case)
 * - description → short_description (first 250 chars) + full_description (complete)
 * - request_tips → assertion_language
 * - Sets verification_status = 'verified' (from official sources)
 */

import { Client } from 'pg'
import { readFile } from 'fs/promises'
import { fileURLToPath } from 'url'
import { dirname, resolve } from 'path'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

// Neon connection string from environment
const DATABASE_URL = process.env.DATABASE_URL_UNPOOLED || process.env.DATABASE_URL

if (!DATABASE_URL) {
  console.error('❌ Error: DATABASE_URL or DATABASE_URL_UNPOOLED must be set')
  console.error('   Add to .env.production or set as environment variable')
  process.exit(1)
}

/**
 * Transform category name to production format
 * "Proactive Disclosure" → "proactive_disclosure"
 * "Enhanced Access Rights" → "enhanced_access"
 */
function transformCategory(category) {
  const categoryMap = {
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
  }

  return categoryMap[category] || category.toLowerCase().replace(/\s+/g, '_').replace(/[^a-z0-9_]/g, '')
}

/**
 * Create right_name from category and subcategory
 */
function createRightName(category, subcategory) {
  if (subcategory) {
    return `${category}: ${subcategory}`
  }
  return category
}

/**
 * Split description into short and full versions
 */
function splitDescription(description) {
  const maxShortLength = 250

  if (!description) {
    return { short: '', full: null }
  }

  if (description.length <= maxShortLength) {
    return { short: description, full: null }
  }

  // Find natural break point (period, newline) near 250 chars
  let breakPoint = description.lastIndexOf('. ', maxShortLength)
  if (breakPoint === -1 || breakPoint < 150) {
    breakPoint = description.lastIndexOf(' ', maxShortLength)
  }

  if (breakPoint === -1) {
    breakPoint = maxShortLength
  } else {
    breakPoint += 1 // Include the period
  }

  return {
    short: description.substring(0, breakPoint).trim(),
    full: description.trim()
  }
}

async function importRights(filePath) {
  const client = new Client({
    connectionString: DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  })

  try {
    // Read and parse JSON file
    const absolutePath = resolve(process.cwd(), filePath)
    const fileContent = await readFile(absolutePath, 'utf-8')
    const data = JSON.parse(fileContent)

    console.log(`\n📄 Importing rights from: ${filePath}`)
    console.log(`🏛️  Jurisdiction: ${data.jurisdiction.name}`)
    console.log(`📊 Rights to import: ${data.rights_of_access.length}`)

    // Connect to database
    await client.connect()
    console.log('✅ Connected to Neon database')

    // Get jurisdiction_id for this jurisdiction
    const jurisdictionQuery = `
      SELECT id, name
      FROM jurisdictions
      WHERE id = $1
    `
    const jurisdictionResult = await client.query(jurisdictionQuery, [data.jurisdiction.slug])

    if (jurisdictionResult.rows.length === 0) {
      throw new Error(`Jurisdiction '${data.jurisdiction.slug}' not found in database`)
    }

    const jurisdictionId = jurisdictionResult.rows[0].id
    const jurisdictionName = jurisdictionResult.rows[0].name
    console.log(`✅ Found jurisdiction: ${jurisdictionName} (${jurisdictionId})`)

    // Check if rights already exist for this jurisdiction
    const existingQuery = `
      SELECT COUNT(*) as count
      FROM rights_of_access
      WHERE jurisdiction_id = $1
    `
    const existingResult = await client.query(existingQuery, [jurisdictionId])
    const existingCount = parseInt(existingResult.rows[0].count)

    if (existingCount > 0) {
      console.log(`⚠️  Warning: ${existingCount} rights already exist for ${jurisdictionName}`)
      console.log(`   Deleting existing rights before import...`)

      await client.query(
        'DELETE FROM rights_of_access WHERE jurisdiction_id = $1',
        [jurisdictionId]
      )
      console.log(`✅ Deleted ${existingCount} existing rights`)
    }

    // Import each right
    let importedCount = 0
    const insertQuery = `
      INSERT INTO rights_of_access (
        jurisdiction_id,
        right_category,
        right_name,
        short_description,
        full_description,
        statutory_citation,
        assertion_language,
        verification_status,
        last_verified,
        verification_source,
        conditions,
        priority
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      RETURNING id
    `

    console.log('\n📝 Importing rights...')

    for (const right of data.rights_of_access) {
      const rightCategory = transformCategory(right.category)
      const rightName = createRightName(right.category, right.subcategory)
      const { short: shortDesc, full: fullDesc } = splitDescription(right.description)

      // Determine priority based on category
      let priority = 'medium'
      if (right.category.includes('Timeliness') || right.category.includes('Fee')) {
        priority = 'high'
      } else if (right.category.includes('Proactive')) {
        priority = 'critical'
      }

      // Build conditions JSONB
      const conditions = {}
      if (right.conditions) {
        conditions.requirements = right.conditions
      }
      if (right.applies_to) {
        conditions.applies_to = right.applies_to
      }
      if (right.implementation_notes) {
        conditions.implementation_notes = right.implementation_notes
      }

      const result = await client.query(insertQuery, [
        jurisdictionId,                                    // $1: jurisdiction_id
        rightCategory,                                     // $2: right_category
        rightName,                                         // $3: right_name
        shortDesc,                                         // $4: short_description
        fullDesc,                                          // $5: full_description
        right.statute_citation,                            // $6: statutory_citation
        right.request_tips || null,                        // $7: assertion_language
        'verified',                                        // $8: verification_status
        data.validation_metadata?.parsed_date || null,     // $9: last_verified
        data.validation_metadata?.source_url || null,      // $10: verification_source
        Object.keys(conditions).length > 0 ? JSON.stringify(conditions) : null,  // $11: conditions
        priority                                           // $12: priority
      ])

      importedCount++
      console.log(`   ✓ ${rightName}`)
    }

    console.log(`\n✅ Imported ${importedCount} rights for ${jurisdictionName}`)

    // Verify import
    const verifyQuery = `
      SELECT right_category, priority, COUNT(*) as count
      FROM rights_of_access
      WHERE jurisdiction_id = $1
      GROUP BY right_category, priority
      ORDER BY right_category, priority
    `
    const verifyResult = await client.query(verifyQuery, [jurisdictionId])

    console.log('\n📊 Import Summary by Category:')
    let currentCategory = null
    verifyResult.rows.forEach(row => {
      if (row.right_category !== currentCategory) {
        console.log(`\n   ${row.right_category}:`)
        currentCategory = row.right_category
      }
      console.log(`      ${row.priority}: ${row.count} rights`)
    })

    // Show sample rights
    const sampleQuery = `
      SELECT right_name, right_category, verification_status
      FROM rights_of_access
      WHERE jurisdiction_id = $1
      LIMIT 5
    `
    const sampleResult = await client.query(sampleQuery, [jurisdictionId])

    console.log('\n📋 Sample Imported Rights:')
    sampleResult.rows.forEach(row => {
      console.log(`   • ${row.right_name} [${row.right_category}] (${row.verification_status})`)
    })

    // Get total count
    const countQuery = `
      SELECT COUNT(*) as total
      FROM rights_of_access
      WHERE jurisdiction_id = $1
    `
    const countResult = await client.query(countQuery, [jurisdictionId])
    console.log(`\n✅ Total rights in database for ${jurisdictionName}: ${countResult.rows[0].total}`)

    console.log('\n🎉 Import completed successfully!')

  } catch (error) {
    console.error('\n❌ Import failed:', error.message)
    if (error.code) {
      console.error(`   Error code: ${error.code}`)
    }
    if (error.detail) {
      console.error(`   Detail: ${error.detail}`)
    }
    throw error
  } finally {
    await client.end()
  }
}

// Main execution
const filePath = process.argv[2]

if (!filePath) {
  console.error('❌ Error: No file path provided')
  console.error('\nUsage: node dev/scripts/import-rights-neon.js <path-to-rights-json>')
  console.error('Example: node dev/scripts/import-rights-neon.js data/v0.12/rights/federal-rights.json')
  process.exit(1)
}

importRights(filePath).catch(error => {
  console.error('Fatal error:', error)
  process.exit(1)
})
