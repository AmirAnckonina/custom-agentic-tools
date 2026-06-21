# Jira Ticket Templates

## Universal Description Structure

All ticket types share this base format. Populate only sections relevant to
what the user provided. Do not fill in sections with invented content.

```markdown
## 🧩 Overview & Problem
[2–4 sentences: what this is, what problem it solves.
Only write what was provided. No invented context.]

## ✅ Task & Requirements
- [What needs to be done]
- [Scope only — not how or where to implement]

## 🎯 Acceptance Criteria
- [ ] [Criterion derived directly from input]
- [ ] ...

## 📋 Definition of Done
- [ ] Code reviewed and merged
- [ ] Tests passing
- [ ] [Any specific DoD items provided by user]
```

---

## Per-Type Field Requirements

### Task
| Field | Required | Default |
|---|---|---|
| Summary | Yes | — |
| Description | Yes | Universal structure |
| Team | Yes | Core team |
| Assignee | Yes | Current user |
| Content Destination | Yes | Cloud |
| Parent Epic | No | Ask if relevant |

### Subtask
| Field | Required | Default |
|---|---|---|
| Summary | Yes | — |
| Description | Yes | Universal structure |
| Parent issue ID | **Yes** | Must be provided |
| Team | Yes | Core team |
| Assignee | Yes | Current user |
| Content Destination | Yes | Cloud |

Subtask description can be shorter — focus on the specific slice of work, not
the full feature context (that lives on the parent).

### Bug
| Field | Required | Default |
|---|---|---|
| Summary | Yes | Format: `[Component] Short description of the bug` |
| Description | Yes | See Bug template below |
| Team | Yes | Core team |
| Assignee | Yes | Current user |
| Content Destination | Yes | Cloud |
| Priority | No | Ask if not provided |

**Bug description structure:**
```markdown
## 🐛 Overview
[What is broken. 1–2 sentences.]

## 🔁 Steps to Reproduce
1. [Step]
2. [Step]
3. [Step]

## 💥 Actual Behavior
[What happens]

## ✅ Expected Behavior
[What should happen]

## 📋 Definition of Done
- [ ] Root cause identified
- [ ] Fix implemented and reviewed
- [ ] Regression test added (if applicable)
- [ ] Verified in [environment]
```

### CVE
| Field | Required | Default |
|---|---|---|
| Summary | Yes | Format: `[CVE-YYYY-XXXXX] Short description` |
| CVE ID | **Yes** | Must be provided |
| Affected component | **Yes** | Must be provided |
| Severity | **Yes** | Ask if not provided (Critical/High/Medium/Low) |
| Content Destination | Yes | Cloud |

**CVE description structure:**
```markdown
## 🔐 Vulnerability Overview
[What the vulnerability is. 2–3 sentences. Only what is known.]

## 📦 Affected Component
- Component: [name]
- CVE ID: [CVE-YYYY-XXXXX]
- Severity: [Critical / High / Medium / Low]

## ✅ Remediation Requirements
- [ ] [What needs to be patched or updated]
- [ ] Verify fix against CVE advisory

## 📋 Definition of Done
- [ ] Dependency updated / patch applied
- [ ] Security scan passing
- [ ] Deployed to [content destination]
```

---

## Style Guardrails

**Always:**
- Keep each section to 3–5 bullets unless more was explicitly provided
- Use checkboxes `- [ ]` for Acceptance Criteria and DoD
- Suggest a title if not given — short, imperative: "Add rate limiting to /logs endpoint"

**Never:**
- Write AC you cannot derive from input ("the API should be efficient" is not an AC)
- Specify implementation location unless the user stated it
- Add assumptions as if they were requirements
- Fill in empty sections with placeholder text — omit the section entirely if no content

---

## Title Conventions

| Type | Format |
|---|---|
| Task | `[Verb] [object] — [context if needed]` e.g. "Add pagination to logs endpoint" |
| Subtask | Same as Task, scoped narrower |
| Bug | `[Component] [what is broken]` e.g. "Auth middleware returns 500 on expired token" |
| CVE | `[CVE-ID] Remediate [library/component]` e.g. "CVE-2024-1234 Remediate log4j in bootstrap-service" |
