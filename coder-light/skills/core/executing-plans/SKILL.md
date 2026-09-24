---
name: executing-plans
description: Use when you have a written implementation plan and want to execute it task-by-task in the current session
---

# Executing Plans

## Overview

Load a plan, review it critically, execute each task, mark progress, verify, hand off to `finishing-a-branch` at the end.

**Core principle:** the plan is the contract. Don't improvise around it; if it's wrong, fix the plan first.

## The process

### Step 1 — Load and review

1. Read the plan file end-to-end.
2. Review critically: are there gaps, ambiguities, missing types, unrealistic verification steps?
3. **Concerns?** Stop. Surface them. Update the plan or get clarification before starting.
4. **No concerns?** Build a todo list (one entry per task), and start.

### Step 2 — Execute each task

For every task:

1. Mark `[~]` (in progress).
2. Follow each step exactly. The steps are bite-sized; don't fold two into one.
3. Run the verification command for each step where one is specified. Watch the output.
4. If a step requires another skill (TDD, debugging), invoke that skill — don't shortcut it.
5. Commit at the end of the task using the message in the plan.
6. Mark `[x]` (done).

### Step 3 — Finish

When every task is `[x]`:

- Run the plan's overall verification command. It must pass.
- Invoke `../../workflow/finishing-a-branch/SKILL.md`.

## When to stop and ask

Stop executing immediately if:

- A blocker appears (missing dep, failing test you can't diagnose in 2 attempts, an instruction you don't understand).
- The plan has a critical gap that prevents starting the next task.
- A verification step fails repeatedly.

Mark the task `[~]` or `[!]`, write what you tried, and ask. Don't guess.

## When to revisit the plan

Return to Step 1 (review) when:

- The user updates the plan based on feedback.
- The fundamental approach needs rethinking (often a signal to invoke `../systematic-debugging/SKILL.md`).

## Iron rules

- Never start implementation on the default branch (`main`/`master`) without explicit consent.
- Never skip a verification step listed in the plan.
- Never reorder tasks unless the plan explicitly says they're independent.
- Never delete or rewrite tests to make them pass.

## Quick reference

| Situation | Action |
|---|---|
| Step says "watch it fail", but it passes | Fix the test (it tests existing behaviour). |
| Step's expected output is wrong but the actual output is correct | Update the plan; don't lie about the outcome. |
| Verification fails twice in a row | Stop, return to Phase 1 of `../systematic-debugging/SKILL.md`. |
| Task touches files outside its `Files:` block | Stop. Plan was wrong. Update or escalate. |

## Pairs with

- `../writing-plans/SKILL.md` — produced the plan.
- `../test-driven-development/SKILL.md` — RED-GREEN-REFACTOR inside each task.
- `../verification-before-completion/SKILL.md` — every "done" claim needs evidence.
- `../../workflow/finishing-a-branch/SKILL.md` — close the work out.

## Bottom line

Read it. Verify it. Execute it. Don't improvise.
