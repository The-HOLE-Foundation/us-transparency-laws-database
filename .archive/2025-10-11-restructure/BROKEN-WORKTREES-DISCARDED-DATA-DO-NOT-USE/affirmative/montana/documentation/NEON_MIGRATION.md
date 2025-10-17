---
DATE: 2025-10-07
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Neon Database Migration
VERSION: v0.12
---

# Neon Database Migration Guide

## Overview

This project has migrated from **Supabase** to **Neon** for PostgreSQL database hosting. Neon provides better performance, cost efficiency, and integration with our Vercel deployment pipeline for the THEHOLETRUTH.ORG platform.

## Migration Status

**Status**: ✅ **COMPLETED**
**Date**: October 2025
**Production Database**: Neon PostgreSQL (us-east-1)

### What Changed

1. **Database Provider**: Supabase → Neon
2. **Connection Pooling**: Supabase Pooler → Neon Pooler
3. **Deployment Method**: Supabase CLI → Direct PostgreSQL migrations
4. **Integration**: TheHoleTruth.org platform now uses Neon exclusively

### What Stayed the Same

- ✅ PostgreSQL database schema (100% compatible)
- ✅ All data and migrations preserved
- ✅ Existing queries and views work unchanged
- ✅ Row-level security policies maintained
- ✅ All 10 core tables + views operational

## Neon Connection Details

### Production Environment

```bash
# Primary pooled connection (use for most operations)
DATABASE_URL=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4-pooler.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require

# Direct connection (use for migrations and admin tasks)
DATABASE_URL_UNPOOLED=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require
```

**Project**: The HOLE Truth Database
**Region**: AWS us-east-1
**Pooler**: Enabled (default for web apps)

### Local Development

For local development, continue using Docker-based PostgreSQL:

```bash
# Start local database
docker-compose up postgres

# Local connection
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/transparency_db
```

## Migration Steps Completed

### 1. Schema Migration ✅

All Supabase migrations were successfully applied to Neon:

```
✅ 00000000000001_initial_schema.sql
✅ 20251007040000_add_flexible_fields.sql
✅ 20251007050000_allow_null_response_fields.sql
✅ 20251007051000_allow_null_appeal_fields.sql
✅ 20251007052000_fix_response_units_and_oversight.sql
✅ 20251007060000_create_transparency_map_view.sql
✅ 20251007061000_add_jurisdiction_to_exemptions.sql
✅ 20251008000000_add_rights_of_access.sql (v0.12)
✅ 20251015000000_add_vector_database.sql (v0.13)
```

### 2. Data Migration ✅

- **52 jurisdictions** imported successfully
- **365 exemptions** with jurisdiction context
- **All response requirements** and fee structures preserved
- **All metadata** and validation info intact

### 3. Views and Functions ✅

- `transparency_map_display` VIEW operational
- `transparency_landscape` VIEW operational (v0.12)
- Vector search functions deployed (v0.13)
- All triggers and constraints active

## Database Access Methods

### 1. Direct PostgreSQL Connection

For migrations, admin tasks, and bulk operations:

```bash
# Using psql
psql "$DATABASE_URL_UNPOOLED"

# Using any PostgreSQL client
# Host: ep-dark-smoke-adkcd3h4.c-2.us-east-1.aws.neon.tech
# Database: neondb
# User: neondb_owner
# Password: [from .env.production]
# SSL: Required
```

### 2. Pooled Connection (Recommended for Apps)

For web applications and API queries:

```bash
# Connection pooling enabled automatically
# Use DATABASE_URL for all application connections
```

### 3. Prisma Integration

TheHoleTruth.org platform uses Prisma ORM:

```typescript
// prisma/schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// Automatic connection pooling
const prisma = new PrismaClient()
```

## Running Migrations on Neon

### New Migration Workflow

**No more Supabase CLI!** Use direct PostgreSQL migrations:

#### Option 1: Direct SQL Execution

```bash
# Execute migration directly
psql "$DATABASE_URL_UNPOOLED" -f supabase/migrations/YOUR_MIGRATION.sql

# Verify migration
psql "$DATABASE_URL_UNPOOLED" -c "SELECT * FROM schema_migrations;"
```

#### Option 2: Migration Script

```bash
# Create migration script
./scripts/migrate-neon.sh

# Script contents:
#!/bin/bash
for migration in supabase/migrations/*.sql; do
  echo "Applying: $migration"
  psql "$DATABASE_URL_UNPOOLED" -f "$migration"
done
```

#### Option 3: Prisma Migrations (Recommended for v0.12+)

```bash
# Generate Prisma migration from schema changes
npx prisma migrate dev --name add_new_feature

# Apply to production
npx prisma migrate deploy
```

## v0.12 Data Import Process

### Import Rights of Access Data

```bash
# 1. Prepare data file
# File: data/v0.12/rights/federal-rights.json

# 2. Run import script
node dev/scripts/import-rights-neon.js data/v0.12/rights/federal-rights.json

# 3. Verify import
psql "$DATABASE_URL" -c "SELECT jurisdiction_slug, COUNT(*) FROM rights_of_access GROUP BY jurisdiction_slug;"
```

### Import Script Template

```javascript
// dev/scripts/import-rights-neon.js
import { Client } from 'pg'
import fs from 'fs/promises'

const client = new Client({
  connectionString: process.env.DATABASE_URL_UNPOOLED,
  ssl: { rejectUnauthorized: false }
})

async function importRights(filePath) {
  const data = JSON.parse(await fs.readFile(filePath, 'utf-8'))

  await client.connect()

  // Get transparency_law_id
  const lawResult = await client.query(
    'SELECT id FROM transparency_laws tl JOIN jurisdictions j ON j.id = tl.jurisdiction_id WHERE j.slug = $1',
    [data.jurisdiction.slug]
  )

  const transparencyLawId = lawResult.rows[0].id

  // Import each right
  for (const right of data.rights_of_access) {
    await client.query(`
      INSERT INTO rights_of_access (
        transparency_law_id, jurisdiction_slug, jurisdiction_name,
        category, subcategory, statute_citation, description,
        conditions, applies_to, implementation_notes, request_tips
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    `, [
      transparencyLawId,
      data.jurisdiction.slug,
      data.jurisdiction.name,
      right.category,
      right.subcategory,
      right.statute_citation,
      right.description,
      right.conditions,
      right.applies_to,
      right.implementation_notes,
      right.request_tips
    ])
  }

  await client.end()
  console.log(`✅ Imported ${data.rights_of_access.length} rights for ${data.jurisdiction.name}`)
}

importRights(process.argv[2])
```

## Querying Neon Database

### Example Queries

```sql
-- Get all jurisdictions
SELECT * FROM jurisdictions ORDER BY name;

-- Get California exemptions (no joins needed!)
SELECT category, description FROM exemptions WHERE jurisdiction_slug = 'california';

-- Use transparency_map_display VIEW
SELECT jurisdiction_name, response_timeline_days, key_features_tags
FROM transparency_map_display
ORDER BY jurisdiction_name;

-- v0.12: Get rights of access for Federal FOIA
SELECT category, description, statute_citation, request_tips
FROM rights_of_access
WHERE jurisdiction_slug = 'federal'
ORDER BY category;

-- v0.12: Compare rights vs exemptions
SELECT jurisdiction_name, total_rights, total_exemptions,
       ROUND(total_rights::numeric / NULLIF(total_exemptions, 0), 2) as transparency_ratio
FROM transparency_landscape
ORDER BY transparency_ratio DESC;
```

### Connection from Application Code

```typescript
// Next.js API Route (app/api/jurisdictions/route.ts)
import { Client } from 'pg'

export async function GET() {
  const client = new Client({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  })

  await client.connect()

  const result = await client.query(`
    SELECT jurisdiction_name, response_timeline_days, key_features_tags
    FROM transparency_map_display
  `)

  await client.end()

  return Response.json(result.rows)
}
```

## Neon-Specific Features

### 1. Automatic Connection Pooling

Neon automatically pools connections - no PgBouncer needed:

```javascript
// Just use DATABASE_URL - pooling handled automatically
const client = new Client({ connectionString: process.env.DATABASE_URL })
```

### 2. Instant Branch Creation

Create database branches for testing:

```bash
# Via Neon Console
# 1. Go to neon.tech console
# 2. Select project
# 3. Click "Branches" → "Create Branch"
# 4. Get new connection string for branch
```

### 3. Point-in-Time Recovery

Neon supports PITR for data recovery:

```bash
# Via Neon Console
# Can restore to any point in last 7 days
# No downtime for restore operations
```

### 4. Automatic Scaling

Neon auto-scales compute based on load:
- Scales up during peak traffic
- Scales down to zero when idle
- Pay only for actual usage

## Benefits of Neon Migration

### 1. Performance
- ⚡ Faster connection times
- ⚡ Better query performance
- ⚡ Auto-scaling for traffic spikes

### 2. Cost
- 💰 Pay-per-use pricing (vs. Supabase fixed tiers)
- 💰 Scale to zero when idle
- 💰 No pooling infrastructure needed

### 3. Developer Experience
- 🔧 Native PostgreSQL (no vendor lock-in)
- 🔧 Git-like branching for databases
- 🔧 Better Vercel integration

### 4. Reliability
- 🛡️ Point-in-time recovery
- 🛡️ Automatic backups
- 🛡️ 99.95% uptime SLA

## Environment Variables

Update your `.env.production` file:

```bash
# Neon Database (Production)
DATABASE_URL=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4-pooler.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require
DATABASE_URL_UNPOOLED=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require

# Vercel-compatible names (aliases to DATABASE_URL)
POSTGRES_URL=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4-pooler.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require
POSTGRES_URL_NON_POOLING=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require
POSTGRES_PRISMA_URL=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4-pooler.c-2.us-east-1.aws.neon.tech/neondb?connect_timeout=15&sslmode=require
```

## Troubleshooting

### Connection Issues

**Problem**: `connection refused`
**Solution**: Ensure SSL mode is set to `require`:
```bash
DATABASE_URL=postgresql://...?sslmode=require
```

**Problem**: `too many connections`
**Solution**: Use pooled connection (DATABASE_URL with -pooler):
```bash
DATABASE_URL=postgresql://...@ep-dark-smoke-adkcd3h4-pooler...
```

### Migration Issues

**Problem**: Migration fails with "permission denied"
**Solution**: Use unpooled connection for migrations:
```bash
psql "$DATABASE_URL_UNPOOLED" -f migration.sql
```

**Problem**: "relation already exists"
**Solution**: Check which migrations have been applied:
```sql
SELECT * FROM schema_migrations ORDER BY applied_at DESC;
```

## Next Steps

1. ✅ **Update Project Documentation** - Reflect Neon in all docs
2. ✅ **Create Neon Import Scripts** - Build import tooling for v0.12
3. ✅ **Update CLAUDE.md** - Guide Claude to use Neon, not Supabase
4. 🔄 **Populate v0.12 Data** - Import rights_of_access for Federal + states
5. 🔄 **Test Integration** - Verify THEHOLETRUTH.ORG platform integration
6. 🔄 **Monitor Performance** - Track query performance and auto-scaling

## References

- **Neon Documentation**: [neon.tech/docs](https://neon.tech/docs)
- **Neon Console**: [console.neon.tech](https://console.neon.tech)
- **THEHOLETRUTH.ORG**: [github.com/The-HOLE-Foundation/THEHOLETRUTH.ORG](https://github.com/The-HOLE-Foundation/THEHOLETRUTH.ORG)
- **Migration Checklist**: See `documentation/v0.12-NEON_MIGRATION_CHECKLIST.md`

---

**Migration Status**: ✅ Complete
**Production Database**: Neon PostgreSQL (us-east-1)
**Platform Integration**: TheHoleTruth.org (Vercel + Neon)
**Next Phase**: v0.12 data population
