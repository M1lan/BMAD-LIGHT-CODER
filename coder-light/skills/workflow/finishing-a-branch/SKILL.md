---
name: finishing-a-branch
description: Use when implementation is complete and tests pass, to decide how to integrate the work — merge, MR, keep, or discard
---

# Finishing a Branch

## Overview

Verify tests, present four clear options, execute the chosen one, clean up.

This is the GitLab variant. We use `glab` against `gitlab.com/ista-se/`. **Never `gh`.** **Never GitHub.**

## Step 1 — Verify tests

Before offering options, run the project's verification command:

```bash
# Pick the right one for the project
pnpm test
cargo nextest run
pytest -q
./gradlew test
just verify     # if the project provides one
```

If the suite fails, stop:

```text
Tests failing (N failures). Must fix before completing.

<failures>

Cannot proceed with merge or MR until tests pass.
```

Don't move on to Step 2.

## Step 2 — Determine base branch

```bash
git symbolic-ref --short refs/remotes/origin/HEAD | sed 's@^origin/@@'
# falls back to main / master detection
```

If unclear, ask:

```text
This branch split from `main`. Correct?
```

## Step 3 — Present the four options

Print exactly:

```text
Implementation complete. What now?

1. Merge back to <base> locally
2. Push and open a Merge Request
3. Keep the branch as-is (handle it later)
4. Discard this work

Which?
```

No explanation. Keep it terse.

## Step 4 — Execute the choice

### Option 1 — Merge locally

```bash
git checkout <base>
git pull --ff-only
git merge --no-ff <feature-branch>

# Re-run tests on the merged state
<verify command>

# If green
git branch -d <feature-branch>
```

Then go to Step 5 (cleanup worktree).

### Option 2 — Push and open an MR

First, generate a runtime MR description from the template:

```bash
# Adjust the source path to wherever coder-light is installed
# (commonly .agent/coder-light/ — see docs/install.md).
cp .agent/coder-light/templates/mr-description.md ./.mr.md
# edit ./.mr.md to fill in summary, why, test evidence -- it is gitignored
printf '\n.mr.md\n' >> .gitignore   # one-time, if not already ignored
```

Then push and open the MR:

```bash
git push -u origin <feature-branch>

glab mr create \
  --target-branch <base> \
  --title "<conventional-commit subject>" \
  --description-from-file ./.mr.md \
  --remove-source-branch \
  --squash-before-merge
```

If the project requires draft MRs:

```bash
glab mr create --draft ...
glab mr update --ready <mr-iid>     # when ready for review
```

Sanity-check the MR exists:

```bash
glab mr view --web   # opens browser, optional
glab mr diff         # see what's in the MR from the CLI
```

Worktree stays. Go to Step 5 only if `--keep-worktree` is not desired.

### Option 3 — Keep as-is

Print:

```text
Keeping branch <name>. Worktree preserved at <path>.
```

Don't clean up the worktree.

### Option 4 — Discard

Confirm first. Require an exact typed token:

```text
This will permanently delete:
  - branch <name>
  - commits: <list of SHAs>
  - worktree at <path>

Type `discard` to confirm.
```

Wait for the literal `discard`. Anything else: abort.

If confirmed:

```bash
git checkout <base>
git branch -D <feature-branch>
git push origin --delete <feature-branch>   # only if it was already pushed
```

Then Step 5.

## Step 5 — Cleanup worktree

For Options 1 and 4:

```bash
git worktree list | rg "$(git rev-parse --show-toplevel)/.worktrees/<feature>"
git worktree remove .worktrees/<feature>
```

For Option 2 (MR open) and Option 3 (keep): leave the worktree alone.

## Quick reference

| Option | Merge | Push | Open MR | Keep worktree | Delete branch |
|---|---|---|---|---|---|
| 1. Merge locally | yes | no | no | no | yes |
| 2. Push + MR | no | yes | yes | yes | no |
| 3. Keep | no | no | no | yes | no |
| 4. Discard | no | no | no | no | yes (force) |

## Iron rules

- Never `--force-push` to `main`/`master`.
- Never delete work without a typed `discard` confirmation.
- Never open the MR before the suite is green.
- Never use `gh` in this project. We are on GitLab.
- All MRs target a branch under `gitlab.com/ista-se/<repo>`.

## glab cheatsheet

| Need | Command |
|---|---|
| Show MR for current branch | `glab mr view` |
| Diff of MR | `glab mr diff` |
| Note (comment) on MR | `glab mr note <iid> -m "<text>"` |
| Mark draft → ready | `glab mr update --ready <iid>` |
| Approve | `glab mr approve <iid>` |
| Pipeline status | `glab ci status` |
| Watch latest pipeline | `glab ci view -b <branch>` |

See `../../platform/gitlab-glab/SKILL.md` for the full ista-se GitLab workflow.

## Common mistakes

| Mistake | Fix |
|---|---|
| Skipping test verification | Always Step 1 first. |
| Open-ended "what now?" | Present the four options exactly. |
| Auto-cleaning worktree on Option 2 or 3 | Only clean for Option 1 and 4. |
| No confirmation for discard | Require typed `discard`. |
| Using `gh` instead of `glab` | This is GitLab. Use `glab`. |

## Pairs with

- `../using-git-worktrees/SKILL.md` — set up the worktree this skill cleans up.
- `../code-review/SKILL.md` — request review before flipping draft → ready.
- `../../platform/gitlab-glab/SKILL.md` — full glab reference.

## Bottom line

Verify. Offer four options. Execute one. Clean up the worktree only when the work is integrated or discarded.
