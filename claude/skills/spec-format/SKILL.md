---
name: spec-format
description: "Spec contract format defining structure, lifecycle states, and validation rules for architecture specifications. Loaded by Architect (to produce specs), Builder (to implement against), and Reviewer (to validate against). Covers acceptance criteria, interfaces, error handling, scope guidelines, and review gates (CTO Review, Detail Audit)."
user-invocable: false
---

## Keywords
specification, architecture, contract, acceptance criteria, interfaces, review gates, TDD, spec lifecycle

## Spec Lifecycle

Every spec moves through these states before the Builder starts:

| Status | Meaning |
|---|---|
| `Draft` | Architect has written the spec. Not yet reviewed. Builder must NOT start. |
| `CTO Review` | CTO challenge in progress. Builder must NOT start. |
| `Detail Audit` | Detail audit (5 perspectives) in progress. Builder must NOT start. |
| `Approved` | All required reviews signed off. Builder may start. |

**Status transitions:**
```
Draft ──→ CTO Review ──→ Detail Audit ──→ Approved    (full pipeline)
Draft ──→ Detail Audit ──→ Approved                    (CTO skipped)
Draft ──→ Approved                                      (both skipped — simple tasks)

CTO Review ──→ Draft       (CTO says RETHINK — Architect revises)
Detail Audit ──→ Draft     (blocking issues — Architect revises)
```

When a review sends the spec back to `Draft`, the Architect revises and the review cycle restarts from that gate — not from scratch. Prior review history is preserved in the spec.

The status appears at the top of every spec (see format below). The Architect updates it after each review cycle. The Builder checks it — if not `Approved`, stop and ask.

---

## Spec Format (Strict Contract)

Every specification MUST contain these sections. The Builder implements against them. The Reviewer validates against them.

```markdown
# [Feature Name]

**Status:** Draft | CTO Review | Detail Audit | Approved

## Overview
[1-2 paragraphs: what this is and why]

## Acceptance Criteria
- [ ] [Testable requirement — the Builder writes tests against these]
- [ ] [Each criterion must be verifiable with a pass/fail test]

## Interfaces
[Exact function signatures, types, and contracts in the target language]

### Types / Models
[Struct/class definitions, enums, error types]

### Public Functions / Methods
[Signatures with parameter types, return types, and error cases]

### API Contracts (if applicable)
[Endpoints, request/response shapes, status codes]

## Files to Change (optional but recommended)
[List of files to create or modify, with a one-line description of what changes.
Do NOT include implementation code — just what and where.]

## Component Responsibilities
[Which component owns what — one paragraph per component]

## Error Handling
[Expected error cases and how each must be handled]

## Security Considerations
[Auth, input validation, data protection requirements]

## Failure Modes
[What can go wrong and the expected recovery behavior]

## Constraints
[Performance targets, compatibility, dependencies]

## CTO Review
<!-- Populated by /cto-review. Do not edit manually. -->
_Not reviewed yet_

## Review Notes
<!-- Populated by /spec-review (detail audits). Do not edit manually. -->
| Perspective  | Status     | Issues |
|---|---|---|
| Security     | ⬜ Pending | —      |
| Scalability  | ⬜ Pending | —      |
| API Design   | ⬜ Pending | —      |
| Completeness | ⬜ Pending | —      |
| Scope        | ⬜ Pending | —      |

<!-- Status values: ⬜ Pending · ✅ Approved · ❌ Issues Found · ⏭️ Skipped -->
```

### When Reviews Are Skipped

When the Architect or user decides to skip a review gate:

- **CTO Review skipped:** Replace `_Not reviewed yet_` with `_Skipped — [reason, e.g., "simple single-component change"]_`
- **Detail Audit skipped:** Set all Review Notes rows to `⏭️ Skipped`
- **Status** advances past the skipped gate directly

The Architect asks the user which reviews to run when finishing the spec (see Architect agent protocol).

---

## Rules

- **Acceptance criteria** must be testable — no vague language like "should be fast."
- **Interfaces** must be exact — the Builder implements them as-is, not interprets them.
- Every function signature must include its error/exception cases.
- Missing or ambiguous sections → STOP and ask. Do not assume or invent.

## Scope Guidelines

A well-scoped spec should:
- Cover **one cohesive capability** (not multiple bundled features)
- Have **5-12 acceptance criteria** (not 25+)
- Define **1-5 function signatures** in the Interfaces section (not 10+)
- Be **readable in under 5 minutes**

**Split the spec** when:
- Acceptance criteria exceed 12 items
- More than 3 components are being modified
- The spec covers independent capabilities that could be implemented and tested separately
- You find yourself writing "Phase 1" and "Phase 2" in the same spec

**Ordering split specs:** Number them and note dependencies (e.g., "Prerequisite: Spec 1 must be complete").

## Anti-Patterns (What NOT to Include)

The spec defines **what** and **why**. The Builder decides **how**. Do NOT include:

| Anti-Pattern | Why It's Wrong | What to Write Instead |
|---|---|---|
| Function body pseudocode | Builder's job — they follow TDD to discover the implementation | Function signature + error cases + acceptance criterion that tests the behavior |
| Step-by-step implementation walkthrough | Removes Builder's autonomy and creates false precision | Files to Change section with one-line descriptions |
| Complete mock/test code | Builder writes tests as part of TDD Red step | List test case names in acceptance criteria |
| Before/after code diffs | Brittle — code may have changed since spec was written | Describe the behavioral change, not the diff |
| "Phase 2 Notes" or future speculation | Out of scope — design Phase 2 when Phase 2 starts | Constraints section: "Phase 2 will add X — design for extensibility but do not implement" |
| Exact log messages or log field names | Implementation detail | "Structured log entry emitted for [operation] including [key context fields]" |

**The test:** If you delete all code blocks from your spec and it still conveys the full design intent, it's the right weight. If it becomes meaningless, you embedded too much implementation.

## How Each Agent Uses This

- **Architect:** Produces specs following this format exactly. All sections required. Writes function signatures and type definitions — never function bodies. If tempted to write pseudocode, convert it to an acceptance criterion instead. When finishing the spec, asks the user which reviews to run before advancing status.
- **CTO Review (`/cto-review`):** Reads the full spec. Writes strategic challenge findings into the `## CTO Review` section. Updates `Status` to `CTO Review` while active, back to `Draft` if RETHINK, or advances if PASS.
- **Detail Audit (`/spec-review`):** Reads the full spec. Fills the `## Review Notes` table per perspective. Updates `Status` to `Detail Audit` while active, back to `Draft` if blocking issues, or to `Approved` if all pass.
- **Builder:** First checks `Status` — if not `Approved`, stop and ask before doing anything. Then maps each section to implementation:
  - Acceptance Criteria → test cases (at least one per criterion)
  - Interfaces → exact implementation (no renaming, no reordering)
  - Files to Change → implementation plan and file creation order
  - Error Handling → recovery behavior
  - Constraints → performance/compatibility targets
- **Reviewer:** Validates implementation against the spec:
  - Signatures, types, error cases match exactly
  - Every acceptance criterion has a corresponding test
  - Scope matches — nothing extra, nothing missing
