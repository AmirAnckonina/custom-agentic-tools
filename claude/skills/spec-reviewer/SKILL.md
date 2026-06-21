---
name: spec-review
description: >
  Detail audit of architecture specs through 5 independent perspectives before the Builder starts.
  Use when: "spec review", "detail audit", "review the spec", "audit the spec", "check the spec", "run detail audits".
  Examines specs through Security, Scalability, API Design, Completeness, and Scope lenses.
  Each perspective runs as a parallel subagent for speed and independence.
  Produces structured findings per perspective with BLOCKING issues and suggestions.
  Updates the Review Notes table in the spec file. Arrives clean — no Architect context by design.
user-invocable: true
---

# Spec Review (Detail Audits)

## Overview

This skill runs **5 independent detail audits** against an architecture spec. Each perspective
examines the spec for specific concerns — security gaps, scalability risks, API inconsistencies,
completeness gaps, and scope issues.

**Position in the pipeline:**
```
Architect (Draft) → /cto-review (strategic gate) → /spec-review (detail audits) → Builder
                                                         ↓
                                                   ❌ Blocking → back to Architect
```

This skill runs AFTER the CTO review has passed (or been skipped). It checks the **details**
the CTO deliberately does not cover.

---

## Keywords

spec review, detail audit, review spec, audit spec, check spec, security review,
scalability review, API review, completeness check, scope review, spec approval, before builder

---

## Step 1: Orient

Before reviewing, gather context:

1. Read the spec file in full — do not skim
2. Check `**Status:**` — should be `Detail Audit` or `CTO Review` (if CTO was skipped, `Draft` is also valid)
3. If Status is `Approved`, ask before re-reviewing
4. Read the `## CTO Review` section — understand what strategic concerns were already addressed
5. Read referenced files in spec (interfaces, existing code patterns):
   - Use Read + Grep to locate relevant existing implementations
   - Understand the codebase conventions this spec must conform to
6. Note the requirements source — what was the user actually asking for?

**Do NOT:**
- Assume you know what the Architect intended
- Carry over any reasoning from the Architect's or CTO's session
- Skip sections because they look fine at a glance
- Re-litigate CTO-level concerns (approach, strategic fit) — that gate is done

---

## Step 2: Launch 5 Parallel Perspective Audits

Each perspective runs as an **independent subagent**. They do not share context or influence
each other — this is by design. Cross-perspective checks happen after all 5 complete.

Launch all 5 in parallel using the Agent tool. Each subagent receives:
- The full spec file path
- Its specific perspective reference file
- Instructions to read the spec, apply its checklist, and return findings

### Subagent Prompt Template

For each perspective, launch a subagent with:

```
You are a spec auditor reviewing from the [PERSPECTIVE] perspective.

1. Read the spec file at: [SPEC_PATH]
2. Read your reference checklist at: .claude/skills/spec-reviewer/references/[REFERENCE_FILE]
3. Read the codebase files referenced in the spec to verify patterns and conventions.
4. Apply every challenge question from your checklist against the spec.
5. For each question: note whether the spec addresses it, and if not, whether it's BLOCKING or a SUGGESTION.

Return your findings in this format:

### [Perspective Name]
Verdict: ✅ Approved | ❌ Blocking Issues | ⚠️ Suggestions Only

BLOCKING:
- [Issue] — [spec section] — [why it's blocking]

SUGGESTIONS:
- [Suggestion] — [spec section] — [why it improves the spec]

CODEBASE NOTES:
- [Any inconsistencies with existing codebase patterns]
```

### The 5 Perspectives

| # | Perspective | Reference File | Focus |
|---|---|---|---|
| 1 | Security | `references/security-review.md` | Auth, input validation, data exposure, injection, tokens |
| 2 | Scalability | `references/scalability-review.md` | Load, queries, caching, concurrency, external deps |
| 3 | API Design | `references/api-design-review.md` | HTTP semantics, consistency, pagination, error shapes |
| 4 | Completeness | `references/completeness-review.md` | All sections filled, ACs testable, edge cases, dependencies |
| 5 | Scope | `references/scope-review.md` | Single capability, right size, no over/under-engineering |

---

## Step 3: Collect and Cross-Check

After all 5 subagents return, check for cross-perspective inconsistencies:

- **Security ↔ API Design:** Do error responses from API Design leak internal info flagged by Security?
- **Scalability ↔ Completeness:** Do Failure Modes cover the scalability failure cases (timeout, pool exhaustion)?
- **Scope ↔ Completeness:** Are all in-scope requirements actually specified? Are out-of-scope items accidentally specified?
- **API Design ↔ Interfaces:** Does the function signature in Interfaces match what the API contract implies?
- **Security ↔ Completeness:** Is Security Considerations section substantive, or is it a placeholder?

Add any cross-perspective findings to the relevant perspective's output.

---

## Step 4: Produce Output

### Per-Perspective Verdict

For each perspective, output:

```
### [Perspective Name]
Verdict: ✅ Approved | ❌ Blocking Issues | ⚠️ Suggestions Only

BLOCKING:
- [Issue 1] — [specific location in spec] — [why it's blocking]

SUGGESTIONS:
- [Suggestion 1] — [specific location] — [why it improves the spec]
```

### Overall Verdict

```
## Spec Review: [Feature Name]
Overall: ✅ Approved | ❌ Not Approved — [N] blocking issues across [perspectives]

### Must Fix (Blocking)
1. [Issue] — [Perspective] — [Action required]

### Suggestions (Non-blocking)
1. [Suggestion] — [Perspective]

### Cross-Perspective Notes
- [Any inconsistencies found]

### Next Step
[If approved]: Status → Approved. Builder may start.
[If blocking]: Status → Draft. Architect to revise. Re-run /spec-review after revision.
```

### Update the Spec File

Update the `## Review Notes` table in the spec:

```markdown
| Perspective  | Status              | Issues                    |
|---|---|---|
| Security     | ✅ Approved / ❌ Issues Found | [summary or "—"]  |
| Scalability  | ✅ Approved / ❌ Issues Found | [summary or "—"]  |
| API Design   | ✅ Approved / ❌ Issues Found | [summary or "—"]  |
| Completeness | ✅ Approved / ❌ Issues Found | [summary or "—"]  |
| Scope        | ✅ Approved / ❌ Issues Found | [summary or "—"]  |
```

**Status update:**
- If all ✅ → set `**Status:**` to `Approved`
- If any ❌ → set `**Status:**` to `Draft` (back to Architect for revision)

---

## Step 5: Iteration Protocol

When the Architect revises after blocking issues and asks for re-review:

1. Re-read the **full spec** (not just changed sections — revisions can introduce new issues)
2. Re-run only the perspectives that had blocking issues, plus cross-perspective checks
3. Check that each blocking issue from the previous round is resolved — do not close an issue unless the fix is complete
4. Update the Review Notes table with the new round's results
5. If new issues surface in unchanged sections — flag them (normal and expected)

---

## When NOT to Use This Skill

- You want a strategic/approach challenge → use `/cto-review`
- Reviewing code (not specs) → use the Reviewer agent
- Advisory architecture questions → use `architect-methodology`
- The spec Status is already `Approved` and nothing has changed
- Reviewing a design doc that is not a formal spec (no ACs, no Interfaces)
