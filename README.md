# BMAD-CODER-LIGHT

Personal hardfork of [bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD).
Private use, public repo. No npm publish — clone, build, install locally.

Two independent trees:

| Tree            | What it is                                                                |
| --------------- | ------------------------------------------------------------------------- |
| `coder-light/`  | Skills-first solo-dev variant. Self-contained. See `coder-light/README.md`. |
| Everything else | BMM framework — `src/` (skill sources) and `tools/installer/` (local CLI).  |

## Setup this clone

```bash
git clone https://github.com/M1lan/BMAD-LIGHT-CODER.git
cd BMAD-LIGHT-CODER
pnpm install --frozen-lockfile
```

## Use coder-light in another repo

```bash
mkdir -p /path/to/project/.agent
cp -r coder-light /path/to/project/.agent/
ln -s .agent/coder-light/AGENTS.md /path/to/project/AGENTS.md
```

Details: [`coder-light/docs/install.md`](coder-light/docs/install.md).

## Install BMM modules into another repo

From inside this clone:

```bash
pnpm bmad:install --directory /path/to/project
```

Headless / scripted form:

```bash
pnpm bmad:install --yes \
  --directory /path/to/project \
  --modules bmm,bmb,cis \
  --tools claude-code
```

Override module config with `--set <module>.<key>=<value>`. List available
keys with `--list-options [module]`. Full reference:
[`docs/how-to/install-bmad.md`](docs/how-to/install-bmad.md).

Prerequisites: Node 20+, pnpm 10+, Git.

## Develop

```bash
pnpm install --frozen-lockfile
pnpm quality   # mandatory before push; see AGENTS.md
```

pnpm only — no `npm`, no `yarn`, no `pnpm publish`.

## Documentation

- Project rules and agent gotchas: [`AGENTS.md`](AGENTS.md)
- Optional reference, how-tos, explanation: [`docs/`](docs/)
- coder-light variant: [`coder-light/README.md`](coder-light/README.md)

## License

MIT — see [`LICENSE`](LICENSE).
"BMad" and "BMAD-METHOD" are trademarks of BMad Code, LLC; see
[`TRADEMARK.md`](TRADEMARK.md).
