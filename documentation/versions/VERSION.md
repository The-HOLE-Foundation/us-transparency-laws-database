---
DATE: 2025-10-06
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Version Information
VERSION: v0.11.1
---

# Version Information

## Current Version: v0.11.1

**Release Date**: October 7, 2025
**Status**: Production Ready ✅ (Development Branch)

### Release Summary

This release completes **Supabase database integration** for v0.11.0 data. All 52 jurisdictions are now deployed to PostgreSQL with optimized views, flexible schema, and enhanced query capabilities. The database is production-ready on the Development branch and ready for authentication integration.

### Version Components

| Component | Version | Status | Completeness |
|-----------|---------|--------|--------------|
| **Layer 1** | Statutory Text | ✅ Complete | 52/52 (100%) |
| **Layer 2** | Structured Metadata | ✅ Complete | 52/52 (100%) |
| **Layer 3** | Process Maps | ✅ Complete | 52+ maps |
| **Supabase Integration** | Database Deployed | ✅ Complete | 10 tables, 1 view |
| **Supabase Authentication** | Auth Setup | 🔜 Next | theholetruth.org + theholefoundation.org |
| **Layer 4** | Agency Data | ⏸️  Future | 0/52 (v0.12+) |
| **Layer 5** | Request Templates | ⏸️  Future | 0/52 (v0.12+) |

### What's Included in v0.11.1

#### Supabase Database (10 Core Tables + 1 View)

**Production Tables**:
- ✅ `jurisdictions` (52 records) - Federal + 50 States + DC
- ✅ `transparency_laws` (52 records) - Statute details and citations
- ✅ `response_requirements` (52 records) - Timelines, extensions, tolling
- ✅ `fee_structures` (52 records) - Search/copy fees, waivers
- ✅ `exemptions` (365 records) - Categories with jurisdiction context
- ✅ `appeal_processes` (52 records) - Administrative and judicial paths
- ✅ `requester_requirements` (52 records) - Identity, residency, eligibility
- ✅ `agency_obligations` (52 records) - Agency responsibilities
- ✅ `oversight_bodies` (38 records) - Enforcement and oversight
- ✅ `agencies` (0 records) - Deferred to v0.12

**Optimized View**:
- ✅ `transparency_map_display` - Single-query map interface

#### Key Features

- ✅ **Smart Exemptions**: Query by jurisdiction without joins
- ✅ **Flexible Timelines**: 10 states use "reasonable time" (-1 code)
- ✅ **JSONB Additional Fields**: Jurisdiction-specific variations preserved
- ✅ **Transparency Map View**: Optimized for interactive map
- ✅ **Type Safety Ready**: Generate TypeScript types for React

#### v0.11.0 Source Data

All data imported from `releases/v0.11.0/jurisdictions/`:
- ✅ Response requirements & timelines
- ✅ Fee structures & waiver criteria
- ✅ Exemption categories with citations (365 total)
- ✅ Appeal processes (administrative + judicial)
- ✅ Requester eligibility requirements
- ✅ Enforcement mechanisms
- ✅ Process maps for all 52 jurisdictions

#### Data Quality

- ✅ 100% verification from official .gov sources
- ✅ Current as of 2024-2025 legislative sessions
- ✅ Zero data loss during migration (additional_fields JSONB)
- ✅ Manual human review of all 52 jurisdictions

### Current Production Status

**v0.11.1 Database**: ✅ Complete and deployed (Development branch)
**Supabase Authentication**: 🔜 Next immediate priority
**Platform Integration**: ✅ Ready (awaiting auth configuration)

### Deferred to Future Versions (v0.12+)

The following enhancements are planned for future releases:

- ⏸️  Agency contact databases (Layer 4)
- ⏸️  Custom FOIA request templates (Layer 5)
- ⏸️  AI training examples
- ⏸️  Public API endpoints

### Version Naming Convention

This project follows [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH
  |     |     |
  |     |     └─ Bug fixes, data corrections
  |     └─ New features, new jurisdictions
  └─ Breaking changes, major milestones
```

**v0.11.0 Interpretation**:

- `0` - Pre-1.0 (not yet fully integrated with platform)
- `11` - Version 11 milestone (Layer 2 completion)
- `0` - Initial release of v0.11 series

### Upgrade Path

#### From v0.11 → v0.11.0

- Master tracking table updated (completion status)
- No breaking changes
- No data migration required

#### v0.11.0 → v0.11.1 ✅ COMPLETE

**Supabase Integration & Deployment**

- ✅ Designed database schema from JSON structure
- ✅ Created 7 Supabase migrations
- ✅ Generated flexible schema with JSONB additional_fields
- ✅ Imported all 52 jurisdictions with zero data loss
- ✅ Deployed to Development Supabase instance
- ✅ Created transparency_map_display view
- ✅ Enhanced exemptions with jurisdiction context
- ✅ Ready for TheHoleTruth.org platform integration

#### v0.11.1 → v0.12.0 (In Development)

##### Rights of Access Feature 🚧

**Primary Addition**: `rights_of_access` table to complement exemptions
- Catalogs affirmative rights to public records (what you CAN access)
- Categories: Proactive Disclosure, Enhanced Access, Technology Rights, Requester-Specific Rights, Inspection Rights, Timeliness Rights
- Enables FOIA Generator to assert specific statutory rights in requests
- Provides complete transparency picture when combined with exemptions
- Creates `transparency_landscape` view for rights vs exemptions analysis

**Design Documentation**: [v0.12-RIGHTS_OF_ACCESS_DESIGN.md](documentation/v0.12-RIGHTS_OF_ACCESS_DESIGN.md)

**Migration Status**: ✅ Schema designed, migration file ready
**Data Collection**: 🔜 Pending (Federal + 10 priority states first)
**Timeline**: Q4 2025 - Q1 2026

##### Additional v0.12 Features

- Agency contact databases (Layer 4) - deferred
- Custom request templates (Layer 5) - deferred
- Enhanced data enrichment

#### v0.12.x → v1.0.0 (Long-term)

##### Public API & Advanced Features

- Public REST API endpoints
- GraphQL API
- Automated statute monitoring
- Real-time update notifications

### Data Freshness

| Jurisdiction | Last Verified | Notable Updates |
|--------------|---------------|-----------------|
| California | Oct 2025 | AB 370, AB 1785 (2025) |
| Texas | Oct 2025 | HB 4219 (2025) |
| Illinois | Oct 2025 | 2024-2025 amendments |
| Federal | Oct 2025 | FOIA Improvement Act (2016) |
| All Others | Oct 2025 | Verified current |

### Compatibility

#### Platform Requirements

- **Storage Format**: JSON (UTF-8)
- **Schema Version**: STANDARD_JURISDICTION_TEMPLATE v0.11
- **Minimum Node.js** (for validation): v18+
- **Minimum Python** (for scripts): 3.9+

#### Integration Status

- ✅ Static JSON consumption: Ready
- ✅ File-based integrations: Ready
- ⏸️  Supabase: Not yet integrated (v0.12)
- ⏸️  REST API: Not yet available (v1.0)
- ⏸️  GraphQL: Not yet available (v1.0)

### Repository Statistics

```
Total Files:                 150+
Jurisdiction Data Files:     52
Process Maps:                52+
Documentation Files:         20+
Validation Scripts:          10+
Reference Materials:         5+
Total Size:                  ~2.5 MB
```

### Contributors to v0.11.0

- **Manual Data Entry**: Human verification of all 52 jurisdictions
- **Schema Design**: STANDARD_JURISDICTION_TEMPLATE
- **Validation**: Python validation scripts
- **Documentation**: Comprehensive guides and references

### Known Issues

None identified. All validation tests passing.

### Next Immediate Priority: Authentication

- **Target**: Q4 2025 (Immediate)
- **Focus**: Supabase Authentication Configuration
- **Scope**:
  - Configure Supabase Auth for theholetruth.org
  - Configure Supabase Auth for theholefoundation.org
  - Set up OAuth providers (Google, GitHub, etc.)
  - Implement Row Level Security (RLS) policies
  - Generate TypeScript types for authenticated queries
  - Test authentication flow with React platform

### Future Enhancements Roadmap

- **v0.12.0** (In Development): Rights of Access table + data collection (Q4 2025 - Q1 2026)
- **v0.12.1**: Agency contact databases + custom templates
- **v0.13.0**: AI training examples + enhanced metadata
- **v1.0.0**: Public API + automated monitoring

---

## Version History

| Version | Date | Milestone |
|---------|------|-----------|
| v0.11.1 | 2025-10-07 | Supabase integration complete ✅ |
| v0.11.0 | 2025-10-03 | Layer 2 complete (52/52) ✅ |
| v0.11 | 2025-09-29 | Transparency map dataset |
| v0.10 | 2025-09-26 | Validation & process maps |
| v0.9 | 2025-09 | Initial data collection |

---

**Current Version**: v0.11.1
**Status**: Production Ready (Development Branch)
**Next Priority**: Supabase Authentication

For detailed changes, see [CHANGELOG.md](CHANGELOG.md).
