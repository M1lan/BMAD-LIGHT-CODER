# BMAD-CODER-LIGHT: task runner over upstream's uv tooling.
# Branches: main mirrors upstream/main (fast-forward only); coder-light = main + fork commits.

set shell := ["bash", "-euo", "pipefail", "-c"]

# List recipes.
default:
    just --list

# Install the Python dev tools from uv.lock.
setup:
    uv sync --frozen

# Python-side quality gate: every pre-commit hook over the whole tree, pytest included.
verify:
    uv run --frozen pre-commit run --all-files

# Validate skill files only.
validate-skills:
    uv run --frozen tools/validate_skills.py --strict

# Fetch upstream, fast-forward main, preview what a sync would bring.
upstream-status:
    git fetch upstream --prune
    git fetch . upstream/main:main
    echo "upstream commits not in coder-light: $(git rev-list --count coder-light..main)"
    git cherry -v main coder-light
    git merge-tree --write-tree --name-only main coder-light >/dev/null && echo "no conflicts" || echo "conflicts expected"

# Rebase coder-light onto the refreshed main. Archive tag first, so the old stack stays recoverable.
sync-upstream: upstream-status
    git switch coder-light
    git tag "archive/coder-light-$(date +%F-%H%M)" coder-light
    git rebase main
