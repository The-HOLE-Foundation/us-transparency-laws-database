---
DATE: 2025-10-10
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
TYPE: Cleanup Report
VERSION: v0.12
---

# Supabase to Neon Cleanup Report

## Executive Summary

**Issue**: Repository contains legacy Supabase files that could confuse developers
**Solution**: Remove/rename all Supabase references, migrate to Neon-specific documentation
**Status**: Ready for cleanup execution

## Files Requiring Action

### Main Repository (8 files)

| File | Action | Reason | Replacement |
|------|--------|--------|-------------|
| `dev/scripts/get-supabase-keys.js` | ❌ DELETE | Supabase-specific | Use `.env.production` for Neon credentials |
| `dev/scripts/inspect-supabase.py` | ❌ DELETE | Supabase-specific | Use `psql` or `neon-database/scripts/inspect-neon.js` |
| `dev/workflows/sync-supabase.md` | 🔄 RENAME to `sync-neon.md` | Still relevant workflow | Convert to Neon instructions |
| `supabase/supabase-api-documentation(new-experimental).json` | ❌ DELETE | API docs | Neon uses standard PostgreSQL |
| `Transparency-Map-Dataset/import-to-supabase.js` | 🔄 RENAME to `import-to-neon.js` | Core import script | Already have `dev/scripts/import-rights-neon.js` |
| `Transparency-Map-Dataset/supabase-schema.sql` | 🔄 MOVE to `neon-database/migrations/` | Schema reference | Keep for migration history |
| `types/supabase.ts` | 🔄 RENAME to `database.types.ts` | Type definitions | Generate from Prisma |
| `workflows/sync-supabase.md` | 🔄 RENAME to `workflows/sync-neon.md` | Workflow doc | Update for Neon |

### Worktrees (Many duplicate files)

**Pattern**: Each worktree contains copies of:
- `types/supabase.ts`
- `workflows/sync-supabase.md`
- `supabase/supabase-api-documentation(new-experimental).json`
- `Transparency-Map-Dataset/import-to-supabase.js`
- `dev/scripts/get-supabase-keys.js`
- `dev/scripts/inspect-supabase.py`

**Action**: Delete all worktree Supabase files (worktrees should use main repo scripts)

## Migration Strategy

### Phase 1: Delete Obsolete Files ✅

```bash
# Delete Supabase-specific scripts (main repo)
rm dev/scripts/get-supabase-keys.js
rm dev/scripts/inspect-supabase.py
rm supabase/supabase-api-documentation\(new-experimental\).json

# Delete all worktree Supabase files
find worktrees -type f \( -name "*supabase*" -o -path "*/supabase/*" \) -delete
```

### Phase 2: Rename/Migrate Core Files ✅

```bash
# Rename workflows
mv dev/workflows/sync-supabase.md dev/workflows/sync-neon.md
mv workflows/sync-supabase.md workflows/sync-neon.md

# Rename type definitions
mv types/supabase.ts types/database.types.ts

# Move schema to migrations (for historical reference)
mv Transparency-Map-Dataset/supabase-schema.sql neon-database/migrations/00_historical_supabase_schema.sql
```

### Phase 3: Convert Import Scripts ✅

```bash
# Rename and update import script
mv Transparency-Map-Dataset/import-to-supabase.js Transparency-Map-Dataset/import-to-neon.js

# Or better: Delete and use the existing Neon script
rm Transparency-Map-Dataset/import-to-supabase.js
# Use: dev/scripts/import-rights-neon.js instead
```

### Phase 4: Create Neon Replacements ✅

**New files to create**:
- `neon-database/scripts/inspect-neon.js` - Neon database inspection
- `neon-database/documentation/migration-from-supabase.md` - Historical reference
- `types/database.types.ts` - Generated from Prisma schema

## Recommended Cleanup Commands

### Safe Cleanup (Recommended)

```bash
# 1. Delete Supabase-specific files in main repo
rm -f dev/scripts/get-supabase-keys.js
rm -f dev/scripts/inspect-supabase.py
rm -f supabase/supabase-api-documentation\(new-experimental\).json

# 2. Delete ALL Supabase files in worktrees (they shouldn't have their own scripts)
find worktrees -type f \( -name "*supabase*" -o -path "*/supabase/*" \) -delete

# 3. Rename core files to Neon equivalents
mv dev/workflows/sync-supabase.md dev/workflows/sync-neon.md
mv workflows/sync-supabase.md workflows/sync-neon.md
mv types/supabase.ts types/database.types.ts

# 4. Move schema for historical reference
mv Transparency-Map-Dataset/supabase-schema.sql neon-database/migrations/00_historical_supabase_schema.sql

# 5. Delete or rename import script (we already have import-rights-neon.js)
rm -f Transparency-Map-Dataset/import-to-supabase.js
```

### Verify Cleanup

```bash
# Should return NOTHING:
find . -type f \( -name "*supabase*" -o -path "*/supabase/*" \) ! -path "*/node_modules/*" ! -path "*/.git/*"

# If anything shows up, delete it
```

## Replacement Documentation

### New Neon-Specific Files

**Created**:
- ✅ `neon-database/README.md` - Main documentation hub
- ✅ `neon-database/documentation/connection-guide.md` - How to connect
- 🔄 `neon-database/scripts/inspect-neon.js` - Database inspection (to create)
- 🔄 `neon-database/documentation/migration-from-supabase.md` - Historical context (to create)

**To Create**:
1. `neon-database/scripts/inspect-neon.js` - Replace `inspect-supabase.py`
2. `neon-database/documentation/query-patterns.md` - Common SQL queries
3. `neon-database/documentation/schema-overview.md` - Database structure
4. `types/database.types.ts` - Generate from Prisma

## Updated References

### Update CLAUDE.md

Change all mentions of Supabase to Neon:

**OLD**:
```markdown
- **Supabase Backend**: Full Supabase integration with TypeScript types
```

**NEW**:
```markdown
- **Neon Backend**: PostgreSQL database with automatic connection pooling
```

### Update README.md

**OLD**:
```markdown
All 52 jurisdictions are now deployed to Supabase.
```

**NEW**:
```markdown
All 52 jurisdictions are deployed to Neon PostgreSQL database.
```

### Update Package.json Scripts

**OLD**:
```json
{
  "scripts": {
    "generate:types": "supabase gen types typescript --local > types/supabase.ts"
  }
}
```

**NEW**:
```json
{
  "scripts": {
    "generate:types": "npx prisma generate",
    "db:pull": "npx prisma db pull",
    "db:push": "npx prisma db push"
  }
}
```

## Risk Assessment

### Low Risk ✅
- Deleting Supabase-specific scripts (`get-supabase-keys.js`, `inspect-supabase.py`)
- Deleting API documentation (Neon uses standard PostgreSQL)
- Deleting worktree Supabase files (they're duplicates)

### Medium Risk ⚠️
- Renaming `types/supabase.ts` (check for imports first)
- Moving schema SQL (keep for historical reference)

### Check Before Deletion

```bash
# Check if anything imports supabase.ts
grep -r "from.*supabase" --include="*.ts" --include="*.tsx" --include="*.js" .

# Check if any scripts reference Supabase files
grep -r "supabase" --include="*.sh" --include="*.py" --include="*.js" .
```

## Post-Cleanup Verification

### 1. Check for remaining references
```bash
# Should return ZERO results:
find . -type f -name "*supabase*" ! -path "*/node_modules/*" ! -path "*/.git/*"
```

### 2. Verify imports work
```bash
# Check TypeScript compilation
npm run build

# Check if any imports broke
npm test
```

### 3. Update documentation
```bash
# Search for "Supabase" in docs
grep -r "Supabase" --include="*.md" .

# Update each occurrence to "Neon"
```

## Benefits After Cleanup

1. ✅ **No confusion** - Developers won't think this is a Supabase project
2. ✅ **Cleaner codebase** - Remove legacy files
3. ✅ **Better documentation** - Neon-specific guides
4. ✅ **Easier onboarding** - Clear database setup instructions
5. ✅ **Maintainability** - Single source of truth for database operations

## Rollback Plan

If issues arise:

```bash
# Restore from git history
git checkout HEAD~1 -- types/supabase.ts
git checkout HEAD~1 -- dev/scripts/get-supabase-keys.js

# Or restore entire state
git reset --hard HEAD~1
```

## Next Steps

1. **Execute cleanup commands** (see "Recommended Cleanup Commands" above)
2. **Create Neon replacement scripts** (inspect-neon.js, etc.)
3. **Update all documentation** (CLAUDE.md, README.md)
4. **Generate new types** from Prisma schema
5. **Verify everything works** with Neon database
6. **Commit changes** with clear message about Supabase removal

---

**Estimated Time**: 30 minutes
**Risk Level**: Low (mostly deletions and renames)
**Impact**: High (eliminates confusion, improves clarity)
**Status**: Ready to execute
