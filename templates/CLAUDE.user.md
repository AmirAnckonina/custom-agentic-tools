# CLAUDE.md — User-Level Rules (Amir)

> Draft — destined for `~/.claude/CLAUDE.md`. Loads into EVERY Claude Code session on this machine, so it stays lean: global behavior only. Project specifics belong in each repo's own CLAUDE.md (see `docs/CLAUDE.md.template` for that).

## GLOBAL RULES (all modes: direct chat, architect, builder, reviewer)

### Communication
- **Strict brevity:** technical, concise language. No filler, no "I understand" preambles.
- **Top-down reporting:** lead with TL;DR / high-level summary; break down details only when asked.
- **Smart referencing:** use `@filename` to locate files; don't scan whole directories unless a file can't be found.

### Planning
- **Planning-first:** before any non-trivial work, present a short plan or outline and wait for approval.

### Coding Standards
- Detailed standards live in the `coding-standards` skill (`~/.claude/skills/coding-standards/SKILL.md`).
  - Agents load it via frontmatter (Builder, Reviewer).
  - Direct chat: load it before producing any implementation code.
- **Code safety:** never handle secrets/passwords insecurely; warn on security implications; use safe, modern APIs (parameterized queries, HTTPS).
- **Respect conventions:** follow the target repo's naming, structure, and architecture; flag deviations.

### Stack Defaults
<!-- ADJUST: personal defaults, e.g.: -->
- Primary language: Go. Secondary: Java/Python as the repo dictates.
- Prefer table-driven tests in Go; standard library before frameworks.

## DIRECT CHAT RULES (no agent active)

- **Ask before acting:** require approval before broad multi-file reads, starting implementation, or repeated automated fix loops. <!-- ADJUST: tune to taste -->
- **No monolithic responses:** for multi-part work, present a numbered outline first.

## AGENT MODE

When a custom agent (Architect, Builder, Reviewer) is active, the agent's own protocol is the **primary authority**; Direct Chat rules do not apply. Global Rules always apply regardless of mode.

## AGENTIC WORKFLOW (Architect → Builder → Reviewer)

- Pipeline guide: `docs/AGENTIC-WORKFLOW.md` (in the source repo: `~/repositories/custom-agentic-tools/capabilities/agentic-workflow/`).
- Specs produced by the Architect live in the target project's `docs/` directory, never in `~/.claude/`.
- The spec's `**Status:**` field is the single source of truth; Builder starts only on `Approved`.
- Reviewer's deliverable is the terminal report; git-host operations (`gh-ops` GitHub / `glab-ops` GitLab, each verifies the actual remote) run only on explicit request.

<!-- ADJUST after install: project-conventions defaults (branch naming, commit style) if you want machine-wide fallbacks -->
