---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from the current workspace, or before executing a multi-task plan
---

# Using Git Worktrees

## Overview

Git worktrees give you a separate working directory for a separate branch, sharing one repository. You can swap between them with `cd`, no stash dance, no broken state.

**Core principle:** systematic directory selection + ignore-status check = reliable isolation.

## Directory selection

Try in order:

1. `.worktrees/` (project-local, hidden) — preferred.
2. `worktrees/` (project-local, visible) — fine.
3. `~/.local/state/worktrees/<repo>/` — global fallback.

If `.worktrees/` and `worktrees/` both exist, `.worktrees/` wins.

If neither exists, ask once: which do you want? Don't guess.

## Safety check (project-local only)

Before creating a worktree under `.worktrees/` or `worktrees/`, verify the directory is gitignored:

```bash
git check-ignore -q .worktrees 2>/dev/null && echo IGNORED || echo NOT_IGNORED
```

If not ignored:

1. Add the line to `.gitignore`.
2. Commit it.
3. Then create the worktree.

Skipping this step pollutes `git status` and risks committing the worktree contents.

For the global fallback under `~/.local/state/`, no `.gitignore` work needed — it's outside any repo.

## Create the worktree

```bash
project=$(basename "$(git rev-parse --show-toplevel)")
branch="feature/<slug>"
path=".worktrees/${branch#*/}"   # or chosen location

git worktree add "$path" -b "$branch"
cd "$path"
```

## Project bootstrap

Auto-detect and run the install step:

```bash
[ -f package.json ]   && pnpm install     # or npm/yarn
[ -f Cargo.toml ]     && cargo build
[ -f pyproject.toml ] && uv sync || uv pip install -e .
[ -f go.mod ]         && go mod download
[ -f build.gradle.kts ] || [ -f build.gradle ] && ./gradlew build -x test
[ -f pom.xml ]        && mvn -DskipTests install
```

## Verify clean baseline

Before writing a single line of new code, run the project's tests in the worktree.

```bash
# pick the right one for the project
pnpm test
cargo nextest run
pytest -q
./gradlew test
```

If they fail, **stop**. Report the failures. Don't begin new work in a worktree that was already broken.

If they pass, log:

```text
Worktree ready at <abs path>
Tests passing: <N>/0 failures
Ready to implement <feature>.
```

## Quick reference

| Situation | Action |
|---|---|
| `.worktrees/` exists | Use it (verify ignored). |
| `worktrees/` exists | Use it (verify ignored). |
| Both exist | `.worktrees/` wins. |
| Neither | Ask user. |
| Not ignored | Add to `.gitignore`, commit, then proceed. |
| Tests fail at baseline | Stop, report, ask. |
| No `package.json`/`Cargo.toml`/etc. | Skip dep install. |

## Common mistakes

| Mistake | Fix |
|---|---|
| Skipping ignore check | Always `git check-ignore` for project-local. |
| Hardcoding setup commands | Detect from project files. |
| Proceeding past failing baseline | Report and stop. |

## Pairs with

- `../finishing-a-branch/SKILL.md` — cleans up the worktree after merge.
- `../parallel-agents/SKILL.md` — sub-agents work in their own worktrees so they don't fight over files.
- `../../core/writing-plans/SKILL.md` — usually the plan is what motivates a fresh worktree.

## Bottom line

A worktree per feature. Verify it's ignored. Verify it's green at baseline. Then start.
