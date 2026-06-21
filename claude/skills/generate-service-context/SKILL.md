---
name: generate-service-context
description: Use when the user wants to generate a new `service-context.yaml` file for a service in their own service catalog. Trigger phrases include "/generate-service-context", "create service context", "audit this service for service-context", "make the service-context.yaml for this repo". Interactively audits the current service repo, cross-references deploy/CI repos, asks the owner targeted questions, drafts the YAML, and writes it to the repo root. Does NOT update existing files. Does NOT validate. Only creates.
---

# generate-service-context

Generates `service-context.yaml` at the root of a service repo, conforming to a locked 7-section schema. The result is a canonical structural overview (ownership, internal deps, runtime edges, deployment) that other agents can read before reasoning about blast radius or cross-service changes.

This skill assumes you maintain a personal/team **service catalog**: a directory (default `~/repositories/service-context/`, but ask the user if it's elsewhere) containing `SCHEMA.md`, `CONVENTIONS.md`, and `INDEX.md`. If no such catalog exists yet, offer to scaffold one (see "First Use — No Catalog Yet" below) before drafting the first file.

## First Use — No Catalog Yet

If `~/repositories/service-context/` (or wherever the user points) doesn't exist:
1. Ask where they want the catalog to live.
2. Create `SCHEMA.md` (field-by-field schema — see "Schema" section below for the canonical fields), `CONVENTIONS.md` (drift-resistance rules — see "Drift Resistance" below), and an empty `INDEX.md`.
3. Proceed with Phase 1 below.

## Canonical references

Before drafting, READ these files in full:
- `<catalog>/SCHEMA.md` — field-by-field schema spec
- `<catalog>/CONVENTIONS.md` — drift-resistance rules, ref format, anti-patterns
- `<catalog>/INDEX.md` — current service list (to update after writing)
- Any existing `<repo>/service-context.yaml` you have access to — as concrete examples

## Preconditions

1. Current working directory must be a service repo (has `pom.xml`, `go.mod`, `package.json`, `Cargo.toml`, `Chart.yaml`, `Dockerfile`, or similar build manifest at root).
2. `service-context.yaml` must NOT already exist at repo root. If it does, stop and direct user to update it manually (an update skill is out of scope here).
3. **Ensure repo is up to date.** Ask the user to confirm they've pulled the latest from the primary branch before proceeding. Do NOT auto-pull — just confirm. Auditing a stale checkout produces a stale context file.

If any precondition fails, tell the user and stop.

## Workflow — 5 phases, strictly ordered

### Phase 1 — Audit

Discover the service by reading its files. Do NOT ask the user for info you can discover.

**Language / build:**
- `pom.xml` → Java/Maven. Parent POM. Internal org-namespaced deps (ask the user for their org's package prefix on first use, e.g. `com.yourorg.*`).
- `go.mod` → Go. Module name and internal module path prefix.
- `package.json` → Node. Workspace/monorepo internal package scope.
- `Chart.yaml` → Helm chart (umbrella or leaf).

**CI:**
- Locate the CI config (`.github/workflows/*`, `.gitlab-ci.yml`, `Jenkinsfile`, etc.) at repo root or common subdirs (`build/`, `.ci/`).
- If the pipeline delegates to a shared/external pipeline definition in another repo, note that repo as the real CI source rather than the local orchestrator file.

**Tests:**
- Unit: convention per language (`**/*_test.go`, `**/src/test/java`, `**/*.test.ts`).
- Integration: look for `*integration-tests*`, `*-IT/`, `**/integration_tests/` directories at repo root or siblings.
- Acceptance/E2E: check for a sibling repo or directory dedicated to acceptance tests for this service, if your org has one.

**Deployment:**
- Look for the deployment manifest local to this repo first: Helm chart, `docker-compose.yml`, Terraform module, CDK/Pulumi stack.
- If deployment lives in a separate repo (common pattern: a central `deployments`/`infra` repo with per-environment branches or directories), ask the user where it is on first use and remember the convention (e.g., "deploy manifests live in `infra-deployments` under `environments/<env>/<service>/`").
- The ref should point at a **directory** containing the actual deployment artifacts, not just a role/module-level path.
- If nothing is found: flag as MANUAL for the user to specify.

**Runtime edges (from code):**
- HTTP server port: scan for server init (framework-specific: `.Run(":XXXX")`, `server.port=`, `app.listen(`, etc.)
- Outbound HTTP: look for HTTP client usage — infer target service names from URLs/config.
- Message queue (Kafka/SQS/RabbitMQ/etc.): look for producer/consumer init; presence → add edge, but DO NOT copy topic/queue names into the draft (drift-prone — see Drift Resistance).
- DB: look for DB driver imports/connection config.

**Owner:**
- Check Helm `values.yaml` `owner:` field, CI config owner annotations, `CODEOWNERS`, README. If ambiguous, MANUAL.

### Phase 2 — Classify

Map findings to schema fields:

- **Internal dependencies**: only org-owned deps, consumed at build/compile time. Filter out third-party libraries and same-repo modules.
- **Deployment type**: `k8s` if Helm chart exists; `compose` / `terraform` / etc. as appropriate; otherwise flag MANUAL.
- **Deployment ref**: `<repo>/<path>` pointing at the directory with the actual manifests.
- **CI pipeline**: `<repo>/<path>` — prefer the actual build pipeline location over a local orchestrator file that merely delegates.
- **Secrets source**: MANUAL by default. Don't guess beyond what code reveals.

### Phase 3 — Interact

Ask the user one question at a time, in order. Do NOT batch questions.

1. **Role sentence** — draft 2-3 HIGH-LEVEL sentences. Describe what the service does and who it serves. **Avoid implementation details**: don't list module names, don't enumerate internal components, don't mention frameworks. If the service has modes/flavors, mention them abstractly ("mode selectable via X"). Present as: *"Draft role description: '<proposed>'. Accept, rewrite, or tweak?"*
2. **Owner** — only if Phase 1 was ambiguous: *"I couldn't determine the owner. Who is it?"*
3. **Secrets source** — *"How does this service get secrets? (cloud secrets manager / env / vault / other)"*
4. **Ambiguous deployment** — only if Phase 1 couldn't resolve: *"I didn't find a deployment manifest. Where is this service deployed?"*
5. **Async event nature** (if a queue/topic inbound edge was detected) — *"What's the nature of the events consumed? (one-line description for an inline comment — don't quote topic/queue names)"*
6. **Any edges I missed?** — *"Here are the edges I detected: <list>. Are any outbound dependencies or inbound interfaces missing?"*

One message per question. Wait for answer before proceeding.

### Phase 4 — Draft

Assemble the YAML against `<catalog>/SCHEMA.md`. Enforce drift-resistance per `<catalog>/CONVENTIONS.md` (see Drift Resistance below for the default rules if you haven't customized them):

- **Forbidden — reject if detected in draft:**
  - `version:` anywhere
  - Consumed topic/queue names in `edges.inbound[].topic`
  - Secret reference names in `secrets.refs`
  - Caller names (specific service names in `edges.inbound[].from`) unless stable and intentional
  - Per-env ports (only the canonical default from code)
  - Framework/packaging details already in the build manifest

- **Required:**
  - All refs as `<repo>/<path>`
  - `edges[].kind` ∈ `{http, queue, db}` (extend as needed)
  - Mandatory sections: `name`, `role`, `owner`, `cicd`, `tests`, `deployment` (at least one target), `edges`
  - Conditional sections (`internal_dependencies`, `secrets`, `notes`, `links`) omitted if empty

- **MANUAL markers** — for anything not resolved in phases 1-3: inline `# MANUAL:` comment explaining what user should verify.

Show the full draft in chat. Ask: *"Review the draft above. Accept as-is / point out fixes / adjust specific fields?"*

Loop until user accepts.

### Phase 5 — Commit

After user accepts:

1. **Write** `service-context.yaml` to repo root (`<cwd>/service-context.yaml`).
2. **Update `INDEX.md`** — add a row pointing at the new file's authoritative path (relative to the catalog's repo root).
   - If `INDEX.md` is in a git repo, prompt user: *"Add and commit the INDEX.md update? (yes/no)"*
   - If yes: stage the change and commit with message `Add <service> to INDEX` (co-authored-by Claude line included).
3. **Remind** the user that a `CLAUDE.md` pointer to the catalog is optional if their global CLAUDE.md already covers it.

## Drift Resistance (default conventions, customize in your own CONVENTIONS.md)

The point of `service-context.yaml` is to stay accurate without manual upkeep. Volatile details belong in their authoritative source, not in this file:

- **No version numbers** — they go stale immediately. Read `pom.xml`/`go.mod`/`package.json` directly when version matters.
- **No topic/queue names, secret names, or per-env ports** — these change without anyone updating the catalog. Describe the *existence and nature* of an edge, not its exact identifier.
- **Refs as `<repo>/<path>`** — always point at where the authoritative artifact lives, never inline a copy of its content.

## What this skill MUST NOT do

- Update / modify an existing `service-context.yaml` (refuse; direct user to manual edit or a future update skill).
- Validate an existing file (future skill).
- Render dependency graphs (future skill).
- Write anything outside the service repo root + `INDEX.md`.
- Guess secrets sources without user confirmation.
- Include volatile values (versions, topic names, specific secret refs) even if discoverable — per drift-resistance.

## Output contract

After successful run:
- ✅ `<service-repo>/service-context.yaml` exists, conforms to `SCHEMA.md`
- ✅ `<catalog>/INDEX.md` has a new row (committed if user agreed)
- ✅ Any `# MANUAL:` markers in the YAML are clearly flagged for user to address later
- User informed of next steps if remaining MANUALs exist
