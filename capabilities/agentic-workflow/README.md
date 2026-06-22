# Agentic Workflow

Spec-driven **Architect → Builder → Reviewer** pipeline. The Architect writes a contract-format spec, the Builder implements it via TDD, and the Internal Reviewer gates the result with mechanical checks plus a 6-lens parallel quality review — before anything ships.

## What it includes

- **Agents:** [`architect`](../../claude/agents/architect.md) (writes/revises specs), [`builder`](../../claude/agents/builder.md) (TDD implementation), [`reviewer-internal`](../../claude/agents/reviewer-internal.md) (mechanical gate + 6-lens review)
- **Command:** [`/review-internal`](../../claude/commands/review-internal.md) — runs the reviewer against the current branch
- **Skills:** [`architect-methodology`](../../claude/skills/architect-methodology/SKILL.md), [`spec-format`](../../claude/skills/spec-format/SKILL.md) (the spec contract + lifecycle states), [`spec-reviewer`](../../claude/skills/spec-reviewer/SKILL.md), [`cto-review`](../../claude/skills/cto-review/SKILL.md) (optional spec challenge gates), [`build-report`](../../claude/skills/build-report/SKILL.md) (Builder's output format), [`coding-standards`](../../claude/skills/coding-standards/SKILL.md), [`review-lenses`](../../claude/skills/review-lenses/SKILL.md) (the 6-lens review mechanism)

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
