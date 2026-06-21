# Lens 3 — Reliability & Operations

**Focus:** What happens when things go wrong — and can you see it happening.

**Principles covered:** From `coding-standards` #4 Error Handling, #11 Logging & Observability, #2 Edge Cases (failure scenarios)

---

## Checklist

### Error Handling
- [ ] Errors caught at appropriate levels — never swallowed silently
- [ ] No bare `catch` / `except` without specific handling
- [ ] Catch blocks are minimal and specific — no suppressing or generalizing the original error
- [ ] Recoverable vs. fatal errors are distinguished
- [ ] Consistent error response structure for APIs
- [ ] Error messages aid debugging without leaking internals
- [ ] No inline error codes (magic numbers) — use named constants or enums
- [ ] No suppressed compiler/linter warnings without a justifying comment and ticket
- [ ] All HTTP status codes in swagger/OpenAPI annotations have explicit handling paths

### Resource Management
- [ ] Connections, streams, locks, and transactions properly opened and closed — including on error paths
- [ ] Look for try-without-finally, missing `close()`, unreleased resources
- [ ] Timeout handling — what happens when external calls hang?
- [ ] Circuit breaker / retry patterns used correctly (not infinite retry, not retry on non-idempotent)

### Failure Recovery
- [ ] State transitions — can it reach an inconsistent state on failure?
- [ ] Partial failure cleanup — what if step 3 of 5 fails?
- [ ] Graceful degradation — does the system degrade safely or crash entirely?
- [ ] Async errors propagated or handled — not silently swallowed by detached goroutine/thread/promise
- [ ] Spawned goroutines/threads/tasks are bounded — no unbounded spawning

### Logging & Observability
- [ ] Key operations logged: entry points, state transitions, external calls
- [ ] Flow reconstructable from logs alone without a debugger
- [ ] Log levels correct: DEBUG for internals, INFO for business events, WARN for recoverable issues, ERROR for failures
- [ ] Logs follow project's existing conventions (format, library, structure)
- [ ] No sensitive data in logs (tokens, passwords, PII)
- [ ] Log messages are actionable — what happened and where
- [ ] Correlation/request IDs included for traceability in distributed flows
- [ ] New error paths have corresponding log statements
