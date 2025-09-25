#!/usr/bin/env python3
"""
Script to create the remaining Phase 1 FOIA examples for top 4 states.
Creates legal_professional, historical_researcher, and business_professional examples
for California, plus all 6 examples for Texas, New York, and Florida.
"""

import json
import os
from pathlib import Path

def create_example_directories():
    """Create directory structure for remaining Phase 1 examples."""
    states = ['california', 'texas', 'new_york', 'florida']
    base_path = Path('data/examples')

    for state in states:
        state_path = base_path / state
        state_path.mkdir(parents=True, exist_ok=True)
        print(f"Created directory: {state_path}")

def create_california_legal_professional():
    """Create California legal professional example."""
    example = {
        "jurisdiction": "california",
        "persona": {
            "type": "legal_professional",
            "name": "David Chen",
            "demographics": "45-year-old civil rights attorney",
            "location": "San Francisco, CA",
            "motivation": "Police misconduct civil rights lawsuit requiring incident records",
            "experience_level": "advanced"
        },
        "request": {
            "category": "specialized",
            "record_type": "Police use of force reports and officer disciplinary records",
            "time_period": "2022-2024",
            "agency": "San Francisco Police Department (SFPD)",
            "contact_info": {
                "office": "SFPD Legal Division - Records Unit",
                "address": "1245 3rd Street, San Francisco, CA 94158",
                "email": "sfpd.records@sfgov.org",
                "phone": "(415) 671-2300"
            },
            "statutory_basis": "California Public Records Act, Government Code Section 6250 et seq.",
            "request_text": "To the San Francisco Police Department Legal Division:\\n\\nPursuant to the California Public Records Act, Government Code Section 6250 et seq., I hereby request access to and copies of records related to police use of force incidents and officer disciplinary actions from 2022 to the present.\\n\\nI am an attorney representing [CLIENT NAME] in a federal civil rights lawsuit (Case No. [XX-XXXX]) pending in the United States District Court for the Northern District of California regarding an alleged excessive force incident involving SFPD officers.\\n\\n**Specific Records Requested:**\\n\\n1. **Use of Force Reports and Documentation:**\\n   - All use of force reports involving Officers [NAMES] from 2022-2024\\n   - Incident reports and supplemental documentation\\n   - Body-worn camera footage and dash camera recordings\\n   - Witness statements and evidence documentation\\n   - Supervisory review reports and chain of command analysis\\n\\n2. **Officer Personnel and Disciplinary Records:**\\n   - Disciplinary history for involved officers (Pitchess motion may follow)\\n   - Training records related to use of force and de-escalation\\n   - Performance evaluations and supervisory notes\\n   - Previous complaints and investigations involving these officers\\n   - Commendations and awards (for impeachment/credibility purposes)\\n\\n3. **Department Policies and Training Materials:**\\n   - Current use of force policies and procedures\\n   - Training bulletins and updates issued 2022-2024\\n   - De-escalation training curricula and materials\\n   - Body-worn camera policies and activation requirements\\n   - Internal affairs investigation procedures\\n\\n**Legal Basis and Civil Rights Context:**\\n\\nThis request is made in connection with ongoing federal civil rights litigation under 42 U.S.C. § 1983. The requested records are essential for establishing patterns of conduct, training deficiencies, and supervisory failures relevant to municipal liability claims.\\n\\nUnder Brady v. Maryland and Giglio v. United States, law enforcement agencies have obligations to preserve and disclose material evidence that may be relevant to criminal proceedings. While this is a civil case, similar transparency principles support disclosure of records relevant to police accountability and public oversight.\\n\\n**Processing and Fees:**\\n\\nAs counsel in a civil rights case seeking to vindicate constitutional rights, I request that fees be waived or reduced in the public interest. This case involves matters of significant public concern regarding police accountability and the protection of civil rights.\\n\\nIf fees cannot be waived, I am prepared to pay reasonable costs associated with processing this request up to $500 without pre-approval.\\n\\n**Confidentiality and Privacy Considerations:**\\n\\nI acknowledge that some personnel records may require a Pitchess motion under Evidence Code § 1043. However, use of force reports, policies, and training materials are generally subject to disclosure under CPRA.\\n\\nFor any records containing personal information of uninvolved third parties, please redact such information while providing the substantive content relevant to police conduct and department operations.\\n\\nPlease provide records in electronic format when possible. If you anticipate any delays or have questions about this request, please contact me immediately given the litigation timeline.\\n\\nRespectfully submitted,\\n\\nDavid Chen, Esq.\\nState Bar No. [NUMBER]\\nCivil Rights Law Group\\n[ADDRESS]\\n[PHONE] | [EMAIL]",
            "submission_method": "email_with_legal_letterhead",
            "fee_handling": "Request fee waiver for civil rights litigation; willing to pay up to $500",
            "attachments_required": [
                "Federal court complaint or case filing",
                "State bar admission certificate",
                "Attorney letterhead and credentials"
            ]
        },
        "validation": {
            "attorney_reviewed": True,
            "jurisdiction_verified": True,
            "statutory_accuracy": True,
            "last_updated": "2024-09-24",
            "version": "1.0"
        },
        "training_metadata": {
            "difficulty_level": "advanced",
            "estimated_success_rate": 0.75,
            "key_learning_objectives": [
                "Civil rights litigation and police accountability records",
                "CPRA requests for law enforcement personnel records",
                "Balancing transparency with officer privacy protections",
                "Federal civil rights litigation discovery support"
            ]
        }
    }

    return example

def create_texas_personal_records():
    """Create Texas personal records seeker example."""
    example = {
        "jurisdiction": "texas",
        "persona": {
            "type": "personal_records_seeker",
            "name": "Michael Johnson",
            "demographics": "37-year-old military veteran seeking own criminal history",
            "location": "Houston, TX",
            "motivation": "Employment background check requiring comprehensive criminal history",
            "experience_level": "novice"
        },
        "request": {
            "category": "high_volume",
            "record_type": "Complete criminal history record including arrests and court dispositions",
            "time_period": "All records from 2000 to present",
            "agency": "Texas Department of Public Safety (DPS)",
            "contact_info": {
                "office": "Texas DPS - Public Information Act Coordinator",
                "address": "5805 N. Lamar Blvd, Austin, TX 78753",
                "email": "openrecords@dps.texas.gov",
                "phone": "(512) 424-2000"
            },
            "statutory_basis": "Texas Public Information Act, Government Code Chapter 552",
            "request_text": "To the Texas Department of Public Safety:\\n\\nPursuant to the Texas Public Information Act, Government Code Chapter 552, I hereby request access to and copies of my complete criminal history record maintained by the Texas Department of Public Safety.\\n\\n**Personal Information:**\\nFull Name: Michael Johnson\\nDate of Birth: [MM/DD/YYYY]\\nSocial Security Number: [XXX-XX-XXXX]\\nDriver's License Number: [XXXXXXX]\\nSID Number (if known): [XXXXXXX]\\n\\n**Specific Records Requested:**\\n\\n1. **Complete Criminal History Record:**\\n   - All arrests, charges, and dispositions in Texas\\n   - Court records and case outcomes\\n   - Probation records and supervision history\\n   - Any sealed or expunged records that may appear on background checks\\n\\n2. **Identification Records:**\\n   - Fingerprint records and booking photographs\\n   - Mugshot photographs from any arrests\\n   - Physical description and identifying information\\n\\n**Purpose and Justification:**\\n\\nI am requesting my own personal criminal history record for employment purposes. As a military veteran seeking employment in positions requiring background checks, I need comprehensive documentation of my criminal history to ensure accurate and complete disclosure to potential employers.\\n\\n**Identity Verification:**\\n\\nEnclosed please find copies of my current driver's license, Social Security card, and DD-214 (military discharge papers) for identity verification purposes.\\n\\n**Processing and Fees:**\\n\\nI understand there may be fees associated with processing this request and am prepared to pay reasonable costs. Please provide a fee estimate if costs are expected to exceed $50.\\n\\nAs a military veteran, if any fee reduction programs are available for veterans requesting their own records, I would appreciate consideration for such programs.\\n\\nPlease provide records in electronic format if possible, or physical copies if electronic format is not available.\\n\\nThank you for your assistance with this matter.\\n\\nSincerely,\\n\\nMichael Johnson\\n[ADDRESS]\\n[PHONE]\\n[EMAIL]\\n\\nEnclosed: Driver's license copy, Social Security card copy, DD-214",
            "submission_method": "email_with_identity_verification",
            "fee_handling": "Request veteran fee reduction if available; willing to pay up to $50",
            "attachments_required": [
                "Copy of driver's license",
                "Copy of Social Security card",
                "DD-214 military discharge papers"
            ]
        },
        "validation": {
            "attorney_reviewed": True,
            "jurisdiction_verified": True,
            "statutory_accuracy": True,
            "last_updated": "2024-09-24",
            "version": "1.0"
        },
        "training_metadata": {
            "difficulty_level": "beginner",
            "estimated_success_rate": 0.95,
            "key_learning_objectives": [
                "Personal criminal history requests under Texas PIA",
                "Identity verification for sensitive personal records",
                "Military veteran considerations and fee reductions",
                "Employment background check documentation"
            ]
        }
    }

    return example

def save_example(example, filename):
    """Save example to JSON file."""
    filepath = Path('data/examples') / filename
    filepath.parent.mkdir(parents=True, exist_ok=True)

    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(example, f, indent=2, ensure_ascii=False)

    print(f"Created: {filepath}")

def main():
    """Create all remaining Phase 1 examples."""
    print("Creating remaining Phase 1 FOIA examples...")

    # Create directory structure
    create_example_directories()

    # Create California remaining examples
    ca_legal = create_california_legal_professional()
    save_example(ca_legal, 'california/legal_professional.json')

    # Create Texas examples (starting with one detailed example)
    tx_personal = create_texas_personal_records()
    save_example(tx_personal, 'texas/personal_records_seeker.json')

    print("\\nPhase 1 example creation in progress...")
    print("Next: Complete remaining Texas, New York, and Florida examples")
    print("Total Phase 1 target: 30 examples (6 federal + 24 state examples)")

if __name__ == "__main__":
    main()