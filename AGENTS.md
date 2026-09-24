# BMAD-METHOD

Open source framework for structured, agent-assisted software delivery.

## Rules

- Use Conventional Commits for every commit.
- Before pushing, run `uv sync --frozen && (cd docs-site && npm ci) && uv run --frozen tools/quality.py` on `HEAD`
  in the exact checkout you are about to push. It mirrors the checks in `.github/workflows/quality.yaml`.
- Run `uv run pre-commit install` once per clone; the commit hook runs the Python-side lint and validation from the quality script.

- Skill validation rules are in `tools/skill-validator.md`.
- Deterministic skill checks run via `uv run tools/validate_skills.py --strict` (included in the quality script).
- Documentation conventions are in `docs/_STYLE_GUIDE.md`.

## Writing prompts

Skills, workflows, tasks, and agent definitions are prompt text that an agent reads in full on every run. Length and
ambiguity are paid on every run; a corner case is paid only when it occurs. So do not add instructions for exotic
cases — the model usually handles them from context, and the reviewing human can correct it when it does not.

## Testing

Automated tests assert outcomes produced by deterministic code. Do not write automated tests for LLM output or for
static source text.

## Releases

Read `tools/release.md` before cutting a release. Stamp on `dev`, fast-forward
`main` with `git push origin dev:main`, tag that commit, then stamp the next
placeholder on `dev`. No release PR or back-merge. The 6.12 npm installer is
maintained separately on `V6.12`.

## Fork: BMAD-CODER-LIGHT

This checkout is a private fork. Upstream rules above apply, except releases: the fork never releases or pushes to upstream.

- Remotes: `origin` is `github.com/M1lan/BMAD-LIGHT-CODER`, `upstream` is `github.com/bmad-code-org/BMAD-METHOD`.
- Branches: `main` mirrors `upstream/main`, fast-forward only, never commit on it. `coder-light` is `main` plus the fork commits. Sync with `just sync-upstream` (rebase, archive tag first); preview with `just upstream-status`.
- Keep the fork stack small: add files, do not delete or rewrite upstream files, so rebases stay conflict-free.
- `coder-light/` is a self-contained skills-first solo-dev variant with its own `AGENTS.md`. Never apply method-module conventions inside it.
- The pre-v7 snapshot of this fork lives at tag `archive/coder-light-2026-05`.
- Node tooling: use pnpm (`pnpm dlx`), never npm or npx. `tools/quality.py` calls `npm` inside `docs-site/`; run the Python side with `just verify` instead.
- `.python-version` pins 3.11. Without a local 3.11, run with `UV_PYTHON=3.13` (any version at or above 3.11 works).
