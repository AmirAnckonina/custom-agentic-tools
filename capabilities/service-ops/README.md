# Service Ops

Two related, independent skills for managing a multi-service codebase: generating a structural catalog entry per repo, and checking whether what's deployed actually matches the latest tag.

## What it includes

- **Skills:** [`generate-service-context`](../../claude/skills/generate-service-context/SKILL.md) (creates `service-context.yaml` per repo), [`version-drift-tracker`](../../claude/skills/version-drift-tracker/SKILL.md) (tag-vs-deployed drift report)

## How it works

**[`generate-service-context`](../../claude/skills/generate-service-context/SKILL.md)** — audits a service repo (language/build files, CI config, tests, deployment manifests, runtime edges like HTTP/queue/DB) by reading its files, asks you only what it can't discover (role description, secrets source, ambiguous edges), then drafts a `service-context.yaml` against a locked schema and writes it to the repo root. Deliberately excludes volatile details (version numbers, topic/queue names, per-env ports) so the file doesn't go stale. Maintains a personal/team catalog (`SCHEMA.md` / `CONVENTIONS.md` / `INDEX.md`) — scaffolds one on first use if it doesn't exist yet.

**[`version-drift-tracker`](../../claude/skills/version-drift-tracker/SKILL.md)** — given a `service-map.md` you write yourself (service name → tag-source repo → deployed config path per environment), fetches the latest tag for each service and compares it against what's actually in the deployment repo per environment, reporting matches/mismatches in a table.

## Install

```bash
./install.sh service-ops
```

## Requires

A git-host capability ([`github-ops`](../github-ops/README.md) or [`gitlab-ops`](../gitlab-ops/README.md)) as the tag-source adapter. `version-drift-tracker` also needs a `service-map.md` you author — it can't run without one. Skip this capability entirely if you only maintain a single service.
