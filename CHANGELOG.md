# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.8.0] - 2026-07-09

### Added

- Configurable HTTP status policy via `degraded_http_status` and `unhealthy_http_status`
- `solid_queue_guard:install:ci` generator for GitHub Actions doctor workflow

## [0.7.0] - 2026-07-09

### Added

- `AsyncSupervisorConfigCheck` for async supervisor mode
- `PumaPluginRuntimeCheck` for co-located Puma plugin health
- Async-aware topology pool recommendations

## [0.6.0] - 2026-07-09

### Added

- Per-check configuration via `disabled_checks` and `config.checks`
- Per-check threshold overrides for queue lag, failed jobs, stale processes, and scheduled backlog

## [0.5.0] - 2026-07-09

### Added

- `TopologyRecommendationCheck` for automatic `queue.yml` and pool recommendations
- `SolidQueueGuard::Recommendations::Topology` analyzer

## [0.4.0] - 2026-07-09

### Added

- Metrics export via `config.metrics_backends` (`:statsd`, `:prometheus`, `:opentelemetry`)
- `SolidQueueGuard::Metrics::Exporter` and per-backend exporters

## [0.3.0] - 2026-07-09

### Added

- Notification adapters: `:rails_logger`, `:slack`, `:datadog`, `:webhook`
- Automatic notification delivery on degraded/unhealthy CLI reports via `config.notify_with`

## [0.2.0] - 2026-07-09

### Added

- Runtime checks: queue lag, stale processes, dispatcher health, scheduled backlog, blocked jobs, orphaned claims, failed jobs, recurring staleness, paused queue lag, pidfile, finished jobs growth
- HTTP `/solid_queue_guard/health` endpoint with optional token auth and response caching
- `health` rake task now runs full runtime scope
- Terminal report hides skipped runtime checks
- Optional Rails `/up` integration via `integrate_rails_health`

## [0.1.0] - 2026-07-09

### Added

- `solid_queue_guard:doctor` rake task for configuration readiness checks
- `solid_queue_guard:report` rake task for full diagnostic output
- `solid_queue_guard:install` generator for the initializer
- JSON output via `SOLID_QUEUE_GUARD_FORMAT=json` or `doctor[json]`
- Strict CI mode via `SOLID_QUEUE_GUARD_STRICT=1` or `--strict`
- Configuration checks: adapter, queue database, `connects_to`, queue schema, thread pool, worker coverage, scheduler, environment flags, process heartbeat thresholds, and Puma co-location
