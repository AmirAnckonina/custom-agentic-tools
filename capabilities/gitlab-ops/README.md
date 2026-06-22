# GitLab Ops

MR lifecycle, discussions, and CI/CD monitoring through the official `glab` CLI. The GitLab counterpart to [`github-ops`](../github-ops/README.md) — same shape, GitLab terminology (merge requests, discussions, pipelines).

## What it includes

- **Skill:** [`glab-ops`](../../claude/skills/glab-ops/SKILL.md) — no agent or command; loaded by other agents (e.g. the [agentic-workflow Reviewer](../agentic-workflow/README.md)) or invoked directly in chat

## How it works

Confirms the repo's remote is a GitLab host before running anything — defers to `gh-ops` if it's actually `github.com`, so the two skills never cross-fire commands against the wrong platform. Covers MR reading (`view`, `diff`, `checkout`), MR lifecycle (`create`, `approve`, `merge`, `rebase`, `close`), discussions (resolvable comment threads, resolve/unresolve), CI/CD pipeline status and job logs, and a `glab api` reference for anything uncovered. **Every write action (create/merge/close/approve/comment) requires your explicit approval** before it runs. Falls back to plain `git` + copy-paste-ready text if `glab` isn't installed.

## Install

```bash
./install.sh gitlab-ops
```

## Requires

`glab` CLI installed and authenticated (`glab auth login`). Self-managed GitLab instances: check [`glab-ops`'s own notes](../../claude/skills/glab-ops/README.md) for host/port/SSH pitfalls.
