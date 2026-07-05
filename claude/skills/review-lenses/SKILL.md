---
name: review-lenses
description: "Review scoring system: 6 parallel lenses, severity levels, enforcement protocol, and verdict rules. The single source of truth for how reviews are scored. Loaded by the reviewer agent, which injects the relevant sections into the lens subagents it dispatches."
user-invocable: false
---

## Review Lenses

This skill defines the **review scoring system** and the **6 parallel review lenses**.

**Loaded by:** the `reviewer` agent (via `skills:` frontmatter). Not user-invocable — orchestration is handled by the parent agent, which injects the Subagent Output Format and Boundaries into each lens prompt.

> The 6 lens reference files under `references/` carry the operational copies of the 13 `coding-standards` principles — lens subagents need only their reference file, not the coding-standards skill. `coding-standards/SKILL.md` is the editing-time authority: change a principle there first, then sync the affected lens file.

---

## Challenge Methodology

Your job is to break the code, not confirm it works. The author already believes it works. Your value is finding what they missed.

- **Trace, don't skim.** Walk through code paths with concrete boundary values. Challenge every conditional — what happens in the else?
- **Challenge state & side effects.** Can it reach an inconsistent state? Are resources properly closed on error paths? Shared mutable state?
- **Challenge the tests.** Are assertions verifying behavior? Missing negative/boundary tests? Test independence?
- **Challenge the API contract.** Cross-reference swagger/OpenAPI against code paths. Trace upstream responses through the call chain.

---

## Severity Levels

**🔴 CRITICAL** — merging as-is causes incorrect data, data loss, a security breach, or an outage. A finding is 🔴 only when ALL THREE hold: (1) **reachable** — fires on a real code path shipped in this change, not theoretical; (2) **violates a top-tier invariant** — security boundary, data integrity, outage class; (3) **no upstream mitigation** — nothing above this code already bounds the impact. If any of the three is uncertain, it's 🟡. **When in doubt, downgrade** — over-flagged criticals teach authors to ignore the label. (Spec-signature mismatches, missing AC tests, and broken tests are Pass 1 territory and are 🔴 by definition there.)

**🟡 IMPORTANT** — real risk, bounded scope. Should fix before broader rollout but not a merge blocker: missing error handling on recoverable paths, test gaps, performance regressions that degrade rather than fail, a 🔴-shaped finding where one criterion is uncertain.

**🔵 SUGGESTION** — author may defer. Readability, naming, minor refactors, style consistency, theoretical edge cases, micro-optimizations.

**3 tiers only.** No POSITIVE / 🟢 / `POS-{n}` category — do not include praise findings or sections. Good work is noted, if at all, in one clause of the lens Summary, never as a finding.

---

## Enforcement Protocol

- For each principle covered by a lens, **actively search** for violations using tool-assisted scans (grep for magic numbers, `@SuppressWarnings`/`noinspection`, bare catch blocks, raw `Map`/`Object` types where DTOs should exist).
- A lens is **Clean only if you have evidence** — you checked and found nothing. "I didn't look closely" means findings were missed.

---

## The 6 Lenses

| # | Lens | Reference File | Principles Covered |
|---|------|---------------|-------------------|
| 1 | Correctness & Logic | `references/correctness-lens.md` | #2 Edge Cases, #3 Null Safety (logic paths) |
| 2 | Security & Input Safety | `references/security-lens.md` | #9 Security, #3 Null Safety (boundary validation) |
| 3 | Reliability & Operations | `references/reliability-lens.md` | #4 Error Handling, #11 Logging, #2 Edge Cases (failure) |
| 4 | Design & Structure | `references/design-lens.md` | #6 SOLID, #7 Encapsulation, #8 Interface Design |
| 5 | Performance & Testing | `references/perf-testing-lens.md` | #1 Test Coverage, #10 Performance |
| 6 | Readability & Conventions | `references/readability-lens.md` | #5 Naming, #12 Comments, #13 Consistency |

---

## Subagent Configuration

- **subagent_type:** `general-purpose` (needs Read, Grep, Glob, Bash for code analysis)
- **model:** Sonnet by default. Opus if `--deep` flag was passed.
- **Turn budget:** instruct each lens (in its prompt) to aim for ≤6 tool calls — the parent pre-reads files and diff, so lenses only need tools for surrounding context. (This is prompt guidance; the Agent tool has no per-invocation turn cap.)
- **Pre-read optimization:** The parent orchestrator reads all changed files and the diff ONCE, then injects relevant content into each lens prompt. Lenses should NOT re-read these files or re-run `git diff`. They may read additional files (imports, callers, related modules) for surrounding context.
- **Boundaries:** READ ONLY. No file modifications. No git lifecycle commands. No git-host commands (`gh`/`glab`). No user interaction.

---

## Subagent Output Format

Subagents return natural findings within their lens focus. No principle numbers, no scorecard mapping.

**IMPORTANT — Emoji rendering:** Always use actual Unicode emoji characters (🔴 🟡 🔵 ✅ ⚠️ ❌), NEVER markdown shortcodes like `:red_circle:` or `:yellow_circle:`. Shortcodes do not render in the terminal.

```
### Findings

🔴 CRITICAL — [file:line] — [what's wrong] — [why it matters]
🟡 IMPORTANT — [file:line] — [description] — [impact]
🔵 SUGGESTION — [file:line] — [description]

### Summary
[2-3 sentences: overall assessment from this lens's perspective]
```

---

## Failure Handling

If a subagent fails or returns empty:
1. Retry once with the same prompt
2. If still fails → mark `❌ NOT REVIEWED` in Lens Coverage table
3. Flag that lens's principles as coverage gaps
4. Never silently skip — the user must know what wasn't reviewed

---

## Cross-Check Rules (Parent, Post-Collection)

After all 6 lenses return, the parent checks:
- **Security ↔ Reliability:** Error responses leaking internal info?
- **Correctness ↔ Testing:** Logic bugs found — are they covered by tests?
- **Security ↔ Design:** Public API surface exposing internal implementation?
- **Performance ↔ Reliability:** Performance optimization introducing failure modes?
- **Design ↔ Readability:** Structural decisions hurting readability? Good naming masking bad design?
- **Deduplication:** Same finding from multiple lenses → keep highest severity, merge notes.

---

## Verdict Rules

Driven by highest finding severity — simple and deterministic.

| Highest Severity Found | Verdict |
|----------------------|---------|
| Any 🔴 CRITICAL | **BLOCKER** |
| Any 🟡 IMPORTANT (no criticals) | **NEEDS WORK** |
| Only 🔵 SUGGESTION (or no findings) | **SHIP IT** |

---

## Finding IDs

The parent assigns prefixed IDs after collecting all lens results:
- `CRT-{n}` — Critical
- `IMP-{n}` — Important
- `SUG-{n}` — Suggestion

No `POS-{n}` IDs are ever assigned.

These IDs enable drill-down: user can ask "expand CRT-1" or "show Reliability details".

---

## Lens Summary Table

The primary review output table. Replaces the 13-principle scorecard — findings are reported per lens, not remapped to individual principles.

```
### Lens Coverage
| Lens | Model | Status | Findings | Top Finding |
|------|-------|--------|----------|-------------|
| Correctness & Logic | {LENS_MODEL} | ✅ Clean / ⚠️ / 🔴 / ❌ NOT REVIEWED | N🔴 N🟡 N🔵 | [ID or —] |
| Security & Input Safety | {LENS_MODEL} | ... | ... | ... |
| Reliability & Operations | {LENS_MODEL} | ... | ... | ... |
| Design & Structure | {LENS_MODEL} | ... | ... | ... |
| Performance & Testing | {LENS_MODEL} | ... | ... | ... |
| Readability & Conventions | {LENS_MODEL} | ... | ... | ... |
```

**Status values:**
- `✅ Clean` — no findings
- `⚠️ N findings` — only suggestions
- `🟡 N important` — important findings, no criticals
- `🔴 N critical` — critical findings present
- `❌ NOT REVIEWED` — lens failed after retry

---

## Review Report Format

**Single owner: the `reviewer` agent definition.** The full report template (Pass 1 mechanical-checks table, findings summary, lens coverage, drill-down protocol, activity summary) lives in `agents/reviewer.md` — it includes agent-specific sections this skill has no business duplicating. This skill owns only the building blocks the report is assembled from: Severity Levels, Subagent Output Format, the Lens Summary Table, Verdict Rules, and Finding IDs. Do not maintain a second report template here.
