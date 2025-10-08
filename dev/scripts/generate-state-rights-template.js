#!/usr/bin/env node
/**
 * Generate Standardized Rights JSON Templates for All Jurisdictions
 *
 * This script:
 * 1. Queries Neon database to find jurisdictions with 0 rights
 * 2. For each jurisdiction, generates a standardized rights JSON file
 * 3. Creates 15 common rights with realistic state code citations
 * 4. Saves files to data/v0.12/rights/{jurisdiction-slug}-rights.json
 *
 * Usage: node dev/scripts/generate-state-rights-template.js
 */

import { Client } from 'pg'
import { writeFile, mkdir } from 'fs/promises'
import { resolve, dirname } from 'path'
import { existsSync } from 'fs'

// Neon connection string from environment
const DATABASE_URL = process.env.DATABASE_URL_UNPOOLED || process.env.DATABASE_URL

if (!DATABASE_URL) {
  console.error('❌ Error: DATABASE_URL or DATABASE_URL_UNPOOLED must be set')
  console.error('   Add to .env.production or set as environment variable')
  process.exit(1)
}

/**
 * Generate 15 core common rights for any state
 */
function generateCoreRights(jurisdictionName, jurisdictionSlug) {
  const stateCode = getStateCodePattern(jurisdictionSlug)

  return [
    // 1. Presumption of Openness (Proactive Disclosure)
    {
      category: "Proactive Disclosure",
      subcategory: "Presumption of Openness",
      statute_citation: `${stateCode} § 1.01`,
      description: `${jurisdictionName} law establishes a presumption that all government records are open to public inspection unless specifically exempted. Government agencies must interpret the public records law broadly to favor disclosure.`,
      conditions: `Applies to all government agencies in ${jurisdictionName}. Exemptions must be narrowly construed.`,
      applies_to: "General public",
      implementation_notes: `Agencies should release records unless a specific exemption clearly applies. Doubtful cases should be resolved in favor of disclosure.`,
      request_tips: `In your request, cite the presumption of openness and note that exemptions must be narrowly construed. If denied, ask the agency to explain which specific exemption applies.`
    },

    // 2. Response Timeline Requirement (Timeliness Rights)
    {
      category: "Timeliness Rights",
      subcategory: "Response Deadline",
      statute_citation: `${stateCode} § 2.03`,
      description: `Agencies must respond to public records requests within a reasonable time period, typically defined by statute or court decisions. Initial acknowledgment and final response deadlines are established by law.`,
      conditions: `Statutory timelines may vary based on request complexity. Extensions may be permitted in certain circumstances.`,
      applies_to: "All requesters",
      implementation_notes: `Track response timelines carefully. If the agency misses deadlines, document this for any future appeals or litigation.`,
      request_tips: `In your request, ask for acknowledgment within the statutory timeframe and request an estimated completion date. If deadlines are missed, send a follow-up citing the statutory timeline requirement.`
    },

    // 3. Fee Limits (Fee Waiver)
    {
      category: "Fee Waiver",
      subcategory: "Fee Limitations",
      statute_citation: `${stateCode} § 3.05`,
      description: `${jurisdictionName} law limits fees that agencies may charge for public records. Agencies may charge only for actual costs of duplication and may not charge for staff time to review or redact records in most cases. Fee waivers are available when disclosure serves the public interest.`,
      conditions: `Fee waivers typically available for news media, researchers, and requests serving public interest. Agencies must itemize all fees charged.`,
      applies_to: "All requesters; waivers for media, researchers, public interest requests",
      implementation_notes: `Request an itemized fee estimate before the agency proceeds with processing. Challenge any fees that exceed statutory limits.`,
      request_tips: `Request a fee waiver if your request serves the public interest or you are affiliated with news media or educational institutions. State: 'I request a fee waiver under ${stateCode} § 3.05 as this request serves the public interest by [explain how disclosure benefits the public].'`
    },

    // 4. Electronic Format Rights (Technology Rights)
    {
      category: "Technology Rights",
      subcategory: "Electronic Format",
      statute_citation: `${stateCode} § 4.02`,
      description: `Requesters have the right to receive records in electronic format when the agency maintains records electronically. Agencies must provide records in the format requested if readily available in that format.`,
      conditions: `Agency must provide electronic records if maintained electronically and no additional programming is required.`,
      applies_to: "All requesters",
      implementation_notes: `Electronic delivery often reduces costs and expedites processing. Native file formats (Excel, Word) are preferable to PDFs for data analysis.`,
      request_tips: `Include in your request: 'I request all responsive records in electronic format, preferably in their native file format (Excel, Word, etc.) or as searchable PDFs. Electronic delivery via email or download link is preferred.'`
    },

    // 5. Inspection Rights (Inspection Rights)
    {
      category: "Inspection Rights",
      subcategory: "In-Person Inspection",
      statute_citation: `${stateCode} § 5.01`,
      description: `${jurisdictionName} law provides the right to inspect public records in person at the agency's office during regular business hours. This allows requesters to review records before deciding which to copy, potentially reducing costs.`,
      conditions: `Agency must make records available for inspection during regular business hours. May require reasonable advance notice.`,
      applies_to: "All requesters",
      implementation_notes: `For voluminous records, inspection before copying can save significant costs. Bring a device to photograph records if permitted.`,
      request_tips: `If requesting extensive records, include: 'I request the opportunity to inspect the responsive records at your office before determining which records I wish to receive in copy form. Please advise available times for inspection.'`
    },

    // 6. Segregability (Enhanced Access Rights)
    {
      category: "Enhanced Access Rights",
      subcategory: "Segregability Requirement",
      statute_citation: `${stateCode} § 6.04`,
      description: `When portions of a record are exempt from disclosure, the agency must redact only the exempt portions and release the remainder. Agencies cannot withhold entire documents when portions are releasable.`,
      conditions: `Mandatory requirement whenever records contain both exempt and non-exempt information.`,
      applies_to: "All requesters",
      implementation_notes: `The segregability requirement is not discretionary. Agencies must conduct a page-by-page, line-by-line review to release all non-exempt information.`,
      request_tips: `When records are redacted, respond: 'I request release of all reasonably segregable portions of any withheld records as required by ${stateCode} § 6.04. Please provide a detailed explanation for each redaction.'`
    },

    // 7. Written Denial Requirement (Enhanced Access Rights)
    {
      category: "Enhanced Access Rights",
      subcategory: "Written Denial with Justification",
      statute_citation: `${stateCode} § 7.02`,
      description: `Agencies must provide written denials that cite the specific statutory exemption and explain why it applies to each withheld record. Generic or conclusory denials are insufficient.`,
      conditions: `Required for all denials, whether full or partial. Must cite specific statutory authority.`,
      applies_to: "All requesters",
      implementation_notes: `Inadequate denial letters can be challenged in court. Denials should reference specific exemption provisions and explain application to particular records.`,
      request_tips: `If denied access, request a written explanation that cites the specific statutory exemption and explains how it applies to each withheld record. Generic denials citing broad categories are legally insufficient.`
    },

    // 8. Attorney Fee Recovery (Appeal Rights)
    {
      category: "Appeal Rights",
      subcategory: "Attorney Fee Recovery",
      statute_citation: `${stateCode} § 8.06`,
      description: `Courts may award attorney fees and litigation costs to requesters who prevail in lawsuits to compel disclosure. This provision encourages agencies to comply with the law and provides recourse for improperly denied requests.`,
      conditions: `Typically available when requester substantially prevails in litigation. Court has discretion based on circumstances.`,
      applies_to: "Requesters who file lawsuits and prevail",
      implementation_notes: `Fee awards are often available even when agencies release records after litigation commences. Document all agency violations for potential fee recovery.`,
      request_tips: `If considering legal action, consult an attorney about potential fee recovery under ${stateCode} § 8.06. Courts often award fees when agencies improperly withhold records or violate procedural requirements.`
    },

    // 9. No ID/Purpose Requirement (Requester-Specific Rights)
    {
      category: "Requester-Specific Rights",
      subcategory: "No Identity or Purpose Requirement",
      statute_citation: `${stateCode} § 9.01`,
      description: `${jurisdictionName} law does not require requesters to identify themselves beyond providing contact information for the agency's response, nor must requesters state the purpose of their request. The public records law is requester-blind.`,
      conditions: `No conditions - requests must be processed regardless of requester identity or purpose.`,
      applies_to: "All persons, including out-of-state residents and organizations",
      implementation_notes: `While contact information may be needed for the agency to respond, requesters need not provide extensive personal details or justify their interest.`,
      request_tips: `You are not required to explain why you want records or provide personal information beyond what is needed for the agency to respond. If an agency demands unnecessary information, cite this provision.`
    },

    // 10. No Residency Requirement (Requester-Specific Rights)
    {
      category: "Requester-Specific Rights",
      subcategory: "No Residency Restriction",
      statute_citation: `${stateCode} § 9.02`,
      description: `${jurisdictionName} public records law applies to all persons regardless of residency. Out-of-state residents, citizens of other countries, and organizations have the same rights as state residents.`,
      conditions: `No residency restrictions. Same rights apply to all requesters.`,
      applies_to: "All persons regardless of residency or citizenship",
      implementation_notes: `Some states historically imposed residency requirements, but most have eliminated these restrictions or courts have found them unconstitutional.`,
      request_tips: `If you are an out-of-state resident and the agency suggests this affects your rights, cite ${stateCode} § 9.02 and note that public records laws apply equally to all persons.`
    },

    // 11. Appeal Process (Appeal Rights)
    {
      category: "Appeal Rights",
      subcategory: "Administrative Appeal",
      statute_citation: `${stateCode} § 10.03`,
      description: `Requesters have the right to appeal denials to a higher authority within the agency or to an independent oversight body. The appeal process provides an opportunity to challenge improper denials before resorting to litigation.`,
      conditions: `Appeal deadlines and procedures vary by jurisdiction. Typically must exhaust administrative remedies before filing suit.`,
      applies_to: "All requesters who receive denials",
      implementation_notes: `File appeals promptly to preserve rights. Document all communications during the appeal process.`,
      request_tips: `If your request is denied, immediately file an administrative appeal citing ${stateCode} § 10.03. In your appeal, explain why the denial is improper and request a detailed reconsideration. Preserve your right to judicial review by exhausting administrative remedies.`
    },

    // 12. Public Records Officer/Coordinator (Proactive Disclosure)
    {
      category: "Proactive Disclosure",
      subcategory: "Public Records Officer",
      statute_citation: `${stateCode} § 11.01`,
      description: `Agencies must designate a public records officer or coordinator responsible for processing public records requests. Contact information for this officer must be publicly available.`,
      conditions: `Required for all agencies subject to public records law.`,
      applies_to: "General public seeking records",
      implementation_notes: `If you cannot identify the proper records officer, contact the agency's main office and ask for the designated public records coordinator.`,
      request_tips: `Direct your request to the agency's designated public records officer. If you cannot identify this person, call the agency and ask for contact information for the public records coordinator.`
    },

    // 13. Database/Electronic Records Access (Technology Rights)
    {
      category: "Technology Rights",
      subcategory: "Database Access",
      statute_citation: `${stateCode} § 12.04`,
      description: `When agencies maintain records in electronic databases, requesters may access the database records or request data in structured formats suitable for analysis. Agencies cannot refuse requests merely because they require database queries or electronic processing.`,
      conditions: `Agency must provide database records unless request requires creating new records or extensive programming. Structured formats must be provided if readily available.`,
      applies_to: "All requesters",
      implementation_notes: `Request data in machine-readable formats like CSV, JSON, or Excel. Agencies cannot charge excessive fees for electronic processing that simply exports existing data.`,
      request_tips: `For database records, request: 'Please provide responsive records from your database in a structured, machine-readable format such as CSV or Excel. I am requesting existing data fields and do not seek creation of new records or custom programming.'`
    },

    // 14. Redaction Requirements (Enhanced Access Rights)
    {
      category: "Enhanced Access Rights",
      subcategory: "Proper Redaction Standards",
      statute_citation: `${stateCode} § 13.05`,
      description: `When agencies redact portions of records, they must use proper redaction techniques that clearly indicate where information has been removed and cite the specific exemption for each redaction. Redactions must be limited to only the exempt information.`,
      conditions: `Applies to all redacted records. Agencies must provide redaction logs or explanations for significant redactions.`,
      applies_to: "All requesters receiving redacted records",
      implementation_notes: `Proper redactions show clearly where information has been removed and often include marginal notations citing the exemption. Excessive or unexplained redactions may be challengeable.`,
      request_tips: `If you receive heavily redacted records, request a detailed explanation: 'Please provide a redaction log identifying each redaction, the specific statutory exemption claimed, and an explanation of how the exemption applies to the redacted information.'`
    },

    // 15. Court Enforcement (Appeal Rights)
    {
      category: "Appeal Rights",
      subcategory: "Judicial Enforcement",
      statute_citation: `${stateCode} § 14.07`,
      description: `Requesters may seek judicial enforcement of public records rights through court action. Courts have authority to order disclosure, impose penalties on agencies for violations, and award attorney fees to prevailing requesters.`,
      conditions: `Typically must exhaust administrative remedies before filing suit. Statutory deadlines may apply for court actions.`,
      applies_to: "Requesters who have exhausted administrative appeals",
      implementation_notes: `Consult an attorney if considering litigation. Courts can impose significant penalties on agencies that willfully violate public records laws.`,
      request_tips: `If administrative appeals fail to produce records, consult an attorney about filing suit under ${stateCode} § 14.07. Document all agency violations, missed deadlines, and improper denials to support your case.`
    }
  ]
}

/**
 * Get realistic state code pattern for citations
 */
function getStateCodePattern(slug) {
  // Common state code patterns
  const codePatterns = {
    // States with "State Code" format
    'alabama': 'Ala. Code',
    'alaska': 'Alaska Stat.',
    'arizona': 'Ariz. Rev. Stat.',
    'arkansas': 'Ark. Code Ann.',
    'california': 'Cal. Gov. Code',
    'colorado': 'Colo. Rev. Stat.',
    'connecticut': 'Conn. Gen. Stat.',
    'delaware': 'Del. Code Ann.',
    'florida': 'Fla. Stat.',
    'georgia': 'Ga. Code Ann.',
    'hawaii': 'Haw. Rev. Stat.',
    'idaho': 'Idaho Code',
    'illinois': 'Ill. Comp. Stat.',
    'indiana': 'Ind. Code',
    'iowa': 'Iowa Code',
    'kansas': 'Kan. Stat. Ann.',
    'kentucky': 'Ky. Rev. Stat.',
    'louisiana': 'La. Rev. Stat.',
    'maine': 'Me. Rev. Stat.',
    'maryland': 'Md. Code Ann.',
    'massachusetts': 'Mass. Gen. Laws',
    'michigan': 'Mich. Comp. Laws',
    'minnesota': 'Minn. Stat.',
    'mississippi': 'Miss. Code Ann.',
    'missouri': 'Mo. Rev. Stat.',
    'montana': 'Mont. Code Ann.',
    'nebraska': 'Neb. Rev. Stat.',
    'nevada': 'Nev. Rev. Stat.',
    'new_hampshire': 'N.H. Rev. Stat.',
    'new_jersey': 'N.J. Stat. Ann.',
    'new_mexico': 'N.M. Stat. Ann.',
    'new_york': 'N.Y. Pub. Off. Law',
    'north_carolina': 'N.C. Gen. Stat.',
    'north_dakota': 'N.D. Cent. Code',
    'ohio': 'Ohio Rev. Code',
    'oklahoma': 'Okla. Stat.',
    'oregon': 'Or. Rev. Stat.',
    'pennsylvania': 'Pa. Stat.',
    'rhode_island': 'R.I. Gen. Laws',
    'south_carolina': 'S.C. Code Ann.',
    'south_dakota': 'S.D. Codified Laws',
    'tennessee': 'Tenn. Code Ann.',
    'texas': 'Tex. Gov. Code',
    'utah': 'Utah Code',
    'vermont': 'Vt. Stat. Ann.',
    'virginia': 'Va. Code Ann.',
    'washington': 'Wash. Rev. Code',
    'west_virginia': 'W. Va. Code',
    'wisconsin': 'Wis. Stat.',
    'wyoming': 'Wyo. Stat.',
    'district_of_columbia': 'D.C. Code'
  }

  return codePatterns[slug] || 'State Code'
}

/**
 * Generate validation metadata
 */
function generateValidationMetadata(jurisdictionName, jurisdictionSlug, rightsCount) {
  return {
    parsed_date: "2025-10-07",
    source_url: `https://www.placeholder-for-${jurisdictionSlug}-statutes.gov`,
    source_verified: false,
    primary_sources: [
      `${jurisdictionName} Public Records Law (official state code website)`,
      `${jurisdictionName} Attorney General FOIA guidance`,
      `${jurisdictionName} state legislature official website`
    ],
    verification_notes: `TEMPLATE GENERATED - These rights represent common patterns found across state public records laws but have NOT been verified against official ${jurisdictionName} statutes. All citations, descriptions, and request tips must be verified and updated from official .gov sources before use. This is a starting template only.`,
    rights_count: rightsCount,
    categories_covered: [
      "Proactive Disclosure",
      "Timeliness Rights",
      "Fee Waiver",
      "Technology Rights",
      "Inspection Rights",
      "Enhanced Access Rights",
      "Appeal Rights",
      "Requester-Specific Rights"
    ],
    template_version: "v0.12",
    requires_verification: true,
    verification_status: "UNVERIFIED TEMPLATE"
  }
}

/**
 * Generate complete rights JSON structure
 */
function generateRightsJSON(jurisdiction) {
  const rights = generateCoreRights(jurisdiction.name, jurisdiction.id)

  return {
    jurisdiction: {
      slug: jurisdiction.id,
      name: jurisdiction.name
    },
    rights_of_access: rights,
    validation_metadata: generateValidationMetadata(jurisdiction.name, jurisdiction.id, rights.length)
  }
}

/**
 * Main execution
 */
async function generateAllRightsTemplates() {
  const client = new Client({
    connectionString: DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  })

  try {
    console.log('\n🔍 Connecting to Neon database...')
    await client.connect()
    console.log('✅ Connected successfully')

    // Query jurisdictions with 0 rights
    const query = `
      SELECT
        j.id,
        j.name,
        COALESCE(COUNT(r.id), 0) as rights_count
      FROM jurisdictions j
      LEFT JOIN rights_of_access r ON r.jurisdiction_id = j.id
      GROUP BY j.id, j.name
      HAVING COALESCE(COUNT(r.id), 0) = 0
      ORDER BY j.name
    `

    console.log('\n📊 Querying jurisdictions with 0 rights...')
    const result = await client.query(query)

    console.log(`✅ Found ${result.rows.length} jurisdictions without rights data\n`)

    if (result.rows.length === 0) {
      console.log('✨ All jurisdictions already have rights data!')
      return
    }

    // Ensure output directory exists
    const outputDir = resolve(process.cwd(), 'data/v0.12/rights')
    if (!existsSync(outputDir)) {
      console.log(`📁 Creating directory: ${outputDir}`)
      await mkdir(outputDir, { recursive: true })
    }

    // Generate files for each jurisdiction
    let generatedCount = 0
    const errors = []

    console.log('📝 Generating rights template files...\n')

    for (const jurisdiction of result.rows) {
      try {
        const rightsData = generateRightsJSON(jurisdiction)
        const fileName = `${jurisdiction.id}-rights.json`
        const filePath = resolve(outputDir, fileName)

        await writeFile(
          filePath,
          JSON.stringify(rightsData, null, 2) + '\n',
          'utf-8'
        )

        generatedCount++
        console.log(`   ✓ ${jurisdiction.name.padEnd(25)} → ${fileName}`)

      } catch (error) {
        errors.push({
          jurisdiction: jurisdiction.name,
          error: error.message
        })
        console.error(`   ✗ ${jurisdiction.name}: ${error.message}`)
      }
    }

    // Summary
    console.log('\n' + '='.repeat(70))
    console.log('📊 GENERATION SUMMARY')
    console.log('='.repeat(70))
    console.log(`✅ Successfully generated: ${generatedCount} files`)
    console.log(`❌ Errors: ${errors.length}`)
    console.log(`📂 Output directory: ${outputDir}`)

    if (errors.length > 0) {
      console.log('\n❌ Errors encountered:')
      errors.forEach(e => {
        console.log(`   • ${e.jurisdiction}: ${e.error}`)
      })
    }

    console.log('\n' + '='.repeat(70))
    console.log('⚠️  IMPORTANT: VERIFICATION REQUIRED')
    console.log('='.repeat(70))
    console.log('These are TEMPLATE files with generic state code citations.')
    console.log('Before importing to database:')
    console.log('  1. Verify all statutory citations against official state codes')
    console.log('  2. Update descriptions to match actual state law language')
    console.log('  3. Confirm all 15 rights exist in each state\'s law')
    console.log('  4. Add/remove rights based on jurisdiction-specific provisions')
    console.log('  5. Update validation_metadata with actual source URLs')
    console.log('  6. Set source_verified = true only after verification')
    console.log('\nOnly use official .gov sources for verification!')
    console.log('='.repeat(70) + '\n')

    console.log('🎉 Template generation complete!')
    console.log('\n💡 Next steps:')
    console.log('   1. Review and verify generated templates')
    console.log('   2. Update with actual statutory citations')
    console.log('   3. Import verified files using: node dev/scripts/import-rights-neon.js')
    console.log()

  } catch (error) {
    console.error('\n❌ Error:', error.message)
    if (error.stack) {
      console.error('\nStack trace:')
      console.error(error.stack)
    }
    throw error
  } finally {
    await client.end()
    console.log('🔌 Database connection closed\n')
  }
}

// Execute
generateAllRightsTemplates().catch(error => {
  console.error('Fatal error:', error)
  process.exit(1)
})
