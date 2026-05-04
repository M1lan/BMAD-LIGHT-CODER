---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behaviour, before proposing fixes
---

# Systematic Debugging

## Overview

Random fixes waste time and create new bugs. Symptom patches mask root causes.

**Core principle:** find the root cause before touching code. Symptom-fixing is failure.

## The iron law

```text
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you skipped Phase 1, you can't propose a fix.

## When to apply

Any technical issue: test failures, prod bugs, unexpected behaviour, performance regressions, build failures, integration issues.

Apply this **especially** when:

- You're under time pressure (emergencies make guessing tempting)
- One quick fix "seems obvious"
- You've already tried two fixes
- The previous fix made it worse
- You don't fully understand the symptom

Don't skip when:

- The bug seems simple (simple bugs have root causes too)
- You're rushing (rushing guarantees rework)
- Someone wants it fixed now (systematic is faster than thrashing)

## The four phases

You must complete each phase before moving to the next.

### Phase 1 — Root cause investigation

Before any fix:

1. **Read the error fully.** Stack traces contain the answer 80% of the time. Note line, file, error code.
2. **Reproduce reliably.** Exact steps. Every time? If not, gather more data, do not guess.
3. **Check recent changes.** `git log --oneline -20`, `git diff main...HEAD`. New deps, new config, new env vars.
4. **Instrument boundaries.** In multi-component systems (CI → build → ship, API → service → DB), add logs at each boundary so the next run reveals which layer is wrong.

Example bash instrumentation chain:

```bash
# Layer A — workflow / runner
echo "ENV at workflow: TOKEN=${TOKEN:+SET}${TOKEN:-UNSET}"

# Layer B — build script
env | rg '^TOKEN=' || echo "TOKEN missing in build"

# Layer C — actual call
glab api /user >/tmp/user.json && jq -e '.username' /tmp/user.json
```

Reveals which layer breaks.

5. **Trace data flow backwards.** Where does the bad value originate? Walk from symptom up the call stack to the source. Fix at the source, never at the symptom.

### Phase 2 — Pattern analysis

Find the pattern before fixing.

1. Find a working example in the same codebase.
2. Compare the working code against the broken code line-by-line.
3. List every difference, however small. "That can't matter" is the lie that hides the cause.
4. Identify dependencies: config, env, init order, feature flags.

### Phase 3 — Hypothesis and test

Scientific method.

1. State one hypothesis: *"I think X is the root cause because Y."* Write it down.
2. Test minimally: smallest possible change, one variable.
3. If it works, go to Phase 4. If not, form a new hypothesis. Do **not** stack fixes.
4. If you don't know, say so. Don't pretend.

### Phase 4 — Implementation

Fix the cause, not the symptom.

1. Write a failing test that reproduces the bug. (See `../test-driven-development/SKILL.md`.) Watch it fail.
2. Implement the single fix. One change. No "while I'm here" cleanup.
3. Run the test, then the full suite. Both green.
4. If the fix doesn't work:
   - Tried <3 fixes? Return to Phase 1 with the new evidence.
   - **Tried 3+ fixes?** Stop. Don't attempt fix #4. The architecture is the problem.

### Phase 4.5 — Three failed fixes means architecture

Pattern that says the architecture is wrong:

- Each fix surfaces a new shared-state / coupling problem somewhere else.
- Fixes need "massive refactoring" to land.
- Each fix creates new symptoms.

Stop and ask:

- Is this pattern fundamentally sound, or are we sticking with it from inertia?
- Is the right move a refactor of the design, not another patch?

This is not a failed hypothesis. It is a wrong architecture.

## Red flags — stop

If you catch yourself thinking:

- "Quick fix for now, investigate later"
- "Just try changing X and see"
- "Add a few changes, run the tests"
- "Skip the test, I'll verify by hand"
- "It's probably X, let me just fix that"
- "Pattern says X but I'll adapt"
- "One more fix attempt" (after ≥2 failed)

All of these mean: stop, return to Phase 1.

## Common rationalizations

| Excuse | Reality |
|---|---|
| "Issue is simple, no need for the process" | Simple bugs have root causes too. The process is fast for them. |
| "Emergency, no time" | Systematic is faster than guess-and-check. |
| "I'll write the test after the fix" | Untested fixes don't stick. |
| "Multiple fixes at once saves time" | Then you can't tell which worked. |
| "I see the problem, let me fix it" | Seeing the symptom ≠ understanding the cause. |
| "One more attempt" (3rd failure) | Three failures = architecture problem. Don't fix again. |

## Quick reference

| Phase | Activity | Done when |
|---|---|---|
| 1. Root cause | Read errors, reproduce, instrument boundaries, trace backward | You understand WHAT and WHY |
| 2. Pattern | Find working examples, compare | Differences listed |
| 3. Hypothesis | One theory, minimal test | Confirmed or rejected |
| 4. Implementation | Failing test → fix → green | Bug gone, regression test in place |

## When the process says "no root cause"

If investigation reveals the issue is genuinely environmental, timing-dependent, or external:

1. Document what you investigated.
2. Implement appropriate handling: retry with backoff, timeout, structured error.
3. Add monitoring/logging so the next occurrence is diagnosable.

But: 95% of "no root cause" cases are incomplete investigation.

## Pairs with

- `../test-driven-development/SKILL.md` — write the failing repro in Phase 4.
- `../verification-before-completion/SKILL.md` — verify the fix really worked before claiming done.
