---
DATE: 2025-10-03
AUTHOR: Claude Code AI Assistant
PROJECT: The HOLE Foundation - US Transparency Laws Database
SUBPROJECT: Agent Launch Template - Statute Name Validation
VERSION: v0.11
---

# How to Launch the Statute Name Validation Agent

## Quick Start

To launch a Claude Code agent for statute name validation, use this exact prompt:

```
I need you to act as a specialized statute name validation agent. Your instructions are in:

workflows/STATUTE_NAME_VALIDATION_AGENT.md

Read those instructions completely, then begin validating statute names for all 52 US jurisdictions (50 states + DC + Federal).

CRITICAL RULES:
1. Do NOT write scripts to automate this task
2. Manually verify EACH statute name against official state code
3. Document EVERY verification with official .gov source URLs
4. Flag any incorrect names for human review (do not auto-correct)
5. Create a comprehensive validation report when complete

Start by reading the full agent instructions, then begin with jurisdiction: [STATE NAME]

If you understand these requirements and are ready to proceed with manual verification, confirm and begin.
```

## For Parallel Validation (Multiple Agents)

If you want to run multiple agents in parallel to speed up validation:

### Agent 1 - Western States (10 jurisdictions)
```
Validate statute names for these 10 Western jurisdictions:
- Alaska, Arizona, California, Colorado, Hawaii
- Idaho, Montana, Nevada, Oregon, Washington

Follow instructions in: workflows/STATUTE_NAME_VALIDATION_AGENT.md
```

### Agent 2 - Southern States (12 jurisdictions)
```
Validate statute names for these 12 Southern jurisdictions:
- Alabama, Arkansas, Florida, Georgia, Kentucky, Louisiana
- Mississippi, North Carolina, South Carolina, Tennessee, Texas, Virginia

Follow instructions in: workflows/STATUTE_NAME_VALIDATION_AGENT.md
```

### Agent 3 - Midwest States (12 jurisdictions)
```
Validate statute names for these 12 Midwest jurisdictions:
- Illinois, Indiana, Iowa, Kansas, Michigan, Minnesota
- Missouri, Nebraska, North Dakota, Ohio, South Dakota, Wisconsin

Follow instructions in: workflows/STATUTE_NAME_VALIDATION_AGENT.md
```

### Agent 4 - Northeast States (11 jurisdictions)
```
Validate statute names for these 11 Northeast jurisdictions:
- Connecticut, Delaware, Maine, Maryland, Massachusetts, New Hampshire
- New Jersey, New York, Pennsylvania, Rhode Island, Vermont

Follow instructions in: workflows/STATUTE_NAME_VALIDATION_AGENT.md
```

### Agent 5 - Mountain & Special (7 jurisdictions)
```
Validate statute names for these 7 jurisdictions:
- New Mexico, Oklahoma, Utah, West Virginia, Wyoming
- District of Columbia
- Federal

Follow instructions in: workflows/STATUTE_NAME_VALIDATION_AGENT.md
```

## After Validation Complete

### Consolidate Reports

Once all agents complete, combine their reports:

1. Collect all individual validation reports
2. Merge into single comprehensive report
3. Review for consistency across agents
4. Identify any jurisdictions flagged by multiple agents
5. Create prioritized fix list

### Review and Correct

For jurisdictions with incorrect names:

1. Human reviewer verifies the agent's findings
2. If confirmed incorrect, update the JSON file
3. Run validation script again to confirm fix
4. Document the correction in git commit

### Update Canonical Names Reference

If new variations or issues were discovered:

1. Update `data/ground-truth/canonical-statute-names.json`
2. Add any new "accepted_variations" found
3. Add any new "rejected_variations" discovered
4. Document sources for all additions

## Example Session Transcript

### Good Agent Start

```
User: I need you to validate statute names. Instructions in workflows/STATUTE_NAME_VALIDATION_AGENT.md

Agent: I've read the validation instructions. I understand that:

1. I must manually verify each statute name against official state code
2. I cannot write scripts to automate this verification
3. I must document every verification with official .gov URLs
4. I should flag issues, not auto-correct them
5. Accuracy is mandatory - this is ground truth data

I'm ready to begin manual verification. Should I start with all 52 jurisdictions or a specific subset?

User: Start with Texas first to show me your process.

Agent: Starting with Texas validation:

[Agent navigates to https://statutes.capitol.texas.gov/]
[Agent locates Texas Government Code Chapter 552]
[Agent reads the official statute title]
[Agent cross-references with Texas AG website]
[Agent documents findings with URLs]

Result:
- File name: "Texas Public Information Act" ✅ CORRECT
- Official statute title: "Public Information Act" (Texas Gov't Code § 552)
- Commonly referred to as: "Texas Public Information Act"
- Verified sources: [lists URLs]

Proceeding to next jurisdiction...
```

### Bad Agent Start (What NOT To Do)

```
User: Validate statute names using workflows/STATUTE_NAME_VALIDATION_AGENT.md

Agent: I'll write a Python script to validate all statute names...

❌ STOP - This violates the core instruction. Agent should be doing MANUAL verification, not automation.
```

```
User: Validate statute names using workflows/STATUTE_NAME_VALIDATION_AGENT.md

Agent: I'll use Perplexity to look up the official statute names...

❌ STOP - This violates the primary sources requirement. Must use official .gov sites only.
```

```
User: Validate statute names using workflows/STATUTE_NAME_VALIDATION_AGENT.md

Agent: I've validated all 52 jurisdictions. Here's my report: [report with no source URLs listed]

❌ STOP - This violates the documentation requirement. Every verification needs official source URLs.
```

## Quality Control Checklist

Before accepting an agent's validation report, verify:

- [ ] Agent read the full instructions (not just skimmed)
- [ ] Agent performed manual verification (not automation)
- [ ] Agent used only official .gov sources (no AI/Wikipedia)
- [ ] Agent documented every verification with source URLs
- [ ] Agent flagged issues for review (didn't auto-correct)
- [ ] Report includes methodology notes
- [ ] Report lists all sources consulted
- [ ] Agent maintained focus on accuracy over speed

## Common Agent Mistakes to Watch For

### Mistake 1: Over-Automation
**Agent says**: "I'll write a script to check all 52 jurisdictions..."

**Correction**: "No - you must manually verify each one against the official state statute. No scripts for this task."

### Mistake 2: Using Secondary Sources
**Agent says**: "I found the statute name on Wikipedia..."

**Correction**: "Wikipedia is not acceptable. Navigate to the official state legislature website and find the statute there."

### Mistake 3: Assuming Consistency
**Agent says**: "Since California uses 'Public Records Act', I'll assume other states do too..."

**Correction**: "Never assume. Each state must be individually verified from its own official statute."

### Mistake 4: Insufficient Documentation
**Agent says**: "I verified it's correct."

**Correction**: "Provide the official .gov URL where you verified it, plus a second cross-reference source."

### Mistake 5: Auto-Correcting Without Review
**Agent says**: "I found an error and fixed it in the JSON file."

**Correction**: "Do not auto-correct. Flag it with evidence for human review, then the human decides whether to correct."

## Success Metrics

A successful validation agent will:

1. **Take appropriate time** (not rush through jurisdictions)
2. **Show their work** (provide URLs for every verification)
3. **Ask questions** when uncertain (not make assumptions)
4. **Maintain focus** on accuracy over completion speed
5. **Document thoroughly** for future auditing

## If Agent Gets Stuck

If the agent cannot access official sources or encounters ambiguity:

1. **Agent should STOP** and report the issue
2. **Agent should document** what they tried
3. **Agent should flag** the jurisdiction for human assistance
4. **Agent should NOT proceed** with uncertain validation

## Estimated Time per Jurisdiction

Proper manual verification takes approximately:

- **10-15 minutes** per jurisdiction for straightforward cases
- **20-30 minutes** for complex cases (recent amendments, naming changes)
- **30+ minutes** if official sources are difficult to navigate

**Total estimated time for all 52**: 10-20 hours of focused work

This is appropriate and expected for ground truth validation work.

## Final Notes

### For the Human Operator

- Monitor agent progress, don't just launch and walk away
- Verify the agent is actually visiting official sites (ask for evidence)
- Spot-check a few validations yourself to confirm quality
- If agent shows signs of rushing/automation, stop and redirect

### For the Agent

- Read the full instructions in STATUTE_NAME_VALIDATION_AGENT.md
- Remember: This is ground truth data - accuracy is mandatory
- When in doubt, verify again
- When certain, verify once more
- Your work will be audited - document everything

---

**Validation begins when the agent confirms understanding of these requirements.**
