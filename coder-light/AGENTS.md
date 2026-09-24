# AGENTS.md — Rules for AI Agents in a coder-light Project

These rules apply to any AI agent operating inside a project that uses BMAD-coder-light. They override style preferences. Violating any of them is a defect.

## Non-negotiable rules

1. **Read before edit.** Never modify a file you have not read in this session.
2. **Plan before code on multi-step work.** If the task touches 3+ files or 3+ steps, write a plan first using `skills/core/writing-plans/SKILL.md`. Save to `plans/YYYY-MM-DD-<slug>.md`.
3. **Test-first.** Production code requires a failing test that you watched fail. See `skills/core/test-driven-development/SKILL.md`.
4. **Verify before claiming done.** Run the verification command in this session and report its output. See `skills/core/verification-before-completion/SKILL.md`.
5. **Root cause over symptom.** No fixes without the four phases of `skills/core/systematic-debugging/SKILL.md`.
6. **Conventional Commits** for every commit. Example: `feat(auth): add MR token rotation`.
7. **GitLab only.** Use `glab`. Never `gh`. The remote is `gitlab.com/ista-se/<repo>`. Merge requests, not pull requests.
8. **GNU tools only.** `rg`, `fd`, `bat`. Never `/bin/grep`, `/bin/find`, `/usr/bin/awk`. macOS BSD tools are broken — use Homebrew.

## Tool path policy

| Allowed prefix | Examples |
|---|---|
| `/opt/homebrew/bin/` | `rg`, `fd`, `bat`, `jq`, `glab`, `gum` |
| `$HOME/.local/bin/` | `uv`, project shims |
| `$HOME/.cargo/bin/` | `cargo`, Rust binaries |

| Forbidden prefix | Why |
|---|---|
| `/bin/` | macOS BSD; broken flags vs GNU |
| `/usr/bin/` | same |

This applies to bash scripts you write, recipes you suggest, and commands you run.

## Python policy

- **Global Python CLIs:** `uv tool install <name>` only.
- **Forbidden:** `pip install --user`, `pipx`, `brew install <python-formula>`.
- **Project deps:** per-project venv via `uv venv` + `uv pip install`.
- The shell sets `PIP_REQUIRE_VIRTUALENV=true`; any `pip install` outside a venv fails by design.

## Bash policy

- Bash 5.3+ only. No POSIX-sh fallbacks.
- Strict mode at the top of every script: `set -euo pipefail` and `IFS=$'\n\t'`.
- No `/bin` or `/usr/bin` tools (see above).
- Treat bash as a programming language: functions, no top-level logic, exit codes mean something.
- See `skills/languages/bash-5.3/SKILL.md`.

## File operations

- `path:line` for citations. `src/auth.kt:42` or `src/auth.kt:42-58`. Never "line 42 of auth.kt".
- Prefer editing existing files over creating new ones.
- Never create `*.md` documentation files unless explicitly asked.
- Never silently rewrite formatting/whitespace of files you didn't intend to touch.

## Communication

- Imperative. Terse. No filler.
- Forbidden phrases (zero tolerance):
  - "I'll help you ..."
  - "great question", "absolutely", "certainly"
  - "delve", "leverage" (as verb), "robust", "comprehensive", "seamlessly", "unleash", "empower"
  - "in today's fast-paced ..."
  - "as an AI ..."
  - "your human partner" (this is a Superpowers idiom; in coder-light we say "you")
- No emojis unless the user asks or the output is literal terminal output.
- No fake enthusiasm. State the result and stop.

## When to escalate to the human

- Plan has gaps you can't infer.
- Three fix attempts failed (architecture is wrong, see `systematic-debugging`).
- A claim cannot be verified ("I can't verify X without Y; should I [investigate/proceed]?").
- A change would touch infrastructure outside the repo (CI secrets, GitLab settings, runners).

## Skill index

See `skills/` and the per-category `SKILL.md` files. Skills are loaded just-in-time — don't preload them.
