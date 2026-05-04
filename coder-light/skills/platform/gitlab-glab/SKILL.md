---
name: gitlab-glab
description: Use when interacting with GitLab on gitlab.com/ista-se via the glab CLI — branches, MRs, pipelines, approvals, and ista-se conventions
---

# GitLab + glab (ista-se)

## Overview

Our remote is `gitlab.com/ista-se/<repo>`. We use `glab` for everything CLI-driven: open MRs, fetch pipelines, leave notes, merge.

**Never `gh`. Never GitHub.**

## Setup

```bash
brew install glab

glab auth login --hostname gitlab.com   # uses a personal access token
glab config set host gitlab.com
glab config set api_protocol https
glab config set --global remote_alias origin
```

Verify:

```bash
glab auth status
glab repo view --web   # opens the current repo's GitLab page
```

## Branch and commit conventions

| Item | Rule |
|---|---|
| Default branch | `main` |
| Feature branch | `feature/<short-slug>` |
| Bugfix branch | `fix/<short-slug>` |
| Release branch | `release/<version>` |
| Commit message | Conventional Commits: `feat(scope): subject` |
| MR title | Same as the squashed commit subject (Conventional Commit) |
| MR target | `main` (unless explicitly otherwise) |

## Day-to-day glab cheatsheet

| Need | Command |
|---|---|
| Clone | `glab repo clone ista-se/<repo>` |
| Status of current branch's MR | `glab mr view` |
| Diff of MR | `glab mr diff` |
| List my MRs | `glab mr list --assignee=@me` |
| Check out an MR locally | `glab mr checkout <iid>` |
| Open the MR in a browser | `glab mr view --web` |
| Comment | `glab mr note <iid> -m "<text>"` |
| Approve | `glab mr approve <iid>` |
| Merge (squash) | `glab mr merge <iid> --squash --remove-source-branch` |
| Pipeline status | `glab ci status` |
| Watch latest pipeline for branch | `glab ci view -b "$(git branch --show-current)"` |
| Trace a job log | `glab ci trace <job-id>` |
| Retry a failed job | `glab ci retry <job-id>` |
| Issues for current repo | `glab issue list` |
| Open an issue | `glab issue create -t "<title>" -d "<body>"` |

## Opening a merge request

Generate a runtime MR description from the template (gitignored, kept out of the tree):

```bash
cp coder-light/templates/mr-description.md ./.mr.md
# fill in summary, why, test evidence
rg -q '^\.mr\.md$' .gitignore || printf '\n.mr.md\n' >> .gitignore
```

Then push and open the MR:

```bash
git push -u origin "$(git branch --show-current)"

glab mr create \
  --target-branch main \
  --title "feat(auth): rotate MR tokens on expiry" \
  --description-from-file ./.mr.md \
  --remove-source-branch \
  --squash-before-merge
```

For draft MRs (work in progress, want pipeline feedback):

```bash
glab mr create --draft ...
glab mr update --ready <iid>     # flip to ready when reviewers should look
```

## Approving and merging

```bash
glab mr approve <iid>
glab mr merge <iid> --squash --remove-source-branch
```

`--squash` is the default for ista-se: one MR == one commit on `main`. The MR title becomes the commit subject. Keep the MR title in Conventional Commits form.

## CI / pipelines

We run pipelines per MR. The MR cannot merge until pipelines are green and required approvals are in.

```bash
glab ci status                           # current
glab ci view -b "$(git branch --show-current)"   # latest for this branch
glab ci trace <job-id>                   # full job log
glab ci retry <job-id>                   # retry a transient failure
```

If a job is flaky often, that's a bug in the job, not a license to retry indefinitely. Open an issue.

## Pipeline triggers

- Push to a branch with an open MR → MR pipeline.
- Push to `main` → main pipeline (release artifacts, Docker images).
- Manual job: `glab ci run --variables KEY=VALUE`.
- Skip CI (rare): `[skip ci]` in the commit message — only for docs-only changes.

## Common pitfalls

| Pitfall | Fix |
|---|---|
| Using `gh pr` | Forbidden. Use `glab mr`. |
| MR title not Conventional Commits | Squash will produce a bad commit on `main`. Fix the title. |
| Force-pushing the source branch after approvals | Approvals reset (good — re-review). Communicate. |
| Force-pushing `main` | Forbidden. Use revert MRs. |
| Long-lived branches | Diverge from `main`. Rebase early, often. |
| MRs that bundle unrelated changes | Split. One MR per concern. |
| Skipping CI without a docs-only reason | Don't. |

## Working with the ista-se group

```bash
glab repo list --group ista-se        # list group repos
glab repo view ista-se/<repo>         # view a specific repo
glab issue list -R ista-se/<repo>     # cross-repo
```

## Hooks worth setting

```bash
# .git/hooks/pre-push   (or use a tool like lefthook / pre-commit)
#!/usr/bin/env bash
set -Eeuo pipefail
just verify   # or the project's verification command
```

So you don't push red branches.

## Pairs with

- `../../workflow/finishing-a-branch/SKILL.md` — uses glab to push and open the MR.
- `../../workflow/code-review/SKILL.md` — uses glab to leave notes and approvals.
- `../../core/verification-before-completion/SKILL.md` — pipelines must be green before flipping draft → ready.

## Bottom line

`glab` only. `gitlab.com/ista-se/<repo>`. Conventional Commit MR titles. Squash-merge to `main`. Pipelines green before ready.
