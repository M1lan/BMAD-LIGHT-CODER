# Contributing

This is a personal fork. Most upstream-bound contributions belong on
[bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD).

## Before opening a PR

1. Search existing issues and discussions on the upstream repo.
2. For a non-trivial change (new features, multi-file refactors), confirm
   scope with a maintainer first — large unsolicited PRs are usually
   rejected.

## PR rules

- Target branch: `main` (or `coder-light` for solo-dev variant work).
- One feature or fix per PR. Keep diffs ≤ 800 lines, ideally 200–400.
- Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`,
  `chore:`. Subject ≤ 72 chars.
- Run before pushing:

  ```bash
  npm ci && npm run quality
  ```

  This mirrors `.github/workflows/quality.yaml`.

- AI-assisted code is fine; AI-substitute-for-thinking is not. You must
  understand and be able to defend every line.

## File-reference validation

| File pattern         | Validator               | Extractor             |
| -------------------- | ----------------------- | --------------------- |
| `*.yaml`, `*.yml`    | `validate-file-refs.js` | `extractYamlRefs`     |
| `*.md`, `*.xml`      | `validate-file-refs.js` | `extractMarkdownRefs` |
| `*.csv`              | `validate-file-refs.js` | `extractCsvRefs`      |

Run: `npm run validate:refs`.

## Code of Conduct

See [`.github/CODE_OF_CONDUCT.md`](.github/CODE_OF_CONDUCT.md).

## License

By contributing, you agree your contribution is MIT-licensed.
