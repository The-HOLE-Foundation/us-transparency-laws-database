# HIGH QUALITY Rights Data (15+ rights per jurisdiction)

**Status**: ✅ READY FOR DATABASE IMPORT
**Count**: 12 jurisdictions
**Quality**: Detailed, complete, California-standard extraction

## Jurisdictions in This Tier

1. California (25 rights) - **BASELINE**
2. Florida (20 rights)
3. New York (20 rights)
4. District of Columbia (20 rights)
5. Georgia (17 rights)
6. Connecticut (16 rights)
7. Alaska (16 rights)
8. Colorado (16 rights)
9. Delaware (16 rights)
10. Utah (15 rights)
11. North Carolina (15 rights)
12. Federal (15 rights)

## Quality Characteristics

✅ Comprehensive extraction (15+ rights)
✅ Detailed descriptions with context
✅ Implementation notes explain practical use
✅ Request tips with assertion language
✅ Multiple categories covered
✅ Specific statutory citations
✅ Conditions clearly stated

## Next Action

Import to Neon database immediately using:
```bash
for file in data/jurisdictions/quality-tiers/high-quality/*-rights.json; do
  node scripts/import-rights-to-neon.js "$file"
done
```
