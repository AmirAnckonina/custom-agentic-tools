# custom-agentic-tools

Personal stack of Claude Code agents, skills, and commands — generalized from a previous employer's setup and stripped of any company-specific content.

## Layout

```
claude/      Lean, 1:1 with a real Claude Code install — agents/, skills/, commands/
templates/   Starting-point files you copy into your own project (not installed into .claude/)
```

`claude/` has no leading dot on purpose — it's source content in this repo, not a live Claude Code directory. It installs into your real (dotted) `~/.claude` or `<repo>/.claude`: copy or symlink whichever `agents/`, `skills/`, or `commands/` entries you want into the matching folder there.

## Agentic Workflow

The spec-driven **Architect → Builder → Reviewer** pipeline this stack is built around — most of the agents and several skills exist to support it. It's dense enough to warrant its own doc: see [AGENTIC-WORKFLOW.md](AGENTIC-WORKFLOW.md) for the full pipeline diagram, task-complexity paths, and setup steps.

## Utility Skills

Independent skills, each usable on its own without the workflow above.

| Skill | What it does | Requires | Setup notes |
|---|---|---|---|
| [`gh-ops`](claude/skills/gh-ops/SKILL.md) | PR/CI ops via `gh` CLI | `gh` CLI, `gh auth login` | Coexists with `glab-ops` — each checks the repo's actual remote before acting |
| [`glab-ops`](claude/skills/glab-ops/SKILL.md) | MR/CI ops via `glab` CLI | `glab` CLI, `glab auth login` | Self-managed GitLab instances: read `glab-ops/README.md` first (host/port/SSH pitfalls) |
| [`channel-request`](claude/skills/channel-request/SKILL.md) | Structured Slack messages, DM-reviewed before posting | Slack MCP | No channel presets pre-loaded — first use against a channel asks for its conventions and remembers them |
| [`daily-update`](claude/skills/daily-update/SKILL.md) | Posts a structured daily-update message | Slack MCP; `atlassian-doc-ops` if pulling tickets | — |
| [`atlassian-doc-ops`](claude/skills/atlassian-doc-ops/SKILL.md) | Jira/Confluence doc and ticket ops | Atlassian MCP | Resolves workspace/cloudId dynamically — no project keys hardcoded |
| [`generate-service-context`](claude/skills/generate-service-context/SKILL.md) | Generates a structural `service-context.yaml` per repo | — | User-level install recommended (cross-repo). Scaffolds its own catalog (`SCHEMA.md`/`CONVENTIONS.md`/`INDEX.md`) on first use. Skip if you only maintain one repo |
| [`skill-creator`](claude/skills/skill-creator/SKILL.md) | Meta-skill for authoring new skills | — | User-level install — used across projects |
| [`version-drift-tracker`](claude/skills/version-drift-tracker/SKILL.md) | Tag-vs-deployed drift report | `gh-ops` or `glab-ops`; a `service-map.md` you write yourself (see the skill's "Required Config"); `slack` skills optional for posting results | Skip if you don't run multiple services with separate deploy-time version pinning |

## Provenance

These were originally built for and used at a previous employer. Everything in this repo has been reviewed and rewritten to remove company names, internal repo paths, real infrastructure hostnames, project/channel IDs, and similar identifying details. `generate-service-context` and `version-drift-tracker` keep the *mechanism* but require you to supply your own config/conventions on first use.
