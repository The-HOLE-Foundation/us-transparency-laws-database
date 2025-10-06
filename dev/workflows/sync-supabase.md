---
DATE: 2025-01-10
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Workflow Automation
VERSION: v0.11
---

# Sync Database with Supabase Workflow

This workflow synchronizes the JSON data structure with Supabase backend, generating necessary migrations and TypeScript types.

## Prerequisites
- Supabase project set up
- Local Supabase CLI configured
- pnpm installed (version >=10.16)
- Clean git working directory

## Overview
This workflow ensures the Supabase database schema matches the current JSON template structure, enabling seamless integration with TheHoleTruth.org platform.

## Execution Steps

### Step 1: Analyze JSON Structure
```bash
# Navigate to project root
cd /Volumes/HOLE-RAID-DRIVE/HOLE/Projects/us-transparency-laws-database

# Analyze current JSON templates
node scripts/analyze-json-structure.js templates/json/STANDARD_JURISDICTION_TEMPLATE_template-v0.11.json
```

This generates schema requirements for Supabase tables:
- `jurisdictions` - Main jurisdiction data
- `transparency_laws` - Law-specific details
- `agencies` - Agency contact information
- `process_maps` - Request procedures
- `tracking_status` - Completion tracking

### Step 2: Review Current Supabase Schema
```bash
# Check current Supabase status
cd supabase
pnpm supabase status

# List existing tables
pnpm supabase db dump --schema public
```

### Step 3: Generate Migration (if needed)
```bash
# Create new migration for schema changes
pnpm supabase migration new update_transparency_schema

# Edit migration file in supabase/migrations/
# Add SQL to create/modify tables matching JSON structure
```

Example migration structure:
```sql
-- Create jurisdictions table
CREATE TABLE IF NOT EXISTS jurisdictions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  level TEXT NOT NULL CHECK (level IN ('state', 'federal')),
  abbreviation TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create transparency_laws table
CREATE TABLE IF NOT EXISTS transparency_laws (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  jurisdiction_id UUID REFERENCES jurisdictions(id),
  statute_citation TEXT NOT NULL,
  statute_url TEXT NOT NULL,
  common_name TEXT,
  response_timeline INTEGER,
  response_timeline_unit TEXT CHECK (response_timeline_unit IN ('business_days', 'calendar_days')),
  extension_allowed BOOLEAN,
  fee_structure JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create agencies table
CREATE TABLE IF NOT EXISTS agencies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  jurisdiction_id UUID REFERENCES jurisdictions(id),
  name TEXT NOT NULL,
  website TEXT,
  foia_contact_email TEXT,
  foia_contact_phone TEXT,
  address JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_jurisdictions_name ON jurisdictions(name);
CREATE INDEX idx_jurisdictions_level ON jurisdictions(level);
CREATE INDEX idx_transparency_laws_jurisdiction ON transparency_laws(jurisdiction_id);
CREATE INDEX idx_agencies_jurisdiction ON agencies(jurisdiction_id);
```

### Step 4: Apply Migration
```bash
# Test migration locally
pnpm supabase db reset

# Apply migration
pnpm supabase migration up

# Verify tables created
pnpm supabase db dump --schema public
```

### Step 5: Generate TypeScript Types
```bash
# Generate types from current schema
pnpm generate:types

# This creates/updates: supabase/types/database.types.ts
```

### Step 6: Populate Database
```bash
# Run data population script
python3 scripts/populate_supabase.py

# This reads JSON files and inserts into Supabase tables
```

Script logic:
1. Read all jurisdiction JSON files
2. Parse data structure
3. Insert into appropriate tables
4. Maintain referential integrity
5. Log any errors for review

### Step 7: Verify Data Integrity
```bash
# Run verification queries
pnpm supabase db query <<EOF
SELECT
  j.name,
  tl.statute_citation,
  COUNT(a.id) as agency_count
FROM jurisdictions j
LEFT JOIN transparency_laws tl ON j.id = tl.jurisdiction_id
LEFT JOIN agencies a ON j.id = a.jurisdiction_id
GROUP BY j.name, tl.statute_citation
ORDER BY j.name;
EOF
```

Expected results:
- 51 jurisdictions (50 states + DC + Federal)
- Each jurisdiction has transparency_law entry
- Agency counts vary by jurisdiction

### Step 8: Update Frontend Types
```bash
# Copy generated types to React platform
cp supabase/types/database.types.ts \
   /path/to/theholetruth-platform/src/types/database.ts

# Update API client configuration
# Ensure Supabase client uses current schema
```

### Step 9: Test API Endpoints
```bash
# Start local Supabase
pnpm supabase start

# Test queries
curl http://localhost:54321/rest/v1/jurisdictions \
  -H "apikey: YOUR_ANON_KEY"

curl http://localhost:54321/rest/v1/transparency_laws?select=*,jurisdictions(*) \
  -H "apikey: YOUR_ANON_KEY"
```

### Step 10: Deploy to Production (when ready)
```bash
# Link to production project
pnpm supabase link --project-ref YOUR_PROJECT_REF

# Push migrations to production
pnpm supabase db push

# Verify production schema
pnpm supabase db dump --schema public --linked
```

## Validation Checklist
- [ ] All JSON templates successfully parsed
- [ ] Migration SQL syntax validated
- [ ] Local database reset and migration applied successfully
- [ ] TypeScript types generated without errors
- [ ] Data population script completes without errors
- [ ] All 51 jurisdictions present in database
- [ ] Referential integrity maintained (no orphaned records)
- [ ] API endpoints return expected data
- [ ] Frontend types updated and compatible

## Common Issues

### Issue: Migration fails due to existing tables
**Solution**: Drop existing tables in migration or use `IF NOT EXISTS` clauses

### Issue: TypeScript generation fails
**Solution**: Check Supabase project connection, verify schema validity

### Issue: Data population encounters duplicates
**Solution**: Add unique constraints, use `ON CONFLICT` clauses in inserts

### Issue: Foreign key violations during population
**Solution**: Populate parent tables (jurisdictions) before child tables (agencies)

### Issue: API returns 401 unauthorized
**Solution**: Check API key configuration, verify RLS policies if enabled

## Security Considerations

### Row Level Security (RLS)
For production deployment, implement RLS policies:
```sql
-- Enable RLS on all tables
ALTER TABLE jurisdictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE transparency_laws ENABLE ROW LEVEL SECURITY;
ALTER TABLE agencies ENABLE ROW LEVEL SECURITY;

-- Allow public read access (transparency is public info)
CREATE POLICY "Public read access" ON jurisdictions
  FOR SELECT USING (true);

CREATE POLICY "Public read access" ON transparency_laws
  FOR SELECT USING (true);

CREATE POLICY "Public read access" ON agencies
  FOR SELECT USING (true);

-- Restrict write access to authenticated admins only
CREATE POLICY "Admin write access" ON jurisdictions
  FOR ALL USING (auth.uid() IN (
    SELECT id FROM admin_users
  ));
```

### API Key Management
- Use environment variables for API keys
- Never commit keys to git
- Rotate keys regularly
- Use separate keys for dev/prod

## Performance Optimization

### Caching Strategy
```typescript
// Implement query caching in React app
const { data, error } = useQuery(
  ['jurisdictions'],
  () => supabase.from('jurisdictions').select('*'),
  {
    staleTime: 1000 * 60 * 60, // 1 hour
    cacheTime: 1000 * 60 * 60 * 24 // 24 hours
  }
);
```

### Database Indexes
Already created in migration:
- Jurisdiction name (frequent lookups)
- Jurisdiction level (filtering state vs federal)
- Foreign keys (join performance)

## Monitoring and Maintenance

### Set up monitoring alerts
1. Database size growth
2. Query performance degradation
3. Failed requests
4. Schema version mismatches

### Regular maintenance tasks
- Weekly: Review query performance
- Monthly: Optimize slow queries
- Quarterly: Review and optimize indexes
- Yearly: Schema review and normalization check

## Success Criteria
- Schema matches JSON structure completely
- All data successfully migrated
- API endpoints functional
- Frontend can query all data
- Performance within acceptable ranges (<100ms queries)
- No data integrity issues

## Estimated Time
- Schema analysis: 10-15 minutes
- Migration creation: 20-30 minutes
- Testing and validation: 15-20 minutes
- Type generation and frontend updates: 10-15 minutes
- **Total: 55-80 minutes**

## Next Steps After Sync
1. Update TheHoleTruth.org to use Supabase data
2. Implement real-time subscriptions if needed
3. Set up backup and recovery procedures
4. Document API endpoints for frontend team
5. Create monitoring dashboard

## Notes
- Always test migrations locally before production
- Keep migration history clean and documented
- Update this workflow as schema evolves
- Document breaking changes clearly
