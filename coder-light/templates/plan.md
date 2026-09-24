# {{Feature Name}} Implementation Plan

> Implement task-by-task. Steps use `[ ]` checkboxes. Mark `[x]` when done, `[~]` when blocked, `[!]` when failed.

**Goal:** {{one sentence}}

**Approach:** {{2–3 sentences on architecture / strategy}}

**Stack:** {{key tech, libraries, language version}}

**Verification:** {{the single command that proves it works, e.g. `cargo nextest run` or `pnpm test`}}

---

## Files touched

- Create: `path/to/new.rs`
- Modify: `path/to/existing.rs:120-180`
- Test: `tests/path/to/new_test.rs`

## Tasks

### Task 1: {{Component name}}

**Files:**

- Create: `exact/path.ext`
- Test: `tests/exact/path_test.ext`

- [ ] **Step 1: Write the failing test**

```rust
#[test]
fn rejects_empty_input() {
    assert!(matches!(parse(""), Err(ParseError::Empty)));
}
```

- [ ] **Step 2: Run the test, watch it fail**

```bash
cargo nextest run rejects_empty_input
```

Expected: `FAIL` with `parse not defined` or `error[E0425]`.

- [ ] **Step 3: Write the minimal implementation**

```rust
pub fn parse(s: &str) -> Result<Token, ParseError> {
    if s.is_empty() { return Err(ParseError::Empty); }
    todo!()
}
```

- [ ] **Step 4: Run the test, watch it pass**

```bash
cargo nextest run rejects_empty_input
```

Expected: `PASS`.

- [ ] **Step 5: Commit**

```bash
git add tests/path src/path
git commit -m "feat(parser): reject empty input"
```

### Task 2: {{...}}

(repeat the bite-sized step pattern)

---

## Out of scope

- {{things explicitly NOT in this plan}}

## Risks

- {{thing that could go wrong + mitigation}}

## Done criteria

- [ ] All task checkboxes are `[x]`
- [ ] `{{verification command}}` passes with exit 0
- [ ] No `[!]` markers remain
- [ ] One commit per task; commit messages follow Conventional Commits
