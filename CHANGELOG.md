# Changelog — user-level-setup staged copy vs. `custom-agentic-tools` originals

All changes made in this staged copy (2026-07-06), pending port back to the source repo at install time. Facts marked *(verified)* were checked against the live Claude Code docs (code.claude.com/docs), not assumed.

## Doc facts established during review *(verified)*

- Agent frontmatter fields `skills:` (preloads FULL skill content at startup), `maxTurns`, `memory: user|project|local`, `color`, `permissionMode`, `hooks` are all supported.
- `@agent-name` spawns a one-shot **subagent** that cannot await user replies mid-run; `claude --agent <name>` runs the agent **as the main session** (fully interactive, CLAUDE.md auto-loads).
- Subagents do NOT receive CLAUDE.md automatically — the agents' Step 0 reads are load-bearing.
- Nested subagents are supported since v2.1.172, but only if `Agent` is in the subagent's `tools`.
- Skill frontmatter `user-invocable: false` is valid (hides from `/` menu; description stays in context in EVERY session — keep those descriptions short). `disable-model-invocation: true` must NEVER be added to the pipeline skills — it blocks agent `skills:` preloading.
- The Agent tool has no per-invocation maxTurns parameter — turn budgets for lens subagents are prompt guidance only.

## agents/architect.md

1. `memory: user` → `memory: project`; Memory Management section rewritten — codebase conventions stay project-scoped; cross-project wisdom goes to the `architect-methodology` skill (human-curated), not agent memory.
2. Added **Run modes** paragraph — full interactive protocol assumes main-session mode (`claude --agent architect`); as a subagent, end turn at a gate with the question as the result.
3. Merged Step 1 confirmation + Discovery questions into one round-trip.
4. `/docs` → repo-relative `docs/` (3 places).
5. Description rewritten as "Use when…" (auto-delegation).
6. Added **PreToolUse write-guard hook** on Write|Edit: blocks writes outside `docs/` (agent-memory paths exempt). The docs/-only boundary is now structural, not prose. Requires `jq`; fails open if absent.

## agents/builder.md

1. Added Step 0 check: **spec `Status:` must be `Approved`** or the Builder refuses and points to the review gates (pipeline's core invariant was previously doc-only). Inline user tasks exempt.
2. Step 1 "wait for user confirmation" → **GO/NO-GO**: Approved + clean validation ⇒ proceed (the status IS the authorization); stop only on discrepancies, with subagent stop semantics.
3. `maxTurns: 25` → `50` (TDD loop over a 12-AC spec doesn't fit in 25; truncation mid-loop is the worst failure).
4. Definition of Done lint criterion: repo-wide "zero warnings" → **zero NEW warnings on changed code**.
5. Description → "Use when…" (states the Approved precondition); `/docs` → `docs/`.

## agents/reviewer.md

1. **Added `Agent` to tools** — Pass 2's 6-lens parallel dispatch was impossible without it (silent inline degradation).
2. **Added `Skill` to tools; removed `gh-ops`/`glab-ops` from `skills:` preload** — leaner default context; git-host skill loaded on demand, per actual remote.
3. **Terminal report is the deliverable** — post-review git actions are opt-in on explicit user request only (was: mandatory "commit+push?" question after SHIP IT).
4. Fixed lens checklist path: `.claude/skills/...` (project-relative, broken) → `~/.claude/skills/...`.
5. Lens output format now **injected verbatim** into lens prompts by the parent (lenses previously told to use a format from a skill they never receive).
6. Removed 🟢 POSITIVE / `POS-{n}` tier everywhere (IDs, verdict table, summary, coverage statuses, emoji list) — 3 tiers only.
7. Pre-review confirmation gate removed (read-only advisory work proceeds; pauses only on missing/unapproved spec). Post-review git gate retained.
8. Dropped the unmeasurable tool-call-count "Lens Summary" table; `/docs` → `docs/`; PR/MR wording generalized; description → "Use when…".

## skills/review-lenses/SKILL.md

1. POSITIVE tier fully removed (severity levels, "manufacture one positive" rule, output format, verdict table, IDs, status values).
2. CRITICAL definition upgraded to the compact 3-criteria gate (reachable / top-tier invariant / no upstream mitigation; when in doubt, downgrade).
3. Stale `deep-reviewer` consumer references → `reviewer`, with the injection contract explained.
4. Unenforceable "requires coding-standards → halt" clause → real relationship: lens reference files are operational copies; `coding-standards` is the editing-time authority.
5. Competing full report template deleted — **single owner: `agents/reviewer.md`**; the skill keeps only building blocks (severity, output format, coverage table, verdict rules, IDs).
6. `maxTurns: 6` reworded as prompt guidance; "no glab commands" → "no git-host commands (gh/glab)".

## skills/spec-format/SKILL.md

1. Added the **`N/A — [reason]` escape hatch** for simple/fast-track specs (headings never omitted; Acceptance Criteria and Interfaces exempt) — resolves the "all sections required" vs. "minimal spec" contradiction without inviting filler.
2. Description trimmed (always-in-context cost for `user-invocable: false` skills).
3. Architect line aligned with the escape hatch.

## skills/architect-methodology/SKILL.md

1. Description rewritten as a trigger ("Use when evaluating a design or architecture decision…") instead of a contents list — routes direct-chat design questions to the skill. Content reviewed in full: no other changes needed (lenses, research protocol, gatekeeper, example all sound and drift-free).

## skills/cto-review/SKILL.md

1. Added Step 1 guards (no spec found → stop; already Approved → stop) and the missing `Status: CTO Review` update at review start — spec-format promised this skill sets it, but the skill never did.
2. Description trimmed to triggers only (was summarizing the whole workflow — SDO risk + always-in-context weight).
3. Replaced the SecuriThings-internal "CDM" example with a generic one (stack must be shareable/demonstrable).
4. Flagged, NOT applied: `context: fork` would make the "arrives clean, no Architect context" claim structurally true instead of aspirational — test at smoke-test time (see Still pending).

## skills/spec-review/SKILL.md

1. Fixed audit-subagent checklist path: `.claude/skills/...` → `~/.claude/skills/...`.
2. Added the missing `Status: Detail Audit` update at review start (promised by spec-format, never done).
3. Explicit verdict mapping: `⚠️ Suggestions Only` → recorded as `✅ Approved` + suggestions in the Issues column (the ⚠️ verdict previously had no representation in spec-format's table legend); overall rule reworded to "no blocking issues → Approved".
4. Audit subagents now dispatched with explicit `model: "opus"` (AGENTIC-WORKFLOW promised Opus; dispatch previously inherited the session model silently).
5. Description trimmed to triggers (was summarizing workflow + the "arrives clean" claim).

## skills/build-report/SKILL.md

1. Description trimmed (always-in-context weight). Content reviewed in full — no other changes; the change-tree rules and skip-conditions are sound.

## skills/coding-standards/SKILL.md

1. Body confirmed byte-identical to the reviewed aa twin (mod line endings) — no content re-review needed.
2. Added "numeric thresholds are defaults, not laws" note — coverage % / size limits / nesting depth yield to a repo's declared conventions (prevents noise findings on legacy codebases).
3. Normalized CRLF → LF (also fixed in commands/review-internal.md — the only two CRLF files in the set).

## skills/gh-ops & skills/glab-ops

1. Default PR/MR target branch: hardcoded `develop` (a SecuriThings-era convention) → the repo's actual default branch, with CLAUDE.md/user override. Fixed in both skills.
2. Removed `user-invocable: false` from glab-ops — gh-ops was visible in the `/` menu, glab-ops hidden, for no reason; both are meaningful user actions.
3. Both skills' Step-0 remote-applicability checks reviewed — sound (each verifies `git remote -v` before acting; auth is user-run only, never agent-interactive).

## commands/review-internal.md

1. Step 3 rewritten: **terminal report is the deliverable**; git actions on explicit request only (was MANDATORY options question).
2. Removed stale "reviewer will ask during Step 1" (gate no longer exists); "Task tool" → "Agent tool"; description updated.

## docs/AGENTIC-WORKFLOW.md

1. Reviewer model corrected in all four places: Sonnet → Opus orchestrator + 6 Sonnet lens subagents; pipeline diagram updated (terminal report as output, git on request).
2. "Why an agent for code review" rationale updated for nested-subagent support (v2.1.172+).
3. Git-host dependency section marked **Optional** — core pipeline works without gh-ops/glab-ops.

## Renames (2026-07-06, user-approved)

1. Skill `spec-reviewer` → **`spec-review`** (dir + `name:` + all references). Fixes a real breakage: every file in the stack referenced `/spec-review`, which didn't exist under the old skill name.
2. Agent `reviewer-internal` → **`reviewer`** (file → `agents/reviewer.md`, `name:`, all references). Clean triad: `@architect` → `@builder` → `@reviewer`. The command stays `/review-internal` (distinct from built-in `/review` and `/code-review`).

## Still pending (not yet reviewed in depth)

- `skills/architect-methodology`, `skills/cto-review`, `skills/spec-review` (content), `skills/build-report`, `skills/coding-standards` (diff vs. aa twin), `skills/gh-ops`, `skills/glab-ops`.
- Builder inverse write-guard hook (block `docs/` writes) — optional symmetry with the architect hook.
- `context: fork` experiment for `cto-review` (guaranteed clean context for the fresh-eyes challenge) — verify interactivity trade-off at smoke-test time.
- Related backlog: `../aa-code-review-improvements-spec.md`.
