# Installing coder-light into a fresh project

## Goal

Drop the `coder-light/` tree into your project so the AI assistant can find and load skills on demand.

## Option 1 — copy the tree (simplest)

In a fresh repo:

```bash
git clone --depth=1 https://gitlab.com/ista-se/BMAD-METHOD.git /tmp/bmad
mkdir -p .agent
cp -r /tmp/bmad/coder-light .agent/
ln -s .agent/coder-light/AGENTS.md AGENTS.md
```

Commit:

```bash
git add .agent AGENTS.md
git commit -m "chore: bootstrap with bmad-coder-light"
```

The skills now live at `.agent/coder-light/skills/<category>/<skill>/SKILL.md`. Most AI assistants will discover them by walking the project tree.

## Option 2 — git submodule (stays in sync)

```bash
git submodule add https://gitlab.com/ista-se/BMAD-METHOD.git .agent/upstream
ln -s upstream/coder-light .agent/coder-light
ln -s .agent/coder-light/AGENTS.md AGENTS.md
git add .agent AGENTS.md .gitmodules
git commit -m "chore: add bmad-coder-light as submodule"
```

To update later:

```bash
git submodule update --remote --merge .agent/upstream
git add .agent/upstream
git commit -m "chore(deps): bump bmad-coder-light"
```

## Option 3 — sparse checkout (only the coder-light tree)

```bash
git clone --filter=blob:none --no-checkout https://gitlab.com/ista-se/BMAD-METHOD.git .agent/upstream
cd .agent/upstream
git sparse-checkout init --cone
git sparse-checkout set coder-light
git checkout main
cd ../..
ln -s upstream/coder-light .agent/coder-light
ln -s .agent/coder-light/AGENTS.md AGENTS.md
```

## IDE / agent bootstrap

### Claude Code

Claude Code reads `~/.claude/skills/` and project-local `AGENTS.md`. If the symlinked `AGENTS.md` is in place, the rules apply. To expose skills globally on this machine:

```bash
ln -s "$PWD/.agent/coder-light/skills" ~/.claude/skills/coder-light
```

### Forge (this repo's primary)

Forge reads `~/forge/skills/` (global) and `.forge/skills/` (project). To expose them per-project:

```bash
mkdir -p .forge/skills
ln -s "$PWD/.agent/coder-light/skills" .forge/skills/coder-light
```

### Generic agents (OpenCode, Cursor, others)

Most file-aware agents will pick up `AGENTS.md` automatically when it sits at the repo root. The skills then load on demand when the agent searches the tree.

## Verifying the install

In your project root:

```bash
test -f AGENTS.md && echo "AGENTS.md present"
test -d .agent/coder-light/skills && echo "skills tree present"
fd SKILL.md .agent/coder-light/skills | wc -l
# expected: 17 (one SKILL.md per skill)
```

Ask your AI assistant: *"What skills are available under coder-light?"* It should list the categories and skill names.

## Updating in place

| Install method | Update command |
|---|---|
| Copy | `rm -rf .agent/coder-light && cp -r /tmp/bmad/coder-light .agent/` (after `git pull` in `/tmp/bmad`) |
| Submodule | `git submodule update --remote --merge .agent/upstream` |
| Sparse | `cd .agent/upstream && git pull` |

## Removing coder-light

```bash
rm -rf .agent
rm -f AGENTS.md
git add -A && git commit -m "chore: drop bmad-coder-light"
```

The plan files in `plans/`, the worktrees in `.worktrees/`, and your code stay put. coder-light is discardable on purpose.
