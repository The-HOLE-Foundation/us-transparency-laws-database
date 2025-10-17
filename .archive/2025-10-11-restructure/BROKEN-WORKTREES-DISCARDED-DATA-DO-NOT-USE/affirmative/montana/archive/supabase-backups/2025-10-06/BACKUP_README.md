# Supabase Production Database Backup

**Date**: October 6, 2025
**Reason**: Pre-wipe backup before deploying v0.11.1 schema

## Contents

### schema_backup.sql (1,048 lines)
- Complete PostgreSQL schema from production
- Includes all tables, functions, triggers, RLS policies
- Custom functions:
  - `before_user_created_hook()` - User metadata
  - `custom_access_token_hook()` - JWT customization
  - Additional auth-related functions

### data_backup.sql (772 lines)
- All data from production database
- Ready to restore if needed

## Migration History (Before Wipe)

14 migrations existed in production database:
- 20240906032500 (2024-09-06)
- 20240906040000 (2024-09-06)
- 20240906040100 (2024-09-06)
- 20240906050000 (2024-09-06)
- 20250912100016 (2025-09-12)
- 20250914055120 (2025-09-14)
- 20250922022650 (2025-09-22)
- 20250923055128 (2025-09-23)
- 20250923080658 (2025-09-23)
- 20250923100956 (2025-09-23)
- 20250923101022 (2025-09-23)
- 20250923101054 (2025-09-23)
- 20251003023707 (2025-10-03)
- 00000000000001 (v0.11.1 initial - local only)

## Restore Instructions

If you need to restore this backup:

```bash
# Restore schema
psql $DATABASE_URL < schema_backup.sql

# Restore data
psql $DATABASE_URL < data_backup.sql
```

Or using Supabase CLI:
```bash
supabase db reset --linked
psql $DATABASE_URL < schema_backup.sql
psql $DATABASE_URL < data_backup.sql
```

## Next Steps (After This Backup)

1. Reset production database
2. Apply v0.11.1 migrations
3. Import v0.11.0 jurisdiction data (52 jurisdictions)
4. Generate TypeScript types
5. Test platform integration

---

**Backup Created By**: Claude Code AI Assistant
**Project**: US Transparency Laws Database v0.11.1
