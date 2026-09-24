---
name: java
description: Use when writing or editing modern Java (21+) code at ista-se — covers Maven/Gradle, JUnit 5, Mockito, SpotBugs, and modern language features (records, sealed types, pattern matching, virtual threads)
---

# Java

## Overview

Modern Java on an LTS release. As of 2026, Java 25 (Sept 2025) is the current LTS; Java 21 (Sept 2023) is the previous LTS. Records, pattern matching, sealed types, virtual threads, scoped values. Maven or Gradle (the project's choice — don't migrate without a reason). JUnit 5. Mockito for mocks. SpotBugs + Error Prone for static analysis.

## Toolchain

| Tool | Where | Version target |
|---|---|---|
| `java` | `/opt/homebrew/bin/java` (Temurin via Homebrew, or SDKMAN) | 25 LTS (or 21 LTS where pinned) |
| `mvn` | `/opt/homebrew/bin/mvn` | 3.9+ |
| `gradle` | `./gradlew` (wrapper) | 8.7+ |

Pin the toolchain in the build:

```kotlin
// Gradle (Kotlin DSL)
java {
    toolchain { languageVersion = JavaLanguageVersion.of(25) }
}
```

```xml
<!-- Maven -->
<properties>
  <maven.compiler.release>25</maven.compiler.release>
</properties>
```

Drop to `21` if the project hasn't moved off the previous LTS yet.

## Style and lint

- Format: Google Java Format or Spotless plugin (Maven `spotless-maven-plugin`, Gradle `com.diffplug.spotless`).
- Static analysis: SpotBugs + Error Prone.

```bash
mvn spotless:apply spotless:check
./gradlew spotlessApply spotlessCheck

mvn spotbugs:check
./gradlew spotbugsMain
```

## Test runner

JUnit 5 (Jupiter):

```bash
mvn test
mvn -Dtest='AuthServiceTest#rotatesTokens' test

./gradlew test
./gradlew test --tests 'com.ista.auth.AuthServiceTest.rotatesTokens'
```

Mockito 5 with `mockito-junit-jupiter`. `mockito-inline` is no longer needed — final-class mocking is on by default in 5+.

## Verification recipe

```bash
# Maven
mvn -B verify

# Gradle
./gradlew check     # runs spotless, spotbugs, tests
```

`mvn verify` runs `compile + test + spotbugs + integration-test`. Cheaper alternative: `mvn test`.

## Modern Java idioms (use these)

| Idiom | When |
|---|---|
| `record` | Immutable DTOs / value objects. |
| `sealed interface` + `permits` | Closed hierarchy + exhaustive `switch`. |
| Pattern-matching `switch` (with `case Foo f when ...`) | Replaces `instanceof` chains. |
| `var` (locals) | When the type is obvious from the right-hand side. |
| Text blocks (`"""`) | Multi-line strings without escaping. |
| `Optional<T>` (return types only) | Never as a field, never as a method parameter. |
| Virtual threads (`Thread.ofVirtual()`, `Executors.newVirtualThreadPerTaskExecutor()`) | I/O-bound concurrency in Java 21+. |
| Scoped values (`ScopedValue.where(...)`) | Replaces `ThreadLocal` for inheritable, immutable per-task context (Java 25+). |
| Stream gatherers (`Stream.gather`) | Custom intermediate operations beyond `map`/`filter`/`reduce` (Java 24+). |

## Common pitfalls

| Pitfall | Fix |
|---|---|
| `null` returns | Return `Optional<T>` or throw. |
| `new ArrayList<>()` for an empty default | `List.of()`. |
| `Optional.get()` without `isPresent()` | `orElseThrow`, `orElse`, or `map`. |
| `equals` / `hashCode` hand-rolled | Use a `record`. |
| Catching `Exception` | Catch the specific subclass. |
| Mutable static state | Make it final and immutable, or move it to a request-scoped bean. |
| `ExecutorService` not shut down | `try-with-resources` (Java 19+ supports `AutoCloseable` on `ExecutorService`). |
| `String` concatenation in a hot loop | `StringBuilder` or `String.join`. |
| Using `Date`/`Calendar` | `java.time.*` only. |

## Project layout (Maven)

```text
pom.xml
src/main/java/com/ista/...
src/test/java/com/ista/...
src/main/resources/
src/test/resources/
```

Same structure for Gradle, with `build.gradle.kts` instead of `pom.xml`.

## Cross-refs

- `../../core/test-driven-development/SKILL.md` — JUnit 5 is the test runner; `mvn test` / `./gradlew test` runs the failing test.
- `../../core/verification-before-completion/SKILL.md` — `mvn verify` or `./gradlew check` is the verification command.
- `../../platform/gitlab-glab/SKILL.md` — pipeline runs `mvn -B verify`.

## Bottom line

Java 25 LTS (or 21 LTS where pinned), records, sealed types, virtual threads, scoped values, Spotless + SpotBugs, JUnit 5 + Mockito 5. Verify with `mvn verify` or `./gradlew check`.
