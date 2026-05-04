# When to use coder-light vs full BMAD

## Decision tree

| Question | If yes | If no |
|---|---|---|
| Are you a solo dev on this project? | continue | full BMAD |
| Is this a fresh repo, no PRD, no stakeholders? | continue | full BMAD |
| Are you the PM, the architect, the reviewer all at once? | continue | full BMAD |
| Do you need sprints / epics / stories / retrospectives? | full BMAD | continue |
| Do you need PRD validation, UX design workflows, market research? | full BMAD | continue |
| Do you want light discipline (TDD, debugging, verification, MR hygiene)? | **coder-light** | full BMAD |

If you answered "continue" to all the relevant questions: use **coder-light**.

## Where coder-light wins

- Greenfield prototypes.
- Solo side projects.
- Internal tools.
- One-off CLI utilities.
- Spike branches before committing to a full BMAD workflow.
- Any context where the full BMAD ceremony (PRD → architecture → epics → stories → sprint plan) would slow you down for no benefit.

## Where full BMAD wins

- Multi-person teams.
- Products with paying users / external stakeholders.
- Projects that already use BMAD and have artifacts (PRDs, architecture docs, story queues).
- Anywhere requirements are negotiated, not just decided.

## What coder-light keeps from full BMAD

- The discipline core: TDD, systematic debugging, verification.
- Plan-then-execute: write a plan, execute it task-by-task.
- Sub-agent delegation patterns (parallel + sub-agent-driven).
- Worktree-per-feature isolation.
- A consistent skill format.

## What coder-light drops

- Analyst, PM, UX, architect personas.
- PRD / product brief / pr-faq workflows.
- Brainstorming, market research, domain research.
- Sprint planning, story creation, retrospectives, sprint status.
- Story-driven dev loops.
- Editorial review skills, document sharding.
- The bmm/bmb/tea/bmgd/cis module ecosystem.

## Switching between

You can move from coder-light to full BMAD when the project grows up. The plan format (`plans/YYYY-MM-DD-<slug>.md`) and the skill format are compatible. Add the `bmm` module via `npx bmad-method install` and start producing PRDs / stories alongside the existing work. coder-light's skills don't conflict with full BMAD's.

You can also stay in coder-light forever. There is no graduation requirement.
