---
DATE: 2025-01-10
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Workflow Automation
VERSION: v0.11
---

# Workflow Automation Directory

This directory contains executable markdown workflows for common development tasks. These workflows enable Claude Code to automate complex, multi-step processes autonomously.

## Available Workflows

### 1. [add-jurisdiction.md](add-jurisdiction.md)
**Purpose**: Add new state or federal transparency law data
**Estimated Time**: 75-110 minutes
**Use When**: Adding a new jurisdiction to the database
**Command**: "Execute workflows/add-jurisdiction.md for [State Name]"

**What it does**:
- Creates directory structure
- Copies and populates templates
- Generates process maps
- Updates tracking table
- Runs validation scripts
- Creates git commit

### 2. [sync-supabase.md](sync-supabase.md)
**Purpose**: Synchronize database with Supabase backend
**Estimated Time**: 55-80 minutes
**Use When**: After schema changes or before deployment
**Command**: "Execute workflows/sync-supabase.md"

**What it does**:
- Analyzes JSON structure
- Generates database migrations
- Creates TypeScript types
- Populates Supabase tables
- Verifies data integrity
- Updates frontend types

### 3. [integrate-ai-foundry.md](integrate-ai-foundry.md)
**Purpose**: Integrate Microsoft AI Foundry FOIA generator
**Estimated Time**: 95-135 minutes
**Use When**: Setting up FOIA generator in React platform
**Command**: "Execute workflows/integrate-ai-foundry.md"

**What it does**:
- Analyzes AI Foundry agent API
- Creates React components
- Implements backend proxy
- Configures authentication
- Adds rate limiting
- Sets up error handling

## How to Use Workflows

### Basic Execution
Simply tell Claude Code to execute a workflow:
```
"Run workflows/add-jurisdiction.md for Texas"
```

Claude will:
1. Read the workflow file
2. Execute each step autonomously
3. Prompt for required inputs
4. Handle errors and validation
5. Report completion status

### With Custom Parameters
Provide specific inputs upfront:
```
"Execute workflows/add-jurisdiction.md with:
- State: California
- Citation: Cal. Gov. Code § 6250
- URL: https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=GOV&sectionNum=6250
- Response timeline: 10 business days"
```

### Checkpoint Mode
For safe autonomous execution:
```bash
# Create checkpoint before workflow
git add . && git commit -m "checkpoint: before [workflow-name]"

# Execute workflow
"Run workflows/[workflow-name].md"

# If successful: keep changes
# If unsuccessful: git reset --hard HEAD
```

## Workflow Development Guidelines

When creating new workflows:

### 1. Structure
```markdown
---
[Document Header]
---

# Workflow Title

## Prerequisites
List required tools, access, state

## Required Inputs
Clearly define all needed parameters

## Execution Steps
Numbered, specific, actionable steps

## Validation Checklist
Verify correctness before completion

## Common Issues
Document known problems and solutions

## Success Criteria
Define what "done" looks like

## Estimated Time
Help users plan their work

## Notes
Additional context and learnings
```

### 2. Best Practices
- **Be specific**: Use exact commands, file paths, URLs
- **Be comprehensive**: Include all steps, no assumptions
- **Be validated**: Include checkpoints and verification
- **Be documented**: Explain why, not just what
- **Be maintained**: Update based on learnings

### 3. Testing Workflows
Before committing new workflows:
1. Execute manually to verify all steps
2. Test with different inputs
3. Verify error handling
4. Confirm validation scripts work
5. Update estimated time based on actual time
6. Document any issues encountered

## Workflow Patterns

### Pattern 1: Linear Execution
Most workflows follow this pattern:
1. Validate prerequisites
2. Gather inputs
3. Execute steps sequentially
4. Validate results
5. Commit changes

### Pattern 2: Conditional Branching
Some workflows adapt based on conditions:
```markdown
## Step 3: Determine Action
If jurisdiction is Federal:
  - Use federal template
  - Skip state-specific steps
Else if jurisdiction is State:
  - Use state template
  - Include state-specific procedures
```

### Pattern 3: Parallel Execution
When steps are independent:
```markdown
## Step 4: Parallel Tasks
Execute simultaneously:
- Task A: Populate agency data
- Task B: Create process map
- Task C: Update tracking table

All must complete before proceeding.
```

### Pattern 4: Iterative Refinement
For workflows requiring feedback:
```markdown
## Step 5: Iterative Review
1. Generate initial version
2. Review output
3. If not satisfactory, refine and retry
4. Repeat until acceptable
5. Proceed to next step
```

## Integration with CLAUDE.md

These workflows implement patterns described in [CLAUDE.md](../CLAUDE.md):
- **Task Classification**: Each workflow categorized (autonomous/supervised/critical)
- **Execution Patterns**: Following Anthropic best practices
- **Continuous Improvement**: Updated based on session learnings
- **Quality Standards**: 100% accuracy requirement maintained

## Automation Features

### Auto-Validation
Workflows include automatic validation:
- JSON syntax checking
- Source URL verification
- Data integrity validation
- Supabase compatibility tests

### Error Recovery
Built-in error handling:
- Clear error messages
- Suggested solutions
- Retry mechanisms
- Rollback procedures

### Progress Tracking
Workflows update tracking systems:
- Git commits with progress
- Tracking table updates
- Status notifications
- Completion reports

## Future Workflows

### Planned Additions
- **deploy-production.md**: Full production deployment
- **update-statute.md**: Refresh data when laws change
- **validate-all.md**: Comprehensive data validation
- **generate-api-docs.md**: API documentation generation
- **backup-restore.md**: Data backup and recovery
- **monitor-health.md**: System health checks
- **optimize-performance.md**: Performance tuning

### Community Contributions
To suggest new workflows:
1. Identify repetitive multi-step tasks
2. Document steps manually
3. Test with multiple iterations
4. Create workflow markdown
5. Submit PR with documentation

## Troubleshooting

### Workflow Fails to Execute
1. Verify file format (markdown with proper headers)
2. Check for syntax errors
3. Ensure all prerequisites met
4. Review recent CLAUDE.md updates

### Workflow Produces Incorrect Results
1. Review input parameters
2. Check for missing validation steps
3. Verify source data accuracy
4. Update workflow based on learnings

### Workflow Takes Longer Than Expected
1. Check for network delays
2. Verify API rate limits
3. Review computational requirements
4. Consider optimizing workflow

## Metrics and Monitoring

Track workflow effectiveness:
- **Success Rate**: % of successful completions
- **Time Accuracy**: Actual vs estimated time
- **Error Frequency**: Common failure points
- **User Satisfaction**: Feedback on results

Review monthly to optimize workflows.

## Support

For workflow issues:
1. Check [CLAUDE.md](../CLAUDE.md) for general guidance
2. Review specific workflow documentation
3. Consult [documentation/](../documentation/) directory
4. Create issue in GitHub repo
5. Contact project maintainers

## Contributing

To improve workflows:
1. Execute workflow and document experience
2. Note any issues or improvements
3. Update workflow markdown
4. Test changes thoroughly
5. Submit PR with clear description
6. Include before/after time comparisons

## Version History

- **v0.11** (2025-01-10): Initial workflow automation system
  - Created add-jurisdiction.md
  - Created sync-supabase.md
  - Created integrate-ai-foundry.md
  - Established workflow patterns

Future versions will add more workflows and refine existing ones based on usage patterns and feedback.
