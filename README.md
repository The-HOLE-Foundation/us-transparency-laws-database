# US Transparency Laws Database

[![Version](https://img.shields.io/badge/version-v0.11.1%20%7C%20v0.12%20in%20development-blue.svg)](VERSION.md)
[![License](https://img.shields.io/badge/license-CC0%201.0-green.svg)](LICENSE)
[![Jurisdictions](https://img.shields.io/badge/jurisdictions-52%2F52-brightgreen.svg)](data/consolidated/master_tracking_table-template.json)
[![Supabase](https://img.shields.io/badge/Supabase-Deployed-success.svg)](documentation/v0.11.1_SUPABASE_INTEGRATION_COMPLETE.md)
[![Database](https://img.shields.io/badge/database-365%20exemptions-informational.svg)](documentation/DATA_COMPLETENESS_AUDIT_v0.11.1.md)

**Part of [The HOLE Truth Project](https://theholetruth.org)** - A comprehensive government transparency platform by [The HOLE Foundation](https://theholefoundation.org)

---

## 🚀 **PROJECT STATUS: v0.11.1 SUPABASE INTEGRATION COMPLETE**

**Release Date**: October 7, 2025
**Milestone**: Complete Supabase database deployment with optimized views and enhancements
**Status**: ✅ **PRODUCTION READY** (Development Branch)

This repository is the **canonical source of truth** for US transparency law data (FOIA/public records laws) covering Federal + 50 States + DC. It serves as the foundational data layer for:

- **TheHoleTruth.org**: Public transparency platform (Transparency Map, Wiki, FOIA Generator)
- **TheHOLEFoundation.org**: Foundation website with unified authentication
- **Future Applications**: Any tools requiring verified transparency law data

### **What's New in v0.11.1**
✅ **Supabase Database Deployment** - All 52 jurisdictions imported to PostgreSQL
✅ **Transparency Map View** - Optimized single-query access for interactive map
✅ **Enhanced Exemptions** - Jurisdiction context without complex joins
✅ **Flexible Schema** - JSONB fields preserve jurisdiction-specific variations
✅ **100% Data Preservation** - Zero loss during v0.11.0 → v0.11.1 migration

## 📊 **v0.11.1 DATABASE SUMMARY**

### **✅ Layer 2 Structured Metadata: 52/52 (100%)**
- **Federal + 50 States + DC** - Complete structured jurisdiction data
- **Response timelines** with business/calendar day specifications
- **Fee structures** including search, copy, electronic delivery, and waivers
- **Exemption categories** with legal citations and scope classifications
- **Appeal processes** covering administrative and judicial review paths

### **✅ Professional Organization**
- **Consistent naming conventions** across all files
- **Logical directory structure** for scalability
- **Comprehensive documentation** and coordination
- **Cross-repository tracking** system established

## 🗂️ **Repository Structure**

```
us-transparency-laws-database/
│
├── releases/v0.11.0/                        # 🎯 PRODUCTION DATA (deploy to Supabase)
│   ├── jurisdictions/                       # 52 jurisdiction JSON files ✅
│   ├── process-maps/                        # 52+ verified workflow diagrams ✅
│   ├── metadata/                            # Tracking table ✅
│   └── README.md                            # Release documentation
│
├── supabase/                                # 🚀 SUPABASE INTEGRATION ✅ DEPLOYED
│   ├── migrations/                          # 7 migrations applied successfully
│   ├── functions/                           # Edge Functions (ready for auth)
│   └── config.toml                          # Supabase configuration
│
├── future/                                  # 🔮 FUTURE ENHANCEMENTS
│   ├── v0.12/                               # Rights of Access + Agency data
│   └── v0.13/                               # AI training examples
│
├── dev/                                     # 🛠️ DEVELOPMENT TOOLS
│   ├── scripts/                             # Validation scripts
│   └── workflows/                           # Development workflows
│
├── archive/                                 # 📦 HISTORICAL (reference only)
│   ├── process-artifacts/                   # Old Transparency-Data, etc.
│   ├── duplicates/                          # Consolidated-Datasets
│   ├── quarantine/                          # Old unverified data
│   └── sessions/                            # Session notes
│
├── docs/                                    # 📚 DOCUMENTATION
│   ├── releases/                            # Release notes
│   └── archive/                             # Old documentation
│
├── PROJECT_ECOSYSTEM.md                     # Complete architecture
├── VERSION.md                               # Current version info
├── CHANGELOG.md                             # Version history
└── README.md                                # Main project README
```

## 📋 **What's Included in v0.11.1**

### **Supabase Database (10 Core Tables + 1 View)**
Complete PostgreSQL deployment with:
- **`jurisdictions`** (52 records) - Federal + 50 States + DC
- **`transparency_laws`** (52 records) - Statute details and citations
- **`response_requirements`** (52 records) - Timelines, extensions, tolling
- **`fee_structures`** (52 records) - Search/copy fees, waivers
- **`exemptions`** (365 records) - Categories with jurisdiction context
- **`appeal_processes`** (52 records) - Administrative and judicial paths
- **`requester_requirements`** (52 records) - Identity, residency, eligibility
- **`agency_obligations`** (52 records) - Agency responsibilities
- **`oversight_bodies`** (38 records) - Enforcement and oversight
- **`agencies`** (0 records) - Deferred to v0.12

### **🚧 v0.12 Development: Rights of Access Table**
New feature in development to complement exemptions:
- **`rights_of_access`** - Affirmative rights to public records (what you CAN access)
- **Categories**: Proactive Disclosure, Enhanced Access, Technology Rights, Requester-Specific Rights
- **Purpose**: Enable FOIA Generator to assert specific statutory rights in requests
- **Status**: Design complete, migration ready, data collection pending
- **Documentation**: [v0.12 Rights of Access Design](documentation/v0.12-RIGHTS_OF_ACCESS_DESIGN.md)
- **`transparency_map_display`** (VIEW) - Optimized for interactive map

### **Key Features**
✅ **Smart Exemptions** - Query by jurisdiction without joins: `WHERE jurisdiction_name = 'California'`
✅ **Flexible Timelines** - 10 states use "reasonable time" (-1 code) accurately represented
✅ **JSONB Additional Fields** - Jurisdiction-specific variations preserved
✅ **Transparency Map View** - Single-query access to all display data
✅ **Type Safety Ready** - Generate TypeScript types for React integration

### **Source Data: v0.11.0 Release**
JSON files in `releases/v0.11.0/jurisdictions/` with complete structured metadata:
- Response timelines (business vs calendar days)
- Fee structures (search, copy, electronic, waivers)
- Exemptions (365 total across 52 jurisdictions)
- Appeal processes and deadlines
- Requester requirements
- Validation metadata with official source URLs

### **Process Maps (52+)**
Visual workflow diagrams in `releases/v0.11.0/process-maps/` showing complete request lifecycle.

### **Reference Materials**
- **Holiday Matrix**: Business day calculation data for all 52 jurisdictions
- **Statute Names**: Official transparency law names and citations
- **Validation Scripts**: Data quality assurance tools

## ✅ **Data Quality & Verification**

### **100% Official Source Verification**
- All data sourced exclusively from official .gov websites
- State legislature sites, official statute databases, AG offices only
- Legal citations verified for accuracy
- Current as of 2024-2025 legislative sessions

### **Notable 2025 Updates Included**
- **California**: AB 370 (cyberattack provisions), AB 1785 (elected official privacy)
- **Texas**: HB 4219 (response timeline clarifications)
- **Illinois**: 2024-2025 FOIA amendments
- **Plus updates** from 7 additional jurisdictions

### **Data Integrity**
- Manual human verification of all 52 jurisdictions
- Standardized JSON schema (STANDARD_JURISDICTION_TEMPLATE v0.11)
- Validation scripts ensure data consistency
- Master tracking table documents completion status
- **Documentation complete** - Full implementation guidance

### **✅ Cross-Repository Coordination**
- **Central tracking** via foundation-meta repository
- **Dependency management** with theholetruth-platform
- **Status synchronization** across all HOLE Foundation repos
- **Production deployment** coordination established

## 🔗 **HOLE Foundation Ecosystem**

This repository is part of the coordinated HOLE Foundation project structure:

- **foundation-meta/** - Central command and coordination
- **us-transparency-laws-database/** - **THIS REPOSITORY** (Production Ready)
- **theholetruth-platform/** - React application (Production Ready)
- **theholefoundation.org/** - Foundation website (Development Ready)
- **shared-infrastructure/** - Common components (Setup Ready)

## 🚧 **Current Phase: Supabase Integration**

### **v0.11.0** ✅ Complete
- Layer 2 structured metadata for all 52 jurisdictions
- Process maps and reference materials
- Production-ready JSON data

### **v0.11.1** 🚧 IN PROGRESS (Next Immediate Step)
**Supabase Integration & Production Deployment**
- Design database schema from JSON structure
- Create Supabase migrations
- Generate TypeScript types
- Import data and deploy to production
- Integrate with TheHoleTruth.org platform

### **v0.12.0+** 🔜 Future Enhancements
Planned for future releases (after Supabase deployment):
- Agency contact databases (Layer 4)
- Custom FOIA request templates (Layer 5)
- AI training examples
- Public REST/GraphQL APIs
- Automated statute monitoring

## 🎯 **Deployment Path**

```
v0.11.0 (✅ Done)          v0.11.1 (🚧 Current)       v0.12.0+ (🔜 Future)
├─ JSON Data Ready    →   ├─ Supabase Setup     →   ├─ Agency Data
├─ 52 Jurisdictions   →   ├─ Database Schema    →   ├─ Templates
├─ Process Maps       →   ├─ TypeScript Types   →   ├─ AI Training
└─ Validation         →   ├─ Data Import        →   └─ Public APIs
                          └─ Platform Integration
```

---

## 🚀 **Quick Start for Developers**

### **Query the Database**
```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://befpnwcokngtrljxskfz.supabase.co',
  'YOUR_ANON_KEY'
)

// Get all jurisdictions for the map
const { data } = await supabase
  .from('transparency_map_display')
  .select('jurisdiction_name, jurisdiction_code, response_timeline_days, key_features_tags')

// Get California exemptions (no joins needed!)
const { data: exemptions } = await supabase
  .from('exemptions')
  .select('category, description')
  .eq('jurisdiction_name', 'California')
```

### **Generate TypeScript Types**
```bash
npx supabase gen types typescript --linked > types/supabase.ts
```

### **Development Setup**
```bash
# Clone repository
git clone https://github.com/The-HOLE-Foundation/us-transparency-laws-database.git
cd us-transparency-laws-database

# Link to Supabase (development branch)
npx supabase link --project-ref befpnwcokngtrljxskfz

# View migrations
npx supabase migration list --linked
```

**Documentation**: See [v0.11.1 Supabase Integration Complete](documentation/v0.11.1_SUPABASE_INTEGRATION_COMPLETE.md) for full API reference.

---

**The HOLE Foundation - US Transparency Laws Database**
*Democratizing access to government information through comprehensive, organized data*