# Lens 5 — Performance & Testing

**Focus:** The safety net (tests) and the runtime behavior (performance).

**Principles covered:** From `coding-standards` #1 Test Coverage, #10 Performance

---

## Checklist

### Test Coverage
- [ ] All public methods/endpoints covered by tests
- [ ] Happy path AND failure paths tested
- [ ] Tests assert behavior, not implementation details
- [ ] Branch coverage ≥ 80% on changed code
- [ ] Test names descriptive of the scenario they verify

### Test Quality
- [ ] Assertions verify actual behavior — a test can pass while checking nothing meaningful
- [ ] Missing negative tests: for every feature path, is there a test for "what happens when this fails?"
- [ ] Missing boundary tests: empty list, single element, max size, zero, negative, overflow
- [ ] Test independence: no dependency on execution order or shared mutable state
- [ ] No flaky patterns: time-dependent, network-dependent, order-dependent assertions
- [ ] Mocking at correct boundaries — not over-mocking (testing mocks instead of code)

### Performance — Data Access
- [ ] No N+1 patterns — use batch/bulk operations instead of row-by-row iteration
- [ ] Filtering/aggregation pushed to data layer (WHERE, GROUP BY) not fetch-all-then-filter
- [ ] Queries examined for missing indexes on new columns/filters
- [ ] Large collections paginated or streamed

### Performance — Runtime
- [ ] No unbounded loops or memory leaks in hot paths
- [ ] No unnecessary allocations or redundant computations
- [ ] Expensive operations cached or deferred where appropriate
- [ ] Blocking operations in async context? (thread pool starvation risk)

### Deployment & Breaking Changes
- [ ] API changes backward compatible? New fields optional?
- [ ] Database migrations reversible? Data backfill needed?
- [ ] Feature flags for risky changes?
- [ ] New dependencies impact startup time or memory footprint?
