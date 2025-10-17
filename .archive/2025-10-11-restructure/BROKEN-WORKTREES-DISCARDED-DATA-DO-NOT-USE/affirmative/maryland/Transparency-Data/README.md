# US Transparency Laws Database - Version 0.11

A comprehensive, verified database of transparency and public records laws for all 51 US jurisdictions (Federal + 50 States + DC).

## Dataset Overview

**Version**: 0.11
**Release Date**: September 26, 2025
**Total Jurisdictions**: 51
**Jurisdictions with 2025 Updates**: 10
**Last Verification**: September 26, 2025

This dataset provides complete, accurate information about transparency laws across the United States, including response timelines, fee structures, exemptions, enforcement mechanisms, and recent legislative changes.

## Version 0.11 Changes Summary

Version 0.11 represents a comprehensive update verifying all 51 jurisdictions against current law as of September 2025. Key changes include:

### Major Statutory Amendments (10 Jurisdictions)

1. **Texas** - HB 4219 (Effective September 1, 2025)
   - 10-day "no records" notification requirement
   - Limited Attorney General appeals on settled issues
   - Expanded contracting transparency
   - Enhanced personnel record disclosure

2. **California** - AB 370 & AB 1785 (Effective July 1, 2025)
   - Cyberattack added to unusual circumstances
   - 14-day extension for cyberattack-affected systems
   - Enhanced privacy protections for elected officials

3. **Colorado** - SB25-077 (Vetoed April 17, 2025)
   - Proposed 5-day response rejected
   - Current 3-day standard remains
   - Documented for accuracy

4. **Illinois** - 2024-2025 Amendments
   - Cybersecurity: requests must be in email body
   - Enhanced FOIA officer training requirements
   - Expanded private information definitions

5. **Washington** - July 27, 2025 Amendments
   - Workplace investigation voice alteration requirements
   - Enhanced witness identity protection

6. **Florida** - SB 268 (2025)
   - Privacy protections for legislators' home addresses
   - Minor response time clarifications

7. **Missouri** - August 2025
   - New exemptions for minors' personal information
   - Clarified fee payment rules

8. **Montana** - October 2025
   - Agency procedure updates for special districts
   - Digital document format requirements

9. **Virginia** - 2025
   - 13 minor technical amendments
   - Enhanced FOIA officer training

10. **Wisconsin** - 2025
    - Digital record handling clarifications
    - Audio/text messaging platform coverage

### Verification Updates (41 Jurisdictions)

All remaining jurisdictions verified as current with no statutory changes since the previous version.

## Folder Structure

```
TransparencyDataset-v0.11/
├── README.md (this file)
├── CHANGELOG-v0.11.md (detailed change log)
│
├── Individual-Jurisdictions/
│   ├── Federal/
│   │   └── Federal-FOIA-v0.11.md
│   └── States/
│       ├── Alabama-PRL-v0.11.md
│       ├── Alaska-Public-Records-v0.11.md
│       └── [... all 50 states ...]
│
├── Consolidated-Datasets/
│   ├── COMPREHENSIVE-MASTER-ALL-51-JURISDICTIONS-v0.11.md
│   ├── transparency-laws-database-v0.11.json
│   └── transparency-laws-database-v0.11.csv
│
├── Full-Text-Statutes/
│   ├── FEDERAL_FOIA_transparency_law.txt
│   ├── CALIFORNIA_transparency_law-v.0.11.txt (updated statute)
│   ├── COLORADO_transparency_law-v.0.11.txt (updated statute)
│   └── [... all 51 full-text statutes ...]
│
├── Reference-Materials/
│   └── v0.11-Update-Documentation/
│       ├── Statute-Updates/
│       ├── Analysis-Examples/
│       ├── FOIA-Writing-Guide/
│       └── Obstruction-Analysis/
│
└── Metadata/
    ├── dataset-manifest.json
    └── version-history.md
```

## How to Use This Dataset

### For FOIA Request Preparation

1. **Identify Your Jurisdiction**: Navigate to `Individual-Jurisdictions/States/` or `Federal/`
2. **Review Process Map**: Each jurisdiction has a complete process map with:
   - Response timelines
   - Fee structures
   - Exemptions
   - Appeal procedures
   - 2025 amendments (if applicable)

3. **Check Full-Text Statute**: If needed, reference `Full-Text-Statutes/` for complete statutory text

### For Research and Analysis

1. **Use Consolidated Datasets**: 
   - **JSON** (`transparency-laws-database-v0.11.json`): For programmatic access and analysis
   - **CSV** (`transparency-laws-database-v0.11.csv`): For spreadsheet analysis and comparisons
   - **Comprehensive Master** (`COMPREHENSIVE-MASTER-ALL-51-JURISDICTIONS-v0.11.md`): For full-text search

2. **Compare Jurisdictions**: CSV format allows easy filtering and comparison of:
   - Response timelines
   - Fee structures
   - Enforcement mechanisms
   - Recent amendments

### For Legal Reference

- Individual process maps include complete legal citations
- Full-text statutes provide authoritative text
- Version history tracks changes over time
- All sources verified as of September 26, 2025

## Data Formats

### Markdown (.md)
- Complete process maps for each jurisdiction
- Human-readable format
- Includes formatting, tables, and detailed explanations
- Ideal for reading and reference

### JSON (.json)
- Structured data format
- Easy to parse programmatically
- Includes all key metadata
- Ideal for applications and automated analysis

### CSV (.csv)
- Tabular format
- Easy to import into spreadsheets
- Ideal for comparison and filtering
- Compatible with Excel, Google Sheets, etc.

### Plain Text (.txt)
- Full statutory text
- Unformatted for maximum compatibility
- Includes complete legal language

## Data Quality and Verification

All data in this dataset has been:
- Verified against current statutory text as of September 26, 2025
- Cross-referenced with official legislative sources
- Updated to reflect all 2025 amendments
- Reviewed for accuracy and completeness

Each jurisdiction file includes:
- Verification certification
- Verification date
- Source citations
- Last statutory update date

**Note on Data Quality**: All data has been verified against primary statutory sources. Update documentation and analysis examples are available in `Reference-Materials/v0.11-Update-Documentation/` for transparency and reproducibility.

## Updates and Maintenance

This dataset is maintained to reflect current law. Version updates occur when:
- Major statutory amendments are enacted
- Significant case law affects interpretation
- Periodic verification cycles complete

**Next anticipated update**: v0.12 (estimated Q2 2026)

## Citation

When citing this dataset, please use:

```
US Transparency Laws Database, Version 0.11 (September 26, 2025)
[Your access date]
```

For specific jurisdictions:
```
[Jurisdiction] transparency law data from US Transparency Laws Database, 
Version 0.11 (September 26, 2025). Verified against [statutory citation] 
as of September 26, 2025.
```

## License

This dataset is released into the public domain under CC0 1.0 Universal.

You are free to:
- Use the data for any purpose
- Modify and redistribute
- Use commercially
- Use without attribution (though attribution is appreciated)

## Questions and Feedback

For questions about this dataset or to report errors, please refer to the verification certifications in each individual jurisdiction file.

## Dataset Statistics

- **Total Process Maps**: 51
- **Total Full-Text Statutes**: 51
- **Jurisdictions Updated in v0.11**: 10
- **Jurisdictions Verified (No Changes)**: 41
- **Total Lines of Documentation**: 13,681
- **Data Formats Available**: 4 (Markdown, JSON, CSV, Plain Text)

## Quick Reference: 2025 Amendment Summary

| Jurisdiction | Effective Date | Key Change |
|--------------|----------------|------------|
| Texas | September 1, 2025 | 10-day no records notification, limited AG appeals |
| California | July 1, 2025 | Cyberattack extensions, privacy protections |
| Colorado | April 17, 2025 | Vetoed 5-day response (3-day remains) |
| Illinois | 2024-2025 | Cybersecurity, training requirements |
| Washington | July 27, 2025 | Voice alteration for investigations |
| Florida | 2025 | Privacy for legislators |
| Missouri | August 2025 | Minor exemptions |
| Montana | October 2025 | Agency procedures |
| Virginia | 2025 | 13 technical amendments |
| Wisconsin | 2025 | Digital records clarifications |

---

**Last Updated**: September 26, 2025
**Version**: 0.11
**Total Jurisdictions**: 51
