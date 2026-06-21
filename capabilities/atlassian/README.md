# Atlassian

Creates and updates Confluence pages (design docs, test plans, architecture docs, PRDs) and Jira tickets (Task, Subtask, Bug, CVE) via the Atlassian MCP — with surgical updates that never clobber existing structure.

## What it includes

- **Skill:** `atlassian-doc-ops` — no agent or command; invoked directly in chat ("create a design doc", "open a bug", "mark TC-001 as passed")

## How it works

Three workflows: **(A) Confluence authoring** — gathers doc type/space/parent page, applies the right template (Design Doc, Test Plan, Architecture, PRD, Manual), embeds Swagger/Mermaid diagrams, and for updates always reads the current page first and edits only the targeted section. **(B) Test plan matrices** — builds a structured test case table (ID/Priority/Expected/Actual) and supports surgical cell updates ("mark TC-005 to TC-010 as failed") without touching unrelated rows. **(C) Jira ticket ops** — creates/updates Task/Subtask/Bug/CVE tickets with a consistent description structure (Overview, Requirements, Acceptance Criteria, DoD), asking rather than inferring for required fields (assignee, team, parent ticket).

## Install

```bash
./install.sh atlassian
```

## Requires

Atlassian MCP connected. Resolves workspace/`cloudId` dynamically on first use — no project keys hardcoded.
