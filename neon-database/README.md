---
DATE: 2025-10-10
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Neon Database Documentation Hub
VERSION: v0.12
---

# Neon Database - Complete Project Documentation

**Production Database**: Neon PostgreSQL (AWS us-east-1)
**Project**: The HOLE Foundation - US Transparency Laws Database
**Current Version**: v0.12 (Rights of Access)

## 📁 Folder Structure

```
neon-database/
├── README.md                          # This file - main hub
├── migrations/                        # Database migrations (SQL)
│   ├── 00000000000001_initial_schema.sql
│   ├── 20251007040000_add_flexible_fields.sql
│   ├── 20251008000000_add_rights_of_access.sql
│   └── migration-guide.md
├── scripts/                           # Import and maintenance scripts
│   ├── import-rights.js
│   ├── verify-schema.js
│   └── backup-restore.md
├── documentation/                     # Comprehensive docs
│   ├── connection-guide.md
│   ├── schema-overview.md
│   ├── query-patterns.md
│   └── troubleshooting.md
├── schemas/                           # JSON schemas and TypeScript types
│   ├── v0.12-rights-schema.json
│   ├── database.types.ts
│   └── schema-changelog.md
├── queries/                           # Common SQL queries
│   ├── rights-queries.sql
│   ├── exemptions-queries.sql
│   └── jurisdiction-queries.sql
└── monitoring/                        # Performance and health checks
    ├── health-check.sql
    └── performance-metrics.md
```

## 🚀 Quick Start

### 1. Connection Setup

**Production Database (Neon)**:
```bash
# Pooled connection (use for web apps)
DATABASE_URL=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4-pooler.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require

# Direct connection (use for migrations)
DATABASE_URL_UNPOOLED=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require
```

### 2. Connect to Database

```bash
# Using psql
psql "$DATABASE_URL_UNPOOLED"

# Using Prisma
npx prisma db pull

# Using Node.js
node scripts/verify-schema.js
```

### 3. Import v0.12 Rights Data

```bash
# Import Federal rights
node dev/scripts/import-rights-neon.js data/v0.12/rights/federal-rights.json

# Verify import
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM rights_of_access;"
```

## 📊 Database Architecture

### v0.11.1 - Core Transparency Data (PRODUCTION)

**Status**: ✅ Deployed and operational

**10 Core Tables**:
- `jurisdictions` (52 records) - All US states + DC + Federal
- `transparency_laws` (52 records) - FOIA/public records laws
- `response_requirements` (52 records) - Response timelines
- `fee_structures` (52 records) - Fee schedules
- `exemptions` (365 records) - What can be withheld
- `appeal_processes` (52 records) - Appeal procedures
- `requester_requirements` (52 records) - Who can request
- `agency_obligations` (52 records) - Agency duties
- `oversight_bodies` (38 records) - Oversight agencies
- `agencies` (0 records) - Deferred to v0.12

**Key Views**:
- `transparency_map_display` - Optimized for interactive map
- `transparency_landscape` (v0.12) - Rights vs exemptions analysis

### v0.12 - Rights of Access (IN DEVELOPMENT)

**Status**: 🟡 1/52 jurisdictions complete (Federal only)

**New Table**:
- `rights_of_access` (15 records Federal, 51 states pending)
  - Affirmative rights to access public records
  - Categories: Proactive Disclosure, Enhanced Access, Technology Rights
  - Assertion language for FOIA Generator
  - Verified from official statutes

**Migration**: `20251008000000_add_rights_of_access.sql`

## 📈 Current Status

### Data Completeness

**v0.11.1 (Core Data)**:
- ✅ 52/52 jurisdictions (100%)
- ✅ 365 exemptions verified
- ✅ All response requirements populated
- ✅ Production ready

**v0.12 (Rights of Access)**:
- ✅ 1/52 jurisdictions complete (Federal)
- ⏸️ 51/52 jurisdictions pending
- 📊 Progress: 2% (1/52)

### Quality Metrics

**v0.12 Validation Audit Results** (2025-10-09):
- Files created: 13
- Files approved: 1 (Federal - 15 rights verified)
- Files deleted: 12 (failed quality standards)
- Pass rate: 8% (1/13)

**Lesson**: Rigorous validation is critical. Only verified data from official .gov sources permitted.

## 🔧 Common Operations

### Run Migrations

```bash
# Apply new migration to Neon
psql "$DATABASE_URL_UNPOOLED" -f neon-database/migrations/YOUR_MIGRATION.sql

# Verify migration
psql "$DATABASE_URL" -c "SELECT * FROM schema_migrations;"
```

### Query Database

```sql
-- Get all jurisdictions
SELECT * FROM jurisdictions ORDER BY name;

-- Get California exemptions (no joins needed!)
SELECT category, description FROM exemptions
WHERE jurisdiction_slug = 'california';

-- Get Federal rights of access
SELECT right_name, right_category, short_description
FROM rights_of_access
WHERE jurisdiction_id = 'federal'
ORDER BY right_category;

-- Compare rights vs exemptions
SELECT jurisdiction_name, total_rights, total_exemptions, transparency_ratio
FROM transparency_landscape
ORDER BY transparency_ratio DESC;
```

### Import Rights Data

```bash
# Import from JSON file
node dev/scripts/import-rights-neon.js data/v0.12/rights/{jurisdiction}-rights.json

# Verify import
psql "$DATABASE_URL" -c "
  SELECT jurisdiction_name, COUNT(*)
  FROM rights_of_access
  GROUP BY jurisdiction_name;
"
```

### Check Database Health

```bash
# Connection test
psql "$DATABASE_URL" -c "SELECT version();"

# Table sizes
psql "$DATABASE_URL" -c "
  SELECT
    schemaname, tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
  FROM pg_tables
  WHERE schemaname = 'public'
  ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
"

# Record counts
psql "$DATABASE_URL" -c "
  SELECT
    'jurisdictions' as table, COUNT(*) FROM jurisdictions
  UNION ALL
    SELECT 'exemptions', COUNT(*) FROM exemptions
  UNION ALL
    SELECT 'rights_of_access', COUNT(*) FROM rights_of_access;
"
```

## 📚 Documentation Index

### Essential Reading

1. **[Connection Guide](documentation/connection-guide.md)** - How to connect to Neon
2. **[Schema Overview](documentation/schema-overview.md)** - Database structure explained
3. **[Query Patterns](documentation/query-patterns.md)** - Common SQL queries
4. **[Migration Guide](migrations/migration-guide.md)** - How to run migrations
5. **[Troubleshooting](documentation/troubleshooting.md)** - Common issues and solutions

### Technical References

- **[v0.12 Rights Schema](schemas/v0.12-rights-schema.json)** - Rights of access JSON schema
- **[TypeScript Types](schemas/database.types.ts)** - Generated from Prisma
- **[Sample Queries](queries/)** - SQL query library
- **[Performance Monitoring](monitoring/)** - Health checks and metrics

### Process Documentation

- **[NEON_MIGRATION.md](../documentation/NEON_MIGRATION.md)** - Migration from Supabase
- **[V0.12_CURRENT_STATUS.md](../V0.12_CURRENT_STATUS.md)** - v0.12 project status
- **[FEDERAL_VALIDATION_COMPLETE.md](../FEDERAL_VALIDATION_COMPLETE.md)** - Federal rights validation

## 🎯 Next Steps

### Immediate Priorities (This Week)

1. **Complete v0.12 Rights Collection**
   - [ ] Validate California, Texas, New York rights files
   - [ ] Begin priority states (IL, PA, FL)
   - [ ] Use worktree infrastructure for isolation
   - [ ] Apply rigorous validation before approval

2. **Database Maintenance**
   - [ ] Document all schemas in TypeScript
   - [ ] Create backup/restore procedures
   - [ ] Set up monitoring alerts
   - [ ] Test query performance

3. **Integration Testing**
   - [ ] Verify THEHOLETRUTH.ORG platform connection
   - [ ] Test FOIA Generator with rights data
   - [ ] Validate transparency map rendering
   - [ ] Performance test under load

### Medium-Term Goals (This Month)

1. **Complete v0.12 Data Population**
   - Target: 52/52 jurisdictions with verified rights
   - Quality standard: 100% accuracy from official sources
   - Documentation: All sources verified and cited

2. **Platform Integration**
   - Deploy v0.12 to production
   - Enable FOIA Generator rights assertions
   - Update transparency map with rights layer
   - Launch public beta

3. **Data Maintenance Pipeline**
   - Automated statute change monitoring
   - Quarterly verification schedule
   - Version control for schema changes
   - Rollback procedures

## 🔐 Security & Access

### Database Access Levels

**Production Database (Neon)**:
- Owner: `neondb_owner` (full access)
- Application: Pooled connection (read/write via RLS)
- Public: Read-only via API (future)

### Row-Level Security

All tables use RLS policies:
- Public read access: jurisdictions, exemptions, rights_of_access
- Authenticated write: Future admin interface
- Audit logging: All writes logged

### Environment Variables

Required in production:
```bash
DATABASE_URL=<pooled-connection>
DATABASE_URL_UNPOOLED=<direct-connection>
POSTGRES_PRISMA_URL=<prisma-optimized>
```

See: `.env.production.template`

## 🐛 Known Issues & Limitations

### Current Limitations

1. **v0.12 Data Coverage**: Only Federal complete (1/52 jurisdictions)
2. **Agencies Table**: Empty (deferred to future release)
3. **Historical Data**: No statute change tracking yet
4. **Multi-language**: English only (Spanish planned)

### Active Issues

- None currently reported

### Planned Improvements

1. Automated data validation pipeline
2. Statute change monitoring service
3. Multi-language support
4. Vector search for semantic queries (v0.13)

## 📞 Support & Resources

### Internal Documentation
- Main README: `/README.md`
- CLAUDE.md: `/CLAUDE.md` (AI assistant instructions)
- Workflows: `/workflows/`

### External Resources
- Neon Docs: https://neon.tech/docs
- PostgreSQL Docs: https://www.postgresql.org/docs/
- Prisma Docs: https://www.prisma.io/docs

### Project Coordination
- Foundation Meta: `/Volumes/HOLE-RAID-DRIVE/HOLE/Github/foundation-meta/`
- Platform Repo: `/Volumes/HOLE-RAID-DRIVE/HOLE/Projects/THEHOLETRUTH.ORG/`

---

**Last Updated**: 2025-10-10
**Maintained By**: The HOLE Foundation Engineering Team
**Database Version**: v0.12 (Rights of Access)
**Status**: 🟡 In Development
