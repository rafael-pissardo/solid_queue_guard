# Configuration

Configure via `config/initializers/solid_queue_guard.rb` (created by the install generator).

```ruby
SolidQueueGuard.configure do |config|
  config.enabled = %w[production staging].include?(Rails.env)

  config.queue_lag_thresholds = {
    critical: 30.seconds,
    default:  5.minutes,
    mailers:  15.minutes
  }

  config.failed_jobs_threshold = 20
  config.stale_process_threshold = 5.minutes
  config.health_cache_ttl = 15.seconds
  config.scheduled_backlog_threshold = 100

  config.disabled_checks = [:pidfile]
  config.checks.queue_lag = { threshold: 10.minutes }
  config.checks.failed_jobs = { threshold: 5, enabled: true }

  config.degraded_http_status = 207   # or :ok (200), 503, etc.
  config.unhealthy_http_status = 503

  config.health_token = ENV["SOLID_QUEUE_GUARD_TOKEN"]
  config.integrate_rails_health = false
  config.integrate_mission_control = true  # requires mission_control-jobs

  config.notify_with = [:rails_logger, :slack, :datadog, :webhook]
  config.metrics_backends = [:statsd, :prometheus, :opentelemetry]

  config.on_status_change = lambda do |previous, current, report|
    # Called when /solid_queue_guard/health detects a status transition
    Rails.logger.info("[SolidQueueGuard] #{previous.inspect} -> #{current}")
  end
end
```

Configuration is validated at boot (`config.validate!`). Invalid HTTP status values or thresholds raise `SolidQueueGuard::Configuration::ValidationError`.

## Options reference

| Option | Default | Description |
| ------ | ------- | ----------- |
| `enabled` | `true` | Master switch for running checks |
| `queue_lag_thresholds` | `{ default: 5.minutes }` | Per-queue lag thresholds |
| `failed_jobs_threshold` | `20` | Failed jobs (1h) before warning |
| `stale_process_threshold` | `5.minutes` | Heartbeat staleness threshold |
| `health_cache_ttl` | `15.seconds` | HTTP health response cache |
| `scheduled_backlog_threshold` | `100` | Scheduled backlog warning level |
| `health_token` | `nil` | Optional bearer token for `/health` |
| `strict_mode` | `false` | Treat warnings as exit code 1 in CLI |
| `integrate_rails_health` | `false` | Extend Rails `/up` with queue status |
| `integrate_mission_control` | `false` | Guard tab in Mission Control |
| `disabled_checks` | `[]` | Check IDs to skip |
| `checks` | `{}` | Per-check overrides (`enabled`, thresholds) |
| `degraded_http_status` | `:ok` (200) | HTTP code when degraded |
| `unhealthy_http_status` | `:service_unavailable` (503) | HTTP code when unhealthy |
| `notify_with` | `[:rails_logger]` | Notification adapters on non-healthy CLI runs |
| `metrics_backends` | `[]` | `:statsd`, `:prometheus`, `:opentelemetry` |
| `on_status_change` | `nil` | Callback `(previous, current, report)` on health status transitions |

## Environment variables

| Variable | Purpose |
| -------- | ------- |
| `SOLID_QUEUE_GUARD_STRICT=1` | Fail CLI on warnings |
| `SOLID_QUEUE_GUARD_FORMAT=json` | JSON output for doctor/report |
| `SOLID_QUEUE_GUARD_SCOPE=config\|runtime\|all` | Check scope for CLI |
| `SOLID_QUEUE_GUARD_TOKEN` | Health endpoint token |
| `SOLID_QUEUE_GUARD_SLACK_WEBHOOK_URL` | Slack notifications |
| `SOLID_QUEUE_GUARD_WEBHOOK_URL` | Generic webhook notifications |
| `DD_API_KEY` | Datadog events API |
| `SOLID_QUEUE_GUARD_STATSD_HOST` / `PORT` | StatsD target |
| `SOLID_QUEUE_GUARD_PROMETHEUS_FILE` | Prometheus textfile path |

## Optional gem dependencies

| Backend / notifier | Gem to add |
| ------------------ | ---------- |
| `:opentelemetry` metrics | `opentelemetry-sdk` |
| Slack / webhook / Datadog | Uses stdlib `net/http` — no extra gem |

StatsD and Prometheus exporters use stdlib / file I/O and ship with the gem.

## HTTP health

```ruby
# config/routes.rb
mount SolidQueueGuard::Engine, at: "/solid_queue_guard"
```

```bash
curl localhost:3000/solid_queue_guard/health
```

Health JSON includes `status_counts` (pass/warn/fail/skip totals) since v1.2.0.

## Mission Control integration

```ruby
gem "mission_control-jobs"

SolidQueueGuard.configure do |config|
  config.integrate_mission_control = true
end

mount MissionControl::Jobs::Engine, at: "/jobs"  # or your mount path
mount SolidQueueGuard::Engine, at: "/solid_queue_guard"
```

Guard tab URL: `/jobs/applications/:application_id/guard?server_id=...` (adjust mount prefix as needed).

Load balancers should keep using `GET /solid_queue_guard/health` — not the Mission Control UI.
