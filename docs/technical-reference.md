# Technical Reference: Cursor Automations

Internal reference material for the demo. Not intended for slide content.

---

## How Trigger Payloads Reach the Agent

### Generic Webhook Trigger

- The POST body is typed as `GenericWebhookPayload` with two fields: `context` (string) and `webhookPayload` (arbitrary JSON)
- Both fields are **concatenated directly onto the agent's prompt** as XML blocks: `<webhook_context>` and `<webhook_payload>`
- No template variables -- literal string concatenation into the prompt
- **No PR-aware tools created** -- triggerMetadata only stores `{ source: "webhook" }`, so the agent has no prComment or requestReviewers tools. It must use `gh` CLI for PR interactions.
- The webhook body is NOT persisted in the DB triggerMetadata -- it lives only in the prompt text.

### Git Trigger (PR events, CI completed, push)

- The raw GitHub webhook is parsed by `buildGitTriggerContext()` into structured data: `prNumber`, `author`, `baseBranch`, `diffCommand`, etc.
- This structured context is injected as a separate `<automation_trigger_info>` message preceding the prompt
- Typed trigger metadata (`pr_number`, `repo_url`, `author`, `pr_title`, `branch`, `base_branch`) is stored in the DB
- **PR-aware tools are dynamically created** at agent startup -- prComment, requestReviewers, etc. are available because the system knows the PR number

### Practical Implications

| | Webhook Trigger | Git Trigger (CI completed) |
|-|----------------|---------------------------|
| Agent sees payload? | Yes -- full POST body in `<webhook_payload>` XML block in prompt | Yes -- structured `<automation_trigger_info>` with PR number, branch, etc. |
| Knows which PR? | Only if the webhook body contains it (agent must parse) | Yes -- automatically extracted from GitHub event |
| PR Comment tool? | No -- must use `gh` CLI | Yes -- native tool available |
| PR Approve tool? | No | Yes (if enabled) |
| Best for | External systems (Datadog, Sonar webhook, JIRA) | GitHub-native events (CI failure, PR opened) |

---

## Available Trigger Types

| Trigger | Config | Use Cases |
|---------|--------|-----------|
| `CronTrigger` | Cron expression | Daily digest, weekly summary, dependency updates, proactive health checks |
| `GitTrigger.pull_request` | `OPENED`, `PUSHED`, `MERGED`, `COMMENTED` | PR review, Guardian, doc sync, Notion logging |
| `GitTrigger.ci_completed` | `FAILURE` / `SUCCESS` / `ANY` | CI autofix, security remediation, post-merge validation |
| `WebhookTrigger` | Generic POST | Datadog alerts, Sentry alerts, Sonar/Snyk, JIRA, Aviator events |
| `SlackTrigger` | Channel + message filter | Incident triage, ad-hoc requests |
| `LinearTrigger` | Issue created / status changed | Auto-implementation, triage |

---

## Datadog MCP Tool Inventory

| Tool | Category | What It Does |
|------|----------|-------------|
| `search_datadog_logs` | Logs | Search raw log entries or detect log patterns |
| `analyze_datadog_logs` | Logs | SQL-based log analytics (counts, group-bys, aggregations) |
| `search_datadog_metrics` | Metrics | Discover available metrics by name, tag, or usage |
| `get_datadog_metric` | Metrics | Query timeseries data with formulas and functions |
| `get_datadog_metric_context` | Metrics | Get metric metadata, available tags, and related assets |
| `search_datadog_spans` | APM | Search spans across distributed traces |
| `get_datadog_trace` | APM | Retrieve full trace with all spans and timing |
| `search_datadog_monitors` | Alerting | List monitors, filter by status/tag/title |
| `search_datadog_incidents` | Incidents | List incidents by state, severity, team |
| `get_datadog_incident` | Incidents | Get incident details with timeline |
| `search_datadog_services` | Service Catalog | Discover services, teams, descriptions |
| `search_datadog_service_dependencies` | Service Catalog | Map upstream/downstream dependencies |
| `search_datadog_rum_events` | RUM | Client-side errors, performance, user sessions |
| `search_datadog_hosts` | Infrastructure | SQL-based host inventory queries |
| `search_datadog_dashboards` | Dashboards | Find dashboards and their underlying queries |
| `search_datadog_events` | Events | Search system events by time, source, tags |
| `search_datadog_notebooks` | Notebooks | Find existing investigation notebooks |
| `get_datadog_notebook` | Notebooks | Read notebook contents |
| `create_datadog_notebook` | Notebooks | Create notebooks with markdown, log cells, metric graphs |
| `edit_datadog_notebook` | Notebooks | Append cells to existing notebooks |

---

## MCP Integrations Available

| MCP Server | Status | Tools | Use In Demo |
|------------|--------|-------|-------------|
| **Datadog** | Connected | 20 tools (logs, metrics, traces, spans, incidents, monitors, notebooks, RUM, services, hosts, dashboards, events) | Incident investigation, health digests, notebook reports |
| **Sentry** | Available | Error triage, stack traces | Application error investigation |
| **Slack** | Available | Messaging | Notifications, incident reports, digests |
| **Linear** | Available | Issue tracking | Auto-implementation trigger, status updates |
| **Notion** | Available | Databases, pages | PR logging, documentation, reporting |
| **Atlassian (JIRA)** | Available | Issue tracking | Enterprise issue tracking via webhook |
| **GitHub** | Available | PR/repo operations | PR management |
| **LaunchDarkly** | Available | Feature flags | Feature flag rollback on incident (potential) |

---

## Cloud Agents API vs. Automations

**Short answer**: Automations are the abstraction; the API is the primitive. Automations are better for ~80% of use cases. The API matters for the other 20%.

| Dimension | Automations | Cloud Agents API |
|-----------|-------------|------------------|
| **Trigger model** | Predefined: Git events, webhooks, cron, Slack, Linear | Anything that can make an HTTP call |
| **Lifecycle** | Managed. Fire-and-forget. | You own it. Poll, cancel, send followups. |
| **Built-in actions** | Slack, PR comments, Git PR, MCP, check runs | None built-in -- agent uses whatever tools the VM has |
| **Orchestration** | Single agent per trigger. No multi-agent coordination. | Spawn N agents, coordinate them, chain them. |
| **Dynamic prompts** | Configured at creation time (with template variables from trigger payload) | Fully dynamic -- constructed at call time from any context |
| **Followups** | Not exposed | `POST /v1/agents/:id` followup messages to guide a running agent |
| **Status visibility** | Via automation run history in Cursor UI | Programmatic via `GET /v1/agents/:id` -- embeddable in any dashboard |
| **Setup cost** | Low -- configure in UI or Terraform | Medium -- need to write calling code, handle auth, manage lifecycle |

---

## Demo Repo Structure

| Component | Path | Purpose |
|-----------|------|---------|
| Android app | `android/` | Kotlin/Gradle -- lint, build, test all run on Linux |
| iOS app | `ios/` | Swift Package -- build + test run on Linux via Swift 5.10 container |
| Android CI | `.github/workflows/android-ci.yml` | Gradle lint -> build -> test |
| iOS CI | `.github/workflows/ios-ci.yml` | SwiftLint -> build -> test |
| Security scan | `.github/workflows/security-scan.yml` | SonarCloud + Snyk |
| Aviator build | `.github/workflows/aviator-build.yml` | Release build via `workflow_dispatch` |
| Aviator deploy | `.github/workflows/aviator-deploy.yml` | Deployment via `workflow_dispatch` |
| Sonar config | `sonar-project.properties` | SonarCloud project configuration |
| Snyk policy | `.snyk` | Snyk dependency scan policy |
