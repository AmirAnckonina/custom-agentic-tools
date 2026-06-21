---
name: glab-ops
description: "GitLab operations via the glab CLI — the official GitLab command-line tool. MR lifecycle (create, merge, approve, close, rebase), MR reading (view, diff, checkout), code review (discussions, comments, resolve/unresolve), CI/CD monitoring (pipeline status, job logs, lint), and git fallback when glab is unavailable. Only applies when the repo's remote is a GitLab host — does not apply to GitHub or other Git hosts (use gh-ops for those)."
user-invocable: false
---

## GitLab Operations via glab CLI

MR lifecycle management, code review interactions, and CI/CD monitoring — all through `glab`.

**Only use this skill when the repo's remote is GitLab.** If the remote is `github.com`, use the `gh-ops` skill instead — do not mix `glab` and `gh` terminology/commands within the same repo.

---

## Preamble

### Scope Check
Before using `glab` commands, confirm the repo's remote is actually GitLab (`git remote -v` shows a gitlab host). If it's `github.com`, stop and defer to `gh-ops`.
Use `glab`, `gitlab` URLs, and "merge request" (MR) terminology — consistently, for this repo only.

### Availability Check
Before using `glab` commands, verify it is available:
```
command -v glab
```
If not installed, follow the **Git Fallback** section for all operations.

### Branch Resolution
The user may reference work by short task ID, full branch name, or MR number. See `CLAUDE.md` for branch naming and resolution conventions.

**Target branch resolution:**
- **Reading an MR:** Extract source and target from `glab mr view` output.
- **Creating an MR:** Default target is `develop`. If the user specifies a different target, use that instead.

### Freshness Rule
**Always work with the latest remote state.** Before reading any diff or file content:
```
git fetch origin <source-branch> <target-branch>
```
Extract source and target from `glab mr view` output first, then fetch both. This prevents stale data when falling back to git commands or using the `Read` tool.

This applies even when glab is available — `glab mr diff` reads from the API (always fresh), but `git diff` fallback or `Read` tool access uses local state which may be stale.

---

## MR Reading

| Operation | Command |
|---|---|
| View MR metadata | `glab mr view <MR>` |
| View MR diff | `glab mr diff <MR>` |
| List changed files | `glab mr diff <MR> --name-only` |
| Checkout MR locally | `glab mr checkout <MR>` |
| Find MR by branch | `glab mr list --source-branch=<branch>` |
| List open MRs | `glab mr list` |
| Related issues | `glab mr issues <MR>` |

**Identify source and target branches:**
- From MR number: extract from `glab mr view <MR>` output.
- **Always diff source against the correct target branch.**

**If any glab command fails, fetch before falling back to git:**
```
git fetch origin <source-branch> <target-branch>
```
Then use Git Fallback commands with `origin/` prefixed refs.

---

## MR Lifecycle

| Operation | Command |
|---|---|
| Create MR | `glab mr create --fill --target-branch develop` |
| Create draft MR | `glab mr create --fill --draft --target-branch develop` |
| Create with reviewer | `glab mr create --fill --reviewer @username --target-branch develop` |
| Update title/description | `glab mr update <MR> --title "..." --description "..."` |
| Add labels | `glab mr update <MR> --label "label1,label2"` |
| Approve MR | `glab mr approve <MR>` |
| Revoke approval | `glab mr revoke <MR>` |
| Merge MR | `glab mr merge <MR>` |
| Merge (squash) | `glab mr merge <MR> --squash` |
| Rebase MR | `glab mr rebase <MR>` |
| Close MR | `glab mr close <MR>` |
| Reopen MR | `glab mr reopen <MR>` |

**Safety rules:**
- `mr create`, `mr merge`, `mr close` — **require explicit user approval**.
- `mr approve` / `mr revoke` — **require explicit user approval**.
- Always use `--fill` on create to populate title/description from commits.

---

## MR Discussions & Comments

**Requires explicit user approval for every comment.** Never post without confirmation.

### Reading discussions

```
# List all discussions on an MR
glab api projects/:id/merge_requests/<MR-IID>/discussions

# Read replies in a specific discussion
glab api projects/:id/merge_requests/<MR-IID>/discussions/<discussion-id>/notes
```

### Posting comments

**Default to discussions** (creates a resolvable thread). Only use notes when explicitly requested.

```
# Post a new discussion (resolvable thread) — preferred
glab api projects/:id/merge_requests/<MR-IID>/discussions -f "body=<comment>"

# Post a simple note (non-resolvable) — only when requested
glab mr note <MR> -m "<comment>"
```

- `:id` auto-resolves to the current repo **only when run from inside a cloned repo directory**. Verify you are in the correct repo directory.
- **Post one comment at a time.** Present formatted comment, wait for approval, then post.

### Resolve / unresolve discussions
```
glab api projects/:id/merge_requests/<MR-IID>/discussions/<discussion-id> -X PUT -f "resolved=true"
glab api projects/:id/merge_requests/<MR-IID>/discussions/<discussion-id> -X PUT -f "resolved=false"
```

### Without glab
Generate copy-paste-ready comments for the user to post manually.

---

## CI/CD Monitoring (Read-Only)

| Operation | Command |
|---|---|
| Pipeline status | `glab ci status` |
| List pipelines | `glab ci list` |
| View pipeline details | `glab ci get <pipeline-id>` |
| View job log | `glab ci trace <job-id>` |
| Lint CI config | `glab ci lint` |

**Common pattern — check pipeline before merge:**
```
glab ci status
# Verify all jobs passed, then:
glab mr merge <MR>
```

---

## Comment Format

```
**[🔴|🟡|🔵] [Category]** — `filename:line`
[Clear, constructive explanation of the issue and suggested fix]
```

**Example:**
```
**[🔴 Critical] Error Handling** — `src/services/PaymentService.java:87`
The `processPayment()` call has no try-catch around the external API call. If the gateway times out, the exception propagates unhandled and leaves the order in a partial state. Wrap in try-catch and rollback the transaction on failure.
```

---

## `glab api` Reference

For operations not covered by glab subcommands, use `glab api` to hit any GitLab REST endpoint directly.

### Syntax

```
glab api <endpoint> [-X METHOD] [-f "field=value" ...]
```

| Flag | Purpose | Example |
|------|---------|---------|
| _(none)_ | GET request (default) | `glab api projects/:id/repository/tags` |
| `-X PUT` | Update an existing resource | `-X PUT -f "resolved=true"` |
| `-f "key=value"` | Send field data (POST if no `-X`) | `-f "body=Review comment"` |
| Multiple `-f` | Send multiple fields | `-f "body=text" -f "resolved=true"` |

### `:id` Auto-Resolution

`:id` resolves to the current project **only when run from inside a cloned repo directory**. For cross-project operations, use the numeric project ID directly:

```
# Current project — :id works
glab api projects/:id/repository/tags

# Different project — use explicit ID
glab api projects/35/repository/files/path%2Fto%2Ffile/raw?ref=main
```

### URL Encoding

The `repository/files` endpoint requires URL-encoded paths — replace `/` with `%2F`:

```
# File: roles/deploy_agent_manager/files/.env
# Encoded: roles%2Fdeploy_agent_manager%2Ffiles%2F.env

glab api "projects/35/repository/files/roles%2Fdeploy_agent_manager%2Ffiles%2F.env/raw?ref=env/test0"
```

This only applies to the file path segment. Query parameters (`?ref=`) and other endpoints do not need encoding.

### Repository Operations

**Fetch tags** — get latest tag for a project:
```
glab api "projects/{PROJECT_ID}/repository/tags?per_page=1&order_by=updated&sort=desc"
```
Returns JSON array; extract first element's `name` field.

**Read raw file content** — fetch a file from a specific branch:
```
glab api "projects/{PROJECT_ID}/repository/files/{URL_ENCODED_PATH}/raw?ref={BRANCH}"
```
Returns raw text content (not JSON).

**Search projects** — find project IDs by name:
```
glab api "projects?search={NAME}&per_page=5"
```
Returns JSON array of project objects with `id` and `path_with_namespace`.

### MR Discussion Operations

See the **MR Discussions & Comments** section above for full patterns. Summary:

| Operation | Endpoint | Method |
|-----------|----------|--------|
| List discussions | `projects/:id/merge_requests/:iid/discussions` | GET |
| Read replies | `projects/:id/merge_requests/:iid/discussions/:did/notes` | GET |
| Post discussion | `projects/:id/merge_requests/:iid/discussions` | POST (`-f`) |
| Reply to thread | `projects/:id/merge_requests/:iid/discussions/:did/notes` | POST (`-f`) |
| Resolve/unresolve | `projects/:id/merge_requests/:iid/discussions/:did` | PUT |

### Query Parameters

Append query params directly to the endpoint:

| Parameter | Purpose | Example |
|-----------|---------|---------|
| `per_page=N` | Limit results (max 100) | `?per_page=1` |
| `page=N` | Pagination offset | `?page=2` |
| `order_by=X` | Sort field | `?order_by=updated` |
| `sort=asc\|desc` | Sort direction | `?sort=desc` |
| `ref=BRANCH` | Git ref for file operations | `?ref=env/test0` |
| `search=TERM` | Search filter | `?search=discovery` |

---

## Git Fallback (glab unavailable)

| Operation | Command |
|---|---|
| Fetch branch | `git fetch origin <branch>` |
| View diff | `git diff origin/<target>..origin/<source>` |
| List changed files | `git diff --name-only origin/<target>..origin/<source>` |
| Read changed files | Use `Read` tool directly |

When in fallback mode, MR comments and lifecycle commands are unavailable — generate copy-paste-ready text instead.
