---
TASK: Collect Agency Contact Databases
AGENT: python-autocoder
PRIORITY: Medium (v0.12 enhancement)
ESTIMATED TIME: 40-80 hours per jurisdiction
---

# Task 2: Collect Agency Contact Databases

## Objective

Build comprehensive agency contact databases for all 51 jurisdictions, enabling the FOIA Generator to address specific agencies.

## Input Sources

**Official State Government Directories**:
- State government websites (.gov domains only)
- Official agency directories
- State FOIA officer registries
- State archives/records office listings

**Examples**:
- Maine: https://www.maine.gov/portal/government/edemocracy/
- California: https://www.ca.gov/agencies/
- Federal: https://www.foia.gov/

## Output Files

**Target**: `data/states/{state-name}/agencies.json` (agencies array)

**Structure**:
```json
{
  "jurisdiction": "Maine",
  "transparency_law": { /* populated by Task 1 */ },
  "agencies": [
    {
      "agency_id": "maine-doe-001",
      "name": "Maine Department of Education",
      "abbreviation": "DOE",
      "category": "Education",
      "foia_contact": {
        "foia_officer_name": "Jane Smith",
        "foia_officer_title": "FOAA Coordinator",
        "email": "foia@maine.gov",
        "phone": "(207) 624-6600",
        "fax": "(207) 624-6700",
        "alternate_email": "doe.foia@maine.gov"
      },
      "mailing_address": {
        "street": "23 State House Station",
        "street_2": "",
        "city": "Augusta",
        "state": "ME",
        "zip": "04333"
      },
      "submission_methods": {
        "email_accepted": true,
        "mail_accepted": true,
        "fax_accepted": true,
        "online_portal": "https://www.maine.gov/doe/foia",
        "in_person_accepted": false
      },
      "website": "https://www.maine.gov/doe/",
      "response_stats": {
        "average_response_days": 7,
        "typical_fee_range": "$0-50",
        "success_rate": 0.85
      },
      "notes": "Use email for fastest response. Include student ID if requesting educational records.",
      "data_quality": {
        "last_verified": "2025-10-02",
        "verification_method": "website_scrape",
        "confidence_level": "high",
        "email_verified": true
      }
    }
  ]
}
```

## Collection Strategy

### Phase 1: Automated Scraping (70% coverage)

**Tools**: Selenium + BeautifulSoup

**Process**:
1. Identify official state agency directory URL
2. Scrape agency list (names, websites)
3. Visit each agency website
4. Locate FOIA contact page
5. Extract contact information
6. Validate email deliverability
7. Export to CSV

**Example Script** (`scripts/scrape_state_agencies.py`):

```python
import requests
from bs4 import BeautifulSoup
from selenium import webdriver
import time
import csv

def scrape_maine_agencies():
    # Step 1: Get agency list
    url = "https://www.maine.gov/portal/government/edemocracy/"
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')

    agencies = []

    # Step 2: Extract agency links
    for agency_link in soup.find_all('a', class_='agency-link'):
        agency_name = agency_link.text.strip()
        agency_url = agency_link['href']

        # Step 3: Visit agency website and find FOIA page
        foia_info = scrape_agency_foia_page(agency_url)

        if foia_info:
            agencies.append({
                'name': agency_name,
                'website': agency_url,
                **foia_info
            })

    return agencies

def scrape_agency_foia_page(agency_url):
    # Common FOIA page patterns
    foia_paths = ['/foia', '/public-records', '/right-to-know', '/transparency']

    for path in foia_paths:
        try:
            response = requests.get(agency_url + path, timeout=10)
            if response.status_code == 200:
                soup = BeautifulSoup(response.text, 'html.parser')

                # Extract contact info
                email = find_email_on_page(soup)
                phone = find_phone_on_page(soup)
                address = find_mailing_address(soup)

                return {
                    'email': email,
                    'phone': phone,
                    'address': address
                }
        except:
            continue

    return None
```

### Phase 2: Manual Verification (30% coverage)

**When scraping fails**:
- Complex website structures
- JavaScript-heavy pages
- No standard FOIA contact page
- Non-standard formats

**Manual Process**:
1. Visit agency website manually
2. Navigate to contact/FOIA page
3. Copy contact information
4. Paste into CSV template
5. Verify email deliverability

### Phase 3: Email Verification

**Tool**: Email validation API (e.g., ZeroBounce, Hunter.io)

**Process**:
```python
import requests

def verify_email(email_address):
    # Using a verification service
    api_url = f"https://api.emailverification.com/verify?email={email_address}"
    response = requests.get(api_url)
    result = response.json()

    return {
        'deliverable': result['deliverable'],
        'valid_format': result['valid_format'],
        'mx_records_exist': result['mx_found']
    }
```

**Actions based on results**:
- ✅ Deliverable: Include in database
- ⚠️ Risky: Flag for manual verification
- ❌ Invalid: Search for alternate email

## Data Sources by Jurisdiction

### Federal
- **Primary**: https://www.foia.gov/agency-directory.html
- **Coverage**: ~100 federal agencies
- **Quality**: High (official FOIA.gov directory)

### California
- **Primary**: https://www.ca.gov/agencies/
- **Secondary**: https://oag.ca.gov/government/responsibilities
- **Estimated Agencies**: 200+

### Maine
- **Primary**: https://www.maine.gov/portal/government/edemocracy/
- **Secondary**: State Archives FOAA resources
- **Estimated Agencies**: 50-75

### General Pattern
Most states have:
1. Official .gov portal with agency directory
2. State archives/records office with FOIA resources
3. Attorney General office with FOIA guidance

## Quality Assurance

### Automated Validation
- [x] Email format valid (regex check)
- [x] Email deliverable (MX records exist)
- [x] Phone number format (US standard)
- [x] ZIP code valid for state
- [x] All required fields populated

### Manual Validation (10% sample)
- [ ] Agency name matches official directory
- [ ] FOIA officer name current (if provided)
- [ ] Submission methods accurate
- [ ] Website URL accessible

## Common Challenges & Solutions

### Challenge 1: No Central Directory
**Solution**: Scrape from multiple sources (AG office, state archives, legislative directory)

### Challenge 2: Outdated Contact Information
**Solution**: Prioritize most recently updated sources, flag for reverification after 6 months

### Challenge 3: Generic Email Addresses
**Solution**: Prefer specific FOIA emails (foia@agency.gov) over generic (info@agency.gov)

### Challenge 4: JavaScript-Required Pages
**Solution**: Use Selenium with headless Chrome to render pages

## Batch Processing Order

**Batch 1**: Federal + Priority 1 (Week 1-4)
- Federal: ~100 agencies
- California: ~200 agencies
- Florida: ~150 agencies
- Illinois: ~100 agencies
- New York: ~180 agencies
- Texas: ~200 agencies

**Batch 2**: Priority 2 (Week 5-8)
- 15 states, ~50-150 agencies each

**Batch 3**: Remaining (Week 9-16)
- 30 states, ~30-100 agencies each

## Output Format

**CSV Template** (for manual collection):
```csv
agency_name,abbreviation,category,foia_officer_name,email,phone,street,city,state,zip,website,notes
Maine Department of Education,DOE,Education,Jane Smith,foia@maine.gov,(207) 624-6600,23 State House Station,Augusta,ME,04333,https://www.maine.gov/doe/,"Use email for fastest response"
```

**CSV → JSON Conversion** (`scripts/csv_to_agencies_json.py`):
```python
import csv
import json

def convert_csv_to_json(csv_file, state_name):
    agencies = []

    with open(csv_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            agency = {
                "agency_id": generate_agency_id(row['agency_name'], state_name),
                "name": row['agency_name'],
                "abbreviation": row['abbreviation'],
                "category": row['category'],
                "foia_contact": {
                    "foia_officer_name": row['foia_officer_name'],
                    "email": row['email'],
                    "phone": row['phone']
                },
                "mailing_address": {
                    "street": row['street'],
                    "city": row['city'],
                    "state": row['state'],
                    "zip": row['zip']
                },
                "website": row['website'],
                "notes": row['notes'],
                "data_quality": {
                    "last_verified": "2025-10-02",
                    "confidence_level": "high"
                }
            }
            agencies.append(agency)

    return agencies
```

## Success Criteria

- [ ] All 51 jurisdictions have populated agencies arrays
- [ ] 90%+ email deliverability rate
- [ ] 50-200 agencies per state (varies by size)
- [ ] All official .gov sources documented
- [ ] 10% sample manually verified

## Deliverables

**Per Jurisdiction**:
1. CSV file with raw scraped data
2. JSON file with validated agencies
3. Scraping log (successes, failures, manual additions)

**Aggregate**:
1. Total agency count: ~5,000
2. Coverage report (% agencies with complete data)
3. Quality metrics (email verification rates)

## Agent Execution Command

```bash
# Launch python-autocoder agent
# Provide this file as context
# Agent should process one jurisdiction at a time
# Agent should export CSV after each scraping run
# Agent should validate emails before finalizing
```

**Note**: This task combines automated scraping with manual data entry. Agent handles automation, human verifies quality.
