# custom-agentic-tools

Personal stack of Claude Code agents, skills, and commands, organized as independently-installable capabilities.

## Layout

```
capabilities/   ← START HERE. One folder per capability: a guide (README.md) + its bundle manifest
claude/            The actual files capabilities install — agents/, skills/, commands/, hooks/
                   (you rarely open these directly; the guides link into them when you want source)
templates/         Starting-point files you copy into your own project (not installed into .claude/)
install.sh         Installs a capability (by symlink) into your live ~/.claude
```

**Two trees, on purpose.** `capabilities/` is what you browse and install from. `claude/` is the flat, shared payload those capabilities are built out of — kept flat so a skill like `review-lenses` can belong to several capabilities without being duplicated. A capability's `bundle` file just lists which payload files to symlink in. `claude/` has no leading dot because it's source content here, not a live Claude Code directory.

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

## License

[MIT](LICENSE)
