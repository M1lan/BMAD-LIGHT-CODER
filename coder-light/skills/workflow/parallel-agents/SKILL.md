---
name: parallel-agents
description: Use when delegating work to one or more sub-agents — either dispatching parallel agents for independent tasks, or running task-by-task with reviewer sub-agents
---

# Parallel Agents

## Overview

Two delegation patterns:

1. **Parallel dispatch** — N independent problems. Send one agent per problem, run them concurrently, integrate the results.
2. **Sub-agent-driven development** — one task at a time. Implementer sub-agent → spec reviewer sub-agent → code-quality reviewer sub-agent → mark task done. Repeat.

**Core principle:** sub-agents start with a fresh context. You construct exactly what they need. Never inherit your session history. This keeps them focused and preserves your context for coordination.

---

## Pattern A — Parallel dispatch

### When to use

- 3+ test files failing with different root causes
- Multiple subsystems broken independently
- Each problem can be understood without the others
- No shared state between investigations

### When NOT to use

- Failures are related (fixing one might fix all)
- You don't yet know what's broken (still exploratory)
- Agents would step on each other's files
- The problems require holistic system understanding

### The recipe

1. **Identify independent domains.** Group failures by what's broken: file A is timing, file B is config, file C is logic. Each is independent.
2. **Write one focused brief per agent.** Each gets:
   - Specific scope — one file or subsystem.
   - Clear goal — make these tests pass.
   - Constraints — don't change unrelated code.
   - Expected output — summary of what was found and what changed.
3. **Dispatch in parallel.** Run them concurrently.
4. **Review and integrate.** Read each summary. Run the full suite. Resolve any file conflicts.

### Brief shape

```text
Fix the 3 failing tests in src/agents/agent-tool-abort.test.ts:

  - "should abort tool with partial output capture"
  - "should handle mixed completed and aborted tools"
  - "should track pendingToolCount"

These look like timing / race conditions.

Your task:
  1. Read the test file. Understand what each test verifies.
  2. Identify root cause: timing, or actual bug?
  3. Fix by:
     - Replacing arbitrary timeouts with event-based waiting.
     - Fixing implementation bugs if found.
  4. Do NOT increase timeouts as a "fix".
  5. Do NOT touch other files.

Return:
  - Root cause.
  - Files changed (paths + line ranges).
  - Verification command and its output.
```

### Common mistakes

| Mistake | Fix |
|---|---|
| Brief too broad ("fix all the tests") | One file or subsystem per agent. |
| No context | Paste error messages and test names. |
| No constraints | Explicit "don't change X". |
| Vague output | "Return summary, files changed, verification command." |

### After they return

1. Read each summary.
2. `git diff` to confirm scope.
3. Run the full suite.
4. Spot-check critical paths — agents make systematic errors silently.

---

## Pattern B — Sub-agent-driven development

### When to use

You have a written plan (`../../core/writing-plans/SKILL.md`) with mostly-independent tasks, and want to stay in this session while a fresh sub-agent handles each task.

### The flow per task

```text
plan task → dispatch implementer → fields questions → implements + tests + commits + self-reviews
         → dispatch spec-reviewer → spec compliant? if no, implementer fixes
         → dispatch quality-reviewer → quality OK? if no, implementer fixes
         → mark task [x] in plan
         → next task
```

### The three sub-agents

| Role | Goal | Input | Output |
|---|---|---|---|
| Implementer | Make the task green | Task text + scene-setting context | Files changed, tests passing, summary |
| Spec reviewer | Confirm output matches the spec | Task text + diff (BASE..HEAD) | Spec issues only (missing or extra) |
| Quality reviewer | Confirm code quality | Diff (BASE..HEAD) | Strengths + issues by severity |

Don't merge spec review and quality review. Spec review first. Then quality. The two stages catch different things.

### Implementer status codes

The implementer reports one of four:

| Status | Meaning | Your move |
|---|---|---|
| `DONE` | Work and self-review complete | Dispatch spec reviewer. |
| `DONE_WITH_CONCERNS` | Done but flagged a doubt | Read concerns. Address if real. Then proceed. |
| `NEEDS_CONTEXT` | Missing info | Provide it, re-dispatch. |
| `BLOCKED` | Cannot proceed | Triage: more context? more capable model? smaller chunks? plan wrong? |

Never silently re-dispatch the same agent on the same task without changing something.

### Model selection

Use the cheapest model that handles the task:

| Task complexity | Model |
|---|---|
| 1–2 files, complete spec, mechanical | small / fast |
| Multi-file, integration concerns | standard |
| Architecture / broad reasoning / review | most capable |

### Iron rules

- Never start implementation on `main`/`master` without explicit consent.
- Never skip a review (spec OR quality).
- Never start quality review while spec issues are open.
- Never dispatch two implementer agents on overlapping files in parallel — they will conflict.
- Never let the implementer's self-review replace the reviewer agents.
- Never make the sub-agent read the whole plan file. Hand it the task text directly.

---

## Quick reference

| You need to ... | Pattern |
|---|---|
| Fix three unrelated failing test files | A — parallel dispatch |
| Implement a 12-task plan, one task at a time, with reviews | B — sub-agent-driven |
| Investigate one bug | Don't use this skill, just think |
| Write a plan | `../../core/writing-plans/SKILL.md` |

## Pairs with

- `../using-git-worktrees/SKILL.md` — each parallel agent gets its own worktree.
- `../code-review/SKILL.md` — the reviewer sub-agents follow the request/receive pattern.
- `../../core/writing-plans/SKILL.md` — produces the plan B executes.
- `../../core/verification-before-completion/SKILL.md` — verify each agent's claim with a fresh `git diff` before trusting it.

## Bottom line

Each sub-agent gets fresh context, a focused brief, and an explicit expected output. You stay the coordinator and verify their work before integrating it.
