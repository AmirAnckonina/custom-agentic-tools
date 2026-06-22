# GitHub Ops

PR lifecycle, code review, and CI monitoring through the official `gh` CLI. Repo-aware — checks the actual git remote before acting, so it coexists safely with `gitlab-ops` in a mixed-host environment.

## What it includes

- **Skill:** [`gh-ops`](../../claude/skills/gh-ops/SKILL.md) — no agent or command; loaded by other agents (e.g. the [agentic-workflow Reviewer](../agentic-workflow/README.md)) or invoked directly in chat

## How it works

Before running anything, it confirms the repo's remote is `github.com` — if not, it stops and defers rather than misfiring `gh` against the wrong host. Covers PR reading (`view`, `diff`, `checkout`), PR lifecycle (`create`, `merge`, `close`, labels, reviewers), reviews & inline comments, GitHub Actions monitoring (run status, logs, re-run), releases/tags, and a `gh api` reference for anything uncovered. **Every write action requires your explicit approval** — it presents the exact command and waits for a "yes" before executing, one write at a time. Falls back to plain `git` + copy-paste-ready text if `gh` isn't installed.

## Install

```bash
./install.sh github-ops
```

## Requires

`gh` CLI installed and authenticated (`gh auth login`).
