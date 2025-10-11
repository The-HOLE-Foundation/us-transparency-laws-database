---
DATE: 2025-10-10
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Neon Database Connection Guide
VERSION: v0.12
---

# Neon Database Connection Guide

**Production Database**: Neon PostgreSQL (AWS us-east-1)
**Connection Type**: PostgreSQL with automatic connection pooling

## Quick Connection

### Environment Variables

Add to `.env.production`:

```bash
# Neon Production Database
DATABASE_URL=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4-pooler.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require

# Direct connection for migrations
DATABASE_URL_UNPOOLED=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require

# Prisma-compatible
POSTGRES_PRISMA_URL=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4-pooler.c-2.us-east-1.aws.neon.tech/neondb?connect_timeout=15&sslmode=require
```

### Using psql

```bash
# Connect to database
psql "$DATABASE_URL"

# Run query
psql "$DATABASE_URL" -c "SELECT * FROM jurisdictions LIMIT 5;"

# Execute SQL file
psql "$DATABASE_URL_UNPOOLED" -f migration.sql
```

### Using Node.js

```javascript
import { Client } from 'pg'

const client = new Client({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
})

await client.connect()
const result = await client.query('SELECT * FROM jurisdictions')
await client.end()
```

### Using Prisma

```typescript
// prisma/schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// app code
import { PrismaClient } from '@prisma/client'
const prisma = new PrismaClient()

const jurisdictions = await prisma.jurisdictions.findMany()
```

## Connection Types

### Pooled Connection (Recommended for Apps)

**When to use**: Web applications, API servers, serverless functions

**URL**: `...@ep-dark-smoke-adkcd3h4-pooler...`

**Benefits**:
- Automatic connection pooling
- Better performance for concurrent requests
- No connection limit issues

**Example**:
```bash
DATABASE_URL=postgresql://neondb_owner:...@ep-dark-smoke-adkcd3h4-pooler.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require
```

### Direct Connection (For Migrations)

**When to use**: Database migrations, admin tasks, schema changes

**URL**: `...@ep-dark-smoke-adkcd3h4...` (no -pooler)

**Benefits**:
- Full PostgreSQL feature access
- DDL operations (CREATE, ALTER, DROP)
- Transaction control

**Example**:
```bash
DATABASE_URL_UNPOOLED=postgresql://neondb_owner:...@ep-dark-smoke-adkcd3h4.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require
```

## Connection Security

### SSL/TLS Requirements

All connections MUST use SSL:

```bash
# Always include: ?sslmode=require
postgresql://...?sslmode=require
```

Without SSL, connection will fail.

### SSL in Node.js

```javascript
const client = new Client({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }  // Required for Neon
})
```

## Troubleshooting

### Common Issues

**Issue**: `connection refused`
**Solution**: Check SSL mode is set to `require`

**Issue**: `too many connections`
**Solution**: Use pooled connection (with `-pooler` in hostname)

**Issue**: `permission denied for schema public`
**Solution**: Use direct connection for migrations

### Health Check

```bash
# Test connection
psql "$DATABASE_URL" -c "SELECT version();"

# Check tables
psql "$DATABASE_URL" -c "\dt"

# Count records
psql "$DATABASE_URL" -c "
  SELECT 'jurisdictions' as table, COUNT(*) FROM jurisdictions
  UNION ALL
  SELECT 'exemptions', COUNT(*) FROM exemptions
  UNION ALL
  SELECT 'rights_of_access', COUNT(*) FROM rights_of_access;
"
```

## Performance Tips

1. **Use pooled connection for web apps**
2. **Close connections when done**
3. **Use prepared statements for repeated queries**
4. **Index frequently queried columns**
5. **Monitor connection count**

---

**Next**: [Schema Overview](schema-overview.md) | [Query Patterns](query-patterns.md)
