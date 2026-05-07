# ── BMAD-CODER-LIGHT Justfile — private hardfork, pnpm only ──
#
# Pkg mgr:    pnpm
# Linters:    eslint (flat) · prettier · rumdl · shellcheck · actionlint
# Validators: tools/validate-skills.js · tools/validate-file-refs.js
# Hooks:      pre-commit
# Usage:      just --list  |  just fzf

set shell := ["bash", "-euo", "pipefail", "-c"]
set dotenv-load := false

pm := "pnpm"

# ── Meta ─────────────────────────────────────────────────────────

# Show available recipes.
help:
    @just --list --unsorted

# Print tool versions.
info:
    @printf 'node:        %s\n' "$(node --version)"
    @printf 'pnpm:        %s\n' "$({{pm}} --version)"
    @printf 'just:        %s\n' "$(just --version)"
    @printf 'rumdl:       %s\n' "$(rumdl --version 2>/dev/null || echo 'not installed')"
    @printf 'shellcheck:  %s\n' "$(shellcheck --version 2>/dev/null | sed -n 2p || echo 'not installed')"
    @printf 'pre-commit:  %s\n' "$(pre-commit --version 2>/dev/null || echo 'not installed')"

# ── Setup ────────────────────────────────────────────────────────

# Install dependencies + pre-commit hooks.
install:
    {{pm}} install --frozen-lockfile
    @if command -v pre-commit >/dev/null 2>&1; then pre-commit install; fi

# Wipe and reinstall everything.
install-clean:
    rm -rf node_modules pnpm-lock.yaml
    {{pm}} install
    @if command -v pre-commit >/dev/null 2>&1; then pre-commit install; fi

# ── Lint & Format ────────────────────────────────────────────────

# Run all linters (no auto-fix).
lint: lint-js lint-md lint-shell

# JS/CJS/MJS/YAML eslint check.
lint-js:
    {{pm}} exec eslint . --ext .js,.cjs,.mjs,.yaml --max-warnings=0

# Markdown via rumdl.
lint-md:
    rumdl check .

# Shell scripts via shellcheck (no-op if no .sh files).
lint-shell:
    @files=$(fd -e sh -e bash --exclude node_modules --exclude .git --hidden 2>/dev/null || true); \
    if [[ -n "$files" ]]; then echo "$files" | xargs shellcheck; else echo "no shell scripts"; fi

# Format check (prettier).
fmt-check:
    {{pm}} exec prettier --check "**/*.{js,cjs,mjs,json,yaml}"

# Format in place.
fmt:
    {{pm}} exec prettier --write "**/*.{js,cjs,mjs,json,yaml}"

# Auto-fix everything that is auto-fixable.
fix:
    {{pm}} exec eslint . --ext .js,.cjs,.mjs,.yaml --fix
    {{pm}} exec prettier --write "**/*.{js,cjs,mjs,json,yaml}"
    rumdl check --fix .

# ── Validate ─────────────────────────────────────────────────────

# Strict skill validation.
validate-skills:
    {{pm}} validate:skills

# Strict file-reference validation.
validate-refs:
    {{pm}} validate:refs

# ── Test ─────────────────────────────────────────────────────────

# Installer-component tests.
test-install:
    {{pm}} test:install

# Source-URL parser tests.
test-urls:
    {{pm}} test:urls

# Installer-channel tests.
test-channels:
    {{pm}} test:channels

# Full test suite.
test: test-install test-urls test-channels

# ── Pre-commit framework ─────────────────────────────────────────

# Run all hooks against all files.
hooks-all:
    pre-commit run --all-files

# Update hook versions.
hooks-update:
    pre-commit autoupdate

# Re-install git hooks.
hooks-install:
    pre-commit install

# ── Verify (mandatory pre-push gate) ─────────────────────────────

# Mirrors `pnpm quality`. Run before every push.
verify:
    {{pm}} quality

# Same as verify; canonical alias.
quality: verify

# ── BMAD installer (this clone -> external project) ──────────────

# Install BMM modules into a target directory.
bmad-install target:
    {{pm}} bmad:install --directory {{target}}

# Headless install of the default stack.
bmad-install-default target:
    {{pm}} bmad:install --yes \
      --directory {{target}} \
      --modules bmm,bmb,cis \
      --tools claude-code

# ── Clean ────────────────────────────────────────────────────────

# Remove caches.
clean:
    rm -rf .rumdl_cache node_modules/.cache

# Full wipe.
clean-all: clean
    rm -rf node_modules

# ── Utilities ────────────────────────────────────────────────────

# Lines of code.
sloc:
    @if command -v scc >/dev/null 2>&1; then scc . --exclude-dir node_modules,coder-light; \
    elif command -v tokei >/dev/null 2>&1; then tokei . -e node_modules; \
    else echo "install scc or tokei"; fi

# ── fzf Workflows ────────────────────────────────────────────────

# Interactive recipe picker.
[no-exit-message]
fzf:
    #!/usr/bin/env bash
    set -euo pipefail
    choice=$(printf '%s\n' \
        '── SETUP ──' \
        '  install        Install deps + git hooks' \
        '── LINT & FORMAT ──' \
        '* lint           All linters' \
        '  lint-js        ESLint' \
        '  lint-md        rumdl' \
        '  lint-shell     shellcheck' \
        '  fmt            Format (prettier)' \
        '  fmt-check      Check formatting' \
        '  fix            Auto-fix everything' \
        '── VALIDATE ──' \
        '  validate-skills' \
        '  validate-refs' \
        '── TEST ──' \
        '  test           Full test suite' \
        '  test-install   Installer components' \
        '  test-urls      Source-URL parser' \
        '── HOOKS ──' \
        '  hooks-all      Run all hooks against all files' \
        '  hooks-update   Update hook versions' \
        '── VERIFY ──' \
        '* verify         Full pre-push gate (= pnpm quality)' \
        '── BMAD INSTALL ──' \
        '  bmad-install <target>' \
        '── UTILITIES ──' \
        '  info           Show tool versions' \
        '  clean          Remove caches' \
        '  sloc           Count lines of code' \
        | fzf --header="BMAD-CODER-LIGHT — pick a recipe (ESC to cancel)" \
              --preview='just --show {1} 2>/dev/null || echo "(section header)"' \
              --preview-window=right:50%:wrap \
        || true)
    [[ -z "$choice" ]] && exit 0
    recipe=$(echo "$choice" | awk '{print $1}' | sed 's/^\*//')
    just "$recipe"

# Pick and edit a source file.
[no-exit-message]
pick:
    #!/usr/bin/env bash
    set -euo pipefail
    choice=$(fd -t f -E node_modules -E .git | \
        fzf --preview "bat --color=always --style=numbers --line-range=:500 {}" \
            --preview-window=right:60%:wrap \
        || true)
    [[ -z "$choice" ]] && exit 0
    "${EDITOR:-vim}" "$choice"

# Live grep across the tree.
[no-exit-message]
search-fzf:
    #!/usr/bin/env bash
    set -euo pipefail
    match=$(rg --color=always --line-number --no-heading --hidden --glob '!node_modules' '.' | \
        fzf --ansi --delimiter ':' \
            --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
            --preview-window=right:60%:+{2}-10:wrap \
        || true)
    [[ -z "$match" ]] && exit 0
    file=$(echo "$match" | cut -d: -f1)
    line=$(echo "$match" | cut -d: -f2)
    "${EDITOR:-vim}" "+$line" "$file"

# Interactive git branch switcher.
[no-exit-message]
branch:
    #!/usr/bin/env bash
    set -euo pipefail
    branch=$(git branch --all --sort=-committerdate --format='%(refname:short)' | \
        fzf --header="Switch branch" --preview='git log --oneline -20 {}' || true)
    [[ -z "$branch" ]] && exit 0
    git switch "$branch" 2>/dev/null || git switch -c "$branch" "origin/$branch"
