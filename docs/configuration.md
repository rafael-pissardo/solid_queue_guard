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
  # recurring_stale uses each task's schedule by default; threshold is fallback only
  # config.checks.recurring_stale = { threshold: 25.hours, multiplier: 2 }

  config.degraded_http_status = 207   # or :ok (200), 503, etc.
  config.unhealthy_http_status = 503

  config.health_token = ENV["SOLID_QUEUE_GUARD_TOKEN"]
  config.integrate_rails_health = false
  config.integrate_mission_control = true  # requires mission_control-jobs

  config.notify_with = [:rails_logger, :slack, :datadog, :webhook]
  config.metrics_backends = [:statsd, :prometheus, :opentelemetry]

  # Operational Datadog metrics (requires dogstatsd-ruby)
  # Or run: bin/rails generate solid_queue_guard:metrics
  config.emit_depth_metrics = true
  config.emit_event_metrics = true
  config.statsd_service_name = 'my-service' # or set DD_SERVICE

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
| `metrics_backends` | `[]` | `:statsd`, `:prometheus`, `:opentelemetry` (guard health status only) |
| `emit_depth_metrics` | `false` | Emit `solid_queue.ready.*` / failed / claimed / scheduled gauges via `EmitDepthJob` |
| `emit_event_metrics` | `false` | Subscribe to Active Job + Solid Queue lifecycle → `solid_queue.jobs.*` counters |
| `statsd_service_name` | `nil` | `service:` tag for DogStatsD (`DD_SERVICE` / `SOLID_QUEUE_GUARD_SERVICE` fallback) |
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
| `SOLID_QUEUE_GUARD_STATSD_HOST` / `PORT` | StatsD target (guard health export) |
| `SOLID_QUEUE_GUARD_PROMETHEUS_FILE` | Prometheus textfile path |
| `DD_SERVICE` | Default `service:` tag for operational DogStatsD metrics |
| `SOLID_QUEUE_GUARD_SERVICE` | Fallback `service:` tag when `DD_SERVICE` unset |

## Optional gem dependencies

| Backend / notifier | Gem to add |
| ------------------ | ---------- |
| `:opentelemetry` metrics | `opentelemetry-sdk` |
| `emit_depth_metrics` / `emit_event_metrics` | `dogstatsd-ruby` |
| Slack / webhook / Datadog events | Uses stdlib `net/http` — no extra gem |

Guard health StatsD/Prometheus exporters use stdlib / file I/O and ship with the gem.

## Operational Datadog metrics

Continuous depth gauges (same source as Mission Control) plus Active Job event counters:

```bash
bin/rails generate solid_queue_guard:metrics
# adds flags to the initializer and emit_solid_queue_depth_metrics to recurring.yml
```

| Metric | Type | Notes |
| ------ | ---- | ----- |
| `solid_queue.ready.count` | gauge | per `queue:` tag; `0` when empty |
| `solid_queue.ready.oldest_age_seconds` | gauge | lag of oldest ready job |
| `solid_queue.failed.count` / `claimed.count` / `scheduled.count` | gauge | table counts |
| `solid_queue.jobs.{enqueued,performed,enqueue_retry,retry_stopped,discard}` | counter | Active Job notifications |
| `solid_queue.job.duration_ms` | timing | perform duration |
| `solid_queue.process.active` | gauge | worker/dispatcher/scheduler lifecycle |

Only emits in `production` / `staging`. Ensure workers consume `solid_queue_recurring`.

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
