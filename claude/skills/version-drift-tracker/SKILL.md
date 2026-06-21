---
name: version-drift-tracker
description: >-
  Compare the latest Git tag of each tracked service against what's actually
  deployed (read from a deployment repo's per-environment config). Posts a
  status report (Slack, or just printed to chat) with match/mismatch indicators.
  Use when: "/version-drift-tracker", "check deployed versions",
  "check service versions", "version drift".
  Works against either GitHub or GitLab as the tag source — pick the adapter
  that matches your repo host. Requires a service-map config (see below).
---

# Version Drift Tracker

Compare the latest tag of each tracked service against what's deployed in your deployment repo, across one or more environment branches/paths. Report mismatches.

This is a generic version of a pattern that's easy to over-specialize: tag-source host (GitHub vs GitLab), deployment-repo layout, and notification target are all org-specific. Keep them in a config file outside this skill, not hardcoded in it.

## Required Config — `service-map.md` (you provide this)

Before using this skill, create a `service-map.md` next to it (or anywhere you point Claude to) with:

```markdown
# Service Map

## Deployment repo
- **Host/Path:** <org/deployment-repo>
- **Environments:** <branch-or-path-per-env, e.g. env/staging, env/prod>

## Services
| Short | Full Name | Repo (tag source) | Deployed config path per env | Tag field name |
|-------|-----------|--------------------|-------------------------------|-----------------|
| <short-name> | <full-service-name> | <org/repo> | <path/to/.env or values.yaml per env> | <VAR_NAME or yaml key> |
```

Without this file, the skill cannot run — ask the user to fill it in on first use, or offer to draft a skeleton from a list of services they name.

## Tag-Source Adapter — pick one per service map (or mix)

| Host | Adapter | Tag fetch |
|------|---------|-----------|
| GitHub | `gh-ops` conventions | `gh api repos/<org/repo>/tags --jq '.[0].name'` |
| GitLab | `glab-ops` conventions | `glab api "projects/<id-or-path>/repository/tags?per_page=1&order_by=updated&sort=desc"` → first element's `name` |

Detect the adapter from the `Repo (tag source)` column: if it's a `gh`-style `org/repo` pointing at a known GitHub remote, use `gh`; if the service map names a GitLab project ID or path on a self-managed instance, use `glab`. If ambiguous, ask the user once and note the answer in the service map.

## Workflow

### Step 1 — Fetch latest tags (parallel)

For each service (or a user-filtered subset), fetch the latest tag using the adapter that matches its tag-source host. Run all fetches in parallel (multiple tool calls in one message).

If a service has no tags, record `no tags found`.

### Step 2 — Fetch deployed versions (parallel)

For each service × each environment, read the deployed config path from the deployment repo (via `gh api` / `glab api` raw-file fetch, or a local clone + `git show <branch>:<path>` if you have one checked out).

Extract the tag value using the "Tag field name" column (env-var style `KEY=value` or a YAML key).

Run all reads in parallel. If a file or branch/path isn't found, record `not found`.

### Step 3 — Compare

For each service + environment:
- Deployed tag **equals** latest tag → match
- Deployed tag **differs** → mismatch
- Tag not found or missing → unknown

### Step 4 — Report

Default: print a table directly in the chat response (service × environment, ✓/✗/⚠, deployed tag, latest tag).

Optional: if the user wants it posted to Slack (or another channel), ask for the destination (channel name or DM) the first time and remember it; use whatever messaging MCP is connected. Don't hardcode a channel ID — resolve it via search each environment, or save the resolved ID as a memory after the user confirms it once.

## Error Handling

| Error | Cause | Action |
|-------|-------|--------|
| API returns 404 | Wrong repo/project reference in service map | Report that service as `not found` — don't fail the whole run |
| Auth failure | Token expired | Tell user to re-authenticate (`gh auth login` / `glab auth login`) |
| Notification send fails | Messaging MCP disconnected | Fall back to printing the report in chat |
| No tags in repo | Service has no tags | Show `no tags` |
| Env path not found | Branch/path doesn't exist in deployment repo | Show `not found` |

## When NOT to Use

- Checking cloud-only deployments that don't have a separate config-per-env file (use whatever your cloud platform's own diffing tool provides instead)
- Updating tags or creating PRs/MRs to fix drift (out of scope — this skill only reports)
- Checking non-service infrastructure (databases, message brokers, etc.)
