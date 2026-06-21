# Lens 6 — Readability & Conventions

**Focus:** Can a human understand and maintain this code? Surface-level quality that compounds over time.

**Principles covered:** From `coding-standards` #5 Naming & Readability, #12 Comments & Docs, #13 Language Idioms & Consistency

---

## Checklist

### Naming
- [ ] Names (variables, functions, classes) are self-documenting
- [ ] A new team member can understand each function within 30 seconds
- [ ] No generic dump names: `utils`, `helpers`, `common`, `shared` without clear purpose
- [ ] Domain-specific names used: `OrderCalculator` not `Processor`
- [ ] No magic numbers or strings — named constants used (includes HTTP headers, query params, config keys, event names)
- [ ] Prefer meaningful names over comments

### Structure & Readability
- [ ] Nesting depth ≤ 3 levels — if deeper, extract or use early returns
- [ ] Single responsibility per function
- [ ] Functions ≤ 80 lines (aim for under 50), files ≤ 200 lines
- [ ] Code flows top-down — reader doesn't need to jump around to understand

### Comments & Documentation
- [ ] Self-explanatory code left without unnecessary comments
- [ ] Non-obvious elements commented: business logic, workarounds, regex, algorithms
- [ ] Comments explain WHY, not WHAT
- [ ] Public API interfaces documented (params, returns, throws)
- [ ] TODO/FIXME/HACK comments tracked with ticket references
- [ ] No stale comments that contradict the code

### Language Idioms & Consistency
- [ ] Follow language-specific conventions (PEP 8, gofmt, Google Java Style, etc.)
- [ ] Code follows existing project conventions (naming, structure, patterns)
- [ ] Similar problems solved the same way across the codebase
- [ ] Code style consistent with surrounding files
- [ ] Error handling patterns consistent with rest of codebase
- [ ] Prefer explicit over implicit — define variable types where supported
