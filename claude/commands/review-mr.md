---
description: "Deep MR review — parallel multi-lens review of a teammate's merge request"
argument-hint: "<MR-number> [focus areas or notes] [--deep]"
---

# Deep MR Review

Review a teammate's merge request using 6 parallel review lenses.

## Arguments

**Raw input:** $ARGUMENTS

Parse the arguments:
- **First token** = MR number (required). This is the GitLab MR IID (e.g., `123` for MR !123).
- **`--deep` flag** = if present, all lens subagents use Opus instead of Sonnet. Remove from remaining tokens after parsing.
- **Remaining tokens** = focus areas, notes, or context from the user (optional).

If no arguments are provided, ask the user for the MR number before proceeding.

## Workflow

Use the Task tool to invoke the **deep-reviewer** agent:
- **subagent_type:** `deep-reviewer`
- **description:** "Deep review of MR"
- **prompt:** Construct the prompt including:
  1. "DEEP REVIEW of MR ![MR number]."
  2. If `--deep` flag was present, add: "MODE: --deep (use Opus for all lens subagents)."
  3. If focus areas / notes were parsed from arguments, add: "Focus areas / notes from the user: [remaining tokens]"
  4. If no focus areas were provided, omit — the deep-reviewer will discover intent in Step 2.

After the deep-reviewer completes, relay the **complete review report verbatim** to the user. This MUST include ALL of the following — do NOT summarize or omit any section:
1. Verdict and TL;DR
2. Lens Coverage table
3. All findings with IDs (CRT/IMP/SUG/POS)
4. Drill-down prompt (remind user they can expand findings)

Do NOT convert the Lens Coverage table into narrative text. Reproduce it as a markdown table exactly as the deep-reviewer produced it.
