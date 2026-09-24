---
name: bash-5.3
description: Use when writing, editing, debugging, or reviewing Bash scripts — Bash 5.3+, strict mode, GNU/Homebrew tools only, never /bin or /usr/bin
---

# Bash 5.3+

## Overview

Treat Bash as a programming language, not a scripting toy. Bash 5.3+ only. Strict mode at the top of every script. Functions, not top-level logic. GNU tools from Homebrew or `~/.local/bin` only — **never** macOS BSD tools at `/bin` or `/usr/bin`.

## Toolchain policy (non-negotiable)

| Allowed prefix | Examples |
|---|---|
| `/opt/homebrew/bin/` | `bash`, `rg`, `fd`, `bat`, `jq`, `gum`, `glab`, `gawk`, `gsed`, `coreutils` (`gls`, `gtimeout`, ...) |
| `$HOME/.local/bin/` | project shims |
| `$HOME/.cargo/bin/` | Rust binaries |

| Forbidden prefix | Why |
|---|---|
| `/bin/` | macOS BSD; flags differ from GNU. |
| `/usr/bin/` | same. |

This applies to:

- Scripts you write.
- Recipes you put in `Justfile`s.
- Commands you suggest in code review.

If a tool is only available at `/usr/bin/`, install the GNU version: `brew install grep coreutils gnu-sed gawk findutils`. Never reach into `/usr/bin/`.

## Strict mode (every script)

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit
IFS=$'\n\t'
```

| Flag | Why |
|---|---|
| `-E` | `ERR` trap survives function calls. |
| `-e` | Exit on any unhandled non-zero. |
| `-u` | Error on unset variable. |
| `-o pipefail` | Pipeline status = first failing stage. |
| `inherit_errexit` | `-e` propagates into command substitutions. |
| `IFS=$'\n\t'` | Word-splitting on newlines/tabs only — survives filenames with spaces. |

Add a trap for diagnostics:

```bash
trap 's=$?; echo "ERROR: ${BASH_SOURCE[0]}:${LINENO}: \"${BASH_COMMAND}\" exited $s" >&2; exit $s' ERR
```

## Shebang

Always:

```bash
#!/usr/bin/env bash
```

Never `#!/bin/bash` (macOS Bash 3.2 — broken for `[[`, `mapfile`, associative arrays, etc.).

Then enforce the version:

```bash
if (( BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 3) )); then
  echo "needs Bash 5.3+, got ${BASH_VERSION}" >&2
  exit 1
fi
```

## Quoting and arrays

- Always double-quote: `"$var"`, `"${arr[@]}"`. Single-quote literals.
- `"$@"` to forward args. Never `$@`.
- Indexed arrays: `arr=(a b c)`; iterate with `"${arr[@]}"`.
- Associative arrays: `declare -A m; m[key]=value`.

## Functions, not top-level

```bash
main() {
  local -r input="${1:?usage: prog INPUT}"
  do_thing "$input"
}

do_thing() {
  local input="$1"
  ...
}

main "$@"
```

Top-level scripts are unmaintainable. Wrap in `main`. Use `local` for variables. Use `local -r` for constants. Prefix functions with the script name when the script grows.

## Required modern idioms

| Idiom | Replaces |
|---|---|
| `[[ ... ]]` | `[ ... ]` |
| `(( ... ))` for arithmetic | `expr`, `let` |
| `mapfile -t lines < file` | `while read` loops with subtle bugs |
| `${var:-default}`, `${var:?err}` | manual `if [[ -z ]]` checks |
| `printf '%s\n' "$x"` | `echo "$x"` (echo flags vary across shells) |
| `command -v <cmd>` | `which <cmd>` |
| `read -r` | `read` (without -r mangles backslashes) |

## Lint and format

```bash
shellcheck script.sh                          # mandatory; treat warnings as errors
shfmt -i 2 -ci -bn -d script.sh               # format diff
shfmt -i 2 -ci -bn -w script.sh               # format in place
```

In CI, run shellcheck with `--severity=warning --enable=all`.

## Tests (yes, even Bash)

Use [bats-core](https://github.com/bats-core/bats-core):

```bash
brew install bats-core
bats tests/
```

A test:

```bash
@test "rotates the token when expired" {
  run rotate_token "expired-foo"
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ ^new-token- ]]
}
```

## Common pitfalls

| Pitfall | Fix |
|---|---|
| `cd "$dir"` without checking | `cd "$dir" \|\| exit 1` (or `cd "$dir"` under `set -e`). |
| Word-splitting filenames with spaces | Quote everything; rely on `IFS=$'\n\t'`. |
| `for f in $(ls)` | `for f in *` or `mapfile`. |
| `eval` | Don't. Use arrays, `printf`, or `bash -c`. |
| `cat file \| grep x` | `grep x file`. (UUOC.) |
| `rm -rf "$dir/$child"` with empty vars | `${dir:?}/${child:?}` — `?` aborts on unset. |
| Source files without `set -u`-safe defaults | Always define `: "${VAR:=default}"`. |
| Coreutils flag mismatch (`sed -i ''` vs GNU `sed -i`) | Use `gsed`/`coreutils` from Homebrew. |
| `which` | `command -v`. |
| `readlink -f` on macOS BSD | `greadlink -f` (Homebrew coreutils) or pure-bash. |

## Justfile snippet

```just
set shell := ["bash", "-Eeuo", "pipefail", "-c"]

# Verify a Bash project
verify:
    shellcheck $(fd -e sh -e bash)
    shfmt -i 2 -ci -bn -d $(fd -e sh -e bash)
    bats tests/
```

## Cross-refs

- `../../core/test-driven-development/SKILL.md` — bats is the test runner; write the failing bats test first.
- `../../core/verification-before-completion/SKILL.md` — `shellcheck && shfmt -d && bats` is the verification command.
- `../../../AGENTS.md` (project-level Bash policy) — re-states the tool-path rule.

## Bottom line

`#!/usr/bin/env bash`, `set -Eeuo pipefail`, GNU/Homebrew tools only, shellcheck mandatory, bats for tests, no `/bin` or `/usr/bin`.
