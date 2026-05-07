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

- **This is a fork.** `origin` is `github.com/M1lan/BMAD-LIGHT-CODER`;
  `upstream` is `github.com/bmad-code-org/BMAD-METHOD`. Most active work
  happens on the `coder-light` branch.
- **Two parallel trees, do not mix them.**
  - `coder-light/` is a self-contained skills-first solo-dev variant. It has
    its own `AGENTS.md` and `README.md`. Never apply upstream BMM
    conventions inside it.
  - The rest of the repo (`src/`, `tools/`, `docs/`, `website/`) is upstream
    BMM. Conventional Commits + the upstream installer rules apply there.
- **`npm run quality` is heavy and mandatory before every push.** It runs
  `format:check`, `lint`, `lint:md`, `docs:build` (Astro), `test:install`,
  `test:urls`, `validate:refs`, `validate:skills`. Run it on the exact
  checkout you are about to push, not a stale one.
- **`docs:build` does not run on Windows** (`tools/build-docs.mjs:56-60`).
  Use macOS, Linux, or WSL.
- **`docs/` content is consumed by the website.**
  `website/src/content/docs` is a symlink to repo-root `docs/`. Renaming or
  deleting a doc that is referenced from `website/astro.config.mjs`
  (sidebar) breaks the build. Update the sidebar when doc structure
  changes.
- **No new top-level docs.** README.md and this file are the only mandatory
  reading. Everything optional belongs under `docs/`. Do not create
  summary, plan, or migration markdown files unless explicitly asked.
- **Skill files are validated.** Anything claiming to be a skill must satisfy
  the rules in `tools/skill-validator.md`. `npm run validate:skills`
  enforces the deterministic subset.
- **File-reference validation is strict.** Markdown/YAML/CSV references must
  resolve. `npm run validate:refs` will fail the quality gate on dead
  paths.
- **Translation drift.** Translated docs under `docs/<locale>/` are mirrors
  of English content and drift quickly. Do not assume they are current.
  Source of truth is the English file at `docs/<same-path>`.
- **Do not write to `build/`, `node_modules/`, or `.husky/_/`.** Those are
  generated.

## Rules

- Use Conventional Commits.
- Run `npm ci && npm run quality` on `HEAD` before pushing.
- Skill rules: `tools/skill-validator.md`. Deterministic checks:
  `npm run validate:skills`.
