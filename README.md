# Aviator Mobile CI/CD Demo

Demo monorepo showcasing [Aviator](https://aviator.co) integration with GitHub Actions for a mobile app CI/CD pipeline (Android + iOS).

## What's in the box

| Directory | What it is |
|-----------|-----------|
| `android/` | Minimal Kotlin/Gradle Android app with unit tests |
| `ios/` | Minimal Swift Package with unit tests (runs on Linux) |
| `.github/workflows/` | GitHub Actions CI/CD workflows |

### CI Workflows (triggered on PRs)

- **Android CI** -- Gradle lint + JVM unit tests + simulated APK build
- **iOS CI** -- Swift build + XCTest unit tests + simulated IPA build
- **Security Scan** -- SonarCloud static analysis + Snyk dependency scan

### Aviator Workflows (triggered via Aviator Releases)

- **Aviator: Build** -- `workflow_dispatch` build pipeline for release cuts
- **Aviator: Deploy** -- `workflow_dispatch` deployment pipeline

## Setup

### 1. GitHub Actions (automatic)

CI workflows run automatically on pull requests. No extra setup needed beyond repo secrets for SonarCloud and Snyk (optional -- see below).

### 2. Aviator

1. **Create account**: Sign up at [app.aviator.co](https://app.aviator.co/auth/login)
2. **Install GitHub App**: During onboarding, connect the Aviator GitHub App and authorize this repository
3. **Configure MergeQueue**:
   - Go to Repositories > select this repo
   - Set trigger label to `mergequeue` (default)
   - Verify required status checks include: `Lint and Test` (Android CI), `Build and Test` (iOS CI)
   - Optionally add `SonarCloud Analysis` and `Snyk Security Scan` as required checks
4. **Configure Releases** (optional):
   - Create a Release Project for this repo
   - Set build workflow to `aviator-build.yml`
   - Set deploy workflow to `aviator-deploy.yml`
   - Add environment(s): `staging`, `production`
5. **Add repo secret**: Generate an API token at [workspace integrations](https://app.aviator.co/settings/workspace/integrations) and add it as `AVIATOR_API_TOKEN` in GitHub repo settings > Secrets

### 3. SonarCloud (optional)

1. Sign up at [sonarcloud.io](https://sonarcloud.io) with your GitHub account
2. Import this repository
3. Add `SONAR_TOKEN` as a repo secret in GitHub
4. Add repo variables `SONAR_ORG` and `SONAR_PROJECT_KEY` (see `sonar-project.properties` for values)

### 4. Snyk (optional)

1. Sign up at [snyk.io](https://snyk.io) with your GitHub account
2. Add `SNYK_TOKEN` as a repo secret in GitHub

## Using MergeQueue

Once Aviator is connected:

1. Open a pull request
2. Wait for CI checks to pass
3. Add the `mergequeue` label to the PR
4. Aviator validates and merges the PR automatically

Slash commands in PR comments:
- `/aviator queue` -- Queue the PR for merge
- `/aviator dequeue` -- Remove from queue
- `/aviator refresh` -- Re-evaluate queue status

## Cost

Everything runs within free tiers:

| Service | Free Tier | Limit |
|---------|-----------|-------|
| Aviator | < 15 users | Free |
| GitHub Actions | Private repos | 2,000 min/month (Linux runners) |
| SonarCloud | < 50K lines | Free |
| Snyk | Free plan | 200 tests/month |

All CI runs on `ubuntu-latest` (1x minute multiplier). No macOS runners are used.
