# Agents

## Cursor Cloud specific instructions

This is a mobile CI/CD demo monorepo with two modules: **Android** (Kotlin/Gradle) and **iOS** (Swift Package). There are no backend services, databases, or runtime servers. The "application" is the CI/CD pipeline demonstrated through GitHub Actions workflows.

### System dependencies

- **JDK 17** — required for Android compilation. Set as default via `update-alternatives` and `JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64`.
- **Docker** — required to run Swift (iOS) builds and SwiftLint, since `download.swift.org` is blocked by network restrictions. The `swift:5.10` and `gradle:8.5-jdk17` images are pre-pulled.
- **Kotlin compiler** (`/opt/kotlinc/bin/kotlinc` v1.9.22) — installed from GitHub releases, used for Android compilation without Gradle since Maven Central/Google repos are blocked.

### Network restrictions (important)

The cloud VM blocks TLS connections to most external hosts except GitHub and Docker Hub. This means:
- `services.gradle.org`, `repo1.maven.org`, `dl.google.com`, `plugins.gradle.org`, `download.swift.org` are all **blocked**.
- Gradle cannot resolve plugins or dependencies. The full `./gradlew` build does **not** work.
- iOS builds work inside Docker (`swift:5.10`) because Swift Package Manager only needs the built-in standard library and XCTest.

### Running tests

**iOS (all commands run via Docker):**
```bash
# Build
sudo docker run --rm -v /workspace/ios:/project -w /project swift:5.10 swift build

# Test (8 tests)
sudo docker run --rm -v /workspace/ios:/project -w /project swift:5.10 swift test

# Lint (SwiftLint must be installed inside container)
sudo docker run --rm -v /workspace/ios:/project -w /project swift:5.10 bash -c \
  "apt-get update -qq && apt-get install -y -qq curl unzip > /dev/null 2>&1 && \
   curl -sL https://github.com/realm/SwiftLint/releases/download/0.57.0/swiftlint_linux.zip -o /tmp/swiftlint.zip && \
   unzip -o /tmp/swiftlint.zip -d /usr/local/bin && chmod +x /usr/local/bin/swiftlint && \
   swiftlint lint --strict Sources/ Tests/"
```

**Android (manual compilation, bypassing Gradle):**
```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Compile source
/opt/kotlinc/bin/kotlinc -jvm-target 17 \
  android/app/src/main/kotlin/com/example/aviatordemo/Calculator.kt \
  -d /tmp/android-build

# Compile tests
/opt/kotlinc/bin/kotlinc -jvm-target 17 \
  -classpath "/tmp/android-build:/tmp/junit-4.13.2.jar:/tmp/hamcrest-core-1.3.jar" \
  android/app/src/test/kotlin/com/example/aviatordemo/CalculatorTest.kt \
  -d /tmp/android-build

# Run tests (7 tests)
java -classpath "/tmp/android-build:/tmp/junit-4.13.2.jar:/tmp/hamcrest-core-1.3.jar:/opt/kotlinc/lib/kotlin-stdlib.jar" \
  org.junit.runner.JUnitCore com.example.aviatordemo.CalculatorTest
```

### Docker daemon

Docker must be started manually on each session:
```bash
sudo dockerd &>/tmp/dockerd.log &
sleep 3
```
All `docker` commands require `sudo` since the user is not in the `docker` group.

### Key file locations

| Path | Purpose |
|------|---------|
| `android/` | Kotlin/Gradle Android app with Calculator class |
| `ios/` | Swift Package with Calculator class (runs on Linux) |
| `.github/workflows/` | 5 GitHub Actions CI/CD workflows |
| `/opt/kotlinc/` | Kotlin compiler 1.9.22 |
| `/tmp/junit-4.13.2.jar` | JUnit 4 test runner |
| `/tmp/hamcrest-core-1.3.jar` | JUnit dependency |
