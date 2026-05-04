---
name: kotlin
description: Use when writing or editing Kotlin code at ista-se — covers Gradle, ktlint, detekt, JUnit5/Kotest, and coroutines pitfalls
---

# Kotlin

## Overview

Kotlin on the JVM. Gradle (Kotlin DSL). ktlint + detekt for static analysis. JUnit 5 (or Kotest) for tests. `kotlinx.coroutines` for async.

## Toolchain (assumed installed)

| Tool | Where | Version target |
|---|---|---|
| `kotlin` | `/opt/homebrew/bin/kotlin` | 2.0+ |
| `gradle` | wrapper (`./gradlew`), not system | 8.7+ |
| `ktlint` | `/opt/homebrew/bin/ktlint` | latest |
| `detekt` | Gradle plugin | 1.23+ |

Always commit and use `./gradlew`, not `gradle`. The wrapper pins the version.

## Project layout

```text
build.gradle.kts
settings.gradle.kts
gradle/libs.versions.toml      # version catalog
src/main/kotlin/<pkg>/...
src/test/kotlin/<pkg>/...
```

JVM target: 21 (LTS). `kotlinOptions { jvmTarget = "21" }` or the modern `compilerOptions { jvmTarget = JvmTarget.JVM_21 }`.

## Style and lint

```bash
./gradlew ktlintCheck      # check
./gradlew ktlintFormat     # auto-fix

./gradlew detekt           # static analysis
```

ktlint config: official Kotlin style. Detekt: enable `complexity`, `style`, `performance`, `coroutines` rule sets at minimum.

## Test runner

JUnit 5 by default:

```bash
./gradlew test                                   # all
./gradlew test --tests "com.ista.auth.*"         # package
./gradlew test --tests "*RotatesTokens*"         # name pattern
```

Kotest equivalent:

```bash
./gradlew test --tests "AuthSpec"
```

## Verification recipe

```bash
./gradlew ktlintCheck detekt test
```

For a fast inner loop:

```bash
./gradlew --continuous test --tests "AuthSpec"
```

## Coroutines pitfalls

| Pitfall | Fix |
|---|---|
| `runBlocking` in production code | Use `suspend fun` and let the caller pick the dispatcher. |
| `GlobalScope.launch` | Forbidden in app code; structured concurrency only. |
| Mixing `Dispatchers.IO` and CPU-bound work | Use `Dispatchers.Default` for CPU-bound. |
| Forgotten cancellation | Long loops must `yield()` or check `isActive`. |
| Tests using real time | `runTest { ... }` from `kotlinx-coroutines-test` and a `TestScheduler`. |

## Common pitfalls

| Pitfall | Fix |
|---|---|
| `!!` (force-unwrap) | Use `?:`, `requireNotNull(x) { "msg" }`, or destructure. |
| `lateinit` for things that have a value at construction | Use a regular `val`. |
| Catching `Throwable` | Catch the specific exception. Never swallow `CancellationException`. |
| `data class` with mutable fields | Data classes are values; keep `val` only. |
| Custom getters on `var` properties | Surprising re-evaluation on each read. Prefer `val` + computed property. |
| Companion object as a god-bag | If it grows, it's hiding a class. Extract one. |

## Idioms

- `sealed class` / `sealed interface` for closed hierarchies; pair with exhaustive `when`.
- `value class` for type-safe wrappers (`UserId`, `Email`).
- `Result<T>` from stdlib for fallible boundaries; don't `Result` everywhere.
- `inline fun <reified T>` for type-erased generics.
- Top-level functions over static utility classes.

## Cross-refs

- `../../core/test-driven-development/SKILL.md` — TDD applies; the failing test runs through `./gradlew test`.
- `../../core/verification-before-completion/SKILL.md` — `./gradlew ktlintCheck detekt test` is the verification command.
- `../../platform/gitlab-glab/SKILL.md` — CI runs the same Gradle command in the pipeline.

## Bottom line

Kotlin DSL, JVM 21, ktlint + detekt, JUnit 5, structured concurrency, no `!!`. Verify with `./gradlew ktlintCheck detekt test`.
