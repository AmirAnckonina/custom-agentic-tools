# custom-agentic-tools

Personal stack of Claude Code agents, skills, and commands — generalized from a previous employer's setup and stripped of any company-specific content.

## Layout

```
claude/         Payload — 1:1 with a real Claude Code install: agents/, skills/, commands/, hooks/
capabilities/   One dir per capability: a `bundle` manifest + a README.md guide, side by side
templates/      Starting-point files you copy into your own project (not installed into .claude/)
install.sh      Installs capabilities (by symlink) into your live ~/.claude
```

`claude/` has no leading dot on purpose — it's source content in this repo, not a live Claude Code directory. The payload is **flat and shared**; a capability's `bundle` file is just a named view over it (so skills like `review-lenses` can belong to several capabilities without being duplicated). Prose lives at the repo root and in `capabilities/`; `claude/` holds only files Claude Code loads.

## Install

Capabilities install independently — take only what you want.

```bash
git clone https://github.com/AmirAnckonina/custom-agentic-tools
cd custom-agentic-tools
./install.sh list                 # see all capabilities
./install.sh agentic-workflow     # install one bundle
./install.sh github-ops atlassian # …or several
./install.sh gh-ops                # …or a single skill by name
./install.sh uninstall             # remove every link this repo created
```

`install.sh` **symlinks** each capability's items into `~/.claude/`, so the repo is the single source of truth: editing a skill from any Claude session edits the file here, and `git commit && git push` is your version control and backup. Idempotent (safe to re-run), backs up any existing real files, and supports project-level installs via `CLAUDE_DIR=path/to/project/.claude ./install.sh <capability>`.

> Hooks live in `claude/hooks/` as scripts but are wired up via `~/.claude/settings.json` (machine-specific), so they're referenced by path rather than symlinked.

## Capabilities

Each row is one `./install.sh <capability>`. Depth lives in each skill's own `SKILL.md`.

| Capability | What it does | Requires | Details |
|---|---|---|---|
| `agentic-workflow` | Spec-driven **Architect → Builder → Reviewer** pipeline — most agents and several skills exist to support it | a git-host capability | [capabilities/agentic-workflow](capabilities/agentic-workflow/README.md) |
| `github-ops` | PR & CI ops via the `gh` CLI — repo-aware, coexists with `gitlab-ops` | `gh` CLI + `gh auth login` | [capabilities/github-ops](capabilities/github-ops/README.md) |
| `gitlab-ops` | MR & CI ops via the `glab` CLI | `glab` CLI + `glab auth login` | [capabilities/gitlab-ops](capabilities/gitlab-ops/README.md) |
| `atlassian` | Jira & Confluence doc and ticket ops — resolves workspace/cloudId dynamically | Atlassian MCP | [capabilities/atlassian](capabilities/atlassian/README.md) |
| `slack-comms` | Structured Slack messages — channel requests (DM-reviewed) & daily updates | Slack MCP (+`atlassian` optional) | [capabilities/slack-comms](capabilities/slack-comms/README.md) |
| `service-ops` | Per-repo `service-context.yaml` catalog + tag-vs-deployed drift report | a git-host capability; drift needs a `service-map` you write | [capabilities/service-ops](capabilities/service-ops/README.md) |
| `skill-authoring` | Meta-skill for authoring new skills | — | [capabilities/skill-authoring](capabilities/skill-authoring/README.md) |

## Provenance

These were originally built for and used at a previous employer. Everything in this repo has been reviewed and rewritten to remove company names, internal repo paths, real infrastructure hostnames, project/channel IDs, and similar identifying details. `generate-service-context` and `version-drift-tracker` keep the *mechanism* but require you to supply your own config/conventions on first use.

## License

[MIT](LICENSE)
