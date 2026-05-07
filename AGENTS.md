# AGENTS.md

## Agent gotchas

In this section, you take note of common mistakes and confusion points that
agents might encounter as they work in this project. If you ever encounter
something in the project that surprises you, please alert the developer
working with you and indicate that this is the case here in this section to
help prevent future agents from having the same issue. Also take note on how
to work efficiently with this codebase, take note on methods to save time
during development; how to avoid endless-loops, context-bloat,
hallucinations, etc.

- **Private hardfork.** `origin` is `github.com/M1lan/BMAD-LIGHT-CODER`;
  `upstream` is `github.com/bmad-code-org/BMAD-METHOD`. Active branch is
  `coder-light`. Project name is **BMAD-CODER-LIGHT**. There is no
  `npm publish` and no published package — all use is clone-then-install-local.
- **pnpm only.** Enforced via `packageManager` in `package.json`. Never
  run `npm install`, `npm ci`, `npx`, or `yarn`. Use
  `pnpm install --frozen-lockfile` and `pnpm dlx <pkg>` for one-shots.
- **Two parallel trees, do not mix them.**
  - `coder-light/` is a self-contained skills-first solo-dev variant. It has
    its own `AGENTS.md` and `README.md`. Never apply BMM conventions inside it.
  - The rest of the repo (`src/`, `tools/`, `docs/`) is the BMM framework
    used by the local installer (`pnpm bmad:install`).
- **`pnpm quality` is mandatory before every push.** It runs `format:check`,
  `lint`, `lint:md` (rumdl), `lint:shell`, `test:install`, `test:urls`,
  `validate:refs`, `validate:skills`. Run it on the exact checkout you are
  about to push, not a stale one.
- **Pre-commit framework, not husky.** `pnpm install` runs `pre-commit install`
  via the `prepare` script. Hooks: gitleaks, pre-commit-hooks, shellcheck,
  actionlint, rumdl, plus local prettier/eslint/validators. Config is
  `.pre-commit-config.yaml`. There is no `.husky/` directory.
- **Husky leftover gotcha.** Older clones may have a stale local
  `core.hooksPath = .husky/_` from when this project used husky. It makes
  `pre-commit install` refuse with *"Cowardly refusing..."*. Both the
  `prepare` script and `just hooks-install` auto-detect and unset it when
  the path doesn't exist. Manual fix: `git config --local --unset-all core.hooksPath`.
- **Markdown lints with rumdl, not markdownlint-cli2.** Config is
  `.rumdl.toml`. `markdownlint-cli2` is no longer a devDep.
- **Justfile is the canonical task runner.** `just --list` shows
  auto-grouped recipes (via `[group(...)]` attrs). `just menu` is the
  interactive picker (gum filter over every recipe). `just verify` ==
  `pnpm quality`. Interactive recipes (`menu`, `pick`, `search`,
  `branch`, `which`) need `gum` and `sk` (skim) — `brew install gum sk`.
  No `fzf` recipe; `sk` replaced it project-wide.
- **Skill files are validated.** Anything claiming to be a skill must satisfy
  the rules in `tools/skill-validator.md`. `pnpm validate:skills`
  enforces the deterministic subset.
- **File-reference validation is strict.** Markdown/YAML/CSV references must
  resolve. `pnpm validate:refs` will fail the quality gate on dead paths.
- **No new top-level docs.** README.md and this file are the only mandatory
  reading. Everything optional belongs under `docs/`. Do not create
  summary, plan, or migration markdown files unless explicitly asked.
- **Do not write to `node_modules/`.** Generated.

## Rules

- Run `pnpm install --frozen-lockfile && pnpm quality` on `HEAD` before pushing.
- Skill rules: `tools/skill-validator.md`. Deterministic checks:
  `pnpm validate:skills`.
