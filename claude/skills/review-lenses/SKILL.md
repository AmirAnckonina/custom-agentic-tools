---
name: review-lenses
description: "Review orchestration: 6 parallel lenses, severity levels, enforcement protocol, verdict rules, and report format. The single source of truth for how reviews are scored and reported. Loaded by deep-reviewer agent."
user-invocable: false
---

## Review Lenses

This skill defines the **review scoring system** and the **6 parallel review lenses**.

**Loaded by:** `deep-reviewer` agent (Opus). Not user-invocable — orchestration is handled by the parent agent.

> **Requires `coding-standards` to be loaded.** Lens checklists reference the 13 coding-standards principles by number. If coding-standards is unavailable, respond with:
> `"review-lenses requires the coding-standards skill. Please load it and retry."` — then halt.

---

## Challenge Methodology

Your job is to break the code, not confirm it works. The author already believes it works. Your value is finding what they missed.

- **Trace, don't skim.** Walk through code paths with concrete boundary values. Challenge every conditional — what happens in the else?
- **Challenge state & side effects.** Can it reach an inconsistent state? Are resources properly closed on error paths? Shared mutable state?
- **Challenge the tests.** Are assertions verifying behavior? Missing negative/boundary tests? Test independence?
- **Challenge the API contract.** Cross-reference swagger/OpenAPI against code paths. Trace upstream responses through the call chain.

---

## Severity Levels

**🔴 CRITICAL** — Must fix. Security vulnerabilities, data loss risks, spec violations that change behavior, broken tests.

**🟡 IMPORTANT** — Should fix. Missing error handling, test gaps, performance issues, incomplete edge cases.

**🔵 SUGGESTION** — Nice to have. Readability, naming, minor refactors, style consistency.

**🟢 POSITIVE** — Good work worth calling out. Clean abstractions, thorough tests, smart edge case handling.

---

## Enforcement Protocol

- For each principle covered by a lens, **actively search** for violations using tool-assisted scans (grep for magic numbers, `@SuppressWarnings`/`noinspection`, bare catch blocks, raw `Map`/`Object` types where DTOs should exist).
- A lens is **Clean only if you have evidence** — you checked and found nothing. "I didn't look closely" means findings were missed.
- Actively identify at least one **POSITIVE** per review — clean abstractions, thorough tests, smart edge case handling. If no genuine positive exists, note it explicitly. Do not manufacture one.

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
- **maxTurns:** 6 per subagent (parent pre-reads files and diff — lenses only need tools for surrounding context)
- **Pre-read optimization:** The parent orchestrator reads all changed files and the diff ONCE, then injects relevant content into each lens prompt. Lenses should NOT re-read these files or re-run `git diff`. They may read additional files (imports, callers, related modules) for surrounding context.
- **Boundaries:** READ ONLY. No file modifications. No git lifecycle commands. No glab commands. No user interaction.

---

## Subagent Output Format

Subagents return natural findings within their lens focus. No principle numbers, no scorecard mapping.

**IMPORTANT — Emoji rendering:** Always use actual Unicode emoji characters (🔴 🟡 🔵 🟢 ✅ ⚠️ ❌), NEVER markdown shortcodes like `:red_circle:` or `:yellow_circle:`. Shortcodes do not render in the terminal.

```
### Findings

🔴 CRITICAL — [file:line] — [what's wrong] — [why it matters]
🟡 IMPORTANT — [file:line] — [description] — [impact]
🔵 SUGGESTION — [file:line] — [description]
🟢 POSITIVE — [file:area] — [what's good]

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
| Only 🔵 SUGGESTION / 🟢 POSITIVE | **SHIP IT** |

---

## Finding IDs

The parent assigns prefixed IDs after collecting all lens results:
- `CRT-{n}` — Critical
- `IMP-{n}` — Important
- `SUG-{n}` — Suggestion
- `POS-{n}` — Positive

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
- `⚠️ N findings` — only suggestions/positives
- `🟡 N important` — important findings, no criticals
- `🔴 N critical` — critical findings present
- `❌ NOT REVIEWED` — lens failed after retry

---

## Review Report Format

**IMPORTANT — Emoji rendering:** Always use actual Unicode emoji characters (🔴 🟡 🔵 🟢 ✅ ⚠️ ❌), NEVER markdown shortcodes.

```
## Review Report

**Verdict: {BLOCKER | NEEDS WORK | SHIP IT}**
**TL;DR:** [1-2 sentences: overall assessment and biggest concern]
**Scope:** [files reviewed, lens count, model used]

### Findings Summary
- 🔴 Critical: [count]
- 🟡 Important: [count]
- 🔵 Suggestion: [count]
- 🟢 Positive: [count]

### Lens Coverage
[Insert Lens Summary Table above]

### Findings

[Critical and Important always expanded]

🔴 **CRT-1** — file:line — description
   └─ Lens: [source lens] · [why it matters]

🟡 **IMP-1** — file:line — description
   └─ Lens: [source lens] · [impact]

🔵 SUG-1 — file:line — description
🟢 POS-1 — [what's good]

> Drill-down: ask by finding ID ("expand CRT-1") or by lens ("show Reliability details")

### Activity Summary
> [e.g., "Pre-read 12 changed files. Launched 6 Sonnet lenses. Collected 14 findings, deduplicated to 11. Cross-checked 5 pairs."]
```
