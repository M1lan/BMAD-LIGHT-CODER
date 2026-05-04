---
name: writing-skills
description: Use when creating a new skill or editing an existing one in this coder-light tree
---

# Writing Skills

## Overview

A skill is a reference guide for one proven technique, pattern, or tool. Skills shape AI behaviour.

**Core principle:** if you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing.

This is TDD, applied to documentation.

## What a skill is, and isn't

A skill **is**: a reusable reference for a technique, pattern, or tool. It tells an AI how to do one thing well.

A skill **is not**:

- A narrative ("how I solved a bug last Tuesday")
- A blog post
- A 2000-word essay
- A template you fill in once

If it's project-specific configuration, put it in `AGENTS.md`. If it's enforceable by a linter or validator, automate it.

## Directory layout

```text
skills/<category>/<skill-name>/
  SKILL.md             # required entrypoint
  supporting-file.*    # only if needed (heavy reference, scripts)
```

`<category>` is one of `core/`, `workflow/`, `languages/`, `platform/`. Skills are flat within a category.

## SKILL.md shape

```markdown
---
name: kebab-case-name
description: Use when <specific triggering condition>
---

# Skill Name

## Overview
One paragraph. Core principle in one sentence.

## When to use
Bullet list of triggers. When NOT to use.

## The rule / The process
The instructions.

## Quick reference
Table for scanning.

## Common rationalizations (only for discipline skills)
Excuse → Reality table.

## Red flags — stop
Phrases that mean you're about to violate.

## Pairs with
Links to related skills.

## Bottom line
One sentence. Forget everything else, remember this.
```

## Frontmatter rules

- `name`: kebab-case, ASCII letters/digits/hyphens. Must match the directory name.
- `description`: starts with **Use when**. Describes triggers, not the workflow.
- Keep the whole frontmatter under 1024 chars.

**Description trap.** If the description summarizes the workflow, agents follow the description and skip the body. Bad: `Use when executing a plan — dispatches a sub-agent and reviews between tasks`. Good: `Use when executing an implementation plan with independent tasks in the current session`.

## Voice

Imperative. Terse. Declarative.

Forbidden everywhere:

- "your human partner" (Superpowers idiom; here we say "you")
- "delve", "leverage" (verb), "robust", "comprehensive", "seamlessly"
- "as an AI ..."
- Marketing hype, fake enthusiasm, em-dash spam
- Emojis (unless literal terminal output)

## Discoverability

The agent must be able to find the skill. Use:

- Words the agent would search for: error messages, symptoms, library names.
- Active verb-first names: `condition-based-waiting` over `async-test-helpers`.
- Gerunds for processes: `writing-plans`, `executing-plans`, `using-git-worktrees`.

## Token efficiency

Aim for:

- Discipline / often-loaded skills: < 200 lines.
- Reference skills: < 500 lines.
- Detail too long for a SKILL.md → put it in a sibling `.md` file and reference it.

## Tables and code blocks

Use tables for reference material. Use fenced code blocks (with language tag) for commands, snippets, and examples. Avoid graphviz diagrams unless a decision is genuinely non-obvious — most decisions fit in a table.

## Anti-patterns

| Anti-pattern | Why bad |
|---|---|
| Multi-language examples for the same point | Mediocre quality, maintenance burden. Pick one good example. |
| Generic step labels (`step1`, `helper2`) | No semantic meaning. |
| Narrative ("In our session on 2025-10-03 ...") | Specific, not reusable. |
| Code in flowcharts | Can't copy-paste. |
| Cross-references with `@` syntax that force-load files | Burns context. Use plain text path or `path/to/SKILL.md`. |

## TDD-for-skills cycle

For any **discipline-enforcing** skill (TDD, verification, debugging):

### RED — baseline

Run a pressure scenario with a sub-agent **without** the skill. Note the exact rationalization the agent uses ("I'll write tests after to save time"). That phrase becomes a row in the rationalization table.

### GREEN — minimal skill

Write a skill that addresses the rationalizations you observed. Don't pre-empt hypothetical ones.

### REFACTOR — close loopholes

Re-run the scenario with the skill loaded. New rationalization? Add it to the table. Repeat until stable.

For **technique** or **reference** skills, the cycle is simpler: write the skill, ask a sub-agent to apply it, fix gaps the agent surfaces.

## Checklist

- [ ] Filename is `SKILL.md` (exact case)
- [ ] Frontmatter has `name` and `description`
- [ ] `name` is kebab-case and matches the directory
- [ ] `description` starts with `Use when ...` and does NOT summarize the workflow
- [ ] Body has the standard sections (Overview, When to use, Process/Rule, Quick reference, Pairs with, Bottom line)
- [ ] No "your human partner" anywhere
- [ ] No emojis
- [ ] No bare URLs (use `<url>` or `[text](url)`)
- [ ] Heading levels increment by one (`##` then `###`, not `##` then `####`)
- [ ] No duplicate sibling headings within the same parent

## Bottom line

A SKILL.md is code for an agent's behaviour. Test it like code: watch the failure first, then write the minimum that fixes it.
