---
name: python
description: Use when writing or editing Python at ista-se — uv for envs and tools, ruff for lint+format, pytest, type hints with pyright/mypy
---

# Python

## Overview

Modern Python 3.13+. `uv` for environment and global tool management. `ruff` for linting and formatting (replaces `isort`, `flake8`, `black`, `pyupgrade`). `pytest` for tests. Type hints everywhere; checked by `pyright` (or `mypy`).

## Toolchain policy (non-negotiable)

| Tool | Allowed via | Forbidden |
|---|---|---|
| Global Python CLIs | `uv tool install <name>` | `pipx`, `pip install --user`, `brew install <python-formula>` |
| Per-project deps | `uv venv` + `uv pip install` (or `uv sync` if using `pyproject.toml` + `uv.lock`) | `pip install` outside a venv |
| Bare `pip install` outside a venv | NEVER | shell sets `PIP_REQUIRE_VIRTUALENV=true`, it will fail |

`isort` is a shim at `~/.local/bin/isort` that delegates to `ruff check --select I`. Don't `uv tool install isort`.

## Toolchain (assumed installed)

| Tool | Where | Version target |
|---|---|---|
| `uv` | `/opt/homebrew/bin/uv` or `~/.local/bin/uv` | 0.4+ |
| `python` | inside the project venv | 3.13+ |
| `ruff` | local devDep or `uv tool install ruff` | latest |
| `pytest` | local devDep | 8+ |
| `pyright` | `uv tool install pyright` | latest |

## Project layout (src layout, recommended)

```text
pyproject.toml
uv.lock
src/<package>/__init__.py
src/<package>/...
tests/
```

`pyproject.toml`:

```toml
[project]
name = "ista-thing"
requires-python = ">=3.13"
dependencies = ["httpx>=0.27"]

[tool.ruff]
line-length = 100
target-version = "py313"

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP", "SIM", "PT", "RUF"]

[tool.pyright]
typeCheckingMode = "strict"
```

## Bootstrap

```bash
uv venv
source .venv/bin/activate
uv pip install -e '.[dev]'
```

Or, with `uv sync` (requires `[tool.uv]` in `pyproject.toml`):

```bash
uv sync
```

## Style and lint

```bash
ruff check .                  # lint
ruff check --fix .            # auto-fix
ruff format .                 # format
ruff format --check .         # check format

pyright                       # type-check
```

## Test runner

```bash
pytest -q                                       # all tests
pytest tests/auth/test_token.py                 # one file
pytest -k 'rotates_tokens' -v                   # name pattern
pytest -x --ff                                  # stop on first failure, run failures first
pytest --cov=<package>                          # with coverage (pytest-cov)
```

## Verification recipe

```bash
ruff check . && ruff format --check . && pyright && pytest -q
```

## Type-hint idioms

| Idiom | Why |
|---|---|
| `from __future__ import annotations` (3.11 and earlier) | Lazy evaluation. Drop on 3.12+. |
| `X \| None` instead of `Optional[X]` (3.10+) | Cleaner. |
| `list[int]`, `dict[str, X]` (PEP 585) | No `typing.List`. |
| `TypedDict`, `Protocol`, `Literal`, `Self` | Use them. |
| `type Alias = ...` statement (PEP 695, 3.12+) | Replaces `TypeAlias`. |
| `class Foo[T]: ...` generic syntax (PEP 695, 3.12+) | Replaces `TypeVar` boilerplate. |
| `assert isinstance(x, Foo)` for narrowing | Plays well with type checkers. |

## Common pitfalls

| Pitfall | Fix |
|---|---|
| Mutable default args (`def f(x=[])`) | `def f(x: list[int] \| None = None): if x is None: x = []`. |
| `except:` or `except Exception:` | Catch specific exceptions. |
| `print` for logs | Use `logging`, configure once at boot. |
| `os.path` joins | `pathlib.Path`. |
| `subprocess.run(cmd, shell=True)` | Pass a list, no shell. |
| `requests` (sync, blocks event loop) | `httpx` (sync or async). |
| `asyncio.get_event_loop()` | `asyncio.run(main())`. |
| Global `Session()` for DB | Per-request session, scoped. |

## Async pitfalls

- `await` inside a sync function: rewrite as async or run via `asyncio.to_thread` for sync libs.
- Mixing sync and async at boundaries → use `httpx.AsyncClient` and friends; don't bridge with `asyncio.run` from inside an async context.

## Cross-refs

- `../../core/test-driven-development/SKILL.md` — pytest is the runner.
- `../../core/verification-before-completion/SKILL.md` — `ruff check && ruff format --check && pyright && pytest` is the verification command.
- `../../platform/gitlab-glab/SKILL.md` — pipeline uses `uv` to install and runs the same command.
- `../../../AGENTS.md` (project-level) — Python tooling policy is enforced repo-wide.

## Bottom line

`uv` for envs, `ruff` for everything that isn't typing, `pyright` for typing, `pytest` for tests. Verify with `ruff check . && ruff format --check . && pyright && pytest -q`.
