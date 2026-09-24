---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development

## Overview

Write the test first. Watch it fail. Write the minimum code to pass. Refactor.

**Core principle:** if you didn't watch the test fail, you don't know that it tests the right thing.

**Violating the letter of this rule violates the spirit.**

## The iron law

```text
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Wrote code before the test? Delete it. Start over.

No exceptions:

- Don't keep it as "reference"
- Don't "adapt" it while writing the test
- Don't peek at it
- Delete means delete

## When to apply

Always for:

- New features
- Bug fixes (the regression test is the bug repro)
- Refactors that change behaviour
- Public API changes

Skip TDD only for:

- Throwaway prototypes you will discard within the hour
- Generated code you don't hand-edit
- Pure config files

Thinking "skip TDD just this once"? That's a rationalization. Don't.

## Red → Green → Refactor

### RED — write the failing test

One behaviour, clear name, real code (no mocks unless unavoidable).

Good (Rust):

```rust
#[test]
fn retries_failed_operations_three_times() {
    let mut attempts = 0;
    let op = || {
        attempts += 1;
        if attempts < 3 { Err("transient") } else { Ok("ok") }
    };
    assert_eq!(retry(op), Ok("ok"));
    assert_eq!(attempts, 3);
}
```

Bad:

```rust
#[test]
fn retry_works() { /* mock-heavy, vague name */ }
```

### Verify RED — watch it fail

Mandatory. Never skip.

```bash
cargo nextest run retries_failed_operations_three_times    # Rust
pnpm test --testNamePattern "retries failed"               # TS
pytest -k retries_failed                                   # Python
./gradlew test --tests "*retriesFailed*"                   # Kotlin/Java
```

Confirm:

- It fails (does not error out compiler-style — that's a typo, fix and re-run).
- The failure message matches your expectation.
- It fails because the feature is missing, not because of a syntax mistake.

Test passes? You are testing existing behaviour. Fix the test.

### GREEN — minimal code

Simplest thing that makes the test pass.

```rust
fn retry<F, T, E>(mut op: F) -> Result<T, E>
where F: FnMut() -> Result<T, E> {
    for i in 0..3 {
        match op() {
            Ok(v) => return Ok(v),
            Err(e) if i == 2 => return Err(e),
            Err(_) => continue,
        }
    }
    unreachable!()
}
```

No bonus features. No "while I'm here" refactors.

### Verify GREEN — watch it pass

Run the same command. Confirm:

- Target test passes.
- All other tests still pass.
- Output is pristine (no warnings, no `dbg!` leftovers, no compiler warnings).

### REFACTOR — clean up

Now (and only now) you can rename, extract helpers, deduplicate. Tests must stay green at every step.

## Good test qualities

| Quality | Good | Bad |
|---|---|---|
| Minimal | One behaviour. No `and` in the name. | `test('validates email AND domain AND whitespace')` |
| Clear | Name describes behaviour. | `test('test1')` |
| Honest | Real code paths exercised. | Tests the mock, not the system. |

## Why order matters

| Excuse | Reality |
|---|---|
| "I'll write tests after to verify" | Tests written after pass immediately. Passing immediately proves nothing. |
| "I already manually tested edge cases" | Manual ≠ systematic. No record. Can't re-run. |
| "Deleting X hours of work is wasteful" | Sunk cost. Untrusted code is debt. |
| "TDD is dogmatic, I'm pragmatic" | TDD is faster than debug-after-the-fact. That's pragmatic. |
| "Tests after achieve the same goal" | Tests-after answer "what does this do?". Tests-first answer "what should this do?". |
| "Too simple to test" | Simple code breaks. The test takes 30 seconds. |
| "Hard to test = unclear design" | Listen to the test. Hard to test = hard to use. |

## Red flags — stop

- Code before test
- Test passes on the first run
- Can't explain why the test failed
- "Adapt the existing implementation while I write the test"
- "Spirit not ritual"
- "This case is different"

All of these mean: delete the code, start over with TDD.

## Bug fix flow

A bug means the test you needed never existed. Steps:

1. Write the test that demonstrates the bug. Run it. It must fail with the actual symptom.
2. Fix the code.
3. Run the test. It must pass.
4. Run the full suite. Nothing else broken.
5. Commit: `fix(<scope>): <imperative description>`.

The test now prevents regression.

## Verification checklist

Before marking the work done:

- [ ] Every new function has at least one test
- [ ] You watched each test fail before writing the implementation
- [ ] Each failure was for the expected reason
- [ ] You wrote minimal code to pass
- [ ] Full suite is green
- [ ] No warnings, no `println!`/`console.log`/`print` left behind
- [ ] Tests use real code, mocks only where unavoidable

If you can't tick all of these, you skipped TDD. Start over.

## When stuck

| Problem | Solution |
|---|---|
| Don't know how to test | Write the wished-for API in the test, then make it real. |
| Test too complicated | Design too complicated. Simplify the interface. |
| Must mock everything | Code is too coupled. Inject dependencies. |
| Test setup huge | Extract helpers. If still huge, redesign. |

## Bottom line

```text
Production code → a test exists and failed first
Otherwise → not TDD
```
