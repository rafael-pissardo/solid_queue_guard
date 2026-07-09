# solid_queue_guard

**Production readiness checks and runtime guards for Rails Solid Queue.**

[![Gem Version](https://img.shields.io/gem/v/solid_queue_guard)](https://rubygems.org/gems/solid_queue_guard)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](MIT-LICENSE)

Rails 8 ships with [Solid Queue](https://github.com/rails/solid_queue). Redis is optional. Production config is not.

Your web tier can be **green** while your jobs are **dead**. Your queue can look **empty** while scheduled work is **stuck**. Your `queue.yml` can declare **10 threads** against a database pool of **5**.

**solid_queue_guard** catches that *before* it becomes a 3am incident.

> **Mission Control** shows what is happening.  
> **solid_queue_guard** warns what is dangerous.

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

## See it in action

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
✅ db/queue_schema.rb exists
❌ Worker threads: 10, queue DB pool: 5
⚠️ No workers configured for "mailers" queue
⚠️ recurring.yml exists but scheduler may not run
✅ Solid Queue is not co-located with Puma

Suggested fixes:
- Increase queue DB pool to at least 12 or reduce worker threads
- Add a worker for the mailers queue
- Verify scheduler process is running in production
```

One command. Actionable output. No Datadog required to get started.

---

## What it checks

### Configuration doctor

Runs locally, in CI, or pre-deploy. **No extra infrastructure.**

| Check | Catches |
| ----- | ------- |
| **Adapter** | Active Job not set to `:solid_queue` |
| **Queue database** | Missing `queue` entry in `database.yml` |
| **connects_to** | Solid Queue pointing at the wrong DB / pool |
| **Queue schema** | Missing `db/queue_schema.rb` |
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

## Quick start

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

## Configuration

```ruby
# config/initializers/solid_queue_guard.rb
SolidQueueGuard.configure do |config|
  config.enabled = Rails.env.production?

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

Configuration attributes, rake tasks, and health JSON shape are public. Internal check classes and registry are `@api private`.

Breaking changes ship only in major versions (`2.0+`). Deprecations warn one minor version ahead.

---

## solid_queue_guard vs Mission Control

| | [Mission Control — Jobs](https://github.com/rails/mission_control-jobs) | solid_queue_guard |
| --- | --- | --- |
| **Purpose** | Inspect & manage jobs | Detect production risk |
| **UI** | Dashboard | CLI + JSON + health endpoint |
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

---

## Compatibility

| Gem version | Ruby | Rails |
| ----------- | ---- | ----- |
| 1.0.x       | 3.1+ | 7.1, 7.2, 8.0 |
| 0.5.x       | 3.1+ | 7.1, 7.2, 8.0 |
| 0.1.x       | 3.1+ | 7.1, 7.2, 8.0 |

## Requirements

- Ruby >= 3.1
- Rails >= 7.1, < 9.0
- [solid_queue](https://github.com/rails/solid_queue) >= 1.0, < 2.0

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

Release a new version by pushing a `v*` tag after CI passes (Trusted Publishing on RubyGems).

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
