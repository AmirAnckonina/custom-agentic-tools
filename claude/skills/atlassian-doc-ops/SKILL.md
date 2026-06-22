---
name: atlassian-doc-ops
description: >
  Creates and updates Confluence pages (design docs, test plans, architecture docs, PRDs)
  and Jira tickets (Task, Subtask, Bug, CVE) via Atlassian MCP.
  Use when user says: "create a design doc", "write a test plan", "add architecture doc
  to Confluence", "update the PRD", "create a ticket", "open a bug", "add a subtask",
  "create CVE ticket", "break this into Jira tasks", "update ticket", "add description
  to ticket", "mark TC-001 as passed", "clear the Actual column".
  Generates structured Confluence pages with ToC, Mermaid diagrams, Swagger API embeds,
  and color-coded test matrices. Performs surgical updates — never breaks existing markup,
  table structure, or embedded objects.
metadata:
  mcp-server: plugin_atlassian_atlassian
---

# Atlassian Doc Ops

## Overview

Handles creating and updating Confluence documentation and Jira tickets via the Atlassian MCP.
Enforces consistent structure, visual quality, and surgical precision on all updates.

**Supported operations:**
- Confluence: Create / update Design Docs, Test Plans, Architecture Docs, PRDs, Manuals
- Jira: Create / update Tasks, Subtasks, Bugs, CVE tickets; add comments

---

## Workflow A: Confluence Doc Authoring

### Step 1: Gather Requirements

Collect before doing anything:

| Field | Notes |
|---|---|
| Doc type | Design Doc / Test Plan / Architecture / PRD / Manual |
| Space | Confluence space key (e.g. `RND`). Ask if unknown. |
| Parent page | Where to nest this page. Ask or search if unknown. |
| Page title | Suggest one if not provided. |
| Create or update? | If updating, require page ID or URL. |

If any field is missing and cannot be inferred, **ask before proceeding**.

### Step 2: Resolve Confluence Target

```
1. getAccessibleAtlassianResources         → obtain cloudId
2. If updating:  getConfluencePage(pageId, contentFormat: "markdown")
                                           → read full content before touching anything
3. If space unknown: getConfluenceSpaces   → find correct space key
4. If parent unknown: searchConfluenceUsingCql → locate parent page
```

For updates: always fetch the current page first. Identify the exact section to touch.
Do not rewrite anything outside that scope.

### Step 3: Structure the Document

Apply the correct template per doc type. All pages share these base rules:

| Element | Rule |
|---|---|
| Table of Contents | Always at the top — use Confluence ToC macro |
| Section headers | H2 for major sections, H3 for sub-sections |
| Emojis in headers | One per major section, only where meaningful |
| Status badges | Use Confluence status macros (Draft, Active, Stable) |
| Page title | Clear and descriptive — follow existing naming in the space |

**Per doc type structure:**

**Design Doc** — Overview · Problem Statement · Goals & Non-Goals · Architecture ·
API Design · Data Model · Security Considerations · Open Questions

**Test Plan** — Overview · Scope · Test Case Matrix (see Workflow B) · Priority Guide · Appendix

**Architecture Doc** — Overview · System Context · Component Breakdown · Data Flow ·
Infrastructure · Failure Modes

**PRD** — Overview · Problem · User Stories · Requirements (Functional / Non-Functional) ·
Out of Scope · Acceptance Criteria

**Manual** — Overview · Prerequisites · Step-by-Step Guide · Troubleshooting · FAQ

See `references/confluence-formatting.md` for full macro syntax and storage format rules.

### Step 4: Embed Visuals

**APIs → Swagger/OpenAPI macro:**
```xml
<ac:structured-macro ac:name="open-api">
  <ac:parameter ac:name="url">[swagger spec URL]</ac:parameter>
</ac:structured-macro>
```
If no URL is available, fall back to a Mermaid sequence diagram.

**Architecture / flow diagrams → Mermaid code block:**
```xml
<ac:structured-macro ac:name="code">
  <ac:parameter ac:name="language">mermaid</ac:parameter>
  <ac:plain-text-body><![CDATA[
graph TD
  A[Client] --> B[API Gateway]
  B --> C[Service]
  ]]></ac:plain-text-body>
</ac:structured-macro>
```

**DB schemas → Mermaid ERD:**
```
erDiagram
  USER { int id PK; string email }
  ORDER { int id PK; int user_id FK }
  USER ||--o{ ORDER : places
```

**Lucid diagrams:** Embed as Smart Link only when the user provides the URL.
Never fabricate a Lucid URL.

### Step 5: Create or Update

**Create:**
```
createConfluencePage(cloudId, spaceKey, parentPageId, title, content)
```

**Update:**
```
1. getConfluencePage → read current version and content
2. Locate the target section only
3. Edit only that section
4. updateConfluencePage(cloudId, pageId, title, full-content, version + 1)
```

**Hard rules for updates — never:**
- Reformat sections you didn't touch
- Remove or alter macros, panels, or embedded objects outside scope
- Change heading levels in untouched sections
- Strip status badges, colors, or table formatting

---

## Workflow B: Test Plan Matrix

### Step 1: Gather Test Plan Input

Ask for:
- Feature or component under test
- Custom columns if the default set doesn't fit
- Initial test cases if available, or generate from provided spec

### Step 2: Build the Matrix

**Default columns:**
```
ID | Assignee | Category | Priority | Endpoint + Description | Expected | Actual | Notes
```

For non-API test plans, replace `Endpoint + Description` with `Scenario` or `Component`
as appropriate — confirm with user if unclear.

**Priority conventions:**

| Priority | Marker | Meaning |
|---|---|---|
| P0 | 🔴 | Critical — must pass |
| P1 | 🟠 | High — important |
| P2 | 🟡 | Medium — edge cases |
| P3 | 🟢 | Low — nice to have |

**Actual column conventions:**

| Value | Meaning |
|---|---|
| ✅ or `V` | Passed |
| ❌ or `X` | Failed |
| ⏳ | In progress |
| `N/A` | Not applicable |
| _(empty)_ | Not tested yet |

Group test cases by Category. Place a Priority Guide section after the matrix.
See `references/test-plan-matrix.md` for the full template.

### Step 3: Surgical Table Updates

When asked to mark, update, or clear cells:

```
1. getConfluencePage(pageId, contentFormat: "markdown")
2. Parse the markdown table — find row(s) by TC-ID
3. Modify only the specified cell(s)
4. Reconstruct the full table — same structure, column count, markdown syntax
5. updateConfluencePage — full page content with only those cells changed
```

**Rules:**
- Never change column count, order, or header row
- Never alter rows outside the requested range
- Preserve mentions (`@Name`), emoji, and status markers in untouched cells
- If a cell contains a macro or custom markup, replace only its text value

**Supported commands:**

| Command | Action |
|---|---|
| "Mark TC-001 as passed" | Actual = `✅` |
| "Mark TC-005 to TC-010 as failed" | Actual = `❌` for that range |
| "Clear the Actual column" | Set all Actual cells to empty |
| "Add a note to TC-003" | Append text to Notes cell |
| "Add test case: [details]" | Append new row, auto-assign next TC-ID |

---

## Workflow C: Jira Ticket Ops

### Step 1: Gather Ticket Info

**Required:**
- Ticket type: Task / Subtask / Bug / CVE
- Title (suggest one based on context if not given)
- Brief description of the work or issue

**Common fields — confirm if not stated, never assume silently:**

| Field | Default |
|---|---|
| Assignee | Current user (fetch via `atlassianUserInfo`) |
| Team / project-specific fields | Ask the user; remember the answer per project |

> If your Jira instance has required custom fields (e.g. a team field, an environment/destination field), resolve their valid values via `getJiraProjectIssueTypesMetadata` and ask the user which to use on first ticket — don't hardcode a default here.

**Per type extras:**
- **Subtask:** parent ticket ID (required)
- **CVE:** CVE ID, affected component, severity
- **Bug:** steps to reproduce, impact (ask if not provided)

### Step 2: Resolve Project and User

```
1. getAccessibleAtlassianResources   → cloudId
2. getVisibleJiraProjects            → confirm project key
3. atlassianUserInfo                 → current user accountId for Assignee default
4. getJiraProjectIssueTypesMetadata  → resolve custom field IDs if needed
```

### Step 3: Format the Ticket

All tickets use this description structure:

```markdown
## 🧩 Overview & Problem
[What this is and what problem it solves. 2–4 sentences max.
Only information that was provided — do not infer or invent.]

## ✅ Task & Requirements
- [What needs to be done, in bullet points]
- [Scope only — do not specify how or where to implement]

## 🎯 Acceptance Criteria
- [ ] Criterion derived from provided input
- [ ] ...

## 📋 Definition of Done
- [ ] Code reviewed and merged
- [ ] Tests passing
- [ ] [Additional DoD items if provided]
```

**Style rules — always apply:**
- Modest: do not add implementation detail not given by the user
- Do not write acceptance criteria you cannot derive from the input
- Do not specify exact file, method, or location unless told
- 3–5 bullets per section unless the user provided more

See `references/jira-ticket-templates.md` for per-type field requirements and examples.

**Create:**
```
createJiraIssue(cloudId, projectKey, issueType, summary, description,
                assignee, team, [parentId], [custom fields])
```

### Step 4: Update Existing Ticket

```
1. getJiraIssue(cloudId, issueKey)     → read current state
2. Identify what to change (field / section / comment)
3. Description edits: surgical — preserve existing sections not in scope
4. editJiraIssue or addCommentToJiraIssue
```

**Hard rules for updates — never:**
- Overwrite sections that weren't in scope
- Invent acceptance criteria during an update
- Change ticket type or parent without explicit instruction

---

## When NOT to Use This Skill

- Generic writing or code not targeting Confluence or Jira
- Read-only searches without intent to create or update
- Project status questions ("what's the state of X?")
- Bulk import / export between systems

---

## Quick Reference

| Intent | MCP Tool |
|---|---|
| Get cloud ID | `getAccessibleAtlassianResources` |
| Get current user | `atlassianUserInfo` |
| Find a Confluence page | `searchConfluenceUsingCql` |
| Read a Confluence page | `getConfluencePage(pageId, contentFormat: "markdown")` |
| Create Confluence page | `createConfluencePage` |
| Update Confluence page | `updateConfluencePage` |
| Find Jira project | `getVisibleJiraProjects` |
| Read Jira ticket | `getJiraIssue` |
| Create Jira ticket | `createJiraIssue` |
| Edit Jira ticket | `editJiraIssue` |
| Comment on ticket | `addCommentToJiraIssue` |
| Get field schema | `getJiraProjectIssueTypesMetadata` |
