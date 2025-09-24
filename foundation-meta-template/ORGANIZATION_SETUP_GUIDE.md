# The Hole Foundation - GitHub Organization Setup Guide

## 🎯 Organization Creation Checklist

### Phase 1: GitHub Organization Setup

#### 1. Create GitHub Organization
- [ ] Go to https://github.com/organizations/new
- [ ] Organization name: `The-HOLE-Foundation`
- [ ] Display name: `The Hole Foundation`
- [ ] Email: `contact@theholefoundation.org`
- [ ] Billing: Start with Free plan (upgrade as needed)

#### 2. Organization Profile Setup
- [ ] **Profile README**: Create organization profile repository
- [ ] **Logo**: Upload foundation logo (SVG preferred)
- [ ] **Description**: "Advancing government transparency through technology, data, and strategic advocacy"
- [ ] **Website**: Link to `theholefoundation.org`
- [ ] **Location**: United States
- [ ] **Social Links**: Twitter, LinkedIn (when available)

#### 3. Basic Organization Settings
- [ ] **Member Visibility**: Private (default)
- [ ] **Repository Visibility**: Mix of public and private
- [ ] **Member Privileges**: Restricted (admins approve)
- [ ] **Repository Creation**: Members can create repositories
- [ ] **Outside Collaborators**: Admin approval required

### Phase 2: Repository Migration & Creation

#### Repository Migration Order
```bash
# Current work becomes the database repository
# 1. Fork/transfer current work to organization
us-transparency-laws-database/  # ← Transfer from current repo

# 2. Create new repositories in order
foundation-meta/                # ← Create first (coordination)
theholetruth-platform/         # ← Create second (main app)
theholefoundation.org/         # ← Already exists, transfer
shared-infrastructure/          # ← Create last (future)
```

#### 1. Transfer `us-transparency-laws-database/`
```bash
# Option A: Transfer existing repository
# Go to repository Settings → Transfer ownership

# Option B: Create new repo and push
git clone https://github.com/current-repo/Statute-Project.git
cd Statute-Project

# Clean up for database-only repo
rm -rf foundation-meta-template/
rm -rf theholetruth-platform-architecture/
git add -A
git commit -m "Clean up for database-only repository"

# Push to new organization repo
git remote set-url origin https://github.com/The-HOLE-Foundation/us-transparency-laws-database.git
git push -u origin main
```

#### 2. Create `foundation-meta/`
```bash
# Create repository in GitHub organization
# Initialize with README
cd /path/to/development
git clone https://github.com/The-HOLE-Foundation/foundation-meta.git
cd foundation-meta

# Copy template structure
cp -r /path/to/foundation-meta-template/* .
git add -A
git commit -m "Initialize foundation meta repository"
git push origin main
```

#### 3. Create `theholetruth-platform/`
```bash
# Initialize new Next.js project
npx create-next-app@latest theholetruth-platform \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*"

cd theholetruth-platform

# Set up repository structure based on architecture
mkdir -p apps/web packages/{ui,database,auth,analytics}
# Move Next.js files to apps/web/
# Set up monorepo configuration

git remote add origin https://github.com/The-HOLE-Foundation/theholetruth-platform.git
git push -u origin main
```

### Phase 3: Organization Configuration

#### 1. Team Structure
```
Organization Teams:
├── Core Team              # Full access to all repositories
├── Frontend Developers    # Platform and website development
├── Backend Developers     # Database and API development
├── Data Team             # Database content and verification
├── Design Team           # UI/UX and brand design
└── Contributors          # External contributors
```

#### 2. Repository Access Permissions
```
Repository Permissions:
├── foundation-meta/
│   ├── Core Team: Admin
│   ├── All Developers: Write
│   └── Contributors: Read
├── us-transparency-laws-database/
│   ├── Core Team: Admin
│   ├── Backend Developers: Write
│   ├── Data Team: Write
│   └── Others: Read
├── theholetruth-platform/
│   ├── Core Team: Admin
│   ├── Frontend Developers: Write
│   ├── Backend Developers: Write
│   └── Others: Read
├── theholefoundation.org/
│   ├── Core Team: Admin
│   ├── Frontend Developers: Write
│   ├── Design Team: Write
│   └── Others: Read
└── shared-infrastructure/
    ├── Core Team: Admin
    ├── All Developers: Write
    └── Contributors: Read
```

#### 3. Branch Protection Rules
Apply to all repositories:
```yaml
Branch Protection (main):
  - Require pull request reviews: 1 reviewer
  - Dismiss stale reviews: true
  - Require review from code owners: true
  - Require status checks: true
    - Required checks: CI tests, build
  - Require branches to be up to date: true
  - Include administrators: false
  - Allow force pushes: false
  - Allow deletions: false
```

### Phase 4: Development Workflow Setup

#### 1. GitHub Actions Templates
Create in `shared-infrastructure/templates/ci-cd/`:

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run test
      - run: npm run build
```

#### 2. Issue Templates
Create in each repository `.github/ISSUE_TEMPLATE/`:
- `bug_report.md`: Bug report template
- `feature_request.md`: Feature request template
- `question.md`: Question template
- `security.md`: Security issue template

#### 3. Pull Request Templates
Create `.github/pull_request_template.md`:
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Self-review completed
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No sensitive information committed
```

### Phase 5: Security & Compliance

#### 1. Security Settings
For each repository:
- [ ] **Vulnerability Alerts**: Enable Dependabot alerts
- [ ] **Security Advisories**: Enable private security advisories
- [ ] **Code Scanning**: Enable CodeQL analysis
- [ ] **Secret Scanning**: Enable secret scanning
- [ ] **Dependency Graph**: Enable dependency tracking

#### 2. Environment Secrets
Set up organization secrets:
```
Organization Secrets:
├── SUPABASE_SERVICE_KEY    # Database access
├── VERCEL_TOKEN           # Deployment
├── POSTHOG_API_KEY        # Analytics
├── SLACK_WEBHOOK_URL      # Notifications
└── NPM_TOKEN              # Package publishing
```

#### 3. Required Status Checks
Configure for all repositories:
- [ ] **Tests**: All tests must pass
- [ ] **Build**: Build must succeed
- [ ] **Lint**: Code linting must pass
- [ ] **Security**: Security scans must pass
- [ ] **Coverage**: Code coverage targets met

### Phase 6: Documentation & Communication

#### 1. Organization Documentation
Create comprehensive docs in `foundation-meta/`:
- [ ] **README.md**: Organization overview
- [ ] **CONTRIBUTING.md**: Contributor guidelines
- [ ] **CODE_OF_CONDUCT.md**: Community standards
- [ ] **SECURITY.md**: Security reporting process
- [ ] **SUPPORT.md**: Getting help and support

#### 2. Project Management
Set up GitHub Projects:
```
Organization Projects:
├── Foundation Roadmap     # High-level strategic planning
├── Database Development   # us-transparency-laws-database tasks
├── Platform Development   # theholetruth-platform tasks
├── Website & Brand       # theholefoundation.org tasks
└── Cross-Project Issues  # Integration and coordination
```

#### 3. Discussion Forums
Enable GitHub Discussions:
- [ ] **General**: General discussion and Q&A
- [ ] **Ideas**: Feature ideas and suggestions
- [ ] **Show and Tell**: Demos and achievements
- [ ] **Q&A**: Technical questions and help
- [ ] **Announcements**: Official updates

### Phase 7: Monitoring & Analytics

#### 1. Repository Insights
Enable for all repositories:
- [ ] **Traffic**: View repository traffic
- [ ] **Clones**: Track repository clones
- [ ] **Referrers**: See traffic sources
- [ ] **Popular Content**: Most viewed files

#### 2. Organization Analytics
Track organization metrics:
- [ ] **Member Activity**: Contribution patterns
- [ ] **Repository Growth**: Creation and activity
- [ ] **Issue Resolution**: Response and resolution times
- [ ] **Security Alerts**: Vulnerability response times

### Phase 8: External Integrations

#### 1. Communication Tools
- [ ] **Slack Integration**: GitHub notifications to Slack
- [ ] **Discord Integration**: Community notifications
- [ ] **Email Notifications**: Critical updates

#### 2. Development Tools
- [ ] **Vercel**: Platform deployment
- [ ] **Supabase**: Database hosting
- [ ] **PostHog**: Analytics and monitoring
- [ ] **Sentry**: Error tracking

### Phase 9: Launch Preparation

#### 1. Pre-Launch Checklist
- [ ] All repositories created and configured
- [ ] Team permissions properly set
- [ ] Branch protection rules active
- [ ] CI/CD pipelines working
- [ ] Security scanning enabled
- [ ] Documentation complete
- [ ] Issue templates configured
- [ ] Project boards set up

#### 2. Launch Announcement
Prepare announcement materials:
- [ ] **Blog Post**: Launch announcement
- [ ] **Social Media**: Twitter/LinkedIn posts
- [ ] **Press Release**: Media outreach
- [ ] **Community Outreach**: Developer communities

## 🚀 Quick Setup Script

Create `setup-organization.sh` for automation:

```bash
#!/bin/bash
# The Hole Foundation - Organization Setup Script

echo "🏢 Setting up The Hole Foundation GitHub Organization"

# Clone repositories
git clone https://github.com/The-HOLE-Foundation/foundation-meta.git
git clone https://github.com/The-HOLE-Foundation/us-transparency-laws-database.git
git clone https://github.com/The-HOLE-Foundation/theholetruth-platform.git

# Set up development environment
cd foundation-meta
npm install

cd ../us-transparency-laws-database
# Set up Supabase connection
cp .env.example .env.local

cd ../theholetruth-platform
npm install
npm run dev

echo "✅ Organization setup complete!"
echo "🌐 Visit: https://github.com/The-HOLE-Foundation"
```

## 📋 Post-Setup Tasks

### 1. Team Onboarding
- [ ] Invite core team members
- [ ] Assign appropriate permissions
- [ ] Provide onboarding documentation
- [ ] Schedule team kickoff meeting

### 2. External Communication
- [ ] Update foundation website with GitHub links
- [ ] Add GitHub links to social media profiles
- [ ] Create developer documentation
- [ ] Set up community guidelines

### 3. Continuous Improvement
- [ ] Schedule monthly organization review
- [ ] Track contribution metrics
- [ ] Gather team feedback
- [ ] Iterate on processes and tools

---

**Organization URL**: https://github.com/The-HOLE-Foundation
**Setup Time**: ~4-6 hours for complete setup
**Maintenance**: 2-4 hours monthly for optimization

**Next Steps**: Begin with Phase 1 organization creation, then proceed sequentially through all phases.