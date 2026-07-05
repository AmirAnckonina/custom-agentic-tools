---
name: gh-ops
description: "GitHub operations via the gh CLI — the official GitHub command-line tool. PR lifecycle (create, merge, approve, close, request-changes), PR reading (view, diff, checkout), code review (review comments, line comments, approve), GitHub Actions monitoring (run status, job logs, re-run failed), releases & tags, gh api fallback for uncovered endpoints, and git fallback when gh is unavailable. Only applies when the repo's remote is github.com — does not apply to GitLab or other Git hosts. Use when: '/gh-ops', 'create a PR', 'review PR #N', 'merge PR', 'check the actions run', 'approve PR', 'gh' mentioned, or working with github.com remotes."
---

## GitHub Operations via gh CLI

PR lifecycle management, code review interactions, and GitHub Actions monitoring — all through `gh`.

---

## Preamble

### Remote Applicability Check (Step 0)

**Before running any command in this skill, confirm the repo is hosted on GitHub:**

```
git remote -v | head -1
```

- Contains `github.com` → this skill applies, proceed.
- Does **not** contain `github.com` (e.g. GitLab, Bitbucket, self-hosted) → **stop. This skill does not apply.** Tell the user the repo is not on GitHub and ask how they want to proceed.
- No git remote configured → ask the user whether the repo is on GitHub before continuing.

Do not invoke `gh` against non-GitHub remotes — it will either fail or hit the wrong host.

### Availability Check

Before using `gh` commands, verify it is available:
```
command -v gh
```
If not installed, follow the **Git Fallback** section for all operations.

Check auth state once per session:
```
gh auth status
```
If not authenticated, instruct the user to run `gh auth login` themselves — do not attempt interactive auth from the agent.

### Branch Resolution

The user may reference work by short task ID, full branch name, or PR number. See `CLAUDE.md` for branch naming and resolution conventions.

**Target branch resolution:**
- **Reading a PR:** Extract base and head from `gh pr view` output.
- **Creating a PR:** Default target is the repo's default branch — read it via `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name` — unless the repo's `CLAUDE.md` declares a different trunk (e.g., `develop`) or the user specifies one.

### Freshness Rule

**Always work with the latest remote state.** Before reading any diff or file content:
```
git fetch origin <head-branch> <base-branch>
```
Extract head and base from `gh pr view` output first, then fetch both. This prevents stale data when falling back to git commands or using the `Read` tool.

This applies even when gh is available — `gh pr diff` reads from the API (always fresh), but `git diff` fallback or `Read` tool access uses local state which may be stale.

### Write-Action Approval

**Every write action requires explicit user approval before execution.** Writes include:
- `gh pr create`, `gh pr merge`, `gh pr close`, `gh pr reopen`, `gh pr edit`, `gh pr ready`
- `gh pr review` (any flag), `gh pr comment`
- `gh run rerun`, `gh run cancel`
- `gh release create`, `gh release edit`, `gh release delete`
- Any `gh api` call with `-X POST | PUT | PATCH | DELETE` or `--method` not `GET`

Present the exact command and its inputs, wait for explicit "yes" / "approved", then execute. One write per approval — never batch.

---

## PR Reading

| Operation | Command |
|---|---|
| View PR metadata | `gh pr view <PR>` |
| View PR as JSON | `gh pr view <PR> --json number,title,state,baseRefName,headRefName,author,labels,mergeable` |
| View PR diff | `gh pr diff <PR>` |
| List changed files | `gh pr diff <PR> --name-only` |
| Checkout PR locally | `gh pr checkout <PR>` |
| Find PR by branch | `gh pr list --head <branch>` |
| List open PRs | `gh pr list` |
| List PRs assigned to me | `gh pr list --assignee @me` |
| Find linked issues | `gh pr view <PR> --json closingIssuesReferences` |

**Identify head and base branches:**
- From PR number: extract from `gh pr view <PR> --json baseRefName,headRefName`.
- **Always diff head against the correct base branch.**

**If any gh command fails, fetch before falling back to git:**
```
git fetch origin <head-branch> <base-branch>
```
Then use Git Fallback commands with `origin/` prefixed refs.

---

## PR Lifecycle

| Operation | Command |
|---|---|
| Create PR | `gh pr create --fill --base develop` |
| Create draft PR | `gh pr create --fill --draft --base develop` |
| Create with reviewer | `gh pr create --fill --reviewer <user> --base develop` |
| Mark draft as ready | `gh pr ready <PR>` |
| Update title/body | `gh pr edit <PR> --title "..." --body "..."` |
| Add labels | `gh pr edit <PR> --add-label "label1,label2"` |
| Remove labels | `gh pr edit <PR> --remove-label "label1"` |
| Add reviewer | `gh pr edit <PR> --add-reviewer <user>` |
| Merge PR (default) | `gh pr merge <PR> --merge` |
| Merge (squash) | `gh pr merge <PR> --squash` |
| Merge (rebase) | `gh pr merge <PR> --rebase` |
| Merge + delete branch | `gh pr merge <PR> --squash --delete-branch` |
| Close PR | `gh pr close <PR>` |
| Reopen PR | `gh pr reopen <PR>` |

**Safety rules:**
- All commands in this section are **writes** — require explicit user approval per the write-action rule above.
- Always use `--fill` on create to populate title/body from commits.
- For `gh pr merge`, default merge strategy is repo-dependent — pass `--squash` / `--merge` / `--rebase` explicitly to avoid surprises.

---

## PR Reviews & Comments

**Requires explicit user approval for every review or comment.** Never post without confirmation.

### Three comment surfaces

| Surface | Command | When |
|---|---|---|
| Top-level PR comment | `gh pr comment <PR> --body "..."` | General comment, not tied to code |
| Review (approve / request changes / comment) | `gh pr review <PR> --approve \| --request-changes \| --comment --body "..."` | Formal review action |
| Inline code comment (line-specific) | `gh api .../pulls/<PR>/comments` | Line-anchored feedback |

### Reading review state

```
# All reviews on a PR
gh pr view <PR> --json reviews

# All review comments (line-level)
gh api repos/{owner}/{repo}/pulls/<PR>/comments

# Top-level issue comments
gh api repos/{owner}/{repo}/issues/<PR>/comments
```

To get `{owner}/{repo}` from current repo:
```
gh repo view --json nameWithOwner --jq .nameWithOwner
```

### Approve / request changes / comment review

```
# Approve
gh pr review <PR> --approve

# Approve with note
gh pr review <PR> --approve --body "LGTM"

# Request changes
gh pr review <PR> --request-changes --body "<reason>"

# Plain review comment (no approval verdict)
gh pr review <PR> --comment --body "<comment>"
```

### Inline (line-anchored) review comments

Use the API — `gh pr review` does not support line targeting from the CLI.

```
# Single inline comment on a specific line
gh api repos/{owner}/{repo}/pulls/<PR>/comments \
  -f body="<comment>" \
  -f path="<file>" \
  -F line=<line-number> \
  -f side=RIGHT \
  -f commit_id="<head-sha>"
```

Get head SHA: `gh pr view <PR> --json headRefOid --jq .headRefOid`

For a **batched review** with multiple inline comments + a verdict in one POST:
```
gh api repos/{owner}/{repo}/pulls/<PR>/reviews \
  -f event=COMMENT \
  -f body="<summary>" \
  -F "comments[][path]=src/foo.ts" -F "comments[][line]=42" -F "comments[][body]=..." \
  -F "comments[][path]=src/bar.ts" -F "comments[][line]=88" -F "comments[][body]=..."
```
`event` values: `APPROVE`, `REQUEST_CHANGES`, `COMMENT`.

### Resolve / unresolve review threads

GitHub REST does not expose thread resolution — use GraphQL:

```
# Resolve a thread (need thread node ID from gh api .../pulls/<PR>/comments output)
gh api graphql -f query='
  mutation($id: ID!) {
    resolveReviewThread(input: {threadId: $id}) { thread { isResolved } }
  }' -f id="<thread-node-id>"

# Unresolve
gh api graphql -f query='
  mutation($id: ID!) {
    unresolveReviewThread(input: {threadId: $id}) { thread { isResolved } }
  }' -f id="<thread-node-id>"
```

### Posting workflow

- **Default to inline review comments** when feedback is tied to specific lines.
- **Use top-level comment** only for general, non-code commentary.
- **Post one comment / review at a time.** Present the formatted comment, wait for approval, then post.

### Without gh

Generate copy-paste-ready comments for the user to post manually.

---

## GitHub Actions Monitoring

| Operation | Command |
|---|---|
| List recent runs | `gh run list` |
| List runs for a workflow | `gh run list --workflow=<file-or-name>` |
| List runs for a branch | `gh run list --branch=<branch>` |
| Filter failed runs | `gh run list --status=failure` |
| View run details | `gh run view <run-id>` |
| View run logs (all) | `gh run view <run-id> --log` |
| View only failed job logs | `gh run view <run-id> --log-failed` |
| View specific job | `gh run view --job=<job-id>` |
| Watch in-progress run | `gh run watch <run-id>` |
| List workflows | `gh workflow list` |
| View workflow definition | `gh workflow view <name-or-file>` |
| Re-run entire run *(write)* | `gh run rerun <run-id>` |
| Re-run only failed jobs *(write)* | `gh run rerun <run-id> --failed` |
| Cancel run *(write)* | `gh run cancel <run-id>` |

Find the run for the current PR head:
```
gh pr checks <PR>
# or
gh run list --branch="$(gh pr view <PR> --json headRefName --jq .headRefName)"
```

**Common pattern — check Actions before merge:**
```
gh pr checks <PR>
# Verify all checks passed, then:
gh pr merge <PR> --squash
```

---

## Releases & Tags

| Operation | Command |
|---|---|
| List releases | `gh release list` |
| View release | `gh release view <tag>` |
| Download release asset | `gh release download <tag> --pattern "<glob>"` |
| List tags | `gh api repos/{owner}/{repo}/tags --paginate` |
| Latest release | `gh release view --json tagName,publishedAt` |
| Create release *(write)* | `gh release create <tag> --title "..." --notes "..."` |
| Create release from notes file *(write)* | `gh release create <tag> --notes-file CHANGELOG.md` |
| Upload asset to release *(write)* | `gh release upload <tag> <file>` |
| Edit release *(write)* | `gh release edit <tag> --notes "..."` |
| Delete release *(write)* | `gh release delete <tag>` |

---

## Comment Format

Use this for all PR review and inline comments:

```
**[🔴|🟡|🔵] [Category]** — `filename:line`
[Clear, constructive explanation of the issue and suggested fix]
```

Severity legend: 🔴 Critical · 🟡 Important · 🔵 Suggestion.

**Example:**
```
**[🔴 Critical] Error Handling** — `src/services/PaymentService.java:87`
The `processPayment()` call has no try-catch around the external API call. If the gateway times out, the exception propagates unhandled and leaves the order in a partial state. Wrap in try-catch and rollback the transaction on failure.
```

---

## `gh api` Reference

For operations not covered by gh subcommands, use `gh api` to hit any GitHub REST endpoint directly. GraphQL is also available via `gh api graphql`.

### Syntax

```
gh api <endpoint> [--method METHOD] [-f "key=value"] [-F "key=value"]
```

| Flag | Purpose | Example |
|------|---------|---------|
| _(none)_ | GET request (default) | `gh api repos/{owner}/{repo}/tags` |
| `--method PUT` / `-X PUT` | Update an existing resource | `--method PATCH -f state=closed` |
| `-f "key=value"` | String field (POST if no `--method`) | `-f body="Review comment"` |
| `-F "key=value"` | Typed field (int, bool, JSON) | `-F line=42 -F draft=false` |
| `--paginate` | Auto-paginate list endpoints | `gh api ... --paginate` |
| `--jq <expr>` | Filter output with jq | `--jq '.[].name'` |
| `-H "Accept: ..."` | Set request header | `-H "Accept: application/vnd.github.v3.diff"` |

**`-f` vs `-F`:** Use `-f` for strings. Use `-F` when the API expects a number, boolean, or nested JSON structure. Mixing them up causes 422 validation errors.

### Owner/repo resolution

`gh api` does **not** auto-resolve repo placeholders. Always substitute explicitly:

```
OWNER_REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
gh api "repos/$OWNER_REPO/pulls/123"
```

Or pass the full path inline: `gh api "repos/owner/foo/pulls/123"`.

### URL encoding

For file paths, branch names with slashes, or any segment containing `/`, `#`, or spaces, URL-encode:

```
# Branch: feature/DEV-12345-foo  →  feature%2FDEV-12345-foo
gh api "repos/$OWNER_REPO/contents/path/to/file.yml?ref=feature%2FDEV-12345-foo"
```

### Repository operations

**Get latest tag:**
```
gh api "repos/$OWNER_REPO/tags?per_page=1"
```
Returns JSON array; first element's `name` is the latest tag.

**Read raw file content** from a specific branch:
```
gh api "repos/$OWNER_REPO/contents/path/to/file?ref=<branch>" \
  -H "Accept: application/vnd.github.v3.raw"
```
With the `raw` accept header, returns raw text (not base64-encoded JSON).

**Search repos:**
```
gh api "search/repositories?q=<term>+org:<org>&per_page=5"
```

### PR review API summary

See **PR Reviews & Comments** above for full patterns. Summary:

| Operation | Endpoint | Method |
|-----------|----------|--------|
| List reviews | `repos/{owner}/{repo}/pulls/{n}/reviews` | GET |
| Submit review | `repos/{owner}/{repo}/pulls/{n}/reviews` | POST |
| List review comments | `repos/{owner}/{repo}/pulls/{n}/comments` | GET |
| Post inline comment | `repos/{owner}/{repo}/pulls/{n}/comments` | POST |
| List PR commits | `repos/{owner}/{repo}/pulls/{n}/commits` | GET |
| Top-level comments | `repos/{owner}/{repo}/issues/{n}/comments` | GET / POST |
| Resolve thread | `graphql` mutation `resolveReviewThread` | POST |

### Query parameters

| Parameter | Purpose | Example |
|-----------|---------|---------|
| `per_page=N` | Limit results (max 100) | `?per_page=1` |
| `page=N` | Pagination offset | `?page=2` |
| `state=open\|closed\|all` | Filter by state | `?state=closed` |
| `sort=created\|updated\|popularity` | Sort field | `?sort=updated` |
| `direction=asc\|desc` | Sort direction | `?direction=desc` |
| `ref=<branch-or-sha>` | Git ref for contents | `?ref=main` |

---

## Git Fallback (gh unavailable)

| Operation | Command |
|---|---|
| Fetch branch | `git fetch origin <branch>` |
| View diff | `git diff origin/<base>..origin/<head>` |
| List changed files | `git diff --name-only origin/<base>..origin/<head>` |
| Read changed files | Use `Read` tool directly |
| Show commits on branch | `git log origin/<base>..origin/<head>` |

When in fallback mode, PR comments, reviews, and lifecycle commands are unavailable — generate copy-paste-ready text instead, and provide the GitHub UI URL: `https://github.com/<owner>/<repo>/pull/<n>`.

---

## When NOT to Use This Skill

- The repo's remote is not `github.com` (e.g. GitLab, Bitbucket, self-hosted Git) → this skill does not apply. Inform the user the repo is not on GitHub.
- The user asks about Jira / Confluence operations → out of scope for this skill.
- The user is asking for Git operations only (no platform interaction) → use plain `git` directly, no skill needed.
- No git remote configured and the user has not specified a platform → ask first, do not guess.
