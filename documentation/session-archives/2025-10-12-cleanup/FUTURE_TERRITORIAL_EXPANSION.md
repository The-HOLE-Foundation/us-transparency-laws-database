---
DATE: 2025-10-10
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
TYPE: Future Expansion Planning
VERSION: v0.13+
---

# Future Territorial Expansion Plan

## Current Status

**v0.12 Coverage**: 52 jurisdictions
- 1 Federal
- 50 States
- 1 Territory (District of Columbia)

**Database Classification**:
- District of Columbia: Currently classified as `type = 'territory'`
- Pragmatic note: DC functions as the "51st state" for FOIA purposes
- No functional difference in data collection or legal analysis

## Future Expansion (v0.13+)

### Additional US Territories to Add

**Inhabited US Territories** (5):
1. **Puerto Rico** - Population: ~3.2M
   - Has its own public records law
   - Spanish/English bilingual statute
   - Priority: HIGH (larger than 21 states by population)

2. **Guam** - Population: ~170K
   - Freedom of Information Act (Guam)
   - Official statute available
   - Priority: MEDIUM

3. **US Virgin Islands** - Population: ~105K
   - Virgin Islands Open Government Act
   - Official statute available
   - Priority: MEDIUM

4. **American Samoa** - Population: ~55K
   - Public records access provisions
   - Unique territorial status
   - Priority: LOW

5. **Northern Mariana Islands** - Population: ~57K
   - Freedom of Information Act
   - Official statute available
   - Priority: LOW

**Total Future Coverage**: 57 jurisdictions (52 current + 5 territories)

### Tribal Nations Consideration (Future)

**Scope**: 574 federally recognized tribes
**Challenge**: Each has own sovereignty and records laws
**Approach**: Phase in major tribal governments
**Priority**: v0.14+ (after territories complete)

**Potential Pilot**:
- Navajo Nation (largest, ~400K citizens)
- Cherokee Nation (second largest, ~400K citizens)
- Choctaw Nation
- Selected tribes with established public records statutes

## Database Schema Changes (v0.13)

### Option 1: Keep Territory Type (Recommended)

**Pros**:
- Accurate constitutional classification
- Allows filtering by jurisdiction type
- Future-proof for tribal nations, territories
- Maintains legal accuracy

**Cons**:
- Queries need `WHERE type IN ('state', 'territory')`
- Slightly more complex than `WHERE type != 'federal'`

**Schema**:
```sql
CHECK (type IN ('federal', 'state', 'territory', 'tribal'))
```

### Option 2: Reclassify All as "State" for Simplicity

**Pros**:
- Simpler queries: `WHERE type = 'state'`
- Matches common usage ("51 states")
- Reduces complexity

**Cons**:
- Technically inaccurate
- Confusing if we add Puerto Rico (definitely not a state)
- Loses semantic meaning

**Schema**:
```sql
-- DC changed to 'state'
UPDATE jurisdictions SET type = 'state' WHERE id = 'district_of_columbia';
```

### Option 3: Use "State-Equivalent" Type

**Pros**:
- Accurate and flexible
- Works for DC, territories, tribal nations
- Clear semantic meaning

**Cons**:
- New category to maintain
- Queries still need multiple types

**Schema**:
```sql
CHECK (type IN ('federal', 'state', 'state_equivalent'))

-- DC, territories, and tribal nations all use 'state_equivalent'
```

## Recommended Approach

### Phase 1 (v0.12 - Current)

**Keep DC as 'territory'**:
- Accurate classification
- No functional impact
- Queries work fine with `WHERE type IN ('state', 'territory')`

**Rationale**: Changing it now doesn't provide value, and we'll need to change it again when we add Puerto Rico, Guam, etc.

### Phase 2 (v0.13 - Territory Expansion)

**When we add Puerto Rico, Guam, USVI, etc.**:

1. Add all 5 territories as `type = 'territory'`
2. Update all queries to use:
   ```sql
   WHERE type IN ('state', 'territory')  -- All state-like jurisdictions
   WHERE type = 'federal'                 -- Federal only
   WHERE type != 'federal'                -- Everything except federal
   ```
3. Update documentation to say "51 states + DC + 5 territories = 57 jurisdictions"

**Benefit**: Single migration, accurate classification, clear semantics

### Phase 3 (v0.14+ - Tribal Nations)

**When we add tribal nations**:

1. Add new type: `type = 'tribal'`
2. Schema: `CHECK (type IN ('federal', 'state', 'territory', 'tribal'))`
3. Queries remain consistent:
   ```sql
   WHERE type != 'federal'  -- All sub-federal jurisdictions
   ```

## Data Collection Impact

### No Impact on v0.12

**Current v0.12 Work**:
- DC needs rights data collection (just like 37 other states)
- Classification as 'territory' vs 'state' doesn't affect data structure
- Same schema, same fields, same validation

**DC FOIA Statute**: D.C. Code § 2-531 et seq.
- Official source: https://code.dccouncil.gov/us/dc/council/code/titles/2/chapters/5/subchapters/II/
- Full text needed in `statutory-text-files/`
- Rights extraction needed for `rights_of_access` table

### Future Territory Collection (v0.13)

**Puerto Rico** will require:
- Spanish-English bilingual statute collection
- Translation verification
- Cultural context notes
- Same database structure (no schema changes needed)

**Other territories**: Same process as states
- Collect statute text
- Extract rights
- Verify from official sources
- Import to database

## Query Pattern Guidelines

### For Application Developers

**Get all non-federal jurisdictions**:
```sql
-- Current (works with DC as territory)
SELECT * FROM jurisdictions WHERE type != 'federal';

-- Also works
SELECT * FROM jurisdictions WHERE type IN ('state', 'territory');
```

**Get all jurisdictions for map display**:
```sql
-- Simple: exclude federal
SELECT * FROM jurisdictions WHERE type != 'federal' ORDER BY name;
```

**Future-proof** (when we add tribal):
```sql
-- Still works!
SELECT * FROM jurisdictions WHERE type != 'federal';

-- Specific types
SELECT * FROM jurisdictions
WHERE type IN ('state', 'territory', 'tribal')
ORDER BY type, name;
```

## Documentation Updates Needed

### v0.13 Release Notes

**Title**: "US Transparency Laws Database - Now with Territories"

**Summary**:
- Added Puerto Rico, Guam, USVI, American Samoa, Northern Mariana Islands
- 57 total jurisdictions (1 federal + 50 states + 1 DC + 5 territories)
- Bilingual support for Puerto Rico statutes
- All territories verified from official .gov sources

### README.md Update

**Current**:
> This database covers all 52 US jurisdictions (50 states + DC + Federal)

**Future (v0.13)**:
> This database covers 57 US jurisdictions:
> - Federal FOIA
> - 50 US States
> - District of Columbia
> - 5 US Territories (Puerto Rico, Guam, US Virgin Islands, American Samoa, Northern Mariana Islands)

## Timeline

**v0.12** (Current - Q4 2025):
- Complete 52 jurisdictions (Federal + 50 states + DC)
- Keep DC as 'territory' type
- Focus on rights_of_access data collection

**v0.13** (Q1 2026):
- Add 5 US territories
- Puerto Rico bilingual support
- 57 total jurisdictions
- No schema changes needed (just more rows)

**v0.14** (Q2 2026+):
- Begin tribal nations pilot
- Add 'tribal' type to schema
- Start with 3-5 major tribal governments
- Expand based on demand and resources

## Conclusion

**Recommendation for Now**:

**KEEP DC AS 'TERRITORY'** and plan comprehensive reclassification in v0.13 when we add all territories together.

**Why**:
- Accurate classification
- No functional problems
- Avoids multiple migrations
- Future-proof for expansion

**Practical Note**:
When communicating with public, perfectly fine to say "51 states + DC" since most people think of DC as a state anyway. The database classification is for technical accuracy, not public communication.

---

**Next Action**: Fetch DC statute text and add to `statutory-text-files/`
**After That**: Collect DC rights_of_access data
**Future**: v0.13 territorial expansion with all 5 territories together

---

**Document Created**: 2025-10-10
**Review Date**: When planning v0.13 release
**Owner**: The HOLE Foundation Engineering Team
