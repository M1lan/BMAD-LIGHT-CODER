# BMAD coder-light

A skills-first, solo-dev variant of BMAD. Strips the agile/PM/PRD/research apparatus and keeps only what helps a single engineer ship code with an AI.

Source tree: `coder-light/` (in this repo).

## When to use it

| Situation                                                            | Use            |
| -------------------------------------------------------------------- | -------------- |
| Solo dev, fresh repo, no stakeholders                                | **coder-light** |
| Prototype, internal tool, side project                               | **coder-light** |
| You want TDD + debugging + verification + MR hygiene, no ceremony     | **coder-light** |
| Multi-person team, paying users, PRD/UX/sprint workflows             | full BMAD (`bmm`) |

Decision tree: `coder-light/docs/when-to-use.md`.

## How it works

- **Skills, not personas.** A flat tree of imperative `SKILL.md` files. The AI loads them on demand. No PM, architect, or UX as separate agents.
- **No ceremony.** No sprints, epics, stories, retrospectives, PRD validation cycles.
- **Just-in-time loading.** The agent walks the tree and pulls the `SKILL.md` it needs for the current task. Skills are not preloaded.
- **`AGENTS.md` is the contract.** Sits at the project root, lists the non-negotiable rules. Symlinked from `coder-light/AGENTS.md`.
- **Strict tooling policy.** GitLab + `glab` only (never `gh`). GNU tools from Homebrew (`rg`, `fd`, `bat`, `jq`). Bash 5.3+ with strict mode. `uv` for Python.

Reference: `coder-light/README.md`, `coder-light/AGENTS.md`.

## Layout

```text
coder-light/
  README.md
  AGENTS.md            non-negotiable rules for agents in a coder-light project
  skills/
    core/              test-driven-development, systematic-debugging,
                       verification-before-completion, writing-plans,
                       executing-plans, writing-skills
    workflow/          using-git-worktrees, finishing-a-branch,
                       code-review, parallel-agents
    languages/         kotlin, java, typescript, python, rust, bash-5.3
    platform/          gitlab-glab
  templates/           plan.md, skill.md, mr-description.md
  docs/                when-to-use.md, install.md
```

17 `SKILL.md` files total.

## Install (per project)

Three install methods. All from `coder-light/docs/install.md`.

### Option 1 — copy the tree

```bash
git clone --depth=1 https://gitlab.com/ista-se/BMAD-METHOD.git /tmp/bmad
mkdir -p .agent
cp -r /tmp/bmad/coder-light .agent/
ln -s .agent/coder-light/AGENTS.md AGENTS.md
git add .agent AGENTS.md
git commit -m "chore: bootstrap with bmad-coder-light"
```

### Option 2 — git submodule (auto-update path)

```bash
git submodule add https://gitlab.com/ista-se/BMAD-METHOD.git .agent/upstream
ln -s upstream/coder-light .agent/coder-light
ln -s .agent/coder-light/AGENTS.md AGENTS.md
git add .agent AGENTS.md .gitmodules
git commit -m "chore: add bmad-coder-light as submodule"

# Bump later:
git submodule update --remote --merge .agent/upstream
```

### Option 3 — sparse checkout (only the `coder-light/` tree)

```bash
git clone --filter=blob:none --no-checkout https://gitlab.com/ista-se/BMAD-METHOD.git .agent/upstream
cd .agent/upstream
git sparse-checkout init --cone
git sparse-checkout set coder-light
git checkout main
cd ../..
ln -s upstream/coder-light .agent/coder-light
ln -s .agent/coder-light/AGENTS.md AGENTS.md
```

## Wire it to your AI tool

| Tool          | Command                                                              |
| ------------- | -------------------------------------------------------------------- |
| Claude Code   | `ln -s "$PWD/.agent/coder-light/skills" ~/.claude/skills/coder-light` |
| Forge         | `mkdir -p .forge/skills && ln -s "$PWD/.agent/coder-light/skills" .forge/skills/coder-light` |
| Cursor / OpenCode / generic | Picks up `AGENTS.md` at the repo root automatically. |

## Verify

```bash
test -f AGENTS.md && echo "AGENTS.md present"
test -d .agent/coder-light/skills && echo "skills tree present"
fd SKILL.md .agent/coder-light/skills | wc -l   # expect 17
```

Then ask the agent: *"What skills are available under coder-light?"*

## The daily loop

`coder-light/AGENTS.md` defines the workflow. Every task obeys these rules:

1. **Read before edit.** Never modify a file you haven't read this session.
2. **Plan first** for any task touching ≥3 files or ≥3 logical steps. Save to `plans/YYYY-MM-DD-<slug>.md`. Skill: `skills/core/writing-plans/SKILL.md`. Template: `templates/plan.md`.
3. **Test-first.** Production code requires a failing test that you watched fail. Skill: `skills/core/test-driven-development/SKILL.md`.
4. **Root-cause debugging.** Four phases (investigate → pattern → hypothesis → fix). No symptom patches. Skill: `skills/core/systematic-debugging/SKILL.md`.
5. **Verify before claiming done.** Run the verification command this session, paste output. Skill: `skills/core/verification-before-completion/SKILL.md`.
6. **Conventional Commits.** Every commit. Example: `feat(auth): rotate MR tokens on expiry`.
7. **GitLab MRs via `glab`.** Never `gh`. Template: `templates/mr-description.md`. Skill: `skills/platform/gitlab-glab/SKILL.md`.

For multi-feature work: one feature per worktree (`skills/workflow/using-git-worktrees/SKILL.md`), close out with `skills/workflow/finishing-a-branch/SKILL.md`.

For per-language conventions (lint, test, verify recipe, pitfalls): the matching `skills/languages/<lang>/SKILL.md`.

## Update / remove

| Install method | Update                                                          |
| -------------- | --------------------------------------------------------------- |
| Copy           | `rm -rf .agent/coder-light && cp -r /tmp/bmad/coder-light .agent/` (after `git pull` in `/tmp/bmad`) |
| Submodule      | `git submodule update --remote --merge .agent/upstream`         |
| Sparse         | `cd .agent/upstream && git pull`                                |

Remove cleanly:

```bash
rm -rf .agent
rm -f AGENTS.md
git add -A && git commit -m "chore: drop bmad-coder-light"
```

`plans/`, `.worktrees/`, and your code stay put. coder-light is intentionally discardable.

## TL;DR

`AGENTS.md` (rules) + `skills/` (loaded on demand) + `templates/` (plan, skill, MR), dropped into `.agent/coder-light/` of any repo. Symlink `AGENTS.md` to the repo root and point your AI's skill loader at `skills/`. The agent then plans → tests → implements → verifies → MRs, under the GitLab + GNU + Bash 5.3 + `uv` policy from `coder-light/AGENTS.md`.
