---
DATE: 2025-01-10
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Workflow Automation
VERSION: v0.11
---

# Add New Jurisdiction Workflow

This workflow automates the complete process of adding a new state or federal jurisdiction to the transparency laws database.

## Prerequisites
- Access to official state/federal .gov website
- State statute citation or URL
- Clean git working directory

## Required Inputs (will prompt during execution)
1. **Jurisdiction Name**: Full state name (e.g., "Texas", "California") or "Federal"
2. **Official Statute URL**: Direct link to official .gov statute page
3. **Primary Citation**: Official statute citation (e.g., "Tex. Gov't Code § 552")
4. **Response Timeline**: Number of days and type (business/calendar)
5. **Fee Structure**: Standard fee per page (if applicable)

## Execution Steps

### Step 1: Validate Source
- Confirm URL is from official .gov domain
- Verify statute authenticity
- Check for most recent version
- Document verification date

### Step 2: Create Directory Structure
```bash
# Create state directory if needed
mkdir -p data/states/[state-name-lowercase]
```

### Step 3: Copy Template
```bash
# Copy standard jurisdiction template
cp templates/json/STANDARD_JURISDICTION_TEMPLATE_template-v0.11.json \
   data/states/[state-name-lowercase]/agencies.json
```

### Step 4: Populate Template
Fill in the following sections in `agencies.json`:
- `jurisdiction_info.name`
- `jurisdiction_info.level` (state/federal)
- `jurisdiction_info.abbreviation`
- `transparency_law.statute_citation`
- `transparency_law.statute_url`
- `transparency_law.common_name`
- `transparency_law.response_timeline`
- `transparency_law.response_timeline_unit`
- `transparency_law.extension_allowed`
- `transparency_law.fee_structure`
- `validation_metadata.last_verified_date`
- `validation_metadata.primary_sources[]`

### Step 5: Create Process Map
```bash
# Copy process map template
cp templates/markdown/PROCESS_MAP_TEMPLATE.md \
   consolidated-transparency-data/verified-process-maps/[state-name-lowercase]-process-map.md
```

Fill in process map with:
- Request submission procedures
- Timeline expectations
- Appeal process
- Fee payment methods
- Common exemptions

### Step 6: Update Tracking Table
Edit `data/consolidated/master_tracking_table-template.json`:
```json
{
  "jurisdiction": "[State Name]",
  "priority": "[1/2/3]",
  "statute_collection": "complete",
  "agency_data_collection": "in_progress",
  "template_creation": "complete",
  "last_updated": "[YYYY-MM-DD]"
}
```

### Step 7: Run Validation
```bash
# Validate JSON syntax
python3 scripts/validate_data.py data/states/[state-name-lowercase]/agencies.json

# Verify sources
python3 scripts/verify_sources.py [state-name-lowercase]

# Check Supabase compatibility
python3 scripts/check_supabase.sh
```

### Step 8: Commit Changes
```bash
# Stage all changes
git add .

# Commit with descriptive message
git commit -m "feat: Add [State Name] transparency law data

- Added agencies.json with complete statute details
- Created process map for request procedures
- Updated master tracking table
- All data verified from official .gov sources
- Validation tests passing

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Validation Checklist
Before completing, verify:
- [ ] All URLs point to official .gov sites
- [ ] Statute citation is accurate
- [ ] Response timeline correctly specified (business/calendar days)
- [ ] Fee structure matches statutory language
- [ ] Process map includes all required steps
- [ ] Tracking table updated
- [ ] All validation scripts pass
- [ ] Git commit includes proper documentation

## Common Issues

### Issue: Statute URL not accessible
**Solution**: Check for https vs http, verify URL is current, search official state code database

### Issue: Multiple statutes apply
**Solution**: Document all applicable statutes in `transparency_law.related_statutes[]` array

### Issue: Response timeline varies by request type
**Solution**: Use base timeline for standard requests, note variations in process map

### Issue: Validation script fails
**Solution**: Check JSON syntax, verify all required fields populated, ensure no trailing commas

## Success Criteria
- All validation scripts pass without errors
- Data verified from official government sources only
- Tracking table shows "complete" status
- Process map provides clear, actionable guidance
- Git commit properly documented

## Next Steps After Completion
1. Sync changes to Supabase database
2. Update TheHoleTruth.org map visualization
3. Add jurisdiction to wiki content
4. Test FOIA generator with new jurisdiction
5. Update deployment documentation

## Estimated Time
- Research and verification: 30-45 minutes
- Template population: 15-20 minutes
- Process map creation: 20-30 minutes
- Validation and testing: 10-15 minutes
- **Total: 75-110 minutes per jurisdiction**

## Notes
- Always verify data from official sources
- Never use AI-generated legal summaries
- Document verification date in metadata
- Include direct URLs to primary sources
- Update this workflow based on learnings
