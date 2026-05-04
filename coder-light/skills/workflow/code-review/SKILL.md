---
name: code-review
description: Use when requesting a review on completed work, or when responding to review feedback on your changes
---

# Code Review

## Overview

Two parts to one workflow:

1. **Requesting** — dispatch a fresh reviewer with precise context, not your full session history.
2. **Receiving** — verify each item, push back when wrong, fix one at a time, never agree performatively.

**Core principle:** review is a technical evaluation. No flattery, no performance.

---

## Part A — Requesting a review

### When to request

Mandatory:

- After each task in a multi-task plan
- After a major feature
- Before flipping a draft MR to ready

Useful:

- When stuck (fresh perspective)
- Before a risky refactor (baseline check)
- After fixing a complex bug (regression confidence)

### How to request — sub-agent dispatch

Get the SHAs:

```bash
BASE_SHA=$(git merge-base HEAD origin/main)
HEAD_SHA=$(git rev-parse HEAD)
```

Dispatch a `code-reviewer` sub-agent. Give it exactly:

- **What was implemented** — one sentence.
- **What it should do** — link to the plan or the requirements.
- **Base SHA / Head SHA** — the diff range.
- **Files of interest** — paths.
- **Constraint** — must not change scope; report findings only.

Don't paste your session history. The reviewer needs the work product, not your thought process.

### Acting on feedback

| Severity | Action |
|---|---|
| Critical (security, data loss, broken build) | Fix immediately. |
| Important (correctness, perf, missing tests) | Fix before proceeding. |
| Minor (naming, comments, magic numbers) | Note for later or fix if cheap. |
| Wrong | Push back with technical reasoning. |

### How to request a review on a GitLab MR

```bash
glab mr note --message "@<reviewer> please review when you have a minute"
```

For inline comments, use the GitLab UI or:

```bash
glab api projects/:fullpath:/merge_requests/<iid>/discussions \
  --method POST -f body="Suggest extracting <thing> here"
```

---

## Part B — Receiving review feedback

### Response pattern

```text
1. READ      complete feedback without reacting
2. UNDERSTAND restate the requirement in your own words, or ask
3. VERIFY    check against the actual codebase
4. EVALUATE  is it technically right for this codebase?
5. RESPOND   technical acknowledgment OR reasoned pushback
6. IMPLEMENT one item at a time, test each
```

### Forbidden responses

Never:

- "You're absolutely right!"
- "Great point!" / "Excellent feedback!"
- "Thanks for catching that!" / any thanks
- "Let me implement that now" (before verifying)

Instead:

- Restate the technical requirement.
- Ask a clarifying question.
- Push back with technical reasoning if wrong.
- Or: just fix it. Actions over words. The diff shows you heard the feedback.

If you catch yourself typing "Thanks", delete it. State the fix.

### Handling unclear feedback

If any item is unclear, **stop**. Don't implement anything yet. Ask.

```text
Wrong: implement items 1, 2, 3, 6 now and ask about 4 and 5 later
Right: "I understand items 1, 2, 3, 6. Need clarification on 4 and 5 before proceeding."
```

Items often relate. Partial understanding = wrong implementation.

### When to push back

Push back when the suggestion:

- Breaks existing functionality
- Violates YAGNI (the feature isn't used)
- Is technically wrong for the stack
- Conflicts with a prior architectural decision
- Comes from a reviewer missing context

How to push back:

- Technical reasoning, not defensiveness.
- Reference working tests or code: `src/auth.rs:42-60` shows the constraint.
- Ask specific questions.

### YAGNI check for "implement properly" requests

If a reviewer asks for a "proper" implementation of something:

```bash
rg -n '<thing>\(' --type <lang>
```

If it's unused, propose removing it (`YAGNI`) before implementing.

### Acknowledging correct feedback

```text
Right: "Fixed in src/auth.rs:54. Was off-by-one in the loop bound."
Right: "Good catch — `clearLayers` and `clearFullLayers` differed. Renamed to clearLayers."
Right: just push the fix.

Wrong: "You're absolutely right!"
Wrong: "Thanks for catching that!"
```

### Gracefully correcting your own pushback

If you pushed back and were wrong:

```text
Right: "You were right. I checked `src/auth.rs:42` and the constraint is the other way. Fixing."
Wrong: long apology, defending the pushback, over-explaining.
```

State the correction. Move on.

---

## Quick reference

| Situation | Action |
|---|---|
| Reviewer flags critical | Fix now. |
| Reviewer flags important | Fix before next task. |
| Reviewer asks for "proper" feature | YAGNI check first. |
| Reviewer is wrong | Push back with citation: `src/x.rs:42`. |
| Multi-item feedback, some unclear | Clarify first, implement second. |
| You pushed back and were wrong | One-line correction, fix it. |

## Pairs with

- `../finishing-a-branch/SKILL.md` — review happens before draft → ready.
- `../parallel-agents/SKILL.md` — when a sub-agent does the implementation, dispatch a separate reviewer sub-agent to check its diff.
- `../../core/verification-before-completion/SKILL.md` — every "fixed" claim needs a fresh test run.

## Bottom line

Review is technical. Verify before agreeing, verify before disagreeing. No flattery, no thanks, no performance.
