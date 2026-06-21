# Test Plan Matrix Reference

## Default Matrix Template

```markdown
## 📋 Test Case Matrix

| ID | Assignee | Category | Priority | Endpoint + Description | Expected | Actual | Notes |
|----|----------|----------|----------|------------------------|----------|--------|-------|
| TC-001 | @Name | [Category] | 🔴 P0 | [endpoint or scenario] | [expected result] | | |
```

---

## Column Definitions

| Column | Description | Notes |
|---|---|---|
| ID | Sequential: TC-001, TC-002, ... | Never reuse or skip IDs |
| Assignee | @mention the tester | Default to current user if not specified |
| Category | Group/theme for this test | Used to group rows visually |
| Priority | P0–P3 with emoji marker | See priority table below |
| Endpoint + Description | API endpoint + what is being tested | Replace with "Scenario" for non-API tests |
| Expected | What should happen | Be specific — not "works correctly" |
| Actual | Test result | Leave empty until tested |
| Notes | Observations, caveats, links | Optional |

---

## Priority Conventions

| Priority | Emoji | Meaning | When to Use |
|---|---|---|---|
| P0 | 🔴 | Critical | Core functionality, must pass before release |
| P1 | 🟠 | High | Important features, security, robustness |
| P2 | 🟡 | Medium | Edge cases, less-common paths |
| P3 | 🟢 | Low | Nice-to-have, cosmetic, future hardening |

---

## Actual Column Values

| Value | Meaning |
|---|---|
| ✅ or `V` | Passed |
| ❌ or `X` | Failed |
| ⏳ | In progress / being tested |
| `N/A` | Not applicable to this environment |
| _(empty)_ | Not tested yet |

---

## Column Adaption by Test Type

For non-API test plans, replace `Endpoint + Description` with the most fitting column:

| Test Type | Suggested Column Name |
|---|---|
| API tests | `Endpoint + Description` |
| UI / flow tests | `Scenario` |
| Component / unit tests | `Component + Case` |
| Security tests | `Attack Vector + Description` |
| OS / environment tests | `Environment + Case` |
| Performance tests | `Metric + Condition` |

Confirm the column name with the user if the test type is ambiguous.

---

## Grouping and Structure

- Group rows by **Category**
- Add a blank separator row or a bold Category header row between groups
- Categories should be consistent across the matrix — define them upfront based on feature areas

Example categories for a typical backend feature:
- Feature Toggle
- List / Discovery
- Fetch / Retrieval
- Validation
- Security
- Error Handling
- Edge Cases
- Performance
- OS-Specific

---

## Priority Guide Section

Place this after the matrix table:

```markdown
## 🎯 Priority Guide

### 🔴 P0 — Critical (Must Pass)
- [category or test range]
- [category or test range]

### 🟠 P1 — High (Important)
- [category or test range]

### 🟡 P2 — Medium (Edge Cases)
- [category or test range]

### 🟢 P3 — Low (Nice to Have)
- [category or test range]
```

---

## Surgical Update Rules

When updating cells in the matrix:

1. **Identify by ID** — always locate the row by TC-ID, not by position
2. **Reconstruct exactly** — column count, pipe alignment, and spacing must be identical to the source
3. **Preserve untouched cells** — copy them verbatim, including mentions, emoji, and empty cells
4. **Batch by range** — for TC-005 to TC-010, update all in a single page write, not one by one
5. **Auto-assign new IDs** — when adding rows, continue from the highest existing TC-ID

### Clear operations
- "Clear Actual column" → set every Actual cell to empty string (keep pipes)
- "Reset TC-001" → clear Actual and Notes for that row only
- "Mark all P0 as passed" → filter by Priority = P0, set Actual = ✅

---

## Full Page Structure for Test Plans

```markdown
[ToC macro]

## 📌 Overview
[What is being tested, why, and what version/scope]

## 🔍 Scope
[What is in scope and what is explicitly out of scope]

## 📋 Test Case Matrix
[matrix table here]

## 🎯 Priority Guide
[P0/P1/P2/P3 breakdown]

## 🧾 Appendix
[Environment setup, tooling notes, reference links]
```
