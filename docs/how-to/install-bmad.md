# Install BMad

This is a private hardfork. There is no published npm package; the only
install path is clone-and-run-local.

## Prerequisites

- Node.js 20+
- pnpm 10+
- Git

## One-time setup of this clone

```bash
git clone https://github.com/M1lan/BMAD-LIGHT-CODER.git
cd BMAD-LIGHT-CODER
pnpm install --frozen-lockfile
```

## Install BMad into a target project

From inside the cloned repo:

```bash
pnpm bmad:install --directory /path/to/target
```

Interactive prompts ask for modules, IDE/tool, and per-module config. The
target ends up with a `_bmad/` directory containing the selected modules
and IDE skills.

To install into the current directory, omit `--directory`:

```bash
pnpm bmad:install
```

## Headless / scripted install

```bash
pnpm bmad:install --yes \
  --directory /path/to/target \
  --modules bmm,bmb,cis \
  --tools claude-code
```

Flag reference:

| Flag                              | Purpose                                                                        |
| --------------------------------- | ------------------------------------------------------------------------------ |
| `--yes`, `-y`                     | Skip prompts; accept flag values + defaults                                    |
| `--directory <path>`              | Install into this directory (default: cwd)                                     |
| `--modules <a,b,c>`               | Exact module set. `core` is auto-added.                                        |
| `--tools <a,b>`                   | IDE/tool selection. Required for `--yes` on a fresh install.                   |
| `--list-tools`                    | Print supported tool/IDE IDs and exit.                                         |
| `--action <type>`                 | `install`, `update`, or `quick-update`.                                        |
| `--custom-source <urls>`          | Install custom modules from Git URLs or local paths.                           |
| `--channel <stable\|next>`        | Apply to all external modules.                                                 |
| `--all-stable` / `--all-next`     | Aliases for `--channel=...`.                                                   |
| `--next=<code>`                   | Put one module on next. Repeatable.                                            |
| `--pin <code>=<tag>`              | Pin one module to a specific tag. Repeatable.                                  |
| `--set <module>.<key>=<value>`    | Set any module config option non-interactively. Repeatable.                    |
| `--list-options [module]`         | Print every `--set` key for built-in / locally-cached modules and exit.        |

`--pin` beats `--next=` beats `--channel` / `--all-*` beats the registry default (`stable`).

## Update an existing install

Re-run the installer in a directory that already contains `_bmad/`:

```bash
pnpm bmad:install --directory /path/to/target
```

The installer offers Quick Update (re-run with existing settings) or
Modify Install (full interactive flow to add/remove modules).

## Manifest

After any install, `_bmad/_config/manifest.yaml` records exactly what's
on disk: module name, version tag, channel, git sha, repo URL. For
reproducibility across machines, convert recorded tags into explicit
`--pin` flags.

## GitHub rate limits

Anonymous GitHub API calls are capped at 60/hour per IP. The installer
hits the API once per external module. Set `GITHUB_TOKEN=<PAT>` in the
environment to raise the limit to 5000/hour. Any public-repo-read token
works; no scopes required.
