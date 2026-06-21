---
description: "Internal code review — reviews current branch against spec, verdict-driven git actions"
argument-hint: "[focus areas or notes]"
model: opus
---

# Internal Code Review

Review the current branch's implementation against the Architect's spec.

## Context

**Branch:** !`git branch --show-current`

**Recent changes:**
!`git diff --stat`

## Workflow

### Step 1: Run the Review
Use the Task tool to invoke the **reviewer-internal** agent:
- **subagent_type:** `reviewer-internal`
- **description:** "Internal code review"
- **prompt:** Construct the prompt including:
  1. "INTERNAL MODE review."
  2. Include the branch name and change summary from the Context section above.
  3. If `$ARGUMENTS` is not empty, add: "Focus areas / notes from the user: $ARGUMENTS"
  4. If `$ARGUMENTS` is empty, omit focus areas — the reviewer will ask during Step 1.

### Step 2: Present Results
After the reviewer completes, relay the **complete review report verbatim** to the user. This MUST include ALL of the following — do NOT summarize or omit any section:
1. TL;DR and Verdict
2. Findings Summary (counts by severity)
3. The full **Lens Coverage table** (all 6 rows)
4. Critical & Important findings with details

Do NOT convert the Lens Coverage table into narrative text. Reproduce it as a markdown table exactly as the reviewer produced it.

### Step 3: Post-Review Actions (MANDATORY)
Based on the reviewer's verdict, present these options to the user:

- If **SHIP IT**: Ask the user: *"Review passed. Should I: (a) commit + push, (b) commit only, (c) no git actions?"*
  - If the user chooses (a) or (b): create a descriptive commit following `CLAUDE.md` conventions, then push if (a).
- If **NEEDS WORK**: List the blockers. Do NOT offer git actions.

**Do NOT suggest compile/build commands or skip this step.** The post-review action is always about git, not verification — the reviewer already ran tests and linter.
