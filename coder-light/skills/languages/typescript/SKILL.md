---
name: typescript
description: Use when writing or editing TypeScript at ista-se — strict mode, pnpm, Vitest, ESLint, modern Node 22+
---

# TypeScript

## Overview

TypeScript with `strict: true` and friends. pnpm (not npm) for the package manager. Vitest for tests. ESLint flat config. Node 24 LTS (or 22 LTS where pinned).

## Toolchain

| Tool | Where | Version target |
|---|---|---|
| `node` | `/opt/homebrew/bin/node` | 24 LTS (or 22 LTS where pinned) |
| `pnpm` | `/opt/homebrew/bin/pnpm` | 9+ |
| `tsc` | local devDep | 5.4+ |
| `vitest` | local devDep | 2+ |
| `eslint` | local devDep | 9+ (flat config) |
| `tsx` | local devDep | for running `.ts` directly |

Forbidden:

- `npm install -g <anything>` — use `pnpm` and project-local devDeps.
- `nvm` global default that doesn't match the project's `.nvmrc` / `.node-version`.

## tsconfig (minimum)

```jsonc
{
  "compilerOptions": {
    "target": "ES2023",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "noImplicitOverride": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "verbatimModuleSyntax": true,
    "isolatedModules": true,
    "skipLibCheck": true
  }
}
```

`noUncheckedIndexedAccess` is the one most projects skip and most regret. Keep it on.

## Style and lint

ESLint 9 flat config (`eslint.config.mjs`), plus typescript-eslint and eslint-plugin-unicorn:

```bash
pnpm lint                # eslint .
pnpm lint:fix            # eslint . --fix
pnpm format              # prettier --write .
pnpm format:check        # prettier --check .
```

Prettier handles formatting. Don't bikeshed style in code review — the linter is the law.

## Test runner

```bash
pnpm test                                   # all tests, single run
pnpm test:watch                             # watch
pnpm test src/auth/auth.test.ts             # one file
pnpm vitest run -t 'rotates tokens'         # by name
pnpm vitest --coverage                      # coverage
```

## Verification recipe

```bash
pnpm lint && pnpm typecheck && pnpm test
```

Where `typecheck` is `tsc --noEmit`.

## Idioms

| Idiom | Why |
|---|---|
| `as const` on literal arrays/objects | Narrow types, enables pattern matching with `satisfies`. |
| `satisfies` operator | Verify a value matches a type without widening it. |
| Discriminated unions (`type X = A \| B \| C`) | Exhaustive `switch` checks via `never`. |
| Branded types (`type UserId = string & { __brand: 'UserId' }`) | Compile-time-safe IDs. |
| `unknown` over `any` | `any` disables the type checker. `unknown` forces narrowing. |
| `readonly` on arrays / objects | Prevents accidental mutation. |
| `import type { Foo } from './foo'` | Erased at runtime, plays nice with `verbatimModuleSyntax`. |

## Common pitfalls

| Pitfall | Fix |
|---|---|
| `any` to silence the type checker | Solve the actual type problem. |
| `as Foo` cast without runtime check | Use `zod`/`valibot` to parse external data, then types follow. |
| `JSON.parse(x)` typed as `any` | Wrap with a parser or assign to `unknown`. |
| `fetch` without timeout | `AbortSignal.timeout(ms)` or `AbortController`. |
| Top-level `await` in a CommonJS package | Switch to `"type": "module"` and ESM. |
| `enum` | Prefer union of string literals. |
| `namespace` | Modules instead. |
| `process.env.X` typed as `string` | It's `string \| undefined`. Validate at boot. |

## Async pitfalls

- Floating promises crash silently. Configure `@typescript-eslint/no-floating-promises`.
- `Promise.all` fails fast — use `Promise.allSettled` if you need all results.
- For cancellation, `AbortSignal` is the standard. Forward it through layers.

## Project layout (typical app)

```text
package.json
pnpm-lock.yaml
tsconfig.json
eslint.config.mjs
src/
tests/                    # or co-located *.test.ts
```

## Cross-refs

- `../../core/test-driven-development/SKILL.md` — Vitest is the runner.
- `../../core/verification-before-completion/SKILL.md` — `pnpm lint && pnpm typecheck && pnpm test` is the verification command.
- `../../platform/gitlab-glab/SKILL.md` — pipeline runs the same command on a Node 24 image (or 22 LTS where pinned).

## Bottom line

`strict` everything. pnpm. Vitest. Flat ESLint. `unknown` not `any`. Verify with `pnpm lint && pnpm typecheck && pnpm test`.
