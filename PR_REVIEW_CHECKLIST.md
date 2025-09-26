# Pull Request Review Checklist

## 🔍 Branch Consolidation Review

### For PR: source-validated-dataset-20250926 → main

#### ✅ **Data Integrity Checks**
- [ ] All 51 jurisdictions present (50 states + DC + Federal)
- [ ] Each state has a dedicated folder with process maps
- [ ] `complete-51-states-data-VERIFIED.json` exists and is valid
- [ ] All JSON files pass schema validation
- [ ] No duplicate or conflicting data entries

#### 📊 **Content Review**
- [ ] Individual state folders properly named (STATE-VERIFIED format)
- [ ] Process maps follow consistent format
- [ ] Verification reports included
- [ ] Master compilation file present
- [ ] Transparency vector data prepared

#### 🔒 **Quality Assurance**
- [ ] Verification dates are current (2024-2025)
- [ ] Source citations included for all data
- [ ] No sensitive or private information exposed
- [ ] File naming conventions consistent
- [ ] Documentation complete and accurate

---

### For PR: source-statute-project-20250926 → main

#### 🚀 **Supabase Integration**
- [ ] `/supabase/migrations/` folder with proper SQL files
- [ ] `/supabase/seed/` folder with data population scripts
- [ ] Database schema covers all 4 required schemas:
  - [ ] legal_reference
  - [ ] transparency_data
  - [ ] strategic_intelligence
  - [ ] foia_operations
- [ ] RLS policies properly configured
- [ ] Environment variables documented

#### 🏗️ **Architecture Components**
- [ ] Foundation-meta template complete
- [ ] Platform architecture documented
- [ ] Cross-repository integration patterns defined
- [ ] Development standards established
- [ ] Organization setup guide included

#### 📚 **Documentation**
- [ ] README updated with current status
- [ ] Deployment guides complete
- [ ] API documentation accurate
- [ ] Configuration examples provided
- [ ] Scripts documented and executable

---

## 🔄 **Merge Conflict Resolution Strategy**

### Priority Rules When Conflicts Occur:

```yaml
Data Conflicts:
  1. Prefer: verified_date (newer wins)
  2. Prefer: validation_status = "verified" over "unverified"
  3. Prefer: more complete data over partial data
  4. Preserve: unique fields from both branches

Structure Conflicts:
  1. Keep: All Supabase integration files
  2. Keep: Organization architecture templates
  3. Merge: Documentation (combine both versions)
  4. Preserve: Scripts from both branches

File Organization:
  1. If duplicate files: Compare content, keep most complete
  2. If different structures: Create consolidated structure
  3. Archive: Outdated versions in /archive folder
```

---

## 🎯 **Critical Review Points**

### Before Approving Any PR:

1. **Data Completeness**
   ```bash
   # Check jurisdiction count
   jq 'keys | length' complete-51-states-data-VERIFIED.json
   # Should return: 51
   ```

2. **Schema Validation**
   ```bash
   # Validate JSON structure
   python scripts/validate_json_schema.py
   ```

3. **Supabase Compatibility**
   ```bash
   # Check migration files
   ls -la supabase/migrations/*.sql
   # Check seed data
   ls -la supabase/seed/*.sql
   ```

4. **No Data Loss**
   ```bash
   # Compare file counts
   git ls-tree -r source-branch --name-only | wc -l
   git ls-tree -r main --name-only | wc -l
   # Ensure no critical files deleted
   ```

---

## 🚦 **Merge Order Recommendation**

### Recommended Sequence:

1. **First PR: source-validated-dataset-20250926**
   - Base data layer with all verified content
   - Individual state folders and process maps
   - No conflicts expected with main

2. **Second PR: source-statute-project-20250926**
   - Adds Supabase integration on top
   - Includes architecture and platform design
   - May have conflicts - resolve favoring Supabase

### Post-Merge Verification:
```bash
# After each merge, verify:
1. git pull origin main
2. npm test (if tests exist)
3. Check file structure integrity
4. Validate JSON data
5. Test Supabase connection
```

---

## 📝 **PR Comment Templates**

### For Approval:
```markdown
✅ **APPROVED**

This PR successfully consolidates [branch name] with:
- ✅ All 51 jurisdictions verified present
- ✅ Data integrity maintained
- ✅ Documentation complete
- ✅ No breaking changes detected
- ✅ Ready for production

Excellent work on Operation Convergence!
```

### For Changes Requested:
```markdown
🔄 **CHANGES REQUESTED**

Before merging, please address:
1. [ ] [Specific issue found]
2. [ ] [Another issue]

Once these are resolved, this will be ready to merge.
```

### For Discussion:
```markdown
💬 **DISCUSSION**

Question about [specific area]:
- Should we [specific decision]?
- Consider [alternative approach]

Let's resolve this before merging.
```

---

## 🤖 **Automated Checks to Run**

Create these as GitHub Actions:

```yaml
name: PR Validation
on: pull_request

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Check Jurisdiction Count
        run: |
          COUNT=$(jq 'keys | length' complete-51-states-data-VERIFIED.json)
          if [ "$COUNT" -ne 51 ]; then
            echo "❌ Missing jurisdictions: Expected 51, found $COUNT"
            exit 1
          fi
          echo "✅ All 51 jurisdictions present"

      - name: Validate JSON
        run: |
          for file in $(find . -name "*.json"); do
            jq empty "$file" || exit 1
          done
          echo "✅ All JSON files valid"

      - name: Check Supabase Structure
        run: |
          if [ -d "supabase/migrations" ]; then
            echo "✅ Supabase migrations found"
          fi
```

---

## 🎉 **Ready for Review**

With this checklist, you can:
1. Manually review PRs on GitHub using these criteria
2. Add comments based on the templates
3. Set up automated checks via GitHub Actions
4. Ensure safe, complete consolidation

Would you like me to help create GitHub Actions for automated PR validation?