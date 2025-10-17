---
DATE: 2025-01-10
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Custom Slash Commands
VERSION: v0.11
---

# Custom Slash Commands

This directory contains custom slash commands for streamlining common workflows in the HOLE Foundation transparency laws database project.

## Available Commands

Note: Commands will be created in individual files within this directory (`.claude/commands/`) to enable slash command functionality.

### Data Management

#### `/add-jurisdiction`
Initiates workflow to add new state/federal transparency law data
```markdown
File: add-jurisdiction.md
Executes: workflows/add-jurisdiction.md with interactive prompts
```

#### `/verify-sources`
Validates data sources for a jurisdiction
```markdown
File: verify-sources.md
Checks: All URLs are official .gov domains
Reports: Non-compliant sources
```

#### `/validate-accuracy`
Runs comprehensive accuracy validation on jurisdiction data
```markdown
File: validate-accuracy.md
Checks: Citations, timelines, fees, URLs
Generates: Validation report
```

### Database Synchronization

#### `/sync-supabase`
Synchronizes database schema with Supabase
```markdown
File: sync-supabase.md
Executes: workflows/sync-supabase.md
Updates: Schema, types, data
```

#### `/update-tracking`
Updates master tracking table
```markdown
File: update-tracking.md
Modifies: master_tracking_table.json
Tracks: Completion status per jurisdiction
```

### Process Maps

#### `/generate-process-map`
Creates standardized process map
```markdown
File: generate-process-map.md
Template: PROCESS_MAP_TEMPLATE.md
Output: verified-process-maps/[jurisdiction]-process-map.md
```

### Integration

#### `/ai-foundry-status`
Checks Microsoft AI Foundry integration status
```markdown
File: ai-foundry-status.md
Tests: API connectivity, agent accessibility
Reports: Integration health
```

## Command Structure

Each command file follows this format:
```markdown
# Command Name

Brief description of what this command does.

## Execution
[Specific steps or workflow reference]

## Parameters
- param1: Description
- param2: Description

## Output
What to expect when command completes
```

## Creating Custom Commands

To add a new slash command:

1. Create markdown file in `.claude/commands/`
2. Use kebab-case naming (e.g., `my-command.md`)
3. Write clear, concise description
4. Reference existing workflows when appropriate
5. Test command thoroughly
6. Update this README

## Usage Examples

### Adding a New Jurisdiction
```
/add-jurisdiction Texas
```
Prompts for:
- Statute URL
- Citation
- Response timeline
- Fee structure

Then executes full workflow autonomously.

### Validating Data
```
/validate-accuracy California
```
Runs validation scripts and reports:
- Source compliance
- Citation accuracy
- Timeline correctness
- Fee structure validity

### Syncing Database
```
/sync-supabase
```
Analyzes JSON structure, generates migrations, updates types, populates database.

## Command Development Guidelines

### Keep Commands Focused
Each command should do one thing well:
- ✅ Good: `/add-jurisdiction` - Complete jurisdiction workflow
- ❌ Bad: `/do-everything` - Multiple unrelated tasks

### Reference Workflows
When appropriate, commands should execute workflows:
```markdown
## Execution
Execute workflows/add-jurisdiction.md with provided parameters
```

### Provide Clear Output
Users should know what happened:
```markdown
## Output
✅ Jurisdiction added successfully
✅ Validation passed
✅ Tracking table updated
✅ Git commit created
```

### Handle Errors Gracefully
Include error scenarios:
```markdown
## Common Errors
- Invalid URL: Must be official .gov domain
- Missing data: All required fields must be populated
- Validation failed: Check validation report for details
```

## Command Categories

### 1. Data Entry Commands
Focus on adding/modifying jurisdiction data
- Require source verification
- Update tracking systems
- Run validation automatically

### 2. Validation Commands
Ensure data quality and accuracy
- Check against official sources
- Verify legal compliance
- Generate detailed reports

### 3. Integration Commands
Connect with external systems
- Supabase synchronization
- AI Foundry status checks
- React platform deployment

### 4. Workflow Commands
Execute complex multi-step processes
- Reference workflow files
- Handle prerequisites automatically
- Provide progress updates

## Integration with Workflows

Commands often execute workflows:
```
/add-jurisdiction → workflows/add-jurisdiction.md
/sync-supabase → workflows/sync-supabase.md
/ai-foundry-status → workflows/integrate-ai-foundry.md (check section)
```

This provides:
- Consistent execution patterns
- Detailed step documentation
- Easy maintenance and updates

## Future Commands

### Planned Additions
- `/deploy-production` - Full production deployment
- `/update-statute` - Refresh when laws change
- `/generate-api-docs` - API documentation
- `/backup-data` - Create backup
- `/restore-data` - Restore from backup
- `/health-check` - System status check
- `/optimize-db` - Database optimization

### Community Suggestions
To suggest new commands:
1. Identify repetitive task
2. Document desired behavior
3. Create draft command file
4. Test thoroughly
5. Submit PR

## Best Practices

### Command Naming
- Use kebab-case: `add-jurisdiction` not `addJurisdiction`
- Be descriptive: `validate-accuracy` not `check`
- Stay consistent: Group related commands with common prefix

### Command Documentation
- Start with brief description
- List all parameters
- Explain expected output
- Include examples
- Document errors

### Command Maintenance
- Update based on feedback
- Refine based on usage patterns
- Remove deprecated commands
- Keep documentation current

## Troubleshooting

### Command Not Found
1. Verify file exists in `.claude/commands/`
2. Check file has `.md` extension
3. Ensure proper formatting
4. Restart Claude Code if needed

### Command Executes Incorrectly
1. Review command documentation
2. Check parameter format
3. Verify prerequisites met
4. Review recent CLAUDE.md updates

### Command Fails Silently
1. Check for syntax errors in command file
2. Verify workflow references are correct
3. Test manually to identify issue
4. Update command documentation

## Support

For command-related issues:
1. Review command documentation
2. Check [CLAUDE.md](../../CLAUDE.md)
3. Consult workflow files
4. Create GitHub issue
5. Contact maintainers

## Contributing

To improve commands:
1. Use commands regularly
2. Note pain points
3. Suggest improvements
4. Test proposed changes
5. Submit PR with examples
6. Update documentation

---

**Note**: This is the command registry. Individual command files will be created as needed based on usage patterns and requirements.
