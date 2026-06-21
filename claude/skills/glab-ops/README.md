# glab-ops — GitLab CLI Integration for Claude Code

Enable Claude Code to manage MRs, review code, and monitor CI/CD pipelines directly through the `glab` CLI.

---

## Prerequisites

### macOS (Homebrew)

```bash
brew install glab
```

### Linux

Installation may vary by distribution. See the [official glab installation guide](https://gitlab.com/gitlab-org/cli/-/blob/main/docs/installation_options.md) for all options.

### Verify installation

```bash
glab version
```

---

## Authentication Setup

If your GitLab instance is self-managed (rather than gitlab.com) and runs on a non-standard host/port, note the hostname, port, and SSH port before starting — most setup issues come from incorrect host configuration.

### Step 1: Generate a Personal Access Token (PAT)

1. Open `https://<your-gitlab-host>/-/user_settings/personal_access_tokens`
2. Create a token with scopes: **`api`** and **`write_repository`**
3. Copy the token — you won't see it again

### Step 2: Authenticate glab

```bash
glab auth login
```

When prompted:
- **GitLab instance hostname:** `<your-gitlab-host>` (include the port if non-standard, e.g. `gitlab.example.com:8081`)
- **API protocol:** `HTTPS`
- **Authentication method:** `Token`
- **Paste your token**
- **Git protocol for operations:** `SSH` (or `HTTPS`, per your preference)

### Step 3: Verify

```bash
glab auth status
```

Expected output:
```
<your-gitlab-host>
  ✓ Logged in to <your-gitlab-host> as <YourUsername>
  ✓ Git operations configured to use ssh protocol.
  ✓ API calls made over https protocol.
  ✓ REST API Endpoint: https://<your-gitlab-host>/api/v4/
  ✓ GraphQL Endpoint: https://<your-gitlab-host>/api/graphql/
  ✓ Token found: **************************
```

---

## Common Setup Pitfalls

| Problem | Cause | Fix |
|---------|-------|-----|
| `connection refused` / `timeout` on glab commands | Using a VPN tunnel hostname instead of the direct hostname | Use the direct hostname your org's GitLab is reachable at — don't use a tunnel alias |
| `ping` to the host fails but glab works | ICMP often blocked on self-managed instances; this is normal | Ignore ping failures if HTTPS on the configured port works fine |
| Host not found / wrong API endpoint | Missing a non-standard port in the hostname | Always include the port if your instance uses one |
| Git clone/push fails | Wrong SSH port | Self-managed instances sometimes run SSH on a non-default port — check with your GitLab admin |
| `401 Unauthorized` | Token expired or missing scopes | Regenerate PAT with `api` + `write_repository` scopes |

---

## Skill Installation

### Step 1: Copy the skill folder

Copy the `glab-ops` skill folder into your Claude Code skills directory.

**User-level (recommended)** — applies to all your projects:
```bash
cp -r glab-ops ~/.claude/skills/glab-ops
```

**Project-level** — applies only to a specific repo:
```bash
cp -r glab-ops <your-repo>/.claude/skills/glab-ops
```

> `~/.claude/skills/` is where Claude Code looks for user-level skills. Each skill is a folder containing a `SKILL.md` file with instructions Claude follows automatically.

### Step 2: Verify the skill is loaded

Restart Claude Code (exit and re-open), then ask:

```
Do you have the glab-ops skill loaded?
```

You can also check with the `/skills` command — `glab-ops` should appear in the list.

> If the skill doesn't appear, verify the folder structure is `~/.claude/skills/glab-ops/SKILL.md` and restart Claude Code.

### How the skill triggers

The skill is **not** a slash command — you don't need to invoke it manually. Claude loads it automatically when it detects GitLab-related context in your request (e.g., "create an MR", "check pipeline", "review this MR", "diff against develop") **and** the repo's remote is GitLab. If the remote is `github.com`, Claude should use `gh-ops` instead.

### Default target branch

When creating MRs, the skill defaults to `main`/`develop` (whichever exists) as the target branch. You can override this per-request by telling Claude the target (e.g., *"create an MR targeting master"*).

To change the default permanently, add this to your project's `CLAUDE.md`:
```markdown
- Default MR target branch: `master`
```

---

## What Claude Can Do With This Skill

Once `glab` is configured, Claude Code can:

| Capability | Examples |
|------------|----------|
| **Read MRs** | View MR metadata, diffs, changed files |
| **MR lifecycle** | Create, update, approve, merge, close MRs |
| **Code review comments** | Post formatted review comments on MRs |
| **CI/CD monitoring** | Check pipeline status, view job logs, lint CI config |
| **Branch resolution** | Resolve ticket IDs to branches and MRs (if your org's naming convention supports it) |
| **Git fallback** | Full diff/read capability even if glab is unavailable |

All destructive or visible operations (create MR, merge, post comments) **require your explicit approval** before execution.

---

## Configuration Reference

Fill this in for your own instance once you set it up:

| Item | Value |
|------|-------|
| GitLab hostname | `<your-gitlab-host>` |
| API protocol | HTTPS |
| Git protocol | SSH or HTTPS |
| REST API | `https://<your-gitlab-host>/api/v4/` |
| GraphQL API | `https://<your-gitlab-host>/api/graphql/` |
| Config file | `~/Library/Application Support/glab-cli/config.yml` (macOS) |

---

## Comment Format

The skill includes a default comment format for MR reviews using severity levels (🔴 Critical, 🟡 Warning, 🔵 Info). This is a suggested convention that can be adjusted per team.

---

## Known Limitations

- **No GitLab-wide repo search** — GitLab indexing is not enabled by default; `glab` can only search within a known/cloned repo
- **GitLab version dependency** — Requires GitLab 16.0+; some `glab` features may not be available on older versions
- **`:id` auto-resolution** — The `glab api` shorthand `:id` only resolves when run from inside a cloned repo directory

---

## Useful Links

- [glab CLI documentation](https://docs.gitlab.com/cli/)
- [glab installation options](https://gitlab.com/gitlab-org/cli#installation)
