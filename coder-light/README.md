# BMAD-coder-light

A skills-first, solo-dev variant of BMAD. Strips the agile/PM/PRD/research apparatus and keeps only what helps a single engineer ship code with an AI.

## When to use this instead of full BMAD

| Situation | Use |
|---|---|
| Greenfield, solo, on your laptop, no stakeholders | **coder-light** |
| Prototype, internal tool, side project | **coder-light** |
| You need PRDs, epics, sprints, multi-role teams | full BMAD (`bmm`) |
| You need PMs, UX designers, architects as personas | full BMAD (`bmm`) |
| You need code discipline (TDD, debugging, reviews) without ceremony | **coder-light** |

Decision tree: [docs/when-to-use.md](docs/when-to-use.md).

## What's in here

```text
coder-light/
  README.md                this file
  AGENTS.md                rules an AI agent must follow inside a coder-light project
  skills/
    core/                  the discipline core (apply on every task)
      test-driven-development/
      systematic-debugging/
      verification-before-completion/
      writing-plans/
      executing-plans/
      writing-skills/
    workflow/              day-to-day flow
      using-git-worktrees/
      finishing-a-branch/
      code-review/
      parallel-agents/
    languages/             per-language playbooks
      kotlin/
      java/
      typescript/
      python/
      rust/
      bash-5.3/
    platform/
      gitlab-glab/         ista-se GitLab workflow (never GitHub)
  templates/
    plan.md                bite-sized implementation plan
    skill.md               new SKILL.md scaffold
    mr-description.md      GitLab merge request description
  docs/
    when-to-use.md         decision: full BMAD vs coder-light
    install.md             drop coder-light into a new solo project
```

## Install (per-project)

In a fresh repo:

```bash
git clone --depth=1 https://gitlab.com/ista-se/BMAD-METHOD.git /tmp/bmad
mkdir -p .agent
cp -r /tmp/bmad/coder-light .agent/
ln -s .agent/coder-light/AGENTS.md AGENTS.md   # optional: surface rules to your agent
```

Then point your AI assistant at `.agent/coder-light/`. See [docs/install.md](docs/install.md) for IDE-specific bootstraps.

## Design rules

- **Skills > agents.** A solo dev does not need a PM, an architect, and a UX designer as separate personas. They need disciplined skills they can invoke.
- **No ceremony.** No sprints, no retrospectives, no story points, no epics, no PRD validation cycles.
- **Imperative, terse markdown.** No marketing voice, no hedging, no filler.
- **Real tools, real commands.** Every skill cites exact CLI commands.
- **GitLab only.** This codebase targets `gitlab.com/ista-se/`. Never `gh`, never GitHub. Use `glab`.
- **GNU tools only.** `rg`, `fd`, `bat`, `jq`. Never `/bin/grep` or `/bin/find` (BSD on macOS is broken).
- **Bash 5.3+.** Tools live in `/opt/homebrew/bin` or `~/.local/bin`. Never `/bin` or `/usr/bin`.

## Languages covered

| Language | Targets |
|---|---|
| Kotlin | 2.0+, JVM 21/25 LTS, Gradle Kotlin DSL, ktlint, detekt, JUnit 5 |
| Java | 25 LTS (or 21 LTS), records, sealed types, virtual threads, JUnit 5, Mockito 5 |
| TypeScript | strict mode, pnpm, Vitest, ESLint 9 flat config, Node 24 LTS |
| Python | 3.13+, `uv`, `ruff`, `pytest`, `pyright` |
| Rust | stable, edition 2024, `cargo nextest`, clippy `-D warnings`, `anyhow` / `thiserror` |
| Bash | 5.3+, strict mode, GNU/Homebrew tools only, shellcheck + shfmt + bats |

One `SKILL.md` per language. Each has toolchain, lint, test, verify recipe, pitfalls.

## Provenance

Adapted from the [Superpowers](https://github.com/obra/superpowers) skill collection (TDD, debugging, verification, plans, worktrees, code review, parallel agents). Voice rewritten, GitHub references replaced with GitLab/`glab`, and content trimmed for solo use.
