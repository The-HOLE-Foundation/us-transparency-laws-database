# Forking to The HOLE Foundation Organization

## Steps to Complete the Fork

### 1. Fork on GitHub
1. Visit: https://github.com/Jobikinobi/us-transparency-laws-database
2. Click **Fork** button
3. Select **The-HOLE-Foundation** as owner
4. Repository name: `us-transparency-laws-database`
5. Click **Create fork**

### 2. Update Local Repository
```bash
# Add the organization remote
git remote add foundation https://github.com/The-HOLE-Foundation/us-transparency-laws-database.git

# Verify remotes
git remote -v

# Push to foundation remote
git push foundation main
git push foundation development
git push foundation testing

# Optional: Change origin to point to foundation
git remote set-url origin https://github.com/The-HOLE-Foundation/us-transparency-laws-database.git
```

### 3. Create Foundation Meta Repository
Create a new repository: `The-HOLE-Foundation/foundation-meta`

**Initial files for meta repo:**
- `MASTER_ROADMAP.md` - Overall project planning
- `REPOSITORY_MAP.md` - How all repos connect
- `WORKFLOWS.md` - Organization standards (copy from current)
- `INTEGRATION_STATUS.md` - Cross-project dependencies
- `WEEKLY_SYNC.md` - Coordination notes

## Current Organization Structure

### Existing Repositories
- ✅ `The-HOLE-Foundation/Theholefoundation.org` - Foundation website
- 🔄 `The-HOLE-Foundation/us-transparency-laws-database` - Data source (fork this)

### Recommended Next Repositories
- `The-HOLE-Foundation/foundation-meta` - Central coordination
- `The-HOLE-Foundation/theholetruth-platform` - Main transparency tools
- `The-HOLE-Foundation/shared-infrastructure` - Common components

## Benefits of Organization Structure

### Centralized Management
- All projects under one GitHub organization
- Unified issue tracking and project management
- Consistent workflows and standards across repos
- Easy access control and team management

### Clear Separation of Concerns
- **foundation-meta**: Strategic planning and coordination
- **us-transparency-laws-database**: Authoritative data source
- **theholefoundation.org**: Organizational website
- **theholetruth-platform**: User-facing transparency tools

### Integration Benefits
- Cross-repository issue linking
- Automated deployments when data updates
- Shared GitHub Actions and workflows
- Organization-wide project boards