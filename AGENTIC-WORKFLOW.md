# Agentic Workflow

The core workflow this stack is built around: a spec-driven **Architect → Builder → Reviewer** pipeline, where each agent owns a distinct responsibility and hands off through a file (`/docs/*.md` in your own project, not this repo) rather than shared conversation context.

## Components

| Component | Type | Model | Invoked by |
|---|---|---|---|
| `architect` | Agent | Opus | `@architect [task]` |
| `cto-review` | Skill | Opus (conversation) | `/cto-review` (after Architect finishes) |
| `spec-reviewer` | Skill | Opus subagents (5 parallel) | `/spec-review` (after CTO passes or is skipped) |
| `builder` | Agent | Sonnet | `@builder [spec path or task]` |
| `reviewer-internal` | Agent | Sonnet | `@reviewer-internal` or `/review-internal` |

Shared skills: `spec-format` (the contract Architect writes against and Builder/reviewer read), `architect-methodology` (5 reasoning lenses + research protocol), `coding-standards` (13 quality standards), `build-report` (Builder's output format), `review-lenses` (the 6-lens review mechanism the reviewer agent uses).

## Pipeline Overview

```
                          ┌─────────────┐
                          │  YOU (User)  │
                          │  Orchestrator│
                          └──────┬───────┘
                                 │ task / requirement
                                 ▼
                     ┌───────────────────────┐
                     │   ARCHITECT (Agent)    │
                     │   Principal Architect  │
                     │   Model: Opus          │
                     │   Skills: spec-format, │
                     │   architect-methodology│
                     └───────────┬───────────┘
                                 │ Draft spec + asks:
                                 │ "Which review path?"
                                 ▼
                  ┌──────────────────────────────┐
                  │      REVIEW GATE CHOICE       │
                  │  (a) Full: CTO + Detail Audits│
                  │  (b) Detail Audits only        │
                  │  (c) Skip → Approved           │
                  └──────────────┬────────────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              ▼                  ▼                   ▼
     ┌────────────────┐  ┌──────────────┐   ┌──────────────┐
     │  /cto-review   │  │ /spec-review │   │   SKIP       │
     │  (Skill)       │  │ (Skill)      │   │  Status →    │
     │  Strategic gate│  │ Detail audits│   │  Approved    │
     └───────┬────────┘  └──────┬───────┘   └──────┬───────┘
             │                  │                    │
        PASS │ RETHINK    APPROVED │ BLOCKING        │
             │    │               │     │            │
             ▼    ▼               ▼     ▼            ▼
     ┌────────────────┐  ┌──────────────┐   ┌──────────────┐
     │  /spec-review  │  │   Approved   │   │              │
     │  Detail audits │  │              │   │              │
     └───────┬────────┘  └──────┬───────┘   │              │
             │                  │            │              │
        APPROVED │ BLOCKING     │            │              │
             │       │          │            │              │
             ▼       ▼          ▼            ▼              │
     ┌──────────────────────────────────────────────┐      │
     │              Status: Approved                 │◄─────┘
     └──────────────────────┬───────────────────────┘
                            │
                            ▼
                ┌───────────────────────┐
                │    BUILDER (Agent)    │
                │   Senior Engineer     │
                │   Model: Sonnet       │
                │   Skills: spec-format,│
                │   coding-standards    │
                │   Method: Strict TDD  │
                └───────────┬───────────┘
                            │ implementation
                            ▼
                ┌─────────────────────────┐
                │  REVIEWER-INTERNAL      │
                │  Internal Code Reviewer │
                │  Model: Sonnet          │
                │  Pass 1: Mechanical     │
                │  Pass 2: Quality        │
                │  Skills: review-lenses, │
                │  coding-standards,      │
                │  gh-ops or glab-ops     │
                └───────────┬─────────────┘
                            │
                  SHIP IT   │   NEEDS WORK / BLOCKER
                     │      │      │
                     ▼      │      ▼
              commit/push   │   Builder fixes
                            │      │
                            └──────┘
```

## Iteration Loops

Both review gates can send the spec back to the Architect:

```
RETHINK (CTO)    ──→ Status: Draft ──→ Architect revises ──→ /cto-review again
BLOCKING (Audit) ──→ Status: Draft ──→ Architect revises ──→ /spec-review again
```

**Context is preserved in the spec file.** Each review writes its findings into the spec's `## CTO Review` and `## Review Notes` sections. The Architect reads these when revising. No conversation context is needed across sessions.

## Task Paths by Complexity

### Complex Task (new service, cross-system, multi-component)
```
Architect (full process) → /cto-review → /spec-review → Builder → Reviewer-Internal
```
- Architect: Discovery → Research → Blueprint → Spec
- CTO Review: mandatory
- Detail Audits: mandatory (5 parallel subagents)
- Expect 1-3 iteration rounds

### Medium Task (new endpoint, single component, bounded scope)
```
Architect (fast track) → /spec-review → Builder → Reviewer-Internal
```
- Architect: Blueprint → Spec (skip Discovery)
- CTO Review: skipped (mark `_Skipped_` in spec)
- Detail Audits: run all 5
- Expect 0-1 iteration rounds

### Simple Task (bug fix, config change, typo-level)
```
Architect (fast track) → Builder → Reviewer-Internal
```
- Architect: minimal spec or inline task description
- CTO Review: skipped
- Detail Audits: skipped (all rows `⏭️ Skipped`)
- Status: Draft → Approved directly

## Spec Status Tracking

The spec's `**Status:**` field is the single source of truth:

| Status | Where we are | Who acts next |
|---|---|---|
| `Draft` | Architect writing or revising | Architect |
| `CTO Review` | CTO challenge in progress | You (invoke `/cto-review`) |
| `Detail Audit` | Detail audits in progress | You (invoke `/spec-review`) |
| `Approved` | Ready for implementation | Builder |

### Spec Sections That Track Review State

- `## CTO Review` — round-by-round CTO challenge history with verdicts
- `## Review Notes` — per-perspective detail audit table (Security, Scalability, API Design, Completeness, Scope)

Both are populated by their respective skills and preserved across iterations.

## Agents vs Skills — Who Does What

| Component | Type | Model | Invoked by | Runs as |
|---|---|---|---|---|
| **Architect** | Agent | Opus | `@architect` | Dedicated agent session |
| **CTO Review** | Skill | Conversation (Opus) | `/cto-review` | Main conversation context |
| **Spec Review** | Skill | Opus subagents | `/spec-review` | Main context + 5 parallel subagents |
| **Builder** | Agent | Sonnet | `@builder` | Dedicated agent session |
| **Reviewer-Internal** | Agent | Sonnet | `@reviewer-internal` or `/review-internal` | Dedicated agent session |

**Why skills for spec reviews, not agents?**
- Spec reviews are interactive — you may want to discuss findings inline
- The spec file carries all state — no agent memory needed
- `/spec-review` launches subagents internally for parallelism

**Why an agent for code review, not a skill?**
- Code review needs Bash (tests, lint, git commands)
- Direct chat may be in a more constrained mode that can't run commands
- Internal review (Sonnet) is mechanical/checklist-driven — fast and cheap

## Quick Reference — Commands

| What you want | What you type |
|---|---|
| Design a feature | `@architect [task description]` |
| Strategic spec challenge | `/cto-review` (after Architect finishes) |
| Detail audit of spec | `/spec-review` (after CTO passes or is skipped) |
| Implement the spec | `@builder [spec path or task]` |
| Review pipeline code (internal) | `@reviewer-internal` or `/review-internal` |

## Key Files

| File | Purpose |
|---|---|
| `claude/agents/architect.md` | Architect agent definition |
| `claude/agents/builder.md` | Builder agent definition |
| `claude/agents/reviewer-internal.md` | Internal code reviewer (Sonnet) — mechanical + quality |
| `claude/skills/cto-review/SKILL.md` | CTO Review skill |
| `claude/skills/spec-reviewer/SKILL.md` | Detail Audit skill (5 perspectives) |
| `claude/skills/spec-format/SKILL.md` | Spec format contract (shared by all) |
| `claude/skills/architect-methodology/SKILL.md` | Architecture reasoning methodology |
| `claude/skills/coding-standards/SKILL.md` | 13 coding quality standards |
| `claude/skills/build-report/SKILL.md` | Builder's output report format |
| `claude/skills/review-lenses/SKILL.md` | 6-lens review process and verdict rules |
| `/docs/` (in your own project, not this repo) | Where specs produced by the Architect live |

## Git-host dependency

`reviewer-internal` needs a git-host skill to commit/push after a SHIP IT verdict — install `claude/skills/gh-ops` (GitHub) or `claude/skills/glab-ops` (GitLab) depending on your remote. Both can coexist; each checks the actual remote before acting.

## Setup

```bash
./install.sh agentic-workflow
./install.sh github-ops   # or: ./install.sh gitlab-ops
```

Then copy [templates/CLAUDE.md.template](templates/CLAUDE.md.template) into your project as `CLAUDE.md` — the agents read it at Step 0 for global rules and project conventions.

**Verify:** `@architect say hello` should load the architect persona and run its Step 0 (read CLAUDE.md, etc.). If it errors about a missing skill, re-run `./install.sh agentic-workflow`.

`cto-review` and `spec-reviewer` are skills, not agents — they run in your main conversation, invoked via `/cto-review` and `/spec-review` once the architect's spec exists.
