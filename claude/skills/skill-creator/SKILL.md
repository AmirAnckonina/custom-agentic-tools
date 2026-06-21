---
name: skill-creator
description: "Interactive guide for creating new Claude skills. Walks through use case definition, frontmatter generation, instruction writing, folder structure, and validation. Use when user says 'create a skill', 'build a skill', 'new skill', 'skill for X', or 'help me make a skill'. Also reviews and improves existing skills."
---

# Skill Creator

## Overview

Interactive workflow for building well-structured Claude skills that follow the official skill specification. Handles standalone skills, MCP-enhanced skills, and multi-skill packages.

**CRITICAL: This is an interactive, step-by-step process. Do NOT generate an entire skill in one shot. Walk the user through each phase, confirm at gates, and iterate.**

---

## Phase 1: Discovery

Gather requirements before writing anything.

### Step 1.1: Identify Skill Category

Ask the user which category fits:

1. **Document & Asset Creation** — Consistent, high-quality output (reports, docs, code, designs)
2. **Workflow Automation** — Multi-step processes with validation gates
3. **MCP Enhancement** — Workflow guidance layered on top of MCP tool access

If unclear, ask: "What does a user accomplish when this skill runs successfully?"

### Step 1.2: Define Use Cases

Require 2-3 concrete use cases. Each must include:

```
Use Case: [Name]
Trigger: User says "[specific phrases]"
Steps:
  1. [Action]
  2. [Action]
  ...
Result: [What the user gets]
```

**Push back** if use cases are vague. "Helps with projects" is not a use case.

### Step 1.3: Identify Tools & Dependencies

- **Built-in only?** (code execution, document creation, web search)
- **MCP required?** Which server(s) and tool names?
- **Scripts needed?** Python, Bash, etc.
- **Reference docs?** API guides, templates, style guides

### Step 1.4: Define Success Criteria

Ask for at least 2 measurable criteria:
- Trigger accuracy (should/should-not trigger scenarios)
- Workflow completion (expected tool call count, error rate)
- Output quality (consistency, user correction rate)

**Gate: Present a summary of Phase 1 findings. Wait for user confirmation before proceeding.**

---

## Phase 2: Structure

Design the skill's folder layout and frontmatter.

### Step 2.1: Folder Name

Rules (enforced):
- **kebab-case only**: `my-skill-name`
- No spaces, underscores, or capitals
- No `claude` or `anthropic` prefix (reserved)
- Must match the `name` field in frontmatter

### Step 2.2: Folder Layout

Generate the folder tree. Minimal:

```
skill-name/
  SKILL.md          # Required
```

Full (when needed):

```
skill-name/
  SKILL.md           # Required - main instructions
  scripts/           # Optional - executable code
  references/        # Optional - docs loaded on demand
  assets/            # Optional - templates, icons, fonts
```

Rules:
- File MUST be `SKILL.md` (exact case)
- **No README.md** inside skill folder
- Reference files go in `references/`
- Large templates go in `assets/`

### Step 2.3: YAML Frontmatter

Generate the frontmatter block. Required fields:

```yaml
---
name: skill-name
description: "[What it does]. [When to use it — include trigger phrases]. [Key capabilities]."
---
```

**Description rules:**
- MUST include WHAT + WHEN + KEY CAPABILITIES
- Under 1024 characters
- No XML angle brackets (`<` or `>`)
- Include specific trigger phrases users would say
- Mention file types if relevant

Optional fields (include when applicable):
- `license: MIT` — for open-source skills
- `compatibility:` — environment requirements (1-500 chars)
- `allowed-tools:` — restrict tool access (e.g., `"Bash(python:*) WebFetch"`)
- `user-invocable: false` — if skill is only loaded by agents, not invoked by user
- `metadata:` — author, version, mcp-server, tags

**Validate the description** against these anti-patterns:

| Anti-pattern | Example | Fix |
|---|---|---|
| Too vague | "Helps with projects" | Add specific actions and triggers |
| Missing triggers | "Creates documentation systems" | Add "Use when user says..." |
| Too technical | "Implements entity model with hierarchies" | Describe user-facing outcome |
| Over-broad | "Processes documents" | Narrow scope, add negative triggers |

**Gate: Present the folder layout + frontmatter. Wait for user confirmation before writing instructions.**

---

## Phase 3: Instructions

Write the SKILL.md body (everything after frontmatter).

### Step 3.1: Structure Template

Follow this skeleton (adapt per category):

```markdown
# [Skill Name]

## Overview
[1-2 sentences: what this skill does and when to use it]

## Keywords
[comma-separated trigger keywords for improved matching]

## Workflow

### Step 1: [First Major Step]
[Clear, actionable instructions]

### Step 2: [Next Step]
[Continue...]

(repeat as needed)

## Examples

### Example 1: [Common Scenario]
User says: "[trigger phrase]"
Actions:
1. [action]
2. [action]
Result: [outcome]

## Edge Cases & Troubleshooting

### [Error or Edge Case]
Cause: [why]
Solution: [how to fix]

## When NOT to Use This Skill
[Negative triggers — what this skill does NOT handle]

## Quick Reference
[Tool names, key parameters, answer structure]
```

### Step 3.2: Writing Rules

Apply these rules to every instruction:

**Be specific and actionable:**
- Include exact tool names and parameter patterns
- Show expected output/response format
- Use code blocks for API calls, scripts, CLI commands

**Include error handling:**
- Common failure modes and their solutions
- MCP connection failures
- Missing required fields / permissions

**Use progressive disclosure:**
- Core instructions in SKILL.md (keep under 5,000 words)
- Detailed API docs, templates → `references/`
- Large assets → `assets/`

**Human-in-the-loop:**
- Present findings/plans before executing destructive or irreversible actions
- Use confirmation gates for multi-step workflows
- Show "Would you like me to..." before creating/modifying external resources

**Negative triggers:**
- Include a "When NOT to Use" section
- Prevents over-triggering on unrelated queries

### Step 3.3: MCP-Specific Rules (if applicable)

When the skill uses MCP tools:

- **Name tools explicitly:** `searchJiraIssuesUsingJql`, not "search Jira"
- **Show parameter patterns:** Include example calls with placeholder values
- **Handle auth failures:** Instruct Claude what to do if MCP is disconnected
- **Sequence multi-tool calls:** Explicitly state dependencies between calls
- **Include the cloudId pattern:** Most Atlassian tools need cloudId — show how to obtain it

**Gate: Present the full SKILL.md draft. Wait for user review.**

---

## Phase 4: Validation

Run through the validation checklist before declaring the skill complete.

### Step 4.1: Structural Validation

Verify against `references/validation-checklist.md`:

- [ ] Folder named in kebab-case
- [ ] `SKILL.md` file exists (exact casing)
- [ ] YAML frontmatter has `---` delimiters
- [ ] `name` field: kebab-case, no spaces, no capitals
- [ ] `description` includes WHAT + WHEN
- [ ] No XML tags (`<` `>`) in frontmatter
- [ ] No `README.md` in skill folder
- [ ] Instructions are clear and actionable
- [ ] Error handling included
- [ ] Examples provided
- [ ] References clearly linked (if any)

### Step 4.2: Trigger Validation

Propose test queries:

**Should trigger (3-5 examples):**
- Obvious match
- Paraphrased request
- Indirect reference

**Should NOT trigger (3-5 examples):**
- Unrelated topic
- Adjacent but out-of-scope task
- Ambiguous query that belongs to another skill

### Step 4.3: Quality Checks

- [ ] SKILL.md under 5,000 words (move excess to `references/`)
- [ ] Description under 1,024 characters
- [ ] No hardcoded user-specific values (project keys, URLs)
- [ ] Confirmation gates before destructive actions
- [ ] Works alongside other skills (composability)

**Gate: Present validation results. Fix any issues before finalizing.**

---

## Phase 5: Finalize

### Step 5.1: Write Files

Create all files in the skill folder:
1. `SKILL.md` — main skill file
2. `references/*.md` — supplementary docs (if any)
3. `scripts/*` — executable code (if any)
4. `assets/*` — templates (if any)

### Step 5.2: Installation Instructions

Provide the user with:

**For Claude Code:**
```
Skill created at: ~/.claude/skills/[skill-name]/
It will be available in your next conversation.
```

**For Claude.ai:**
```
1. Zip the skill folder
2. Go to Settings > Capabilities > Skills
3. Upload the zip file
4. Toggle the skill on
```

### Step 5.3: Next Steps

Suggest:
- Test with 3-5 real queries
- Monitor for under/over-triggering
- Iterate on description and instructions based on results
- Consider adding more examples or edge cases

---

## Review Mode

When asked to **review an existing skill**, evaluate against:

1. **Frontmatter quality** — description specificity, trigger coverage, naming
2. **Instruction clarity** — actionable steps, error handling, examples
3. **Structure** — progressive disclosure, folder conventions, no README.md
4. **Trigger accuracy** — propose should/should-not trigger test cases
5. **Composability** — does it play well with other skills?

Present findings as:
```
## Skill Review: [name]

### Strengths
- [what works well]

### Issues
- [CRITICAL] [must fix]
- [IMPORTANT] [should fix]
- [SUGGESTION] [nice to have]

### Recommended Changes
1. [specific change]
2. [specific change]
```

---

## Anti-Patterns to Flag

When creating or reviewing skills, flag these:

| Anti-pattern | Problem | Fix |
|---|---|---|
| Monolithic SKILL.md | Too large, slow to load | Move details to `references/` |
| No confirmation gates | Destructive actions without consent | Add "present before executing" steps |
| Vague instructions | "Validate data properly" | Be specific: what, how, expected result |
| Missing negative triggers | Over-triggers on unrelated queries | Add "When NOT to Use" section |
| Hardcoded values | Not portable across users/orgs | Use placeholders, ask user for values |
| No examples | Claude guesses the workflow | Add 2-3 concrete input/output examples |
| README.md in skill folder | Violates spec | Remove it; use SKILL.md for all docs |
