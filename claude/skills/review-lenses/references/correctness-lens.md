# Lens 1 — Correctness & Logic

**Focus:** Finding bugs. The #1 value of code review.

**Principles covered:** From `coding-standards` #2 Edge Cases, #3 Null & Empty Safety (logic paths)

---

## Checklist

### Logic Errors
- [ ] Walk through code paths with concrete values — pick boundary values (0, -1, max, empty, null) and mentally execute
- [ ] Challenge every conditional: what happens in the else? Are compound conditions correct under all combinations?
- [ ] Follow data from entry to exit — where can it be null/empty/malformed that the code doesn't check?
- [ ] Are transformations lossy? Data type conversions that lose precision or truncate?
- [ ] Off-by-one errors in loops, slices, ranges, pagination

### Data Flow
- [ ] Can variables reach a state the code doesn't handle?
- [ ] Are return values from called functions checked before use?
- [ ] Does the code correctly distinguish between "absent" and "present but empty"?
- [ ] Optional/Maybe types used instead of returning null where the language supports it

### State & Side Effects
- [ ] Can the code reach an inconsistent state? What if a step fails midway?
- [ ] Does any function modify state beyond its return value? Are callers aware?
- [ ] Concurrent/race conditions — shared mutable state? Are operations atomic that need to be?

### Boundary Values
- [ ] Boundary values handled: max, min, zero, negative, empty, single element, overflow
- [ ] Unexpected input shapes: wrong type, extra fields, truncated data
- [ ] Timeout and retry scenarios — what happens at the boundary of max retries?

### Intent vs. Implementation
- [ ] Does the code actually do what the MR description/intent says it does?
- [ ] Are there code paths that contradict the stated intent?
- [ ] Are there missing code paths that the intent implies should exist?
