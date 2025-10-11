---
DATE: 2025-10-08 (Updated: 2025-10-10)
INCIDENT_TYPE: Credential Exposure
SEVERITY: CRITICAL
STATUS: ACTIVE RESPONSE (Keys will be rotated at Neon)
ACTION_REQUIRED: Complete key rotation and repository privatization
---

# Security Incident Report: Database Credential Exposure

## 🚨 INCIDENT SUMMARY

**Discovered**: 2025-10-08 during security protocol deployment
**Updated**: 2025-10-10 - Keys exposed very recently, rotation in progress
**Repository**: THEHOLETRUTH.ORG (and potentially others)
**Severity**: CRITICAL
**Status**: Active response - Neon key rotation planned, repository privatization required

### What Happened

During deployment of the organization-wide security .gitignore protocol, security audit discovered **live database credentials committed to git** in the THEHOLETRUTH.ORG repository.

### Exposed Credentials

**Files Containing Live Credentials**:
1. `.env.local` - Neon database connection strings (pooled and direct)
2. `.env.production` - Production database URL
3. `.env.local.example` - Example file (less critical)
4. `.env.production.example` - Example file (less critical)

**Exposed Information**:
```
DATABASE_URL=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4-pooler.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require

DATABASE_URL_UNPOOLED=postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require
```

**Database**: Neon PostgreSQL
**Credentials Exposed**:
- Database username: `neondb_owner`
- Database password: `npg_BvEIth7j8lfG`
- Database host: `ep-dark-smoke-adkcd3h4.c-2.us-east-1.aws.neon.tech`
- Database name: `neondb`

## IMMEDIATE ACTIONS TAKEN

### 1. Removed Credentials from Git Tracking
**Commit**: `f4903da` (THEHOLETRUTH.ORG, branch: development/v0.12)
**Action**: `git rm --cached .env.*`
**Result**: Files removed from git index, still exist locally, now properly ignored

### 2. Deployed Security .gitignore
**Source**: foundation-meta/.gitignore-SECURITY-TEMPLATE
**Result**: Future .env files will be automatically excluded from git

### 3. Verified Protection
**Test**: Security audit confirms .env files now properly ignored
**Result**: ✅ All .env patterns correctly excluded

## EXPOSURE ASSESSMENT

### Timeline (Requires Investigation)

**Unknown Factors**:
- When were credentials first committed?
- How long were they in git history?
- Has repository been pushed to remote?
- Is repository public or private?
- Who has access to the repository?

**Investigation Needed**:
```bash
# Check when .env files were first added
cd /Volumes/HOLE-RAID-DRIVE/HOLE/Github/THEHOLETRUTH.ORG
git log --all --full-history -- .env.local .env.production

# Check if pushed to remote
git log --branches --remotes --grep='.env'

# Check repository visibility
gh repo view --json visibility
```

### Potential Impact

**If Repository is Private + Not Pushed**:
- ⚠️ Moderate Risk: Only local exposure
- Action: Rotate credentials as precaution

**If Repository is Private + Pushed to GitHub**:
- 🔴 High Risk: Credentials in remote git history
- Action: Rotate credentials immediately
- Note: GitHub caches history forever

**If Repository is Public**:
- 🚨 CRITICAL: Assume credentials compromised
- Action: Rotate immediately, audit database access logs
- Assume: Credentials may have been harvested by bots

## REQUIRED ACTIONS

### Priority 1: IMMEDIATE (In Progress - 2025-10-10)

1. **Rotate Neon Database Credentials** [PLANNED]
   - Action: Will rotate keys directly in Neon console
   - Timeline: Immediate (today)
   - Process: Manual rotation via Neon dashboard
   - Follow-up: Update all .env files with new credentials

2. **Privatize All Repositories** [URGENT]
   - us-transparency-laws-database: Make private immediately
   - THEHOLETRUTH.ORG: Verify privacy status
   - All other repos: Default to private until public launch
   - Policy: All new repositories must be private by default

2. **Audit Database Access Logs**
   - Check Neon console for unauthorized access
   - Look for suspicious queries or connections
   - Review connection timestamps
   - Document any anomalies

3. **Verify Repository Visibility**
   ```bash
   cd /Volumes/HOLE-RAID-DRIVE/HOLE/Github/THEHOLETRUTH.ORG
   gh repo view --json visibility,isPrivate
   ```

### Priority 2: SHORT-TERM (This Week)

4. **Remove Credentials from Git History** (Optional but Recommended)
   - **Warning**: Requires force push, team coordination
   - **Alternative**: Accept that credentials are in history, rely on rotation

   ```bash
   # If you choose to purge history:
   cd /Volumes/HOLE-RAID-DRIVE/HOLE/Github/THEHOLETRUTH.ORG

   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch .env.local .env.production .env.*.example' \
     --prune-empty -- --all

   git push origin --force --all

   # WARNING: All team members must delete local copies and re-clone
   ```

5. **Update Deployment Environments**
   - Vercel environment variables
   - Any staging/preview environments
   - CI/CD secrets
   - Team member local .env files

6. **Team Notification**
   - Notify all developers of credential rotation
   - Provide new credentials securely (not via email/Slack)
   - Remind about .env file security

### Priority 3: ONGOING (This Month)

7. **Security Training**
   - Review security file naming protocol with team
   - Emphasize classification at file creation
   - Practice pre-commit security checks

8. **Implement Pre-Commit Hooks** (Recommended)
   - Deploy pre-commit hook that warns about .env files
   - Require verification before allowing commit
   - See: foundation-meta/.claude/SECURITY_FILE_NAMING_PROTOCOL.md

9. **Quarterly Security Audits**
   - Schedule regular audits: foundation-meta/.claude/scripts/security-audit.sh
   - Next audit: 2026-01-08
   - Document any findings

## LESSONS LEARNED

### What Went Wrong

1. **.env files committed before .gitignore existed**
   - No protection in place when files were created
   - Developers may not have known to exclude them

2. **No pre-commit security checks**
   - Nothing prevented committing sensitive files
   - Relied entirely on developer awareness

3. **No regular security audits**
   - Issue existed undetected until protocol deployment
   - Could have been caught earlier with quarterly audits

### What Went Right

1. **Security protocol deployment caught the issue**
   - Automated audit immediately detected exposure
   - Clear remediation steps provided

2. **Quick response**
   - Files removed from tracking within minutes
   - Security .gitignore deployed immediately

3. **Documentation exists**
   - Security protocol provides clear procedures
   - Emergency procedures documented

### Additional Discovery (2025-10-10)

4. **Repository Visibility Issue Identified**
   - us-transparency-laws-database was unexpectedly public
   - Need to implement "private by default" policy
   - All repositories should remain private until explicit public launch decision

## PREVENTION MEASURES IMPLEMENTED

### Now Active

1. ✅ **Security .gitignore deployed** - Prevents future .env commits
2. ✅ **Classification-based exclusions** - Systematic file protection
3. ✅ **Security audit script** - Regular vulnerability detection
4. ✅ **Emergency procedures documented** - Clear response protocols

### New Policies (2025-10-10)

5. 🔄 **Repository Privacy Policy** - All repos private by default until public launch
6. 🔄 **Immediate Repository Privatization** - Current public repos being made private
7. 🔄 **Neon Key Rotation** - Direct rotation via Neon console

### Recommended Additions

1. **Pre-commit hooks** - Block .env commits before they happen
2. **Secrets scanning** - GitHub/GitLab secret scanning enabled
3. **Environment variable management** - Use secure secret management (Doppler, 1Password, etc.)
4. **Access logging** - Monitor database access patterns
5. **Repository creation checklist** - Ensure private default for all new repos

## VERIFICATION CHECKLIST

After completing remediation:

- [ ] Neon database credentials rotated
- [ ] New credentials updated in all environments (local, staging, production)
- [ ] Database access logs reviewed for suspicious activity
- [ ] Repository visibility confirmed (public/private)
- [ ] Git history investigation completed (when credentials first committed)
- [ ] Decision made: purge history or accept with rotation
- [ ] Team notified of credential rotation
- [ ] All team members have new credentials
- [ ] Pre-commit hooks deployed (optional but recommended)
- [ ] Incident documented in security log
- [ ] Quarterly audit scheduled (2026-01-08)

## RELATED INCIDENTS

**None known at this time**

Check other repositories for similar issues:
```bash
# Audit all repositories
for repo in foundation-meta us-transparency-laws-database Theholefoundation.org; do
  echo "Auditing $repo..."
  cd /Volumes/HOLE-RAID-DRIVE/HOLE/Github/$repo
  /Volumes/HOLE-RAID-DRIVE/HOLE/Github/foundation-meta/.claude/scripts/security-audit.sh
done
```

## CONTACT INFORMATION

**Incident Lead**: User (jth)
**Technical Lead**: Claude Code AI Assistant
**Security Protocol**: foundation-meta/.claude/SECURITY_FILE_NAMING_PROTOCOL.md

## STATUS TRACKING

**Current Status**: ACTIVE RESPONSE (Updated 2025-10-10)
**Key Exposure**: Very recent, rotation planned for immediate execution
**Repository Status**: Making all repos private until public launch
**Remaining Risk**: HIGH (until Neon keys rotated and repos privatized)
**Next Actions**: 
- Rotate Neon credentials today (manual process)
- Privatize us-transparency-laws-database repository
- Implement private-by-default policy for new repos
**Follow-up**: 2025-10-15 (verify all actions completed)

---

**Report Created**: 2025-10-08
**Last Updated**: 2025-10-08
**Classification**: CONFIDENTIAL (Internal security report)
**Next Review**: After credential rotation completed
