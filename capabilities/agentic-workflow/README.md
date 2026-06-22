# Agentic Workflow

Spec-driven **Architect → Builder → Reviewer** pipeline. The Architect writes a contract-format spec, the Builder implements it via TDD, and the Internal Reviewer gates the result with mechanical checks plus a 6-lens parallel quality review — before anything ships.

## What it includes

| Component | Type | Role | Source |
|---|---|---|---|
| `architect` | Agent | Writes/revises the spec | [→](../../claude/agents/architect.md) |
| `builder` | Agent | Implements it via TDD | [→](../../claude/agents/builder.md) |
| `reviewer-internal` | Agent | Mechanical gate + 6-lens review | [→](../../claude/agents/reviewer-internal.md) |
| `/review-internal` | Command | Runs the reviewer on the current branch | [→](../../claude/commands/review-internal.md) |
| `spec-format` | Skill | The spec contract + lifecycle states | [→](../../claude/skills/spec-format/SKILL.md) |
| `architect-methodology` | Skill | Architect's reasoning lenses + research protocol | [→](../../claude/skills/architect-methodology/SKILL.md) |
| `cto-review` | Skill | Optional strategic spec challenge gate | [→](../../claude/skills/cto-review/SKILL.md) |
| `spec-reviewer` | Skill | Optional 5-perspective detail audit | [→](../../claude/skills/spec-reviewer/SKILL.md) |
| `build-report` | Skill | Builder's output format | [→](../../claude/skills/build-report/SKILL.md) |
| `coding-standards` | Skill | Quality standards (Builder + Reviewer) | [→](../../claude/skills/coding-standards/SKILL.md) |
| `review-lenses` | Skill | The 6-lens review mechanism | [→](../../claude/skills/review-lenses/SKILL.md) |

## How it works

1. **Architect** turns a request into a spec (`Acceptance Criteria`, `Interfaces`, `Error Handling`, etc.), optionally run through `/cto-review` and `/spec-review` gates, until `Status: Approved`.
2. **Builder** implements strictly against the approved spec via Red→Green→Refactor TDD, and cannot start until the spec is `Approved`.
3. **Reviewer-internal** runs Pass 1 (binary mechanical checks: tests, lint, signatures match spec, ACs covered) then Pass 2 (6 parallel lens subagents — Correctness, Security, Reliability, Design, Performance, Readability), cross-checks findings, and issues a verdict (`SHIP IT` / `NEEDS WORK` / `BLOCKER`).

Full pipeline diagram, task-complexity paths (simple/medium/complex), and spec lifecycle: see [AGENTIC-WORKFLOW.md](AGENTIC-WORKFLOW.md).

## Install

```bash
./install.sh agentic-workflow
```

## Requires

A git-host capability ([`github-ops`](../github-ops/README.md) or [`gitlab-ops`](../gitlab-ops/README.md)) for the Reviewer's commit/push step after a `SHIP IT` verdict.
