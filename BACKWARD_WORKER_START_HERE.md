# Backward Worker - START HERE
## Working Z→A (Wyoming to Louisiana)

**Your Role:** Extract affirmative rights for states Wyoming → Louisiana (backward alphabetically)

---

## Quick Start (5 Minutes)

### 1. Read Full Methodology
📖 **Read:** `EXTRACTION_METHODOLOGY_v0.12.md` (complete instructions)

### 2. Check Current Progress
📊 **Review:** `MASTER_EXTRACTION_TRACKER.md` (see what's done)

**Current Status:**
- ✅ Forward worker completed: A-K (20 states done - 38%)
- 🎯 Your assignment: Z-L (32 states)
- 🤝 Meeting point: Around Louisiana/Maine

### 3. Your First State: WYOMING

**File to read:**
```
data/jurisdictions/states/wyoming/statute-full-text.txt
```

**Current status:** 10 rights (MEDIUM quality - needs review/supplement)

**Your task:**
1. Read Wyoming's ENTIRE statute
2. Extract ALL affirmative rights (target: 15-25)
3. Create: `data/jurisdictions/quality-tiers/high-quality/wyoming-rights.json`
4. Validate JSON
5. Update tracker

---

## States You'll Process (Z→A Order)

### Your 32 States:

**W's (4 states):**
1. Wyoming ← **START HERE**
2. Wisconsin
3. West Virginia
4. Washington

**V's (2 states):**
5. Virginia
6. Vermont

**U's (0 states):**
- Utah ✅ SKIP (already complete)

**T's (2 states):**
7. Texas
8. Tennessee

**S's (2 states):**
9. South Dakota
10. South Carolina

**R's (1 state):**
11. Rhode Island

**P's (1 state):**
12. Pennsylvania

**O's (3 states):**
13. Oregon
14. Oklahoma
15. Ohio

**N's (5 states):**
16. North Dakota
17. New York ✅ SKIP (already complete)
18. New Mexico
19. New Jersey
20. New Hampshire
21. Nevada
22. Nebraska

**M's (8 states):**
23. Montana
24. Missouri
25. Mississippi
26. Minnesota
27. Michigan
28. Massachusetts
29. Maryland
30. Maine

**L's (1 state):**
31. Louisiana ← **STOP HERE**

**STOP at Louisiana.** Forward worker will complete Kentucky and earlier alphabetically.

---

## Extraction Template (Copy This for Each State)

```json
{
  "jurisdiction": {
    "name": "Wyoming",
    "slug": "wyoming",
    "type": "state",
    "transparency_law": "Wyoming Public Records Act"
  },
  "validation_metadata": {
    "parsed_date": "2025-10-16",
    "source_url": "https://[official .gov URL]",
    "verified_by": "[YOUR NAME]",
    "verification_method": "Complete manual review of W.S. § 16-4-201 et seq.",
    "statutory_text_file": "statute-full-text.txt"
  },
  "rights_of_access": [
    {
      "category": "[Category]",
      "subcategory": "[Subcategory]",
      "statute_citation": "[Citation]",
      "description": "[Description]",
      "conditions": "[Conditions]",
      "applies_to": "[Who]",
      "implementation_notes": "[How it works]",
      "request_tips": "[Exact language to use]"
    }
  ]
}
```

---

## Quality Standard: California Baseline

**California has 25 rights** - this is your quality target.

**If your state has:**
- ✅ 15-25 rights → HIGH QUALITY (good!)
- ⚠️ 10-14 rights → Check again (might have missed some)
- ❌ <10 rights → Definitely incomplete (review entire statute again)

---

## Progress Tracking Protocol

### After EVERY 3 states:

**1. Update Progress Tracker:**

Edit `MASTER_EXTRACTION_TRACKER.md` and add:

```markdown
### Wyoming
- **Status:** ✅ COMPLETE (17 rights - High Quality)
- **File:** `quality-tiers/high-quality/wyoming-rights.json`
- **Extracted:** 2025-10-16
- **Extractor:** [Your Name]
- **Original:** 10 rights → **Final:** 17 rights
- **Notes:** Supplemented with 7 missing rights from full statute review
```

**2. Check Forward Worker Progress:**

See if forward worker completed any new states:
```bash
tail -50 MASTER_EXTRACTION_TRACKER.md
```

**3. Cross-Check Quality:**

Compare one of your states to one of theirs:
- Similar rights count? (15-25 range)
- Similar detail level?
- Same category usage?
- Consistent citation format?

**If major differences:** Note in tracker and discuss.

---

## Common Rights to Look For

### In EVERY state statute, look for:

**Response Deadlines:**
- "Agency shall respond within [X] days"
- "Acknowledgment within [Y] days"
- "Records provided within [Z] days"
→ These are Timeliness Rights!

**Fee Provisions:**
- "Fee shall not exceed [amount]"
- "First [X] pages provided free"
- "Actual cost only"
- "Fee waiver if [public interest]"
→ These are Fee Waiver Rights!

**Procedures:**
- "Request may be made by [email/phone/mail]"
- "No purpose statement required"
- "Records provided in [electronic format]"
→ These are Technology/Requester-Specific Rights!

**Enforcement:**
- "Attorney fees available"
- "Appeal to [AG/Ombudsman/Court]"
- "Burden of proof on agency"
- "Penalties for violations"
→ These are Enhanced Access/Appeal Rights!

---

## Example: Wyoming (Your First State)

### Current Status:
- Medium quality (10 rights)
- File exists but incomplete
- Needs supplementation or full re-extraction

### What to Do:

**Step 1:** Read `data/jurisdictions/states/wyoming/statute-full-text.txt` (entire file)

**Step 2:** Extract rights. You should find approximately:
- 7-day acknowledgment
- 30-day production
- Immediate release for available records
- Designated records person
- Public records ombudsman
- Attorney fees
- No ID/purpose required
- Electronic parity
- Business hours access
- Burden on agency
- In camera review
- Good cause extensions
- (and more...)

**Expected: 15-20 rights total**

**Step 3:** Compare to current 10-right file - what's missing?

**Step 4:** Either:
- **Supplement:** Add missing rights to reach 15+
- **Rebuild:** Create new file if easier than editing

**Step 5:** Validate JSON and save to high-quality tier

---

## File Structure Your Output Should Match

Look at these completed examples for formatting:

**Good Examples:**
- `data/jurisdictions/quality-tiers/high-quality/california-rights.json` (25 rights - BEST)
- `data/jurisdictions/quality-tiers/high-quality/idaho-rights.json` (17 rights)
- `data/jurisdictions/quality-tiers/high-quality/kansas-rights.json` (16 rights)

**Match:**
- Same JSON structure
- Same field names
- Same level of detail in descriptions
- Same category taxonomy
- Same citation format style

---

## Your Progress Checklist

Track your completion:

- [ ] Wyoming (10 → ?)
- [ ] Wisconsin (12 → ?)
- [ ] West Virginia (12 → ?)
- [ ] Washington (12 → ?)
- [ ] Virginia (12 → ?)
- [ ] Vermont (12 → ?)
- [ ] Texas (14 → ?)
- [ ] Tennessee (14 → ?)
- [ ] South Dakota (10 → ?)
- [ ] South Carolina (10 → ?)
- [ ] Rhode Island (12 → ?)
- [ ] Pennsylvania (9 → ?)
- [ ] Oregon (7 → ?)
- [ ] Oklahoma (8 → ?)
- [ ] Ohio (8 → ?)
- [ ] North Dakota (7 → ?)
- [ ] New Mexico (7 → ?)
- [ ] New Jersey (6 → ?)
- [ ] New Hampshire (5 → ?)
- [ ] Nevada (5 → ?)
- [ ] Nebraska (5 → ?)
- [ ] Montana (4 → ?)
- [ ] Missouri (4 → ?)
- [ ] Mississippi (3 → ?)
- [ ] Minnesota (4 → ?)
- [ ] Michigan (5 → ?)
- [ ] Massachusetts (4 → ?)
- [ ] Maryland (4 → ?)
- [ ] Maine (5 → ?)
- [ ] Louisiana (4 → ?) ← STOP HERE

---

## Questions? Issues?

### If statute file is wrong:
Check `.archive/2025-10-11-complete-data-backup/statutory-text-files/` for correct version

### If you can't find 15 rights:
- Reread fee sections (caps, waivers are rights!)
- Reread enforcement sections (appeals, fees, penalties are rights!)
- Reread procedure sections (timelines, formats are rights!)
- Compare to California - what categories are you missing?

### If JSON won't validate:
- Use `python3 -m json.tool [file]` to find error
- Check for missing commas between rights entries
- Check for trailing commas after last entry
- Verify all quotes are properly escaped

### If unsure about quality:
- Count rights: should be 15-25
- Check file size: should be 10-25 KB
- Compare to California baseline
- Ensure all 6 categories represented

---

## Let's Go!

**Your first task: Read Wyoming statute and extract ALL affirmative rights.**

**Remember:** Slow and thorough beats fast and incomplete. This data lasts forever!

**Good luck! 🚀**
