---
description: "Internal code review — reviews the current branch against the Architect's spec and prints the verdict report to the terminal. Git actions optional, on request only."
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
Use the Agent tool to invoke the **reviewer** agent:
- **subagent_type:** `reviewer`
- **description:** "Internal code review"
- **prompt:** Construct the prompt including:
  1. "INTERNAL MODE review."
  2. Include the branch name and change summary from the Context section above.
  3. If `$ARGUMENTS` is not empty, add: "Focus areas / notes from the user: $ARGUMENTS"
  4. If `$ARGUMENTS` is empty, omit focus areas — the reviewer runs a full review by default.

### Step 2: Present Results
After the reviewer completes, relay the **complete review report verbatim** to the user. This MUST include ALL of the following — do NOT summarize or omit any section:
1. TL;DR and Verdict
2. Findings Summary (counts by severity)
3. The full **Lens Coverage table** (all 6 rows)
4. Critical & Important findings with details

Do NOT convert the Lens Coverage table into narrative text. Reproduce it as a markdown table exactly as the reviewer produced it.

### Step 3: Close Out
**The terminal report is the deliverable — the command ends there.**

- If **SHIP IT**: append one line: *"Review passed. Git actions available on request (commit / push / PR-MR)."* Take NO git action unless the user explicitly asks in a follow-up.
- If **NEEDS WORK / BLOCKER**: the findings list is the close-out. Do NOT offer git actions.

**Do NOT suggest compile/build commands.** The reviewer already ran tests and linter — do not re-verify.
