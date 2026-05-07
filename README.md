# BMAD-METHOD

Agent-assisted software-development framework. Personal fork of
[bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD).

This repo contains two independent trees:

| Tree | What it is |
|------|------------|
| `coder-light/` | Skills-first, solo-dev variant. Self-contained `AGENTS.md`, skills, templates. See [`coder-light/README.md`](coder-light/README.md). |
| Everything else | Upstream BMM framework (installer, agents, modules, docs site). |

## Use

### coder-light (solo, fresh repo)

```bash
git clone --depth=1 https://github.com/M1lan/BMAD-LIGHT-CODER.git /tmp/bmad
mkdir -p .agent && cp -r /tmp/bmad/coder-light .agent/
ln -s .agent/coder-light/AGENTS.md AGENTS.md
```

Details: [`coder-light/docs/install.md`](coder-light/docs/install.md).

### Upstream BMM (full agile workflow)

```bash
npx bmad-method install
```

CI-friendly form:

```bash
npx bmad-method install --directory /path/to/project --modules bmm --tools claude-code --yes
```

Override module config with `--set <module>.<key>=<value>`. List known
options with `--list-options [module]`.

Prerequisites: Node ≥ 20, Python ≥ 3.10, [`uv`](https://docs.astral.sh/uv/).

## Modules (upstream)

| Module | Purpose |
|--------|---------|
| [BMM](https://github.com/bmad-code-org/BMAD-METHOD) | Core: 34+ workflows |
| [BMB](https://github.com/bmad-code-org/bmad-builder) | Build custom agents and workflows |
| [TEA](https://github.com/bmad-code-org/bmad-method-test-architecture-enterprise) | Risk-based test strategy |
| [BMGD](https://github.com/bmad-code-org/bmad-module-game-dev-studio) | Game dev (Unity, Unreal, Godot) |
| [CIS](https://github.com/bmad-code-org/bmad-module-creative-intelligence-suite) | Brainstorming, design thinking |

## Documentation

- Project rules and agent gotchas: [`AGENTS.md`](AGENTS.md)
- Optional reference, how-tos, explanation: [`docs/`](docs/)
- Upstream docs site: <https://docs.bmad-method.org>
- coder-light variant: [`coder-light/README.md`](coder-light/README.md)

## Develop

```bash
npm ci
npm run quality   # mandatory before push; see AGENTS.md
```

Conventional Commits. PRs go to `main` upstream; this fork tracks
`coder-light` for variant work. See [`CONTRIBUTING.md`](CONTRIBUTING.md).

## License

MIT — see [`LICENSE`](LICENSE).
"BMad" and "BMAD-METHOD" are trademarks of BMad Code, LLC; see
[`TRADEMARK.md`](TRADEMARK.md).
