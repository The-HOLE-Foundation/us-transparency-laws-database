---
DATE: 2025-10-08
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
DOCUMENT_TYPE: Versioning Standards
VERSION: 1.0
---

# Versioning Guidelines

## Purpose

Ensure all templates, schemas, data files, and workflows are clearly versioned to:
1. Track which data model version they belong to
2. Allow multiple versions to coexist during transitions
3. Identify deprecated vs. current files
4. Maintain compatibility across system components

## Version Naming Convention

### Format: `vMAJOR.MINOR`

**Examples**:
- `v0.11` - Layer 2 metadata, basic schema
- `v0.12` - Rights of access + simplified agencies
- `v0.13` - Vector embeddings (planned)
- `v1.0` - First production release

### When to Increment

**MAJOR version (v1.0, v2.0)**: Breaking changes
- Schema structure completely redesigned
- Incompatible with previous version
- Requires migration scripts
- Example: v0.x → v1.0 (beta to production)

**MINOR version (v0.11, v0.12)**: New features
- New tables/fields added
- Backward compatible (old data still works)
- New capabilities added
- Example: v0.11 → v0.12 (added rights_of_access table)

## File Naming Standards

### Templates

**Pattern**: `{purpose}-TEMPLATE-{version}.{ext}`

**Examples**:
```
✅ agencies-TEMPLATE-v0.12.json
✅ rights-TEMPLATE-v0.12.json
✅ jurisdiction-TEMPLATE-v0.11.json

❌ agencies-TEMPLATE.json (missing version)
❌ template-agencies.json (wrong pattern)
❌ agencies_template_v0.12.json (inconsistent separator)
```

**Inside Template**:
```json
{
  "_TEMPLATE_VERSION": "v0.12",
  "_SCHEMA_VERSION": "v0.12-agencies-simplified-schema.json",
  "_TEMPLATE_STATUS": "UNVERIFIED",
  ...
}
```

### Schemas

**Pattern**: `{version}-{purpose}-schema.{ext}`

**Examples**:
```
✅ v0.12-agencies-simplified-schema.json
✅ v0.12-rights-of-access-schema.json
✅ v0.13-vector-database-schema.json

❌ agencies-schema.json (missing version)
❌ schema-v0.12-agencies.json (version in wrong place)
```

**Inside Schema**:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Simplified State Government Agencies Schema",
  "version": "v0.12",
  "last_updated": "2025-10-08",
  ...
}
```

### Workflows

**Pattern**: `{version}-{purpose}_WORKFLOW.md`

**Examples**:
```
✅ v0.12-AFFIRMATIVE_RIGHTS_WORKFLOW.md
✅ v0.12-AGENCIES_SIMPLIFIED_WORKFLOW.md
✅ v0.13-VECTOR_EMBEDDINGS_WORKFLOW.md

❌ AFFIRMATIVE_RIGHTS_WORKFLOW.md (missing version)
❌ workflow-affirmative-rights-v0.12.md (wrong pattern)
```

**Inside Workflow** (header):
```markdown
---
VERSION: v0.12
WORKFLOW_TYPE: Data Collection
RELATED_SCHEMA: v0.12-agencies-simplified-schema.json
---
```

### Data Files (Verified)

**Pattern**: `{purpose}-{version}.{ext}`

**Examples**:
```
✅ agencies-v0.12.json
✅ rights-v0.12.json
✅ jurisdiction-data-v0.11.json

❌ agencies.json (missing version - OK if only one version exists)
❌ agencies_v0.12.json (inconsistent separator)
```

**Inside Data File**:
```json
{
  "data_model_version": "v0.12",
  "schema": "v0.12-agencies-simplified-schema.json",
  "last_updated": "2025-10-08",
  ...
}
```

### Scripts

**Pattern**: `{purpose}-{version}.{ext}` (if version-specific)

**Examples**:
```
✅ import-rights-neon.js (current version, no suffix needed)
✅ import-rights-v0.11-legacy.js (old version kept for reference)
✅ migrate-v0.11-to-v0.12.py (migration script between versions)

❌ import_rights.js (use kebab-case, not snake_case)
```

## Version Compatibility Matrix

### Current Versions (as of 2025-10-08)

| Component | Version | Compatible With | Status |
|-----------|---------|----------------|--------|
| **Jurisdictions data** | v0.11 | - | ✅ Production |
| **Exemptions** | v0.11 | Jurisdictions v0.11 | ✅ Production |
| **Rights of Access** | v0.12 | Jurisdictions v0.11 | 🔄 In Development |
| **Agencies (simplified)** | v0.12 | Jurisdictions v0.11 | 🔄 In Development |
| **Vector Embeddings** | v0.13 | All v0.12 tables | 📋 Planned |

### Compatibility Rules

**Forward Compatible**: New version works with old data
- ✅ v0.12 schemas can read v0.11 data
- ✅ Additional fields added (not removed)
- ✅ Old queries still work

**Backward Incompatible**: Old version can't read new data
- ❌ v0.11 schemas can't read v0.12 rights_of_access
- ❌ New fields required
- ❌ Structure changed

## Version Transition Checklist

### When Creating New Version

**1. Schema Design**:
- [ ] Create new schema: `v0.XX-{purpose}-schema.json`
- [ ] Document version in schema file
- [ ] Note compatibility with previous versions
- [ ] Add to compatibility matrix

**2. Templates**:
- [ ] Generate templates: `{purpose}-TEMPLATE-v0.XX.json`
- [ ] Include `_TEMPLATE_VERSION` field
- [ ] Reference schema in template
- [ ] Document what changed from previous version

**3. Workflows**:
- [ ] Create workflow: `v0.XX-{PURPOSE}_WORKFLOW.md`
- [ ] Document version in header
- [ ] Note dependencies on other versions
- [ ] Include migration path from previous version

**4. Scripts**:
- [ ] Update import scripts to handle new version
- [ ] Create migration script if needed
- [ ] Test with sample data
- [ ] Document version requirements

**5. Documentation**:
- [ ] Update CHANGELOG.md with version changes
- [ ] Update ROADMAP.md with version timeline
- [ ] Add to compatibility matrix
- [ ] Document breaking changes

### When Deprecating Old Version

**1. Mark as Deprecated**:
```json
{
  "_DEPRECATED": true,
  "_DEPRECATED_DATE": "2025-10-08",
  "_REPLACEMENT": "v0.12-agencies-simplified-schema.json",
  "_MIGRATION_GUIDE": "documentation/MIGRATE_v0.11_to_v0.12.md"
}
```

**2. Rename File**:
```
agencies-TEMPLATE-v0.11.json
  → agencies-TEMPLATE-v0.11-DEPRECATED.json
```

**3. Keep for Reference**:
- Move to `archive/v0.11/` directory
- Don't delete (needed for historical data)
- Update documentation to point to new version

## Examples by Use Case

### Use Case 1: Worker Needs Template

**Worker asks**: "Where's the agencies template?"

**Clear answer**:
```
Current: data/states/{state}/agencies-TEMPLATE-v0.12.json
Version: v0.12 (simplified agencies, 15-25 main agencies only)
Schema: schemas/v0.12-agencies-simplified-schema.json
Workflow: workflows/v0.12-AGENCIES_SIMPLIFIED_WORKFLOW.md
```

### Use Case 2: Data Import

**Import script checks version**:
```javascript
const data = require('./texas/agencies-v0.12.json');

if (data.data_model_version !== 'v0.12') {
  console.error(`Wrong version! Expected v0.12, got ${data.data_model_version}`);
  console.log(`Migration needed. See: documentation/MIGRATE_to_v0.12.md`);
  process.exit(1);
}

// Proceed with import
importAgencies(data);
```

### Use Case 3: Schema Evolution

**Timeline**:
```
v0.11.0 (Sept 2024)
  └─ Basic jurisdiction data + exemptions

v0.11.1 (Sept 2024)
  └─ Supabase integration, no schema changes

v0.12.0 (Oct 2024) ← Current
  ├─ Added: rights_of_access table
  ├─ Added: agencies table (simplified)
  └─ Changed: Nothing (backward compatible)

v0.13.0 (Planned Nov 2024)
  ├─ Add: Vector embeddings for semantic search
  ├─ Add: embedding column to rights_of_access
  └─ Changed: Nothing (backward compatible)

v1.0.0 (Planned Q1 2025)
  ├─ Production release
  ├─ Freeze schema (no breaking changes)
  └─ Migration scripts for all v0.x → v1.0
```

## File Organization by Version

```
us-transparency-laws-database/
├── schemas/
│   ├── v0.11-jurisdiction-schema.json
│   ├── v0.12-agencies-simplified-schema.json
│   ├── v0.12-rights-of-access-schema.json
│   └── v0.13-vector-database-schema.json (planned)
│
├── templates/
│   ├── v0.11/
│   │   └── jurisdiction-TEMPLATE-v0.11.json (deprecated)
│   └── v0.12/
│       ├── agencies-TEMPLATE-v0.12.json
│       └── rights-TEMPLATE-v0.12.json
│
├── workflows/
│   ├── v0.11-JURISDICTION_DATA_WORKFLOW.md
│   ├── v0.12-AFFIRMATIVE_RIGHTS_WORKFLOW.md
│   ├── v0.12-AGENCIES_SIMPLIFIED_WORKFLOW.md
│   └── v0.13-VECTOR_EMBEDDINGS_WORKFLOW.md (planned)
│
├── data/
│   └── states/
│       └── texas/
│           ├── agencies-TEMPLATE-v0.12.json (working)
│           ├── agencies-v0.12.json (verified - will exist)
│           └── jurisdiction-data-v0.11.json (current)
│
└── scripts/
    ├── migrate-v0.11-to-v0.12.py
    └── import-rights-neon.js (current version)
```

## Migration Scripts

**Naming**: `migrate-{OLD_VERSION}-to-{NEW_VERSION}.{ext}`

**Example**: `migrate-v0.11-to-v0.12.py`

**Contents**:
```python
#!/usr/bin/env python3
"""
Migrate data from v0.11 to v0.12 schema

Changes:
- Add data_model_version field
- Add schema reference
- Preserve all existing data
- No breaking changes
"""

def migrate_v0_11_to_v0_12(input_file, output_file):
    # Read v0.11 data
    with open(input_file) as f:
        data = json.load(f)

    # Add v0.12 fields
    data['data_model_version'] = 'v0.12'
    data['schema'] = 'v0.12-jurisdiction-schema.json'

    # Preserve all existing fields (backward compatible)
    # No fields removed, only added

    # Write v0.12 data
    with open(output_file, 'w') as f:
        json.dump(data, f, indent=2)

    print(f"✓ Migrated {input_file} to v0.12 format")
```

## Best Practices

### DO:
✅ Include version in filename for templates and schemas
✅ Include version metadata inside files
✅ Document version in file headers
✅ Create migration scripts for version changes
✅ Keep old versions for historical reference
✅ Test version compatibility

### DON'T:
❌ Use version numbers inconsistently
❌ Delete old version files (archive instead)
❌ Change version numbers retroactively
❌ Skip versions (go from v0.11 → v0.13)
❌ Make breaking changes in MINOR versions

---

**Version**: 1.0
**Effective Date**: 2025-10-08
**Next Review**: After v0.13 release
**Maintained By**: Project architecture team
