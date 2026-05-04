# {{Title — Conventional Commit subject, e.g. `feat(auth): rotate MR tokens`}}

## Summary

- {{2–4 bullets: what changed, why, and the user-visible effect}}

## Why

{{One paragraph on motivation. Reference the issue: `Closes ista-se/repo#123`.}}

## How it was tested

```bash
{{exact verification commands run, with their exit status}}
```

- [ ] Unit tests pass: `{{test command}}`
- [ ] Build / typecheck passes: `{{build command}}`
- [ ] Lint passes: `{{lint command}}`
- [ ] Manual check: {{what you exercised by hand, if anything}}

## Risk and rollback

- **Blast radius:** {{which services/modules}}
- **Rollback:** {{revert SHA or feature flag}}

## Out of scope

- {{things deliberately not in this MR}}

## Checklist

- [ ] Conventional Commit subject
- [ ] No unrelated changes bundled in
- [ ] No secrets, no `dbg!`/`println!`/`console.log` left behind
- [ ] CI green on the MR pipeline
- [ ] Updated docs/AGENTS.md if behaviour visible to other agents changed

---

<sub>Generated against `gitlab.com/ista-se/{{repo}}` — never GitHub.</sub>
