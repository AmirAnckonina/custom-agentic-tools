# Description Field Examples

The `description` field in YAML frontmatter is how Claude decides whether to load a skill. This is the most important field to get right.

## Formula

```
[What it does] + [When to use it / trigger phrases] + [Key capabilities]
```

---

## Good Examples

### MCP Enhancement (Atlassian)

```yaml
description: "Automatically convert Confluence specification documents into structured Jira backlogs with Epics and implementation tickets. When Claude needs to: (1) Create Jira tickets from a Confluence page, (2) Generate a backlog from a specification, (3) Break down a spec into implementation tasks, or (4) Convert requirements into Jira issues."
```

**Why it works:** Specific action, 4 explicit trigger scenarios, mentions both Confluence and Jira.

### MCP Enhancement (Linear)

```yaml
description: "Manages Linear project workflows including sprint planning, task creation, and status tracking. Use when user mentions 'sprint', 'Linear tasks', 'project planning', or asks to 'create tickets'."
```

**Why it works:** Names the service, lists capabilities, includes exact trigger phrases.

### Standalone Workflow

```yaml
description: "Interactive guide for creating new skills. Walks the user through use case definition, frontmatter generation, instruction writing, and validation. Use when user says 'create a skill', 'build a skill', or 'new skill'."
```

**Why it works:** Describes the workflow, includes trigger phrases, clear scope.

### Document Creation

```yaml
description: "Create distinctive, production-grade frontend interfaces with high design quality. Use when building web components, pages, artifacts, posters, or applications."
```

**Why it works:** Clear output type, lists triggering contexts.

### Agent-Only (not user-invocable)

```yaml
description: "Core code review principles, severity levels, scorecard template, and verdict rules. Auto-loaded during any code review task."
```

**Why it works:** States what it provides and when it loads. Doesn't need user trigger phrases since it's agent-loaded.

---

## Bad Examples

### Too Vague

```yaml
description: "Helps with projects."
```

**Problem:** No specifics on WHAT or WHEN. Claude can't decide when to load this.

### Missing Triggers

```yaml
description: "Creates sophisticated multi-page documentation systems."
```

**Problem:** Describes capability but no trigger conditions. When should Claude use this?

### Too Technical

```yaml
description: "Implements the Project entity model with hierarchical relationships."
```

**Problem:** Internal implementation detail, not user-facing outcome. Users don't ask for "entity models."

### Over-Broad

```yaml
description: "Processes documents."
```

**Problem:** Matches almost everything. Will over-trigger constantly.

---

## Negative Trigger Technique

For skills that over-trigger, add negative scope:

```yaml
description: "Advanced data analysis for CSV files. Use for statistical modeling, regression, clustering. Do NOT use for simple data exploration (use data-viz skill instead)."
```

---

## Character Limit

Description must be under **1,024 characters**. If you need more detail, put it in the SKILL.md body or a Keywords section.

## Keywords Section Alternative

For additional trigger coverage without bloating the description, add a `## Keywords` section in the SKILL.md body:

```markdown
## Keywords
status report, project status, weekly update, daily standup, Jira report, project summary, blockers, progress update
```

This is loaded at the second level (when Claude reads the SKILL.md body) and helps with matching.
