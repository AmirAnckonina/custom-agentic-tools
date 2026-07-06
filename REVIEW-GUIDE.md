# Review Guide — branch `feat/user-level-agentic-workflow`

What this branch is, why each change was made, and how to go over it. Written 2026-07-06.

## What happened

The whole `agentic-workflow` capability (3 agents, 9 skills, 1 command, pipeline doc) went through a
one-artifact-at-a-time review against the **current** Claude Code platform docs, got fixed/hardened,
was renamed where naming was broken, and is now **installed live**: `~/.claude/{agents,skills,commands}`
symlink into this repo (this branch), and `~/.claude/CLAUDE.md` symlinks to `templates/CLAUDE.user.md`.

- **CHANGELOG.md** — the per-file detail (every change, per artifact).
- **This file** — the reading order, the big decisions, and the smoke-test checklist.

## How to review the branch

```bash
git log --oneline main..feat/user-level-agentic-workflow   # the commits
git diff main --stat                                        # what moved
git diff main -- claude/agents/                             # the 3 agents (highest value)
git diff main -- claude/skills/review-lenses claude/skills/spec-format
git diff main -- capabilities/agentic-workflow/             # bundle + docs
```

Suggested reading order (most consequential first):

1. `claude/agents/reviewer.md` — most changes; the parallel-dispatch fix lives here.
2. `claude/agents/builder.md` — the Approved-gate enforcement.
3. `claude/agents/architect.md` — memory scope, run modes, write-guard hook.
4. `claude/skills/review-lenses/SKILL.md` — severity system overhaul.
5. `claude/skills/spec-format/SKILL.md` — the N/A escape hatch (small diff, big contract).
6. Everything else via CHANGELOG.md.

## The 7 decisions that matter (and why)

1. **Renames.** `spec-reviewer` → `spec-review`: every file in the stack referenced `/spec-review`,
   which did not exist under the old skill name — this was a live bug, not cosmetics.
   `reviewer-internal` → `reviewer`: the "-internal" contrasted with a long-archived external
   reviewer; the triad `@architect → @builder → @reviewer` is the demo story. The command stays
   `/review-internal` (distinct from built-in `/review`, `/code-review`).

2. **Reviewer can actually parallelize now.** Its instructions said "dispatch 6 lenses via the Agent
   tool" but `Agent` was not in its tools — dispatch silently degraded to one big inline pass.
   Nested subagents are supported (Claude Code ≥ 2.1.172) only when `Agent` is listed. Also fixed:
   lens checklist paths were project-relative (broken in every target repo), and lenses were told to
   use an output format from a skill they never receive — the parent now injects it verbatim.

3. **Terminal report is the reviewer's deliverable.** Git actions (commit/push/PR-MR) are opt-in on
   explicit request only; `gh-ops`/`glab-ops` are no longer preloaded — the reviewer loads the one
   matching `git remote -v` via the Skill tool when asked. The git-host bundles are optional; the
   core pipeline is self-contained.

4. **The Approved gate is enforced, not just documented.** The pipeline's core invariant ("Builder
   cannot start until the spec is Approved") existed only in prose docs. The Builder now checks
   `**Status:**` in Step 0 and refuses otherwise. Symmetrically, cto-review and spec-review now SET
   the status while active (spec-format always claimed they did). Human confirmation gates that
   duplicated the file-based approval were removed (GO/NO-GO instead) — approval travels in the spec
   file; that is the point of the design.

5. **3 severity tiers, hard CRITICAL gate.** The 🟢 POSITIVE tier is gone everywhere (a lesson
   already learned in the aa-code-review pilot: praise findings dilute signal). 🔴 requires all
   three: reachable + violates a top-tier invariant + no upstream mitigation; when in doubt,
   downgrade. One report-format owner (the reviewer agent) — the duplicate template in
   review-lenses was deleted because the two had already drifted apart.

6. **Structural enforcement over prose.** Architect: PreToolUse hook blocks writes outside `docs/`
   (needs `jq`; fails open). Memory scoped `project` (was `user` — repo A's conventions were
   bleeding into repo B designs). Numeric thresholds in coding-standards (coverage %, size caps)
   are now explicit *defaults* that yield to a repo's declared conventions — kills noise findings
   on legacy codebases. De-SecuriThings'd: hardcoded `develop` MR/PR target and a "CDM" example
   are now generic.

7. **Where this lives, long-term.** This monorepo + capability bundles + symlink install IS the
   management model: unrelated capabilities (atlassian, slack-comms, …) stay dormant at zero cost
   until `./install.sh <name>`. Not splitting repos (shared gh/glab dependency would fork).
   Not converting to plugins yet — *(verified)* plugin agents ignore `hooks` and `permissionMode`
   frontmatter, which would silently drop the architect's write-guard and the builder's
   acceptEdits. Revisit when sharing becomes real. Model: `main` = installed/stable; every change
   on a branch (symlinks make the checked-out branch the live canary); merge + tag after testing.

## Smoke-test checklist (before merging to main)

In a scratch git repo (small Go module), run the pipeline end to end:

- [ ] `@architect` (or `claude --agent architect`) with a small feature ask
  - [ ] Step 0 reads happen (CLAUDE.md, manifest, structure) before any design
  - [ ] Stops at the combined summary + Discovery gate (subagent mode: returns the questions)
  - [ ] Write-guard hook: spec lands in `docs/`; a write outside `docs/` is BLOCKED
- [ ] Fast-track + skip-reviews path → spec `Status: Approved`, skip conventions recorded
- [ ] `@builder` on the Approved spec
  - [ ] Refuses a `Draft` spec (test once with status manually reverted)
  - [ ] GO/NO-GO: proceeds without asking when spec is Approved + validation clean
  - [ ] TDD loop runs; Build Report format; DoD honest (no new lint warnings claim)
- [ ] `/review-internal`
  - [ ] Pass 1 mechanical table appears
  - [ ] 6 lens subagents actually dispatch in parallel (visible in the subagent panel)
  - [ ] Terminal report, 3 tiers only, NO git actions offered
- [ ] Experiments (flagged in CHANGELOG "Still pending"):
  - [ ] `context: fork` on cto-review (guaranteed clean-context challenge)
  - [ ] Builder inverse write-guard (block `docs/` writes)

## After the smoke test

1. Fix whatever failed, on this branch.
2. Merge to `main`, tag `v1.0`, push.
3. Backlog lives at `~/agentic-workflow-workbench/aa-code-review-improvements-spec.md`
   (the other repo's reviewer — candidate to fold in here as a capability later).
