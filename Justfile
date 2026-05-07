# ── BMAD-CODER-LIGHT Justfile ────────────────────────────────────
#
# Pkg mgr:    pnpm
# Linters:    eslint (flat) · prettier · rumdl · shellcheck · actionlint
# Validators: tools/validate-skills.js · tools/validate-file-refs.js
# Hooks:      pre-commit
# Interactive: gum (menus, prompts, style) · sk (skim — picker w/ preview)
# Default:    just  →  just menu
#
# `just --list` is auto-grouped via [group('...')] attributes.

set shell := ["bash", "-euo", "pipefail", "-c"]
set dotenv-load := false
set quiet

pm := "pnpm"

# ── Default ──────────────────────────────────────────────────────

# Default: launch interactive menu (falls back to --list if gum missing).
[private]
default:
    if command -v gum >/dev/null 2>&1; then just menu; else just --list; fi

# ── Meta ─────────────────────────────────────────────────────────

# Show grouped recipe list.
[group('meta')]
help:
    just --list

# Show recipe source.
[group('meta')]
show recipe:
    just --show {{recipe}}

# Print tool versions.
[group('meta')]
info:
    if command -v gum >/dev/null 2>&1; then \
      gum style --bold --border double --padding "0 2" --foreground 212 "BMAD-CODER-LIGHT"; \
    else \
      printf '== BMAD-CODER-LIGHT ==\n'; \
    fi
    printf 'node:        %s\n' "$(node --version)"
    printf 'pnpm:        %s\n' "$({{pm}} --version)"
    printf 'just:        %s\n' "$(just --version)"
    printf 'gum:         %s\n' "$(gum --version 2>/dev/null || echo 'not installed')"
    printf 'sk:          %s\n' "$(sk --version 2>/dev/null || echo 'not installed (brew install sk)')"
    printf 'rumdl:       %s\n' "$(rumdl --version 2>/dev/null || echo 'not installed')"
    printf 'shellcheck:  %s\n' "$(shellcheck --version 2>/dev/null | sed -n 2p || echo 'not installed')"
    printf 'pre-commit:  %s\n' "$(pre-commit --version 2>/dev/null || echo 'not installed')"

# ── Setup ────────────────────────────────────────────────────────

# Install dependencies + pre-commit hooks.
[group('setup')]
install:
    {{pm}} install --frozen-lockfile
    if command -v pre-commit >/dev/null 2>&1; then pre-commit install; fi

# Wipe and reinstall everything.
[group('setup')]
[confirm("This deletes node_modules and pnpm-lock.yaml. Continue?")]
install-clean:
    rm -rf node_modules pnpm-lock.yaml
    {{pm}} install
    if command -v pre-commit >/dev/null 2>&1; then pre-commit install; fi

# ── Lint & Format ────────────────────────────────────────────────

# Run all linters (no auto-fix).
[group('lint')]
lint: lint-js lint-md lint-shell

# JS/CJS/MJS/YAML eslint check.
[group('lint')]
lint-js:
    {{pm}} exec eslint . --ext .js,.cjs,.mjs,.yaml --max-warnings=0

# Markdown via rumdl.
[group('lint')]
lint-md:
    rumdl check .

# Shell scripts via shellcheck (no-op if no .sh files).
[group('lint')]
lint-shell:
    files=$(fd -e sh -e bash --exclude node_modules --exclude .git --hidden 2>/dev/null || true); \
    if [[ -n "$files" ]]; then echo "$files" | xargs shellcheck; else echo "no shell scripts"; fi

# Format check (prettier).
[group('lint')]
fmt-check:
    {{pm}} exec prettier --check "**/*.{js,cjs,mjs,json,yaml}"

# Format in place.
[group('lint')]
fmt:
    {{pm}} exec prettier --write "**/*.{js,cjs,mjs,json,yaml}"

# Auto-fix everything that is auto-fixable.
[group('lint')]
fix:
    {{pm}} exec eslint . --ext .js,.cjs,.mjs,.yaml --fix
    {{pm}} exec prettier --write "**/*.{js,cjs,mjs,json,yaml}"
    rumdl check --fix .

# ── Validate ─────────────────────────────────────────────────────

# Strict skill validation.
[group('validate')]
validate-skills:
    {{pm}} validate:skills

# Strict file-reference validation.
[group('validate')]
validate-refs:
    {{pm}} validate:refs

# ── Test ─────────────────────────────────────────────────────────

# Full test suite.
[group('test')]
test: test-install test-urls test-channels

# Installer-component tests.
[group('test')]
test-install:
    {{pm}} test:install

# Source-URL parser tests.
[group('test')]
test-urls:
    {{pm}} test:urls

# Installer-channel tests.
[group('test')]
test-channels:
    {{pm}} test:channels

# ── Pre-commit framework ─────────────────────────────────────────

# Run all hooks against all files.
[group('hooks')]
hooks-all:
    pre-commit run --all-files

# Update hook versions.
[group('hooks')]
hooks-update:
    if command -v gum >/dev/null 2>&1; then \
      gum spin --title "Updating pre-commit hooks..." -- pre-commit autoupdate; \
    else \
      pre-commit autoupdate; \
    fi

# Re-install git hooks.
[group('hooks')]
hooks-install:
    pre-commit install

# ── Verify (mandatory pre-push gate) ─────────────────────────────

# Mirrors `pnpm quality`. Run before every push.
[group('verify')]
verify:
    {{pm}} quality

# Canonical alias for `verify`.
[group('verify')]
quality: verify

# ── BMAD installer (this clone -> external project) ──────────────

# Install BMM modules into a target directory.
[group('bmad')]
bmad-install target:
    {{pm}} bmad:install --directory {{target}}

# Headless install of the default stack.
[group('bmad')]
bmad-install-default target:
    {{pm}} bmad:install --yes \
      --directory {{target}} \
      --modules bmm,bmb,cis \
      --tools claude-code

# ── Clean ────────────────────────────────────────────────────────

# Remove caches.
[group('clean')]
clean:
    rm -rf .rumdl_cache node_modules/.cache

# Full wipe.
[group('clean')]
[confirm("This deletes node_modules. Continue?")]
clean-all: clean
    rm -rf node_modules

# ── Utilities ────────────────────────────────────────────────────

# Lines of code.
[group('utils')]
sloc:
    if command -v scc >/dev/null 2>&1; then scc . --exclude-dir node_modules,coder-light; \
    elif command -v tokei >/dev/null 2>&1; then tokei . -e node_modules; \
    else echo "install scc or tokei"; fi

# ── Interactive (gum + sk) ───────────────────────────────────────

# Interactive recipe picker (auto-includes every recipe).
[group('interactive')]
[no-exit-message]
menu:
    if ! command -v gum >/dev/null 2>&1; then \
      echo "gum not installed (brew install gum)" >&2; just --list; exit 0; \
    fi
    just --chooser 'gum filter --header=" BMAD-CODER-LIGHT — pick a recipe " --placeholder="type to filter..." --indicator="▶" --height=20' --choose

# Pick a file and open in $EDITOR (preview via bat).
[group('interactive')]
[no-exit-message]
pick:
    if ! command -v sk >/dev/null 2>&1; then \
      echo "sk not installed (brew install sk)" >&2; exit 1; \
    fi
    choice=$(fd -t f -E node_modules -E .git | \
      sk --preview "bat --color=always --style=numbers --line-range=:500 {}" \
         --preview-window=right:60%:wrap \
         --header="pick a file" \
      || true); \
    [[ -z "$choice" ]] && exit 0; \
    "${EDITOR:-vim}" "$choice"

# Live grep (re-runs rg per keystroke); opens at the matched line.
[group('interactive')]
[no-exit-message]
search:
    if ! command -v sk >/dev/null 2>&1; then \
      echo "sk not installed (brew install sk)" >&2; exit 1; \
    fi
    match=$(sk --ansi -i \
      -c 'rg --color=always --line-number --no-heading --hidden --glob "!node_modules" --glob "!.git" "{}"' \
      --delimiter=':' \
      --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
      --preview-window=right:60%:+{2}-10:wrap \
      --header="live grep — type to search" \
      || true); \
    [[ -z "$match" ]] && exit 0; \
    file=$(echo "$match" | cut -d: -f1); \
    line=$(echo "$match" | cut -d: -f2); \
    "${EDITOR:-vim}" "+$line" "$file"

# Switch git branch (preview shows recent commits).
[group('interactive')]
[no-exit-message]
branch:
    if ! command -v sk >/dev/null 2>&1; then \
      echo "sk not installed (brew install sk)" >&2; exit 1; \
    fi
    branch=$(git branch --all --sort=-committerdate --format='%(refname:short)' | \
      sk --header="switch branch" --preview='git log --oneline -20 --color=always {}' \
      || true); \
    [[ -z "$branch" ]] && exit 0; \
    git switch "$branch" 2>/dev/null || git switch -c "$branch" "origin/${branch#origin/}"

# Open a chosen recipe's source (sk preview).
[group('interactive')]
[no-exit-message]
which:
    if ! command -v sk >/dev/null 2>&1; then just --list; exit 0; fi
    recipe=$(just --summary | tr ' ' '\n' | \
      sk --preview 'just --show {} 2>/dev/null' \
         --preview-window=right:55%:wrap \
         --header="just recipe explorer" \
      || true); \
    [[ -z "$recipe" ]] && exit 0; \
    just --show "$recipe"
