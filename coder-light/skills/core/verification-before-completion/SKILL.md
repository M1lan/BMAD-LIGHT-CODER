---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or opening a merge request
---

# Verification Before Completion

## Overview

Claiming work is done without verification is dishonesty, not efficiency.

**Core principle:** evidence before claims, every time.

## The iron law

```text
NO COMPLETION CLAIM WITHOUT FRESH VERIFICATION EVIDENCE
```

If you have not run the verification command in this session, you cannot claim it passes.

## The gate

Before any status claim or expression of satisfaction:

1. **Identify** the command that proves the claim.
2. **Run** the full command, fresh, in this session.
3. **Read** the full output, the exit code, the failure count.
4. **Verify** the output matches the claim.
5. **Then** state the result, with the evidence.

Skip any step = lying, not verifying.

## Common claims and what they require

| Claim | Required evidence | Not sufficient |
|---|---|---|
| Tests pass | Test command output, 0 failures | "It passed last time" |
| Linter clean | Linter exit 0 | "Looks clean" |
| Build succeeds | Build exit 0 | "Linter passed" |
| Bug fixed | Original repro now passes | "Code changed, assumed fixed" |
| Regression test works | RED → GREEN cycle observed | "Wrote a regression test" |
| Sub-agent finished | `git diff` shows expected changes | "Agent reported success" |
| Requirements met | Line-by-line checklist confirmed | "Tests pass, must be done" |

## Forbidden language

These phrases are signals that you are about to claim without evidence:

- "should work now"
- "probably fixed"
- "seems to pass"
- "Great!", "Perfect!", "Done!" (before running anything)
- "I'm confident"
- "the linter passed" (when the question is about the build)

If you catch yourself typing one, stop. Run the command first.

## Patterns

**Tests:**

```text
Right: [run test command] → [read: 34/34 pass] → "All tests pass."
Wrong: "Should pass now."
```

**Regression tests (RED-GREEN cycle):**

```text
Right: write test → run (must FAIL) → revert fix → run (must FAIL) → restore fix → run (PASS)
Wrong: "I wrote a regression test." (without observing the cycle)
```

**Build:**

```text
Right: [run build] → [exit 0] → "Build passes."
Wrong: "Linter passed." (linter ≠ compiler)
```

**Requirements:**

```text
Right: re-read plan → checklist each item → run verification → report gaps or done.
Wrong: "Tests pass, the phase is complete."
```

**Delegated agent:**

```text
Right: agent reports done → check `git diff` → confirm expected changes → report actual state.
Wrong: trust the agent's "success" report.
```

## Rationalization table

| Excuse | Reality |
|---|---|
| "Should work now" | Run it. |
| "I'm confident" | Confidence ≠ evidence. |
| "Just this once" | No exceptions. |
| "Linter passed" | Linter ≠ compiler ≠ tests. |
| "Agent said success" | Verify independently. |
| "Partial check is enough" | Partial proves nothing. |
| "Different words, rule doesn't apply" | Spirit over letter. |

## When to apply

Always before:

- Any success claim, in any words
- Any expression of satisfaction
- Committing, pushing, opening an MR
- Marking a task done in a plan
- Moving to the next task
- Handing off to another agent

The rule applies to exact phrases, paraphrases, synonyms, and any implication of completion.

## What "verification" looks like in this project

Run the project-defined verifier. Common shapes:

```bash
# Rust
cargo fmt --check && cargo clippy -- -D warnings && cargo nextest run

# TypeScript / Node
pnpm lint && pnpm typecheck && pnpm test

# Python
ruff check . && ruff format --check . && pytest

# Kotlin / JVM
./gradlew detekt ktlintCheck test

# This repo (BMAD)
npm run quality
```

If the project defines a single verify recipe (e.g. `just verify`), use that.

## Bottom line

Run the command. Read the output. Then claim the result.

This is non-negotiable.
