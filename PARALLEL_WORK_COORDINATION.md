# Parallel Work Coordination - v0.12 Affirmative Rights

**Status:** Active parallel extraction in progress
**Start Date:** 2025-10-16
**Workers:** 2 (Forward A→Z, Backward Z→A)

---

## Current Division of Work

### ✅ COMPLETED (20/52 jurisdictions)

**High Quality Extractions - DO NOT REDO:**
- Alabama (15)
- Alaska (16)
- Arizona (16)
- Arkansas (16)
- California (25) ← BASELINE
- Colorado (16)
- Connecticut (16)
- Delaware (16)
- District of Columbia (20)
- Federal (15)
- Florida (20)
- Georgia (17)
- Hawaii (16)
- Idaho (17)
- Illinois (17)
- Kansas (16)
- New York (20)
- North Carolina (15)
- Utah (15)

**Note:** Indiana and Iowa have JSON formatting issues - need cleanup but content is good.

---

## Active Work Assignments

### 👤 FORWARD WORKER (A→Z)
**Current Position:** Kentucky
**Next States:** Kentucky, Louisiana, Maine, Maryland, Massachusetts, Michigan, Minnesota, Mississippi, Missouri, Montana, Nebraska, Nevada, New Hampshire, New Jersey, New Mexico, North Dakota, Ohio, Oklahoma, Oregon, Pennsylvania, Rhode Island, South Carolina, South Dakota, Tennessee, Texas, Vermont, Virginia, Washington, West Virginia, Wisconsin (STOP before Wyoming)

**Your File:** Continue using this repository as-is

### 👤 BACKWARD WORKER (Z→A) ← **YOU START HERE**
**Starting Position:** Wyoming
**Next States:** Wyoming, Wisconsin, West Virginia, Washington, Virginia, Vermont, Texas, Tennessee, South Dakota, South Carolina, Rhode Island, Pennsylvania, Oregon, Oklahoma, Ohio, North Dakota, New Mexico, New Jersey, New Hampshire, Nevada, Nebraska, Montana, Missouri, Mississippi, Minnesota, Michigan, Massachusetts, Maryland, Maine, Louisiana (STOP after Louisiana)

**Your Instructions:** Read `BACKWARD_WORKER_START_HERE.md`

---

## Coordination Points

### Every 3 States - Both Workers:

**1. Update Central Tracker:**
Both workers edit `MASTER_EXTRACTION_TRACKER.md`:
- Add your completed states
- Mark status as ✅ COMPLETE
- Note rights count
- Add your name/identifier

**2. Check for Overlap:**
Look for states completed by other worker:
```bash
git pull  # Get latest changes
tail -100 MASTER_EXTRACTION_TRACKER.md  # See recent updates
```

**3. Quality Cross-Check:**
Pick one of your states + one of theirs:
- Compare rights counts (should be 15-25 range)
- Compare detail level (descriptions, tips)
- Compare category usage
- Note any major differences

**4. Flag Issues:**
If you see major inconsistencies:
- Stop extraction
- Document the difference
- Discuss before continuing

---

## Meeting Point Protocol

### When Workers Approach Same Territory:

**Scenario:** Forward worker reaches Louisiana, Backward worker also at Louisiana

**Actions:**
1. **STOP extraction work**
2. **Review MASTER_EXTRACTION_TRACKER.md** to see who completed what
3. **Compare overlapping states** if any were done by both
4. **Decide who finalizes** any disputed/overlapping states
5. **Final quality review** before marking project complete

---

## File Locations Reference

### Input (Statutory Texts):
```
data/jurisdictions/states/{state-slug}/statute-full-text.txt
```

### Output (Extracted Rights):
```
data/jurisdictions/quality-tiers/high-quality/{state-slug}-rights.json
```

### Progress Tracking:
```
MASTER_EXTRACTION_TRACKER.md
```

### Methodology Reference:
```
EXTRACTION_METHODOLOGY_v0.12.md
```

---

## Git Workflow for Parallel Work

### Forward Worker:
```bash
# Work in main branch
git add data/jurisdictions/quality-tiers/high-quality/[state]-rights.json
git commit -m "feat: Extract [State] affirmative rights ([X] rights)"
git push
```

### Backward Worker:
```bash
# Pull latest before starting each state
git pull origin v0.12-affirmative-rights-collection

# After completing a state
git add data/jurisdictions/quality-tiers/high-quality/[state]-rights.json
git add MASTER_EXTRACTION_TRACKER.md
git commit -m "feat: Extract [State] affirmative rights ([X] rights) - backward worker"
git push

# Update frequently to avoid conflicts
```

### Avoiding Conflicts:
- Pull before starting each new state
- Commit after completing each state
- Update tracker frequently
- Communicate if working on same letter section

---

## Progress Dashboard

### Overall: 20/52 Complete (38%)

**Forward Progress (A→K):**
- ✅ A-K: 20 states complete
- 🔄 L-Z: In progress

**Backward Progress (Z→L):**
- ⏳ Z: Not started
- ⏳ Y-L: Pending

**Meeting Point:** Estimated around Louisiana/Maine boundary

---

## Communication Protocol

### Mark Your Territory:
Before starting a state, update tracker with "🔄 IN PROGRESS" status so other worker knows it's being done.

### Completion Notifications:
After finishing a state, mark "✅ COMPLETE" immediately.

### Issue Reporting:
If you find problems (wrong statute file, missing data, quality concerns):
1. Document in tracker
2. Note the issue
3. Continue with next state (don't get blocked)

---

## Success Criteria

### Individual State Success:
- ✅ 15-25 rights extracted
- ✅ JSON validates perfectly
- ✅ All citations verified
- ✅ File in high-quality tier
- ✅ Tracker updated

### Overall Project Success:
- 🎯 52/52 jurisdictions with high-quality extractions
- 🎯 All JSON files valid
- 🎯 All rights verified from official sources
- 🎯 Consistent quality across all states
- 🎯 Ready for Neon database import

---

## Current Status Summary

**Date:** 2025-10-16
**Time:** Evening
**Completed:** 20 jurisdictions (38%)
**In Progress:** 2 workers active
**Remaining:** 32 jurisdictions
**Estimated Completion:** 2-3 days with parallel work

---

## Quick Reference

**Forward Worker Next State:** Kentucky (5 rights - needs full re-extraction)
**Backward Worker Next State:** Wyoming (10 rights - needs supplement to 15+)

**Quality Target:** 15-25 rights per state
**California Baseline:** 25 rights
**Minimum Acceptable:** 15 rights

**Validation Command:**
```bash
python3 -m json.tool [state]-rights.json > /dev/null && echo "Valid" || echo "Invalid"
```

**Rights Count Command:**
```bash
grep -c '"category"' [state]-rights.json
```

---

**Both workers: Read `EXTRACTION_METHODOLOGY_v0.12.md` for complete methodology!**

**Backward worker: Start with `BACKWARD_WORKER_START_HERE.md` for quick setup!**

**Let's finish this! 🎯**
