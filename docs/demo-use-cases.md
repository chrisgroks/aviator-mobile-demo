# Cursor Automations + Aviator: Demo Deck

---

## Slide 1: The Problem

- CI pipelines break. Tests fail. Security scans find vulnerabilities.
- Developers context-switch to fix issues they didn't cause -- merge conflicts, flaky tests, dependency CVEs.
- On-call engineers get paged, manually triage Datadog alerts, dig through logs.
- All of this is repetitive, interruptible, and automatable.

**Talking point**: "What if your CI pipeline could fix itself?"

---

## Slide 2: The Solution -- Cursor Automations + Aviator

- **Cursor Automations**: Event-driven AI agents that respond to pipeline events automatically.
- **Aviator**: Intelligent merge queue that orchestrates the pipeline.
- Together: a self-healing CI/CD pipeline.

```
Developer pushes code
       |
       v
  Aviator Merge Queue -- validates CI
       |
       v
  CI fails? --> Cursor Automation fires
                    |
                    v
              AI Agent fixes the code, pushes
                    |
                    v
              CI re-runs, Aviator re-evaluates
                 (loop until green)
```

**Talking point**: "The automation fires, fixes, and shuts down. If CI still fails, it re-triggers. No human in the loop."

---

## Slide 3: Why Aviator? (Not just GitHub)

| Problem | GitHub Native | Aviator |
|---------|-------------- |---------|
| Merge queue speed | Serial. PRs test one at a time. | Parallel -- multiple PRs tested concurrently. |
| Flaky tests | PR ejected. Manual re-queue. | Auto-detection, auto-retry, flake tracking. |
| Queue priority | FIFO only. | Priority queuing -- hotfixes jump the line. |
| Change-based testing | Full CI suite every time. | Only run affected tests. Saves time and cost. |
| Stacked PRs | No dependency awareness. | First-class stacked PR support. |
| Release management | Manual tags + workflows. | Structured release cuts, environment promotion. |
| Merge analytics | None. | Cycle time, wait time, flake rates, throughput. |

**Talking point**: "GitHub Actions runs your CI. Aviator makes sure the process around merging is fast and reliable. They're complementary."

---

## Slide 4: How Automations Work

**Triggers** -- what starts the automation:
- CI completed (pass/fail)
- PR opened / pushed / merged / commented
- Webhook (from any external system)
- Slack message
- Linear issue
- Cron schedule

**Agent** -- a Cloud Agent spins up in a Linux VM with the repo cloned. It can:
- Read CI logs, error output, scan results
- Edit code, run tests, commit and push
- Use MCP tools (Datadog, Sentry, Slack, etc.)
- Create PRs, leave comments

**Lifecycle** -- fire and forget. Agent works, shuts down. If the fix doesn't work, CI re-triggers the automation.

---

## Slide 5: Live Demo -- CI Failure Auto-Fix

**Setup**: Mobile app repo (Android + iOS) with Aviator merge queue.

**What happens**:
1. Open a PR with a broken unit test
2. CI fails (Gradle test / Swift test)
3. Automation fires -- agent reads CI logs, identifies the failure
4. Agent fixes the code, pushes to the PR branch
5. CI re-runs -- passes
6. Aviator merge queue picks up the PR

**Key config**:
- Trigger: CI completed, condition: Failure
- `ignore_base_failures` enabled -- only fix new regressions, not pre-existing issues

**Talking point**: "The developer pushed broken code. Within minutes, the automation diagnosed it, fixed it, and CI is green. No human touched it."

---

## Slide 6: Live Demo -- Security Scan Remediation

**Setup**: Snyk dependency scanning integrated via webhook.

**What happens**:
1. PR introduces a dependency with a known CVE
2. Snyk scan runs, finds the vulnerability
3. Webhook fires to Cursor automation with the scan payload
4. Agent parses the payload, identifies the vulnerable dependency and branch
5. Agent bumps the dependency version, pushes the fix to the PR
6. CI re-runs, scan passes, Aviator merges

**How the agent knows which PR to fix**: The webhook payload contains the branch name. Agent uses `gh pr list --head <branch>` to find the PR, checks out the branch, and pushes directly.

**Talking point**: "A CVE was introduced at 2pm. By 2:05pm, the automation had patched it. No Slack thread, no ticket, no context-switching."

---

## Slide 7: Live Demo -- Datadog Incident Investigation

**Setup**: Datadog monitor fires, webhook triggers a Cursor automation with Datadog MCP.

**What happens**:
1. Datadog monitor detects error rate spike
2. Webhook fires to Cursor automation
3. Agent uses Datadog MCP to investigate:
   - Searches logs for recent errors
   - Queries metrics to find when the spike started
   - Pulls distributed traces to identify failing spans
   - Maps service dependencies for blast radius
   - Checks RUM events for user-facing impact
4. Agent creates a Datadog investigation notebook with findings
5. Agent correlates with codebase, proposes or creates a fix PR

**Talking point**: "The agent has the same tools an on-call engineer uses -- logs, metrics, traces. It investigates like a human would, but in minutes instead of hours."

*Note: This demo uses existing automation sessions from prod, not this repo.*

---

## Slide 8: Cloud Agents API -- Beyond Automations

Automations are event-driven. But sometimes you need programmatic control.

**Use case: On-Demand Investigation**
- "Investigate" button in internal tooling (Retool, Slack bot)
- Calls `POST /v1/agents` with dynamic context
- Poll status, retrieve results

**Use case: Batch Migration**
- Script spawns N agents in parallel, one per module
- Each agent handles its piece of a codebase-wide migration
- Orchestrator collects PRs when done

**When to use API vs. Automations**:
- Automations: anything triggered by a pipeline or monitoring event
- API: human-initiated tasks, multi-agent orchestration, custom tooling integration

---

## Slide 9: More Use Case Ideas

| Category | Use Case | Trigger |
|----------|----------|---------|
| **Code Review** | Auto-review every PR, post inline comments | PR opened |
| **Security** | Guardian -- flag high-risk patterns, post to security channel | PR opened |
| **Incidents** | Sentry alert triggers investigation + fix PR | Webhook |
| **Productivity** | Daily digest -- categorize merged PRs with fun awards | Cron |
| **Productivity** | Weekly PR summary for standups | Cron |
| **Docs** | Auto-update README when code changes | PR merged |
| **CI** | CI autofix with memory -- agent learns from past fixes | CI failure |
| **Pipeline** | Aviator queue conflict resolution | Webhook |
| **Dependencies** | Weekly dependency update bot | Cron |
| **Project Mgmt** | Linear/JIRA issue auto-implementation | Linear / Webhook |
| **Compliance** | Log merged PRs to Notion database | PR merged |

**Talking point**: "The trigger system is flexible enough for almost anything. If it can fire a webhook or match a Git event, you can automate it."

---

## Slide 10: Mobile-Specific Considerations

- Cloud Agents run on **Linux VMs**
- **Android**: Builds and tests run natively on Linux. Full verification loop.
- **iOS**: Requires macOS for Xcode builds. Agent fixes code based on CI log output, pushes, and relies on CI (with macOS runners) to verify. The recursive trigger loop handles retries.
- **Swift on Linux**: This demo uses Swift Package Manager on Linux for unit tests -- many issues caught without macOS.

**Talking point**: "For Android, the agent can build and test locally before pushing. For iOS, it fixes blind from CI logs and lets the pipeline verify. The recursive loop converges to green either way."

---

## Slide 11: Wrap-Up

**What we showed**:
- CI failures auto-fixed in minutes, no human intervention
- Security vulnerabilities auto-remediated from scan webhook
- Datadog incidents investigated with full observability context
- Cloud Agents API for programmatic, on-demand tasks

**The pitch**:
- Aviator manages your merge queue and pipeline intelligence
- Cursor Automations handle remediation when things break
- Together: a self-healing pipeline that keeps developers focused on building, not fixing

---

## Appendix: Demo Repo

| Component | Path |
|-----------|------|
| Android app (Kotlin) | `android/` |
| iOS app (Swift) | `ios/` |
| Android CI | `.github/workflows/android-ci.yml` |
| iOS CI | `.github/workflows/ios-ci.yml` |
| Security scan (Snyk) | `.github/workflows/security-scan.yml` |
| Aviator build | `.github/workflows/aviator-build.yml` |
| Aviator deploy | `.github/workflows/aviator-deploy.yml` |

See [technical-reference.md](technical-reference.md) for detailed automation internals, Datadog MCP tool inventory, and trigger payload mechanics.
