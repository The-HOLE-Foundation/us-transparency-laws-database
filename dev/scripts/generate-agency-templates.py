#!/usr/bin/env python3
"""
Generate Standardized Agency Templates for All 52 Jurisdictions

Creates consistent JSON templates with clear placeholder markers.
Sub-agents will ONLY fill in bracketed placeholders, not modify structure.

Output: data/states/{state}/agencies-TEMPLATE.json (52 files)
"""

import json
from pathlib import Path
from datetime import datetime

# All 52 jurisdictions
JURISDICTIONS = [
    # Federal
    {"slug": "federal", "name": "Federal"},
    # States
    {"slug": "alabama", "name": "Alabama"},
    {"slug": "alaska", "name": "Alaska"},
    {"slug": "arizona", "name": "Arizona"},
    {"slug": "arkansas", "name": "Arkansas"},
    {"slug": "california", "name": "California"},
    {"slug": "colorado", "name": "Colorado"},
    {"slug": "connecticut", "name": "Connecticut"},
    {"slug": "delaware", "name": "Delaware"},
    {"slug": "florida", "name": "Florida"},
    {"slug": "georgia", "name": "Georgia"},
    {"slug": "hawaii", "name": "Hawaii"},
    {"slug": "idaho", "name": "Idaho"},
    {"slug": "illinois", "name": "Illinois"},
    {"slug": "indiana", "name": "Indiana"},
    {"slug": "iowa", "name": "Iowa"},
    {"slug": "kansas", "name": "Kansas"},
    {"slug": "kentucky", "name": "Kentucky"},
    {"slug": "louisiana", "name": "Louisiana"},
    {"slug": "maine", "name": "Maine"},
    {"slug": "maryland", "name": "Maryland"},
    {"slug": "massachusetts", "name": "Massachusetts"},
    {"slug": "michigan", "name": "Michigan"},
    {"slug": "minnesota", "name": "Minnesota"},
    {"slug": "mississippi", "name": "Mississippi"},
    {"slug": "missouri", "name": "Missouri"},
    {"slug": "montana", "name": "Montana"},
    {"slug": "nebraska", "name": "Nebraska"},
    {"slug": "nevada", "name": "Nevada"},
    {"slug": "new-hampshire", "name": "New Hampshire"},
    {"slug": "new-jersey", "name": "New Jersey"},
    {"slug": "new-mexico", "name": "New Mexico"},
    {"slug": "new-york", "name": "New York"},
    {"slug": "north-carolina", "name": "North Carolina"},
    {"slug": "north-dakota", "name": "North Dakota"},
    {"slug": "ohio", "name": "Ohio"},
    {"slug": "oklahoma", "name": "Oklahoma"},
    {"slug": "oregon", "name": "Oregon"},
    {"slug": "pennsylvania", "name": "Pennsylvania"},
    {"slug": "rhode-island", "name": "Rhode Island"},
    {"slug": "south-carolina", "name": "South Carolina"},
    {"slug": "south-dakota", "name": "South Dakota"},
    {"slug": "tennessee", "name": "Tennessee"},
    {"slug": "texas", "name": "Texas"},
    {"slug": "utah", "name": "Utah"},
    {"slug": "vermont", "name": "Vermont"},
    {"slug": "virginia", "name": "Virginia"},
    {"slug": "washington", "name": "Washington"},
    {"slug": "west-virginia", "name": "West Virginia"},
    {"slug": "wisconsin", "name": "Wisconsin"},
    {"slug": "wyoming", "name": "Wyoming"},
    {"slug": "district-of-columbia", "name": "District of Columbia"},
]

def create_agency_template(jurisdiction_slug: str, jurisdiction_name: str) -> dict:
    """Create standardized template with clear placeholders"""

    return {
        "_TEMPLATE_VERSION": "v0.12",
        "_TEMPLATE_STATUS": "UNVERIFIED - ALL BRACKETED VALUES MUST BE REPLACED WITH VERIFIED DATA",
        "_INSTRUCTIONS": "Replace all [BRACKETED] placeholders with verified data from official .gov sources. Do NOT modify structure. Do NOT add/remove fields.",
        "_VERIFICATION_REQUIRED": True,
        "_SCHEMA_VERSION": "v0.12-agencies-simplified-schema.json",

        "jurisdiction": {
            "slug": jurisdiction_slug,
            "name": jurisdiction_name
        },

        "government_structure": {
            "executive_branch": {
                "chief_executive": {
                    "title": "[TITLE - e.g., Governor, President, Mayor]",
                    "current_officeholder": {
                        "name": "[FULL NAME]",
                        "party": "[PARTY or 'Nonpartisan' or 'N/A']",
                        "assumed_office": "[YYYY-MM-DD]",
                        "term_ends": "[YYYY-MM-DD]"
                    },
                    "term_info": {
                        "length_years": "[NUMBER - usually 4]",
                        "term_limits": "[TEXT - e.g., 'Two terms', 'None', 'N/A']",
                        "next_election": "[YYYY-MM-DD]"
                    },
                    "contact": {
                        "website": "[https://OFFICIAL.GOV]",
                        "primary_contact_method": "[email|phone|web_form|mail]",
                        "email": "[EMAIL@DOMAIN.GOV or null if web form only]",
                        "phone": "[XXX-XXX-XXXX]",
                        "fax": "[XXX-XXX-XXXX or null]",
                        "mailing_address": {
                            "street": "[STREET ADDRESS]",
                            "city": "[CITY]",
                            "state": "[STATE ABBR]",
                            "zip": "[ZIPCODE]"
                        }
                    }
                },

                "major_agencies": [
                    {
                        "_AGENCY_NUMBER": 1,
                        "_REQUIRED": "Department of Transportation or equivalent",
                        "agency_name": "[FULL OFFICIAL NAME - e.g., Texas Department of Transportation]",
                        "agency_abbreviation": "[ABBR - e.g., TxDOT, CalTrans, DOT]",
                        "primary_function": "[BRIEF DESCRIPTION - e.g., Transportation infrastructure, highways, motor vehicles]",

                        "agency_head": {
                            "title": "[TITLE - e.g., Director, Commissioner, Secretary]",
                            "current_officeholder": {
                                "name": "[FULL NAME or 'Vacant' or 'Not Listed']",
                                "assumed_office": "[YYYY-MM-DD or 'Unknown']",
                                "term_ends": "[YYYY-MM-DD or 'Unknown' or 'N/A for career position']",
                                "appointment_type": "[gubernatorial_appointment|elected|board_appointed|career_position]"
                            }
                        },

                        "contact": {
                            "website": "[https://AGENCY.STATE.GOV]",
                            "primary_contact_method": "[email|phone|web_form]",
                            "email": "[EMAIL@AGENCY.GOV or null]",
                            "phone": "[XXX-XXX-XXXX]",
                            "fax": "[XXX-XXX-XXXX or null]",
                            "mailing_address": {
                                "street": "[STREET]",
                                "city": "[CITY]",
                                "state": "[ST]",
                                "zip": "[ZIP]"
                            },
                            "foia_portal": "[https://AGENCY.GOV/FOIA or null]",
                            "contact_verified_date": "[YYYY-MM-DD - date you verified this]",
                            "contact_verification_source": "[URL where you found contact info]"
                        },

                        "foia_officer": {
                            "name": "[NAME or 'Not Designated' or 'See general contact']",
                            "title": "[TITLE - e.g., Public Information Officer, Records Officer]",
                            "email": "[FOIA-SPECIFIC EMAIL or null]",
                            "phone": "[XXX-XXX-XXXX or null]"
                        }
                    },
                    {
                        "_AGENCY_NUMBER": 2,
                        "_REQUIRED": "Department of Education or equivalent",
                        "agency_name": "[OFFICIAL NAME]",
                        "agency_abbreviation": "[ABBR]",
                        "primary_function": "[K-12 education oversight, curriculum, etc.]",
                        "agency_head": {"title": "[TITLE]", "current_officeholder": {"name": "[NAME]", "assumed_office": "[DATE]", "appointment_type": "[TYPE]"}},
                        "contact": {"website": "[URL]", "primary_contact_method": "[METHOD]", "email": "[EMAIL]", "phone": "[PHONE]", "foia_portal": "[URL or null]", "contact_verified_date": "[DATE]", "contact_verification_source": "[URL]"},
                        "foia_officer": {"name": "[NAME or 'See general contact']", "title": "[TITLE]", "email": "[EMAIL or null]", "phone": "[PHONE or null]"}
                    },
                    {
                        "_AGENCY_NUMBER": 3,
                        "_REQUIRED": "Department of Health or Health and Human Services",
                        "agency_name": "[OFFICIAL NAME]",
                        "agency_abbreviation": "[ABBR]",
                        "primary_function": "[Public health, Medicaid, social services]",
                        "agency_head": {"title": "[TITLE]", "current_officeholder": {"name": "[NAME]", "assumed_office": "[DATE]", "appointment_type": "[TYPE]"}},
                        "contact": {"website": "[URL]", "primary_contact_method": "[METHOD]", "email": "[EMAIL]", "phone": "[PHONE]", "foia_portal": "[URL or null]", "contact_verified_date": "[DATE]", "contact_verification_source": "[URL]"},
                        "foia_officer": {"name": "[NAME or 'See general contact']", "title": "[TITLE]", "email": "[EMAIL or null]", "phone": "[PHONE or null]"}
                    },
                    {
                        "_AGENCY_NUMBER": 4,
                        "_REQUIRED": "Department of Public Safety, State Police, or Highway Patrol",
                        "agency_name": "[OFFICIAL NAME]",
                        "agency_abbreviation": "[ABBR]",
                        "primary_function": "[Law enforcement, emergency management, highway patrol]",
                        "agency_head": {"title": "[TITLE]", "current_officeholder": {"name": "[NAME]", "assumed_office": "[DATE]", "appointment_type": "[TYPE]"}},
                        "contact": {"website": "[URL]", "primary_contact_method": "[METHOD]", "email": "[EMAIL]", "phone": "[PHONE]", "foia_portal": "[URL or null]", "contact_verified_date": "[DATE]", "contact_verification_source": "[URL]"},
                        "foia_officer": {"name": "[NAME or 'See general contact']", "title": "[TITLE]", "email": "[EMAIL or null]", "phone": "[PHONE or null]"}
                    },
                    {
                        "_AGENCY_NUMBER": 5,
                        "_REQUIRED": "Department of Environmental Quality/Conservation",
                        "agency_name": "[OFFICIAL NAME or 'Not a separate agency in this state']",
                        "agency_abbreviation": "[ABBR or N/A]",
                        "primary_function": "[Environmental protection, pollution control]",
                        "agency_head": {"title": "[TITLE]", "current_officeholder": {"name": "[NAME]", "assumed_office": "[DATE]", "appointment_type": "[TYPE]"}},
                        "contact": {"website": "[URL]", "primary_contact_method": "[METHOD]", "email": "[EMAIL]", "phone": "[PHONE]", "foia_portal": "[URL or null]", "contact_verified_date": "[DATE]", "contact_verification_source": "[URL]"},
                        "foia_officer": {"name": "[NAME or 'See general contact']", "title": "[TITLE]", "email": "[EMAIL or null]", "phone": "[PHONE or null]"}
                    },
                    {
                        "_AGENCY_NUMBER": 6,
                        "_OPTIONAL": "Department of Revenue or Tax Commission - include if exists",
                        "agency_name": "[OFFICIAL NAME or DELETE THIS ENTRY if doesn't exist]",
                        "agency_abbreviation": "[ABBR]",
                        "primary_function": "[Tax collection, revenue administration]",
                        "agency_head": {"title": "[TITLE]", "current_officeholder": {"name": "[NAME]", "assumed_office": "[DATE]", "appointment_type": "[TYPE]"}},
                        "contact": {"website": "[URL]", "primary_contact_method": "[METHOD]", "email": "[EMAIL]", "phone": "[PHONE]", "foia_portal": "[URL or null]", "contact_verified_date": "[DATE]", "contact_verification_source": "[URL]"},
                        "foia_officer": {"name": "[NAME or 'See general contact']", "title": "[TITLE]", "email": "[EMAIL or null]", "phone": "[PHONE or null]"}
                    },
                    {
                        "_NOTE": "ADD 6-7 MORE AGENCIES following same template (Agriculture, Corrections, Labor, Natural Resources, etc.)",
                        "_STOP_AT": "12 agencies maximum"
                    }
                ]
            },

            "independent_agencies": [
                {
                    "_REQUIRED": "Attorney General (if independent elected official or separate office)",
                    "agency_name": "[Office of the Attorney General or equivalent]",
                    "agency_abbreviation": "[OAG, AG, etc.]",
                    "agency_type": "[elected_official|independent_agency|oversight_body]",
                    "primary_function": "[Legal representation, consumer protection, FOIA oversight]",

                    "current_head": {
                        "title": "[Attorney General]",
                        "current_officeholder": {
                            "name": "[FULL NAME]",
                            "party": "[PARTY or N/A]",
                            "assumed_office": "[YYYY-MM-DD]",
                            "term_ends": "[YYYY-MM-DD]"
                        },
                        "term_info": {
                            "length_years": "[NUMBER]",
                            "term_limits": "[TEXT]",
                            "next_election": "[YYYY-MM-DD]"
                        },
                        "contact": {
                            "website": "[https://AG.STATE.GOV]",
                            "primary_contact_method": "[METHOD]",
                            "email": "[EMAIL]",
                            "phone": "[PHONE]"
                        }
                    },

                    "contact": {
                        "website": "[https://AG.STATE.GOV]",
                        "primary_contact_method": "[email|web_form]",
                        "email": "[publicrecords@ag or similar]",
                        "phone": "[PHONE]",
                        "foia_portal": "[URL or null]"
                    },

                    "special_roles": [
                        "[FOIA appeals authority - YES or NO]",
                        "[Open meetings enforcement - YES or NO]",
                        "[Public records rulings - YES or NO]"
                    ]
                },
                {
                    "_OPTIONAL": "Secretary of State (if independent)",
                    "agency_name": "[Office of the Secretary of State or DELETE if doesn't exist]",
                    "agency_abbreviation": "[SOS]",
                    "agency_type": "[elected_official or DELETE]",
                    "primary_function": "[Elections, business filings]",
                    "current_head": {"title": "[Secretary of State]", "current_officeholder": {"name": "[NAME]", "party": "[PARTY]", "assumed_office": "[DATE]", "term_ends": "[DATE]"}, "term_info": {"length_years": "[N]", "next_election": "[DATE]"}, "contact": {"website": "[URL]", "primary_contact_method": "[METHOD]", "email": "[EMAIL]", "phone": "[PHONE]"}},
                    "contact": {"website": "[URL]", "primary_contact_method": "[METHOD]", "email": "[EMAIL]", "phone": "[PHONE]"},
                    "special_roles": []
                },
                {
                    "_NOTE": "Add Treasurer, Comptroller, Auditor if independent elected officials"
                }
            ],

            "legislative_branch": {
                "upper_chamber": {
                    "chamber_name": "[STATE] Senate or [NAME]",
                    "presiding_officer": {
                        "title": "[President of the Senate, Lieutenant Governor, etc.]",
                        "name": "[FULL NAME]",
                        "party": "[PARTY or Nonpartisan]",
                        "term_ends": "[YYYY-MM-DD]"
                    },
                    "contact": {
                        "website": "[https://SENATE.STATE.GOV]",
                        "primary_contact_method": "[METHOD]",
                        "email": "[EMAIL or null]",
                        "phone": "[PHONE]"
                    },
                    "clerk_office": {
                        "title": "[Secretary of the Senate, Senate Clerk, etc.]",
                        "name": "[NAME if available]",
                        "contact": {
                            "email": "[RECORDS EMAIL]",
                            "phone": "[PHONE]"
                        }
                    }
                },

                "lower_chamber": {
                    "chamber_name": "[STATE] House of Representatives or Assembly or [NAME]",
                    "presiding_officer": {
                        "title": "[Speaker of the House, Speaker, etc.]",
                        "name": "[FULL NAME]",
                        "party": "[PARTY]"
                    },
                    "contact": {
                        "website": "[https://HOUSE.STATE.GOV]",
                        "primary_contact_method": "[METHOD]",
                        "email": "[EMAIL or null]",
                        "phone": "[PHONE]"
                    },
                    "clerk_office": {
                        "title": "[Chief Clerk, Clerk of the House, etc.]",
                        "name": "[NAME if available]",
                        "contact": {
                            "email": "[RECORDS EMAIL]",
                            "phone": "[PHONE]"
                        }
                    }
                }
            },

            "judicial_branch": {
                "highest_court": {
                    "court_name": "[STATE] Supreme Court or Court of Appeals or [OFFICIAL NAME]",
                    "jurisdiction_type": "[Civil, Criminal, Both, or specific description]",
                    "chief_justice": {
                        "name": "[FULL NAME]",
                        "assumed_office": "[YYYY-MM-DD]",
                        "term_ends": "[YYYY-MM-DD or 'Life tenure' or 'Mandatory retirement age XX']"
                    },
                    "contact": {
                        "website": "[https://COURTS.STATE.GOV]",
                        "primary_contact_method": "[METHOD]",
                        "phone": "[PHONE]"
                    },
                    "clerk_office": {
                        "title": "[Clerk of the Supreme Court]",
                        "contact": {
                            "email": "[CLERK EMAIL for records requests]",
                            "phone": "[PHONE]"
                        }
                    }
                },

                "intermediate_appellate": {
                    "note": "[STATE] has [NUMBER] appellate court districts/divisions or 'No intermediate appellate courts'",
                    "contact_central": "[URL to court system main page or specific appellate division]"
                }
            }
        },

        "metadata": {
            "created_date": datetime.now().strftime("%Y-%m-%d"),
            "created_by": "[RESEARCHER NAME or AGENT ID - REPLACE THIS]",
            "valid_as_of": "[YYYY-MM-DD - date you verified data is current]",
            "last_verified": "[YYYY-MM-DD - same as valid_as_of for initial entry]",
            "verification_source": "[List main .gov URLs used: state portal, AG site, etc.]",
            "next_verification_due": "[YYYY-MM-DD - usually 3-6 months from creation]",
            "maintenance_protocol": "Verify after each general election. Check agency heads quarterly. Verify contact info semi-annually. Update immediately if website changes detected.",

            "_VERIFICATION_NOTES": [
                "ALL bracketed [VALUES] must be replaced with verified data",
                "Remove all fields starting with underscore (_) before final submission",
                "Use official .gov sources only",
                "Document source URLs in verification_source field",
                "If data not available, use 'Not Available' or 'Not Listed' - do NOT leave brackets",
                "If agency doesn't exist in this state, note: 'This state does not have [AGENCY NAME]'"
            ]
        }
    }


def main():
    """Generate template for all 52 jurisdictions"""

    output_dir = Path("data/states")

    print(f"Generating agency templates for all 52 jurisdictions...")
    print(f"Output directory: {output_dir}\n")

    for jurisdiction in JURISDICTIONS:
        slug = jurisdiction["slug"]
        name = jurisdiction["name"]

        # Create template
        template = create_agency_template(slug, name)

        # Create directory
        state_dir = output_dir / slug
        state_dir.mkdir(parents=True, exist_ok=True)

        # Write template file WITH VERSION
        template_file = state_dir / "agencies-TEMPLATE-v0.12.json"
        with open(template_file, 'w', encoding='utf-8') as f:
            json.dump(template, f, indent=2, ensure_ascii=False)

        print(f"✓ Created: {template_file}")

    print(f"\n{'='*60}")
    print(f"SUCCESS: Generated {len(JURISDICTIONS)} agency templates")
    print(f"{'='*60}")
    print(f"\nNext steps:")
    print(f"1. Assign each template to a research agent")
    print(f"2. Agent replaces ALL [BRACKETED] values with verified data")
    print(f"3. Agent removes all _UNDERSCORED fields before submission")
    print(f"4. Verify JSON is valid and all brackets removed")
    print(f"5. Rename file from agencies-TEMPLATE-v0.12.json to agencies-v0.12.json")
    print(f"\nConsistency guaranteed: All 52 templates identical structure ✓")
    print(f"Version: v0.12 (clearly indicates data model version)")


if __name__ == "__main__":
    main()
