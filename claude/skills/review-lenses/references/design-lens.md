# Lens 4 — Design & Structure

**Focus:** Architectural quality — abstractions, coupling, and API contracts.

**Principles covered:** From `coding-standards` #6 Simplicity & SOLID, #7 Access & Encapsulation, #8 Interface Design

---

## Checklist

### SOLID & Simplicity
- [ ] Single responsibility: each class/function does exactly one thing
- [ ] Open/closed: can the code be extended without modification?
- [ ] Liskov substitution: do subtypes honor the base contract?
- [ ] Interface segregation: are interfaces lean or do clients depend on methods they don't use?
- [ ] Dependency inversion: high-level modules depend on abstractions, not concrete implementations
- [ ] The solution is the simplest that meets requirements — no gold-plating
- [ ] No premature abstractions or unnecessary design patterns
- [ ] No dead code, unused imports, or commented-out blocks
- [ ] Library-first: existing libraries used where appropriate instead of custom code
- [ ] DRY — but only when the duplication represents the same concept

### Encapsulation
- [ ] Fields and methods private by default, only widened when genuinely needed
- [ ] No public fields that should be behind accessors
- [ ] Internal implementation details hidden from public API surface
- [ ] `protected` access justified by actual inheritance needs
- [ ] Module/package-level visibility used where appropriate
- [ ] Utility classes restrict instantiation when appropriate
- [ ] Prefer immutable data structures — mutate only when performance requires it

### Interface Design
- [ ] Dependencies injected via interfaces/abstractions, not concrete classes
- [ ] Components testable in isolation (mockable boundaries)
- [ ] Contracts (input/output types) explicitly defined
- [ ] Modules loosely coupled with clear boundaries
- [ ] Request/response payloads modeled as dedicated types (DTOs), not raw maps or inline literals
- [ ] Immutable models at boundaries — DTOs and value objects not mutated after construction

### Architectural Fit
- [ ] Does the change fit the existing architecture or introduce a new pattern?
- [ ] If a new pattern: is it justified? Does it conflict with existing approaches?
- [ ] Module boundaries respected — no reaching across layers
- [ ] Could this be simpler? Challenge the complexity.
