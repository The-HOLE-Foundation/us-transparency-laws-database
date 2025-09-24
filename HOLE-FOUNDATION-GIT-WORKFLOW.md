# The Hole Foundation Git Workflow Standard
*Version 1.0 - Foundation-wide Standard*

## Core Philosophy: DOCUMENT → PLAN → IMPLEMENT

Every Hole Foundation project follows this three-stage workflow with Git integration:

### Branch Structure
```
main (protected) ← testing ← development
```

- **development**: Active feature development and experimentation
- **testing**: Staging for quality assurance and validation
- **main**: Production-ready, protected branch (deployment source)

## Versioning System

### Semantic Versioning for Foundation Projects
- `v0.x.x` - Alpha/Development phase
- `v1.x.x` - Beta/Testing phase
- `v2.x.x` - Production releases

### Version Components
- **Major** (v1.0.0): Significant milestones, breaking changes
- **Minor** (v1.1.0): New features, substantial improvements
- **Patch** (v1.1.1): Bug fixes, minor updates

### Foundation Project Phases
- **Alpha** (v0.1.0): Core development, basic functionality
- **Beta** (v0.9.0): Testing phase, feature complete
- **Release** (v1.0.0): Production deployment

## Workflow Implementation

### 1. Branch Creation (One-time setup)
```bash
git checkout -b development
git checkout -b testing
git checkout main
git push -u origin development
git push -u origin testing
```

### 2. Development Cycle
```bash
# Start new work
git checkout development
git pull origin development

# Make changes, commit
git add .
git commit -m "feat: implement transparency statute validation"

# Push to development
git push origin development
```

### 3. Testing Phase
```bash
# Move to testing when development ready
git checkout testing
git merge development
git push origin testing

# Run all tests, validation, QA
# Fix any issues in development, re-merge
```

### 4. Production Release
```bash
# Create release from testing
git checkout main
git merge testing
git tag v0.1.0
git push origin main --tags
```

## Branch Protection Rules

### GitHub Settings → Branches → Add Rule for `main`

**Required Settings:**
- ✅ Require a pull request before merging
- ✅ Require approvals (1 minimum for solo projects)
- ✅ Dismiss stale PR approvals when new commits are pushed
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ✅ Require conversation resolution before merging
- ✅ Include administrators (apply rules to admins)

**Optional but Recommended:**
- ✅ Restrict pushes that create files
- ✅ Require signed commits
- ✅ Require linear history

## Foundation Project Standards

### Commit Message Format
```
type(scope): description

feat(auth): add FOIA request authentication
fix(data): correct statute citation formatting
docs(api): update endpoint documentation
test(validation): add statute accuracy tests
```

### Required Files for Each Project
- `README.md` - Project overview and setup
- `CHANGELOG.md` - Version history and changes
- `TESTING.md` - Testing procedures and validation
- `DEPLOYMENT.md` - Production deployment guide

## Testing Requirements

### Development → Testing Criteria
- [ ] All features implemented as planned
- [ ] Code follows foundation standards
- [ ] No breaking changes without version bump
- [ ] Documentation updated

### Testing → Main Criteria
- [ ] All automated tests pass
- [ ] Manual QA completed
- [ ] Data validation confirmed (for data projects)
- [ ] Security review completed
- [ ] Performance benchmarks met

## Foundation Ecosystem Integration

### Project Hierarchy
```
hole-foundation.org/          # Organizational website
├── theholetruth.org/         # Primary transparency platform
│   ├── transparency-map/     # Interactive state transparency map
│   ├── foia-generator/       # Automated FOIA request tool
│   ├── foia-wiki/           # Searchable transparency knowledge base
│   ├── appeal-analyzer/      # Request appeal assistance (future)
│   └── document-repo/        # Public records repository (future)
├── us-transparency-laws-database/  # Statute verification project
└── foundation-tools/         # Shared utilities and standards
```

### Cross-Project Standards
- **Naming Convention**: kebab-case for repositories
- **License**: All projects use consistent open-source license
- **Copyright**: "© 2025 The Hole Foundation"
- **Documentation**: Standardized README format
- **Testing**: Common validation approaches
- **Deployment**: Consistent CI/CD patterns

## Implementation Checklist

### New Project Setup
- [ ] Create repository with foundation naming convention
- [ ] Implement three-branch structure
- [ ] Set up branch protection on main
- [ ] Add required documentation files
- [ ] Configure automated testing (where applicable)
- [ ] Set initial version tag (v0.1.0)
- [ ] Add to foundation project hierarchy

### Ongoing Maintenance
- [ ] Regular dependency updates
- [ ] Version increments with significant changes
- [ ] Documentation updates with new features
- [ ] Cross-project compatibility maintained
- [ ] Security updates applied promptly

## Medical Ethics Integration

### "Name and Shame" Philosophy
Drawing from medical training's accountability standards:
- **Transparency**: All decisions and processes documented
- **Accountability**: Clear responsibility for quality
- **Standards**: High ethical and technical standards maintained
- **Community**: Peer review and collaborative improvement

This workflow ensures the same rigorous standards applied in medical education are maintained across all Hole Foundation technology projects.

---
*This workflow standard applies to all Hole Foundation projects and should be referenced when establishing new repositories or updating existing ones.*