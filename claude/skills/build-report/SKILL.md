---
name: build-report
description: "Standardized Build Report format for implementation agents. Outputs TL;DR, status, ASCII change tree with file tags and method-level detail, test results, and activity summary. Use when an agent completes implementation work and needs to report changes. Loaded by Builder and other implementation agents via frontmatter — not user-invocable."
user-invocable: false
---

# Build Report

## Overview
Standardized output format for agents that implement code. Ensures every implementation report is scannable, consistent, and includes a file-level change tree with method granularity.

## Report Template

When reporting task completion, use this exact structure:

~~~
## Build Report

**TL;DR:** [1-2 sentences: what you did and the result]

**Status:** DONE | BLOCKED | PARTIAL

### Change Tree
```
src/
├── path/to/File.ext        [new|modified|deleted]  — methodA(), methodB()
├── path/to/
│   ├── AnotherFile.ext     [modified]              — updatedMethod() (signature change)
│   └── NewFile.ext         [new]                   — create(), validate(), parse()
└── tests/
    └── file.test.ext       [new]
```

### Test Results
- New: X passed | Full suite: Y passed, Z failed | Lint: clean

### Activity Summary
> [e.g., "Read spec + 6 source files, created /pkg/sync with 3 new files, built SyncService, wrote 14 tests (all green), full suite clean."]

### Details available on request
- [List areas you can break down further if asked]
~~~

## Change Tree Rules

### File Tags
Every file gets exactly one tag:
- `[new]` — file was created
- `[modified]` — file existed, content changed
- `[deleted]` — file was removed

### Method Detail
- List ONLY methods/functions that were **added, modified, or removed** — not every method in the file.
- Use short name only: `validate()`, not `public async validate(input: string): Promise<boolean>`.
- Add a short annotation when non-obvious: `(signature change)`, `(renamed)`, `(moved from X)`.

### When to Skip Method Detail
Skip method-level breakdown for:
- Test files
- Config files (JSON, YAML, TOML, env)
- Pure boilerplate / generated files
- Trivial single-purpose files (e.g., barrel exports, constants)

### Formatting
- Group files by directory.
- Use ASCII tree characters: `├──`, `└──`, `│`.
- Align tags and method lists for readability.
- Sort directories alphabetically within each level.

## When NOT to Use
- Research-only tasks with no code changes.
- Tasks that only modify documentation (Architect's territory).
- Single-file trivial edits where a one-liner suffices — still use the template but the tree will just have one entry.
