---
DATE: 2025-10-07
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Supabase Branch Migration
VERSION: v0.11.1
---

# Supabase Branch Migration Guide

**Objective**: Promote the Development branch to Production after successful v0.11.1 deployment

## Current State

### Development Branch (befpnwcokngtrljxskfz) ✅
- **Status**: Production Ready
- **Data**: All 52 jurisdictions imported successfully
- **Schema**: 10 tables + 1 view deployed
- **Migrations**: 7 migrations applied cleanly
- **Verification**: All tables verified, zero data loss

### Production Branch (ctxhmgmeflnemjfzyabr) ❌
- **Status**: Corrupted (previous issues)
- **Data**: Empty or inconsistent
- **Schema**: Problematic migration state
- **Issues**: Permission errors, schema cache problems

## Migration Strategy Options

### Option 1: Direct Data Migration (RECOMMENDED)

**Pros**:
- Cleanest approach
- Preserves production branch credentials
- No URL changes needed in applications

**Cons**:
- Requires careful migration execution
- Temporary downtime during migration

**Steps**:

1. **Backup Development Data**
   ```bash
   # Export all data from development
   npx supabase db dump --linked --data-only > backup-dev-data.sql

   # Export schema
   npx supabase db dump --linked --schema-only > backup-dev-schema.sql
   ```

2. **Switch to Production Branch**
   ```bash
   # Update project reference
   echo "ctxhmgmeflnemjfzyabr" > supabase/.temp/project-ref

   # Link to production
   npx supabase link --project-ref ctxhmgmeflnemjfzyabr
   ```

3. **Clean Production Database**
   ```bash
   # Drop all existing tables (fresh start)
   npx supabase db reset --linked
   ```

4. **Deploy Clean Schema to Production**
   ```bash
   # Push all migrations
   npx supabase db push --linked
   ```

5. **Import Data to Production**
   ```bash
   # Import data
   psql "postgresql://postgres:PASSWORD@db.ctxhmgmeflnemjfzyabr.supabase.co:5432/postgres" < backup-dev-data.sql
   ```

6. **Verify Production Deployment**
   ```bash
   # Run verification script with production credentials
   node dev/scripts/verify-schema.js
   ```

### Option 2: Make Development the New Production (EASIER)

**Pros**:
- Zero migration work
- Already verified working
- Immediate deployment

**Cons**:
- Applications must update Supabase URL
- Loses "production" branch name
- Development branch becomes permanent

**Steps**:

1. **Rename Branches in Supabase Dashboard**
   - Go to Supabase Dashboard
   - Navigate to Project Settings
   - Rename "Development" → "Production"
   - Archive old production branch

2. **Update Application Configurations**
   - Update theholetruth-platform/.env:
     ```env
     NEXT_PUBLIC_SUPABASE_URL=https://befpnwcokngtrljxskfz.supabase.co
     NEXT_PUBLIC_SUPABASE_ANON_KEY=<development_anon_key>
     ```
   - Update theholefoundation.org/.env similarly

3. **Update Repository Documentation**
   - Update README.md with new production URL
   - Update all documentation references

### Option 3: Pause and Use Development as Staging

**Pros**:
- Most conservative approach
- Allows thorough testing before production
- Can configure authentication on development first

**Cons**:
- Delays production deployment
- Requires eventual migration anyway

**Steps**:

1. **Configure Authentication on Development**
   - Set up Supabase Auth
   - Test authentication flows
   - Verify RLS policies

2. **Test Platform Integration**
   - Connect React applications
   - Test all features thoroughly
   - Performance testing

3. **Then Migrate to Production** (using Option 1 or 2)

## Recommended Approach

**Use Option 2: Make Development the New Production**

### Rationale:
1. Development branch is **verified working** with all data
2. Zero risk of migration errors
3. Can deploy immediately
4. Cleaner than fixing corrupted production branch
5. URL change is one-time configuration update

### Implementation Plan:

#### Step 1: Verify Development Branch (Already Done ✅)
- [x] All 52 jurisdictions imported
- [x] All tables verified
- [x] Zero data loss confirmed
- [x] Schema documentation complete

#### Step 2: Configure as Production
```bash
# No code changes needed - development IS production ready
```

#### Step 3: Update Application Environment Variables

**theholetruth-platform/.env.production**:
```env
NEXT_PUBLIC_SUPABASE_URL=https://befpnwcokngtrljxskfz.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJlZnBud2Nva25ndHJsanhza2Z6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3ODA3NjAsImV4cCI6MjA3NTM1Njc2MH0.fCvpOqf2Kf7x1BQqKV8CfSuTQ9b5c9Z8j7_Q9gH1h5E
```

**theholefoundation.org/.env.production**:
```env
NEXT_PUBLIC_SUPABASE_URL=https://befpnwcokngtrljxskfz.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJlZnBud2Nva25ndHJsanhza2Z6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3ODA3NjAsImV4cCI6MjA3NTM1Njc2MH0.fCvpOqf2Kf7x1BQqKV8CfSuTQ9b5c9Z8j7_Q9gH1h5E
```

#### Step 4: Update Repository Documentation

Files to update:
- [x] README.md - Production URL references
- [x] CLAUDE.md - Database connection examples
- [x] documentation/v0.11.1_SUPABASE_INTEGRATION_COMPLETE.md
- [ ] dev/scripts/verify-schema.js (update default URL comment)

#### Step 5: Archive Old Production Branch

In Supabase Dashboard:
1. Navigate to old production project (ctxhmgmeflnemjfzyabr)
2. Pause project (to save costs)
3. Document as "Archived - Replaced by v0.11.1 deployment"

#### Step 6: Rename Development Branch (Optional)

In Supabase Dashboard:
1. Project Settings → General
2. Change project name from "Development" to "Production - v0.11.1"
3. Update organization settings if needed

## Post-Migration Verification

### Checklist:
- [ ] All 10 tables accessible via REST API
- [ ] transparency_map_display view returns 52 jurisdictions
- [ ] Exemptions table returns 365 records
- [ ] Authentication providers configured (next phase)
- [ ] RLS policies applied (next phase)
- [ ] TypeScript types generated
- [ ] React applications connect successfully
- [ ] No 401/403 errors with anon key
- [ ] Performance acceptable (<100ms for map queries)

### Verification Commands:

```bash
# Verify table counts
curl "https://befpnwcokngtrljxskfz.supabase.co/rest/v1/jurisdictions?select=count" \
  -H "apikey: ANON_KEY" \
  -H "Authorization: Bearer ANON_KEY"

# Verify transparency map view
curl "https://befpnwcokngtrljxskfz.supabase.co/rest/v1/transparency_map_display?select=jurisdiction_name,response_timeline_days&limit=5" \
  -H "apikey: ANON_KEY" \
  -H "Authorization: Bearer ANON_KEY"

# Verify exemptions with jurisdiction context
curl "https://befpnwcokngtrljxskfz.supabase.co/rest/v1/exemptions?jurisdiction_name=eq.California&select=category,description&limit=5" \
  -H "apikey: ANON_KEY" \
  -H "Authorization: Bearer ANON_KEY"
```

## Rollback Plan

If issues discovered after migration:

1. **Immediate Rollback** (if using Option 1):
   ```bash
   # Restore from backup
   psql "postgresql://postgres:PASSWORD@db.ctxhmgmeflnemjfzyabr.supabase.co:5432/postgres" < backup-dev-data.sql
   ```

2. **No Rollback Needed** (if using Option 2):
   - Development branch remains unchanged
   - Simply revert application environment variables if needed

## Next Steps After Migration

1. **Configure Authentication** (Phase 2)
   - Set up OAuth providers (Google, GitHub)
   - Configure email authentication
   - Set up RLS policies
   - Test authentication flows

2. **Platform Integration** (Phase 3)
   - Connect theholetruth-platform
   - Implement Transparency Map
   - Build Wiki interface
   - Develop FOIA Generator

3. **Performance Optimization**
   - Add database indexes as needed
   - Configure caching strategies
   - Monitor query performance
   - Optimize slow queries

4. **Monitoring Setup**
   - Configure Supabase logging
   - Set up error tracking
   - Monitor API usage
   - Track query performance

---

## Summary

**Recommended**: Use Option 2 (Make Development the New Production)

**Why**: Development branch is fully verified, tested, and production-ready. The URL change is a simple one-time configuration update that's safer than attempting to fix the corrupted production branch.

**Timeline**: Immediate deployment possible - just update environment variables

**Risk**: Minimal - development branch already verified working
