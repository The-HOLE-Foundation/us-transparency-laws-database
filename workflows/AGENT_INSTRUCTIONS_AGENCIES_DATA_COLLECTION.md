---
DATE: 2025-10-08
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Precise Agent Instructions for Agencies Data Collection
VERSION: v0.12
DOCUMENT_TYPE: Agent Task Definition
---

# AGENT INSTRUCTIONS: State Agencies Data Collection

## CRITICAL: Read This First

**THIS DOCUMENT DEFINES EXACTLY WHAT TO COLLECT - DO NOT DEVIATE**

You are NOT collecting:
- ❌ All state agencies
- ❌ Local governments (cities, counties, townships)
- ❌ School districts
- ❌ Water authorities, utility districts
- ❌ Special districts
- ❌ Semi-autonomous boards
- ❌ Every commission or committee

You ARE collecting:
- ✅ EXACTLY 15-25 major state agencies per jurisdiction
- ✅ Only agencies listed in the "REQUIRED AGENCIES" section below
- ✅ Nothing more, nothing less

## Your Task Assignment

**Jurisdiction**: [STATE NAME WILL BE PROVIDED]

**Deliverable**: ONE JSON file containing ONLY the agencies listed below

**Time Estimate**: 3-4 hours

**Output File**: `data/states/{state-slug}/agencies.json`

## REQUIRED AGENCIES - COLLECT EXACTLY THESE

### Category 1: EXECUTIVE BRANCH - Constitutional Officers (ALWAYS REQUIRED)

**1. GOVERNOR**
   - Official title (e.g., "Governor", "Governor and Commander-in-Chief")
   - Current officeholder name
   - Party affiliation
   - Date assumed office (inauguration date)
   - Term ends (CRITICAL - calculate from election date + term length)
   - Term length in years (usually 4)
   - Next election date
   - Main website (governor's office official site)
   - Primary contact: email or web form URL
   - Phone number
   - Mailing address

**2. LIEUTENANT GOVERNOR** (if exists in this state)
   - Same fields as Governor
   - Note: Some states don't have Lt. Governor (e.g., Arizona, Maine)
   - If not present, note: "No Lieutenant Governor position in this state"

### Category 2: INDEPENDENT ELECTED OFFICIALS (COLLECT IF EXISTS)

**3. ATTORNEY GENERAL**
   - Official title
   - Current officeholder name
   - Party (if elected) or appointment type
   - Date assumed office
   - Term ends
   - SPECIAL FIELD: "FOIA Appeals Authority" (yes/no)
   - SPECIAL FIELD: "Open Meetings Enforcement" (yes/no)
   - Website
   - FOIA-specific email (often publicrecords@ag.state.gov or similar)
   - General contact email
   - Phone
   - FOIA portal URL (if exists)

**4. SECRETARY OF STATE** (if independent elected official)
   - Same fields as AG
   - Primary function: elections, business filings, or other
   - If appointed by Governor, note under Executive Branch instead

**5. STATE TREASURER or COMPTROLLER** (if exists)
   - Same fields as above
   - Title varies: "Treasurer", "Comptroller", "Comptroller of Public Accounts"

**6. STATE AUDITOR** (if independent)
   - Same fields
   - Note if appointed vs. elected

### Category 3: MAJOR EXECUTIVE AGENCIES (EXACTLY 12 MAXIMUM)

**Collect ONLY these types of agencies (in priority order):**

**TIER 1 - ALWAYS COLLECT** (if exists):
1. **Department of Transportation**
   - Handles: highways, roads, DMV/motor vehicles
   - Common names: DOT, TXDOT, CalTrans, etc.

2. **Department of Education** or **State Board of Education**
   - Handles: K-12 public education oversight
   - Common names: State Education Agency, Dept of Public Instruction

3. **Department of Health** or **Department of Health and Human Services**
   - Handles: public health, Medicaid, social services
   - Common names: HHS, Health Dept, DHHS

4. **Department of Public Safety** or **State Police**
   - Handles: law enforcement, highway patrol, emergency management
   - Common names: DPS, State Police, Highway Patrol

5. **Department of Environmental Quality/Conservation**
   - Handles: environmental protection, pollution control
   - Common names: DEQ, TCEQ (Texas), CalEPA

**TIER 2 - COLLECT IF PRESENT** (next priority):
6. **Department of Revenue** or **Tax Commission**
   - Handles: tax collection, revenue

7. **Department of Labor** or **Workforce Commission**
   - Handles: employment, unemployment, labor relations

8. **Department of Agriculture**
   - Handles: farming, food safety, rural development

9. **Department of Corrections** or **Department of Criminal Justice**
   - Handles: prisons, parole, probation

10. **Department of Motor Vehicles** (if separate from DOT)
    - Handles: driver licensing, vehicle registration

**TIER 3 - COLLECT IF SPACE REMAINING** (to reach ~12 total):
11. **Department of Natural Resources**
12. **Department of Commerce** or **Economic Development**
13. **Department of Insurance** or **Financial Regulation**
14. **Department of Housing** or **Community Development**

**STOP AT 12 EXECUTIVE AGENCIES** - Do not collect more

### Category 4: LEGISLATIVE BRANCH (ALWAYS REQUIRED)

**7. UPPER CHAMBER** (Senate in most states)
   - Official name (e.g., "Texas Senate", "California State Senate")
   - Presiding officer title (e.g., "President of the Senate", often Lt. Governor)
   - Presiding officer name
   - **RECORDS OFFICER**: Title (e.g., "Secretary of the Senate", "Senate Clerk")
   - Records officer contact: email, phone
   - Senate website
   - FOIA/records request portal (if exists)

**8. LOWER CHAMBER** (House of Representatives, Assembly, etc.)
   - Official name
   - Presiding officer title (e.g., "Speaker of the House")
   - Presiding officer name
   - **RECORDS OFFICER**: Title (e.g., "Chief Clerk", "Clerk of the House")
   - Records officer contact: email, phone
   - House/Assembly website
   - FOIA/records request portal

### Category 5: JUDICIAL BRANCH (REQUIRED)

**9. HIGHEST COURT** (Supreme Court or Court of Appeals)
   - Official name (e.g., "Texas Supreme Court", "New York Court of Appeals")
   - Chief Justice name
   - **CLERK OF THE COURT** (for records requests)
   - Clerk contact: email, phone
   - Court website
   - Public records/FOIA portal

**OPTIONAL**: Court of Criminal Appeals (if separate from Supreme Court, e.g., Texas, Oklahoma)

**10. INTERMEDIATE APPELLATE COURTS** (if exists, collect just ONE regional example)
   - Do NOT collect all appellate districts
   - Just note: "State has [X] appellate court districts"
   - Provide contact for state court administrative office if available

## DATA COLLECTION PROCEDURE

### Step 1: Start with State's Main Portal

**URL Pattern**: `https://{state}.gov` or `https://www.{state}.gov`

Example: https://texas.gov, https://www.ca.gov, https://www.illinois.gov

**Find**: "Agencies" or "State Government" directory

### Step 2: Identify Elected Officials

**Look for**:
- "Elected Officials" page
- "State Government" > "Executive Branch"
- "About [State]" > "Leadership"

**Collect**:
- Current officeholder names
- Election dates (for term calculation)
- Contact information

### Step 3: Identify Major Agencies

**Use state's official agency directory**

**Look for**:
- Cabinet-level departments
- Agencies with large budgets
- Agencies mentioned in state constitution
- Multi-function agencies (health, education, transportation)

**For EACH agency on the REQUIRED list**:

1. **Find Official Website**
   - Navigate to agency site
   - Verify it's .gov domain
   - Record exact URL

2. **Find Agency Head**
   - Look for "About" > "Leadership"
   - Record: title, name, appointment type
   - Try to find appointment date
   - Calculate/estimate term end if applicable

3. **Find Contact Information**
   - Look for "Contact Us" page
   - Primary email (general inquiries)
   - Public Information Officer email (if different)
   - Main phone number
   - Mailing address

4. **Find FOIA Portal** (if exists)
   - Look for "Public Records", "Open Records", "FOIA"
   - Record URL to request portal
   - Record dedicated FOIA email if available

5. **Record Verification Metadata**
   - Today's date as verification date
   - URL where you found this information
   - Any notes about data quality

### Step 4: Structure the Data

**Create JSON file** following this EXACT template:

```json
{
  "jurisdiction": {
    "slug": "texas",
    "name": "Texas"
  },

  "government_structure": {
    "executive_branch": {
      "chief_executive": {
        "title": "Governor",
        "current_officeholder": {
          "name": "Greg Abbott",
          "party": "Republican",
          "assumed_office": "2015-01-20",
          "term_ends": "2027-01-20"
        },
        "term_info": {
          "length_years": 4,
          "term_limits": "None",
          "next_election": "2026-11-03"
        },
        "contact": {
          "website": "https://gov.texas.gov",
          "primary_contact_method": "web_form",
          "email": null,
          "phone": "512-463-2000",
          "mailing_address": {
            "street": "P.O. Box 12428",
            "city": "Austin",
            "state": "TX",
            "zip": "78711"
          }
        }
      },

      "major_agencies": [
        {
          "agency_name": "Texas Department of Transportation",
          "agency_abbreviation": "TxDOT",
          "primary_function": "Transportation infrastructure, highways, motor vehicle regulation",

          "agency_head": {
            "title": "Executive Director",
            "current_officeholder": {
              "name": "Marc Williams",
              "assumed_office": "2023-01-15",
              "appointment_type": "gubernatorial_appointment"
            }
          },

          "contact": {
            "website": "https://www.txdot.gov",
            "primary_contact_method": "email",
            "email": "pio@txdot.gov",
            "phone": "512-463-8700",
            "fax": null,
            "mailing_address": {
              "street": "125 E. 11th Street",
              "city": "Austin",
              "state": "TX",
              "zip": "78701"
            },
            "foia_portal": "https://www.txdot.gov/open-records",
            "contact_verified_date": "2025-10-08",
            "contact_verification_source": "https://www.txdot.gov/contact"
          },

          "foia_officer": {
            "name": "Jane Smith",
            "title": "Public Information Officer",
            "email": "pio@txdot.gov",
            "phone": "512-463-8700"
          }
        }
      ]
    },

    "independent_agencies": [
      {
        "agency_name": "Office of the Attorney General",
        "agency_abbreviation": "OAG",
        "agency_type": "elected_official",
        "primary_function": "Legal representation of state, consumer protection, FOIA appeals",

        "current_head": {
          "title": "Attorney General",
          "current_officeholder": {
            "name": "Ken Paxton",
            "party": "Republican",
            "assumed_office": "2015-01-05",
            "term_ends": "2027-01-05"
          },
          "term_info": {
            "length_years": 4,
            "next_election": "2026-11-03"
          },
          "contact": {
            "website": "https://www.texasattorneygeneral.gov",
            "primary_contact_method": "email",
            "email": "publicinfo@oag.texas.gov",
            "phone": "512-463-2100"
          }
        },

        "contact": {
          "website": "https://www.texasattorneygeneral.gov",
          "primary_contact_method": "email",
          "email": "publicinfo@oag.texas.gov",
          "phone": "512-463-2100",
          "foia_portal": "https://www.texasattorneygeneral.gov/open-government/public-information-act"
        },

        "special_roles": [
          "FOIA appeals authority",
          "Open meetings law enforcement",
          "Public Information Act rulings"
        ]
      }
    ],

    "legislative_branch": {
      "upper_chamber": {
        "chamber_name": "Texas Senate",
        "presiding_officer": {
          "title": "Lieutenant Governor / President of the Senate",
          "name": "Dan Patrick",
          "party": "Republican",
          "term_ends": "2027-01-20"
        },
        "contact": {
          "website": "https://www.senate.texas.gov",
          "primary_contact_method": "email",
          "email": "webmaster@senate.texas.gov",
          "phone": "512-463-0100"
        },
        "clerk_office": {
          "title": "Secretary of the Senate",
          "name": "[Name if available]",
          "contact": {
            "email": "records@senate.texas.gov",
            "phone": "512-463-0100"
          }
        }
      },

      "lower_chamber": {
        "chamber_name": "Texas House of Representatives",
        "presiding_officer": {
          "title": "Speaker of the House",
          "name": "Dade Phelan",
          "party": "Republican"
        },
        "contact": {
          "website": "https://www.house.texas.gov",
          "primary_contact_method": "email",
          "phone": "512-463-1000"
        },
        "clerk_office": {
          "title": "Chief Clerk of the House",
          "contact": {
            "email": "records@house.texas.gov",
            "phone": "512-463-1000"
          }
        }
      }
    },

    "judicial_branch": {
      "highest_court": {
        "court_name": "Texas Supreme Court",
        "jurisdiction_type": "Civil appeals",
        "chief_justice": {
          "name": "Nathan Hecht",
          "assumed_office": "2014-10-01"
        },
        "contact": {
          "website": "https://www.txcourts.gov/supreme",
          "primary_contact_method": "email",
          "phone": "512-463-1312"
        },
        "clerk_office": {
          "title": "Clerk of the Supreme Court",
          "contact": {
            "email": "supreme.clerk@txcourts.gov",
            "phone": "512-463-1312"
          }
        }
      },

      "intermediate_appellate": {
        "note": "Texas has 14 Courts of Appeals organized by district",
        "contact_central": "https://www.txcourts.gov/courts-of-appeals"
      }
    }
  },

  "metadata": {
    "created_date": "2025-10-08",
    "created_by": "[Your Name or Agent ID]",
    "valid_as_of": "2025-10-08",
    "last_verified": "2025-10-08",
    "verification_source": "https://texas.gov/agencies, individual agency websites",
    "next_verification_due": "2026-01-08",
    "maintenance_protocol": "Verify after each general election (Nov even years). Check agency heads quarterly. Verify contact info semi-annually."
  }
}
```

## QUALITY CHECKLIST

Before submitting, verify:

- [ ] **SCOPE**: Collected ONLY 15-25 agencies (not all state agencies)
- [ ] **REQUIRED AGENCIES**: All required categories present
- [ ] **NO LOCAL GOVERNMENTS**: No cities, counties, school districts
- [ ] **OFFICIAL SOURCES**: All URLs are .gov domains
- [ ] **CURRENT DATA**: Verified current as of today
- [ ] **CONTACT INFO**: Email or web form for each agency
- [ ] **FOIA PORTALS**: Recorded where available
- [ ] **TERM DATES**: Recorded for all elected officials
- [ ] **METADATA**: All metadata fields complete
- [ ] **SOURCES**: Verification sources documented
- [ ] **JSON VALID**: File passes JSON validation

## COMMON MISTAKES TO AVOID

**❌ WRONG**: "I collected all 150 state agencies"
**✅ RIGHT**: "I collected the required 18 major agencies as specified"

**❌ WRONG**: "I included county sheriffs and city police departments"
**✅ RIGHT**: "I only included state-level Department of Public Safety"

**❌ WRONG**: "I collected all 254 school districts in Texas"
**✅ RIGHT**: "I only included Texas Education Agency (state oversight)"

**❌ WRONG**: "I found a Wikipedia page with agency info"
**✅ RIGHT**: "I used official .gov websites only"

**❌ WRONG**: "I couldn't find agency head name so I left it blank"
**✅ RIGHT**: "I searched the agency's 'About' and 'Leadership' pages thoroughly"

**❌ WRONG**: "Contact info verification source: N/A"
**✅ RIGHT**: "Contact verification source: https://agency.state.gov/contact (verified 2025-10-08)"

## IF YOU CANNOT FIND INFORMATION

**If agency doesn't exist in this state**:
```json
{
  "note": "This state does not have a Department of [X]. Function handled by [Y] instead."
}
```

**If current officeholder not found**:
- Note: "Current officeholder not listed on official website as of [date]"
- Check recent news for appointment/election
- Check state's official roster if available

**If contact info not available**:
- Try agency's main website > "Contact Us"
- Try state directory > agency listing
- Last resort: Note "Contact info not publicly available, use main state portal"

## ESTIMATED TIME BREAKDOWN

- Research state portal structure: 15 minutes
- Collect executive branch data: 45 minutes
- Collect agencies data (12 agencies × 10 min each): 2 hours
- Collect legislative/judicial data: 30 minutes
- Structure JSON and verify: 30 minutes
- **TOTAL: 4 hours maximum**

If taking longer than 4 hours, you may be collecting too much detail or too many agencies.

## DELIVERABLE

**Submit ONE file**:
- Path: `data/states/{state-slug}/agencies.json`
- Format: Valid JSON
- Schema: Matches v0.12-agencies-simplified-schema.json
- Verified: All data from official .gov sources
- Complete: All required fields present

## SUPPORT

If stuck or unclear:
- Review: `workflows/v0.12-AGENCIES_SIMPLIFIED_WORKFLOW.md`
- Check: `schemas/v0.12-agencies-simplified-schema.json`
- Example: `data/states/texas/agencies.json` (reference implementation)
- Ask: Clarify specific ambiguity before proceeding

---

**REMEMBER**: The goal is PRACTICAL and MAINTAINABLE data for FOIA request routing, NOT comprehensive government cataloging.

**Quality over quantity. Accuracy over completeness. Maintainability over exhaustiveness.**
