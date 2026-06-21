# Skill Authoring

A meta-skill: an interactive, gated workflow for building (or reviewing) new Claude Code skills that follow the official spec.

## What it includes

- **Skill:** `skill-creator` — invoked directly in chat ("create a skill", "build a skill for X")

## How it works

Walks through 5 phases, with a confirmation gate between each — never generates a whole skill in one shot: **(1) Discovery** — category, 2-3 concrete use cases with trigger phrases, tool/MCP dependencies, success criteria. **(2) Structure** — kebab-case folder name, minimal vs. full layout (`references/`, `scripts/`, `assets/`), YAML frontmatter validated against anti-patterns (vague descriptions, missing trigger phrases). **(3) Instructions** — writes the `SKILL.md` body against a standard skeleton (Overview, Workflow, Examples, Edge Cases, When NOT to Use), enforcing progressive disclosure (core instructions under 5,000 words, details pushed to `references/`). **(4) Validation** — runs a structural + trigger-accuracy checklist. **(5) Finalize** — writes the files and gives install instructions.

Also supports **Review Mode** — point it at an existing skill and it evaluates frontmatter quality, instruction clarity, structure, and composability, returning categorized findings.

## Install

```bash
./install.sh skill-authoring
```

## Requires

Nothing — works standalone, useful across any project.
