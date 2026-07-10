<p align="center">
  <img src="https://img.shields.io/gem/v/solid_queue_guard?style=for-the-badge" alt="Gem Version">
  <img src="https://img.shields.io/badge/Ruby-3.1%2B-red?style=for-the-badge&logo=ruby" alt="Ruby 3.1+">
  <img src="https://img.shields.io/badge/Rails-7.1–8.0-red?style=for-the-badge&logo=rubyonrails" alt="Rails 7.1–8.0">
  <img src="https://img.shields.io/github/actions/workflow/status/rafael-pissardo/solid_queue_guard/ci.yml?branch=main&style=for-the-badge&label=CI" alt="CI">
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="MIT License">
</p>

<h1 align="center">solid_queue_guard</h1>

<p align="center">
  <strong>Your Solid Queue production doctor.</strong><br>
  Catch dead workers, queue lag, and broken config <em>before</em> the 3am page.
</p>

<p align="center">
  <a href="#-quick-start"><strong>Quick start</strong></a> ·
  <a href="#-see-it-in-action"><strong>Demo output</strong></a> ·
  <a href="#-mission-control-dashboard-opt-in"><strong>Mission Control tab</strong></a> ·
  <a href="#-solid_queue_guard-vs-mission-control"><strong>vs Mission Control</strong></a>
</p>

---

Rails 8 ships with [Solid Queue](https://github.com/rails/solid_queue). Redis is optional. **Production config is not.**

Your web tier can be **green** while your jobs are **dead**. Your queue can look **empty** while scheduled work is **stuck**. Your `queue.yml` can declare **10 threads** against a database pool of **5**.

**solid_queue_guard** catches that *before* it becomes an incident.

> **Mission Control** shows what is happening.  
> **solid_queue_guard** warns what is dangerous.

### Install in 30 seconds

```bash
bundle add solid_queue_guard
bin/rails solid_queue_guard:install
bin/rails solid_queue_guard:doctor
```

---

## Table of contents

- [Why this exists](#why-this-exists)
- [See it in action](#-see-it-in-action)
- [What it checks](#what-it-checks)
- [Quick start](#-quick-start)
- [Mission Control dashboard](#-mission-control-dashboard-opt-in)
- [How to use it](#how-to-use-it)
- [Runtime process checks](#runtime-process-checks)
- [Configuration](#configuration)
- [Public API (v1.0+)](#public-api-v10)
- [solid_queue_guard vs Mission Control](#-solid_queue_guard-vs-mission-control)
- [Roadmap](#roadmap)
- [Compatibility](#compatibility)
- [Development](#development)
- [Contributing](#contributing)

---

## Why this exists

Solid Queue is excellent. Operating it blindly is not.

| Symptom | What actually happened |
| ------- | ---------------------- |
| "Site is up, emails stopped" | Workers dead, heartbeats stale |
| "Only 3 jobs in the queue, why the panic?" | Oldest job waiting 40 minutes — **lag**, not depth |
| "Recurring billing just… stopped" | Scheduler not running, nobody noticed for a week |
| "Jobs hang after deploy" | Thread count > DB pool — connection starvation |
| "Health check passes, jobs don't" | `/up` doesn't know Solid Queue exists |

You don't need another dashboard. You need a **doctor**.

---

## 👨‍⚕️ See it in action

```bash
bundle add solid_queue_guard
bin/rails solid_queue_guard:install
bin/rails solid_queue_guard:doctor
```

```text
SolidQueueGuard Report

Status: DEGRADED

Checks:
✅ Active Job adapter is :solid_queue
✅ Queue database configured in database.yml
✅ Solid Queue connects_to queue database (pool: 10)
✅ Solid Queue schema tables present
❌ Worker threads: 10, queue DB pool: 5
⚠️ No workers configured for "mailers" queue
⚠️ recurring.yml exists but scheduler may not run
✅ Solid Queue is not co-located with Puma

Suggested fixes:
- Increase queue DB pool to at least 12 or reduce worker threads
- Add a worker for the mailers queue
- Verify scheduler process is running in production
```

**One command. Actionable output. No Datadog required to get started.**

---

## What it checks

### Configuration doctor

Runs locally, in CI, or pre-deploy. **No extra infrastructure.**

| Check | Catches |
| ----- | ------- |
| **Adapter** | Active Job not set to `:solid_queue` |
| **Queue database** | Missing `queue` entry in `database.yml` |
| **connects_to** | Solid Queue pointing at the wrong DB / pool |
| **Queue schema** | Missing Solid Queue tables in schema files or queue database |
| **Thread pool** | `threads` > available queue DB connections |
| **Worker coverage** | Queues with no worker assigned |
| **Scheduler** | `recurring.yml` tasks without a scheduler |
| **Env flags** | `SOLID_QUEUE_SKIP_RECURRING=true` in production |
| **Heartbeats** | Default thresholds that may not fit your deploy |
| **Puma plugin** | Solid Queue co-located with web in production |
| **Async supervisor** | `async` mode with thread/pool sizing risks |
| **Topology** | `queue.yml` worker and pool recommendations |

### Runtime guards

| Check | Catches |
| ----- | ------- |
| **Queue lag** | Oldest ready job waiting too long |
| **Stale processes** | Dead workers, dispatchers, schedulers |
| **Dispatcher health** | Scheduled jobs never becoming ready |
| **Blocked jobs** | Concurrency control silently holding jobs |
| **Recurring staleness** | Cron tasks that stopped firing |
| **Puma plugin runtime** | Plugin enabled but no active Solid Queue processes |
| **HTTP `/health`** | Kamal, ECS, K8s, UptimeRobot integration |

---

## 🚀 Quick start

### Install

```bash
bundle add solid_queue_guard
bin/rails solid_queue_guard:install
bin/rails generate solid_queue_guard:install:ci   # optional GitHub Actions workflow
```

### Run the doctor

```bash
# Human-readable report
bin/rails solid_queue_guard:doctor

# JSON for scripts / CI
bin/rails "solid_queue_guard:doctor[json]"
SOLID_QUEUE_GUARD_FORMAT=json bin/rails solid_queue_guard:doctor

# Fail CI on warnings too
SOLID_QUEUE_GUARD_STRICT=1 bin/rails solid_queue_guard:doctor

# Full report (config + runtime when available)
bin/rails solid_queue_guard:report
```

### Exit codes

| Code | Meaning |
| ---- | ------- |
| `0` | Healthy or degraded |
| `1` | Unhealthy (or degraded in `--strict` / `SOLID_QUEUE_GUARD_STRICT=1`) |

Perfect for deploy pipelines:

```yaml
# GitHub Actions
- name: Solid Queue production readiness
  run: SOLID_QUEUE_GUARD_STRICT=1 bin/rails solid_queue_guard:doctor
```

Or generate a workflow:

```bash
bin/rails generate solid_queue_guard:install:ci
```

### HTTP health

```ruby
# config/routes.rb
mount SolidQueueGuard::Engine, at: "/solid_queue_guard"
```

```bash
curl localhost:3000/solid_queue_guard/health
# => { "status": "degraded", "queue_lag_seconds": 245, "warnings": [...] }
```

Optional token protection:

```ruby
config.health_token = ENV["SOLID_QUEUE_GUARD_TOKEN"]
# curl -H "X-Solid-Queue-Guard-Token: $TOKEN" ...
```

HTTP status policy (for Kamal, ECS, load balancers):

```ruby
config.degraded_http_status = 207   # or :ok (200), 503, etc.
config.unhealthy_http_status = 503  # default
```

Works with **Kamal**, **Heroku**, **Fly.io**, **ECS/Fargate**, **Kubernetes**, **Better Stack**, **UptimeRobot**.

---

## 🛡️ Mission Control dashboard (opt-in)

Add a **Guard** tab to [Mission Control — Jobs](https://github.com/rails/mission_control-jobs) — same Bulma UI, same auth, same navigation:

```ruby
# Gemfile
gem "mission_control-jobs"
gem "solid_queue_guard"

# config/initializers/solid_queue_guard.rb
SolidQueueGuard.configure do |config|
  config.integrate_mission_control = true
end

# config/routes.rb
mount MissionControl::Jobs::Engine, at: "/jobs"
mount SolidQueueGuard::Engine, at: "/solid_queue_guard" # keep /health for probes
```

Open `/jobs/applications/:application_id/guard` (or click the **Guard** tab inside Mission Control):

![Guard tab in Mission Control — overall status, metrics, warnings, and checks table](docs/mission-control-guard-dashboard.png)

| Section | Content |
| ------- | ------- |
| **Overall status** | `healthy` / `degraded` / `unhealthy` badge |
| **Metrics** | Queue lag, failed jobs (1h), dead processes, check count |
| **Warnings & suggestions** | Same messages as `doctor` / `/health` |
| **Checks table** | Every check with status tag, message, and suggestion |

**Authentication:** the Guard tab inherits Mission Control auth — HTTP basic (default) or your admin controller via `MissionControl::Jobs.base_controller_class`. No separate login.

**Load balancers:** keep using `GET /solid_queue_guard/health` with optional `health_token`. Probes do not go through Mission Control.

**Requirements:** an asset pipeline (Propshaft or Sprockets), same as Mission Control. `mission_control-jobs` is optional — only needed when `integrate_mission_control` is enabled.

---

## How to use it

Solid Queue does not show up in Rails `/up`. **solid_queue_guard** gives you four operational surfaces:

| Surface | Command / URL | Best for |
| ------- | ------------- | -------- |
| **Doctor** | `bin/rails solid_queue_guard:doctor` | Local pre-deploy, config review |
| **CI gate** | `SOLID_QUEUE_GUARD_STRICT=1 bin/rails solid_queue_guard:doctor` | Block merges with broken queue config |
| **HTTP health** | `GET /solid_queue_guard/health` | Production uptime monitors (Kamal, ECS, UptimeRobot) |
| **Guard tab** | `GET /jobs/applications/:application_id/guard` (with `integrate_mission_control`) | Human-readable checks inside Mission Control |

**Mission Control** shows what is happening. **solid_queue_guard** warns what is dangerous. Use both.

### Local and pre-deploy

Run before changing `queue.yml`, `database.yml`, or recurring tasks:

```bash
bin/rails solid_queue_guard:doctor      # config checks (default scope)
bin/rails solid_queue_guard:report      # config + runtime when the queue DB is available
```

By default the install generator sets `config.enabled = %w[production staging].include?(Rails.env)`, so in **development** and other non-deployed environments checks are skipped unless you enable them:

```ruby
SolidQueueGuard.configure { |c| c.enabled = true }
```

Or run with production config locally when validating deploy readiness.

### CI pipelines

Validate **configuration** before deploy. Process/runtime checks usually **skip** in CI because there is no `bin/jobs` supervisor on the runner.

```yaml
- name: Solid Queue production readiness
  run: SOLID_QUEUE_GUARD_STRICT=1 bin/rails solid_queue_guard:doctor
```

`STRICT=1` turns warnings into exit code `1`, so the pipeline fails on misconfigured pools, missing worker coverage, or missing schema tables — not only hard failures.

Generate a starter workflow:

```bash
bin/rails generate solid_queue_guard:install:ci
```

### Production monitoring

Mount the engine and point your load balancer or Kamal health check at `/solid_queue_guard/health`:

```ruby
# config/routes.rb
mount SolidQueueGuard::Engine, at: "/solid_queue_guard"
```

Runtime checks matter here: queue lag, stale heartbeats, dispatcher health, and process topology reflect **live** Solid Queue state.

Optional hardening:

```ruby
config.health_token = ENV["SOLID_QUEUE_GUARD_TOKEN"]
config.health_cache_ttl = 15.seconds
config.degraded_http_status = 207   # or :ok (200), 503, etc.
config.notify_with = [:rails_logger, :slack]
```

### Typical flow

```text
Developer          CI                    Production
    │               │                         │
    │ doctor        │ doctor --strict           │ GET /health (every 30–60s)
    ▼               ▼                         ▼
 "pool wrong?"   block bad deploy          alert: worker dead
 "schema ok?"    before merge              alert: queue lag
```

---

## Runtime process checks

Runtime checks query the **queue database** (via `SolidQueue::Record`). If `connects_to` is missing or the DB is unreachable, they **skip** — they do not pass silently as healthy.

### `process_topology` — are the expected roles present?

Reads distinct `kind` values from `solid_queue_processes`:

| Kind | Role |
| ---- | ---- |
| `Supervisor` | Parent process (`bin/jobs`) |
| `Worker` | Consumes ready jobs |
| `Dispatcher` | Moves scheduled jobs to ready |
| `Scheduler` | Runs recurring tasks |

| Result | Meaning |
| ------ | ------- |
| ⚠️ No processes | Nothing registered — supervisor not running |
| ⚠️ No Worker | Jobs will not be processed |
| ⚠️ No Dispatcher | Scheduled work may stall (when recurring/scheduled jobs exist) |
| ✅ Pass | Expected kinds are present |

This check looks at **presence of records**, not heartbeat freshness.

### `stale_process` — are heartbeats fresh?

Finds processes where `last_heartbeat_at` is older than `stale_process_threshold` (default **5 minutes**):

| Result | Meaning |
| ------ | ------- |
| ✅ Pass | All processes reported recently |
| ❌ Fail | One or more workers/dispatchers look dead or stuck |

Use this in production health to catch workers that died after deploy.

### `pidfile` — optional supervisor liveness

When `tmp/pids/solid_queue.pid` (or `SOLID_QUEUE_PIDFILE`) exists, verifies the PID is alive. Often **warns in development** where `bin/jobs` is not running. Disable if you do not use pidfiles:

```ruby
config.disabled_checks = [:pidfile]
```

### `puma_plugin_runtime` — Solid Queue inside Puma

When `plugin :solid_queue` is in `config/puma.rb`, verifies active processes with recent heartbeats exist. **Skips** when the Puma plugin is not enabled.

### Queue schema detection

`QueueSchemaCheck` does **not** require `db/queue_schema.rb`. It validates that all tables for your installed **solid_queue** version exist in any of:

- `db/queue_schema.rb`
- `db/schema.rb`
- `db/structure.sql`
- the connected queue database

Apps that keep Solid Queue tables only in `structure.sql` (common in Revelo-style repos) pass correctly.

### Where each check type applies

| Context | Config checks | Process / runtime checks |
| ------- | ------------- | ------------------------ |
| Local `doctor` | ✅ Primary value | ⚠️ Partial without `bin/jobs` |
| CI `--strict` | ✅ Primary value | ⏭️ Usually skip |
| Production `/health` | ✅ When DB up | ✅ Primary value |

---

## Configuration

```ruby
# config/initializers/solid_queue_guard.rb
SolidQueueGuard.configure do |config|
  config.enabled = %w[production staging].include?(Rails.env)

  config.queue_lag_thresholds = {
    critical: 30.seconds,
    default:  5.minutes,
    mailers:  15.minutes
  }

  config.failed_jobs_threshold = 20
  config.stale_process_threshold = 5.minutes

  # Per-check overrides (v0.6+)
  config.disabled_checks = [:pidfile]
  config.checks.queue_lag = { threshold: 10.minutes }
  config.checks.failed_jobs = { threshold: 5, enabled: true }

  # HTTP status policy (v0.8+)
  # config.degraded_http_status = 207
  # config.unhealthy_http_status = 503

  # config.health_token = ENV["SOLID_QUEUE_GUARD_TOKEN"]
  # config.integrate_rails_health = true
  # config.integrate_mission_control = true  # Guard tab in Mission Control (requires mission_control-jobs)
  # config.notify_with = [:rails_logger, :slack, :datadog, :webhook]
  # config.metrics_backends = [:statsd, :prometheus, :opentelemetry]
end
```

---

## Public API (v1.0+)

The following surface is **stable** until `2.0` and follows [semantic versioning](https://semver.org/):

| API | Description |
| --- | ----------- |
| `SolidQueueGuard.configure` | Block-style configuration |
| `SolidQueueGuard.config` | Current configuration object |
| `SolidQueueGuard.enabled?` | Whether checks run |
| `solid_queue_guard:doctor` | Config readiness report |
| `solid_queue_guard:health` | Runtime health report |
| `solid_queue_guard:report` | Full diagnostic report |
| `solid_queue_guard:install` | Initializer generator |
| `solid_queue_guard:install:ci` | GitHub Actions workflow generator |
| `mount SolidQueueGuard::Engine` | HTTP health endpoint |
| `config.integrate_mission_control` | Guard tab in Mission Control (opt-in, requires `mission_control-jobs`) |
| `GET /jobs/applications/:application_id/guard` | Human-readable health dashboard (when integration enabled) |

Configuration attributes, rake tasks, health JSON shape, and Mission Control integration are public. Internal check classes and registry are `@api private`.

Breaking changes ship only in major versions (`2.0+`). Deprecations warn one minor version ahead.

---

## ⚔️ solid_queue_guard vs Mission Control

| | [Mission Control — Jobs](https://github.com/rails/mission_control-jobs) | solid_queue_guard |
| --- | --- | --- |
| **Purpose** | Inspect & manage jobs | Detect production risk |
| **UI** | Dashboard | CLI + JSON + health endpoint + optional Guard tab in Mission Control |
| **Retry / discard** | Yes | No (use Mission Control) |
| **Config doctor** | No | Yes |
| **Queue lag alerts** | No | Yes |
| **Pre-deploy checks** | No | Yes |
| **Recurring job guard** | Manual inspection | Automatic |

**Use both.** They solve different problems.

---

## Roadmap

| Version | Ships | Status |
| ------- | ----- | ------ |
| **v0.1** | `doctor` — config checks, CI integration, install generator | ✅ Released |
| **v0.2** | Runtime health, queue lag, dispatcher/blocked jobs, HTTP endpoint | ✅ Released |
| **v0.3** | Slack, Datadog, webhook notifications | ✅ Released |
| **v0.4** | StatsD, Prometheus, OpenTelemetry metrics | ✅ Released |
| **v0.5** | Auto-recommendations for `queue.yml` topology | ✅ Released |
| **v0.6** | Per-check configuration (`disabled_checks`, `config.checks`) | ✅ Released |
| **v0.7** | Puma plugin runtime check, async supervisor awareness | ✅ Released |
| **v0.8** | HTTP status policy, `install:ci` generator | ✅ Released |
| **v1.0** | Stable public API, strict semver | ✅ Released |
| **v1.1** | Mission Control Guard tab (opt-in) | ✅ Released |

---

## Compatibility

| Gem version | Ruby | Rails |
| ----------- | ---- | ----- |
| 1.1.x       | 3.1+ | 7.1, 7.2, 8.0 |
| 1.0.x       | 3.1+ | 7.1, 7.2, 8.0 |
| 0.5.x       | 3.1+ | 7.1, 7.2, 8.0 |
| 0.1.x       | 3.1+ | 7.1, 7.2, 8.0 |

## Requirements

- Ruby >= 3.1
- Rails >= 7.1, < 9.0
- [solid_queue](https://github.com/rails/solid_queue) >= 1.0, < 2.0
- [mission_control-jobs](https://github.com/rails/mission_control-jobs) >= 1.0 — optional, only for `integrate_mission_control`

---

## Development

```bash
git clone https://github.com/rafael-pissardo/solid_queue_guard.git
cd solid_queue_guard
bundle install
cd test/dummy && bin/setup
cd ../.. && bundle exec rake test
bundle exec rubocop
bundle exec appraisal install
bundle exec appraisal rake test
```

Release a new version after CI passes:

```bash
# Tag must match lib/solid_queue_guard/version.rb (currently 1.1.4)
git tag v1.1.4
git push origin v1.1.4
```

Trusted Publishing on RubyGems publishes automatically when the tag is pushed.

---

## Contributing

Issues and PRs welcome. Keep it focused: **production safety**, not another job dashboard.

1. Fork it
2. Create your branch (`git checkout -b my-new-check`)
3. Write a test first
4. Make the check pass
5. Open a PR

---

## License

MIT — see [MIT-LICENSE](MIT-LICENSE).

---

<p align="center">
  <strong>Run the doctor before you run the deploy.</strong><br>
  <sub>Built for Rails teams who chose Solid Queue and still sleep at night.</sub>
</p>
