---
name: rust
description: Use when writing or editing Rust at ista-se — cargo, clippy, rustfmt, anyhow/thiserror, tokio, nextest, criterion
---

# Rust

## Overview

Stable Rust, edition 2024. cargo, clippy, rustfmt, cargo-nextest. `anyhow` for application errors, `thiserror` for library errors. `tokio` for async. `criterion` for benchmarks.

## Toolchain

| Tool | Where | Version target |
|---|---|---|
| `rustup` | `~/.cargo/bin/rustup` | latest stable |
| `cargo` | `~/.cargo/bin/cargo` | matches stable |
| `cargo-nextest` | `cargo install cargo-nextest --locked` | latest |
| `cargo-watch` | `cargo install cargo-watch` (optional) | latest |

Pin the toolchain in the repo:

```toml
# rust-toolchain.toml
[toolchain]
channel = "1.85"
components = ["rustfmt", "clippy"]
```

Edition 2024 went stable in Rust 1.85 (Feb 2025). Use it on new crates: `edition = "2024"` in `Cargo.toml`.

## Project layout

```text
Cargo.toml
Cargo.lock
src/main.rs        # binary
src/lib.rs         # library
src/<module>/mod.rs
tests/             # integration tests
benches/           # criterion benches
```

For workspaces:

```toml
[workspace]
resolver = "2"
members = ["crates/*"]
```

## Style and lint

```bash
cargo fmt --check                       # check
cargo fmt                               # fix

cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo clippy --fix --allow-dirty
```

`-D warnings` makes clippy a hard gate. Treat lints as errors.

## Test runner

```bash
cargo nextest run                       # all
cargo nextest run -p <crate>            # one crate
cargo nextest run rotates_tokens        # name match
cargo nextest run --workspace --all-features

cargo test --doc                        # doctests (nextest doesn't run them)
```

`cargo nextest` is faster and gives better output than `cargo test`. Run doctests separately.

## Verification recipe

```bash
cargo fmt --check \
  && cargo clippy --workspace --all-targets --all-features -- -D warnings \
  && cargo nextest run --workspace --all-features \
  && cargo test --doc
```

For an inner loop:

```bash
cargo watch -x 'nextest run -p <crate>'
```

## Error handling idioms

| Use | When |
|---|---|
| `Result<T, E>` everywhere fallible | Always. |
| `?` operator | For propagation. |
| `anyhow::Result<T>` | App-level / binaries; loose error type. |
| `thiserror` | Library boundaries; named, matchable error variants. |
| `panic!` | Only for invariants the program author guarantees. |
| `unwrap()` / `expect()` | Tests, examples, build scripts. NEVER in app paths. |

## Common pitfalls

| Pitfall | Fix |
|---|---|
| `unwrap()` in app code | `?` and a typed error. |
| `clone()` to satisfy the borrow checker | Reach for it only after considering `&`, `&mut`, lifetimes. |
| `String` parameter where `&str` works | `&str` (or `impl AsRef<str>`). |
| `Vec<T>` parameter where `&[T]` works | `&[T]`. |
| `Box<dyn Trait>` everywhere | Use generics first; only box when you need heterogeneity. |
| `Arc<Mutex<T>>` reflexively | Reach for channels first; mutex is the last resort. |
| `async fn` that blocks (e.g. `std::fs::read_to_string`) | `tokio::fs::read_to_string` (or `spawn_blocking` for CPU-bound). |
| `tokio::spawn` that's never `await`ed or `JoinHandle`-tracked | Spawned tasks can leak; track or `JoinSet`. |
| `RUST_BACKTRACE=0` | Always run with `RUST_BACKTRACE=1` during dev. |

## Async (tokio) idioms

- One runtime, started once: `#[tokio::main]` for binaries; in tests `#[tokio::test]`.
- `select!` for racing futures, with `biased;` if order matters.
- Cancellation: `tokio_util::sync::CancellationToken` for app-defined cancel; `JoinSet` to track tasks.
- Timeouts: `tokio::time::timeout(dur, fut).await`.

## Performance idioms

- Allocate once, reuse: `Vec::with_capacity`, `String::with_capacity`.
- Iterate, don't index, when possible.
- `criterion` for any perf claim. Don't trust `Instant::now()` micro-benchmarks.
- `cargo flamegraph` (or `samply`) for profiling.

## Cross-refs

- `../../core/test-driven-development/SKILL.md` — `cargo nextest run` is the runner.
- `../../core/verification-before-completion/SKILL.md` — `cargo fmt --check && cargo clippy ... && cargo nextest run` is the verification command.
- `../../platform/gitlab-glab/SKILL.md` — pipeline mirrors the same recipe.

## Bottom line

stable Rust, `-D warnings`, nextest, `anyhow` in apps, `thiserror` in libs, no `unwrap()` in app code. Verify with `cargo fmt --check && cargo clippy ... && cargo nextest run && cargo test --doc`.
