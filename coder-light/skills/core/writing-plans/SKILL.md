---
name: writing-plans
description: Use when you have a multi-step task or spec, before touching code
---

# Writing Plans

## Overview

Write a plan that an engineer with no project context could execute. Document which files to touch, what to write, what to test, what command to run, what output to expect.

**Core principle:** every step is bite-sized, every command is exact, every code block is complete.

DRY. YAGNI. TDD. Frequent commits.

## When to write a plan

- Task touches 3+ files
- Task has 3+ logical phases
- You will hand the work off to a sub-agent
- The change is risky enough that you want to think before you type

For one-line fixes, skip the plan.

## Where to save

```text
plans/YYYY-MM-DD-<feature-slug>.md
```

If the spec covers multiple independent subsystems, split it into one plan per subsystem.

## Use the template

Start from `coder-light/templates/plan.md`. Don't reinvent the structure.

## Header (required)

```markdown
# {{Feature}} Implementation Plan

**Goal:** one sentence.

**Approach:** 2–3 sentences on architecture.

**Stack:** key tech and versions.

**Verification:** the single command that proves it works.
```

## Files-touched section

Map out the file changes before defining tasks. This locks in the decomposition.

- One file = one responsibility.
- Files that change together live together.
- Follow existing project layout. If a file you touch has grown unwieldy, splitting it is a fair task.
- Smaller, focused files are easier to reason about than one mega-file.

## Bite-sized task granularity

Each step is one action that takes a couple of minutes:

- Write the failing test — step
- Run it, watch it fail — step
- Write the minimal implementation — step
- Run the tests, watch them pass — step
- Commit — step

## Task block shape

````markdown
### Task N: <component>

**Files:**

- Create: `exact/path/file.rs`
- Modify: `exact/path/existing.rs:120-180`
- Test: `tests/exact/path_test.rs`

- [ ] **Step 1: Write the failing test**

```rust
#[test]
fn does_the_thing() { /* ... */ }
```

- [ ] **Step 2: Run the test, watch it fail**

```bash
cargo nextest run does_the_thing
```

Expected: FAIL with "function not defined".

- [ ] **Step 3: Implement minimally**

```rust
pub fn thing() { /* ... */ }
```

- [ ] **Step 4: Run the test, watch it pass**

```bash
cargo nextest run does_the_thing
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add tests/path src/path
git commit -m "feat(thing): add the thing"
```
````

## No placeholders

These are plan failures. Never write them:

- `TBD`, `TODO`, "implement later", "fill in details"
- "Add appropriate error handling" / "handle edge cases" (without showing how)
- "Write tests for the above" (without the actual test)
- "Similar to Task N" (repeat the code; the sub-agent may read tasks out of order)
- Steps that describe *what* without showing *how*
- References to types/functions/methods not defined in any task

## Self-review

After writing the plan, walk back through with fresh eyes:

1. **Spec coverage.** For every requirement in the spec, point at the task that implements it. List gaps.
2. **Placeholder scan.** Search for `TBD`, `TODO`, "later", "etc.", vague phrases. Fix them.
3. **Type consistency.** Method/type names match across tasks (`clearLayers()` in Task 3 vs `clearFullLayers()` in Task 7 is a bug).
4. **Verification step.** Each task has a way to confirm it worked.

If you find a missing requirement, add a task. No re-review needed — just fix and move on.

## Status markers

Use these inline checkboxes inside tasks:

| Marker | Meaning |
|---|---|
| `[ ]` | not started |
| `[~]` | in progress / blocked |
| `[x]` | done |
| `[!]` | failed; stop and re-plan |

## Execution handoff

After saving the plan:

```text
Plan saved at plans/<filename>.md.

Two execution options:
  1. Inline — execute tasks here in this session (use ../executing-plans/SKILL.md).
  2. Sub-agent — dispatch a fresh sub-agent per task (use ../../workflow/parallel-agents/SKILL.md).

Which?
```

## Pairs with

- `../executing-plans/SKILL.md` — turns the plan into work.
- `../../workflow/parallel-agents/SKILL.md` — sub-agent handoff.
- `../test-driven-development/SKILL.md` — every implementation step is RED → GREEN → REFACTOR.

## Bottom line

A plan that an engineer with zero context can execute, end-to-end, without asking a single clarifying question.
