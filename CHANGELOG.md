# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.4] - 2026-07-10

### Fixed

- Mission Control Guard tab now uses application-scoped URLs (`/applications/:application_id/guard`) with the engine mount prefix and `server_id`, matching Queues, Workers, and Recurring tasks navigation

## [1.1.3] - 2026-07-09

### Fixed

- Mission Control integration now reads `integrate_mission_control` in `after_initialize`, so setting it in `config/initializers/solid_queue_guard.rb` works without duplicating the flag in `config/application.rb`

## [1.1.2] - 2026-07-09

### Fixed

- RuboCop Style/ClassAndModuleChildren offense in test helper

## [1.1.1] - 2026-07-09

### Fixed

- Rails 7.1 CI: keep `:solid_queue` adapter in integration tests instead of ActiveJob's default `TestAdapter`, so Mission Control navigation renders on the Guard dashboard

## [1.1.0] - 2026-07-09

### Added

- Opt-in Mission Control — Jobs integration via `config.integrate_mission_control`
- **Guard** tab at `/jobs/guard` with Bulma UI matching Mission Control (status, metrics, warnings, suggestions, checks table)
- Reuses Mission Control authentication and layout; `/solid_queue_guard/health` JSON endpoint unchanged for load balancers

## [1.0.3] - 2026-07-09

### Fixed

- Sync `Gemfile.lock` and appraisal lockfiles with the published gem version so CI bundle install succeeds in frozen mode

## [1.0.2] - 2026-07-09

### Changed

- Install generator enables SolidQueueGuard in `production` and `staging` by default

## [1.0.1] - 2026-07-09

### Changed

- `QueueSchemaCheck` validates Solid Queue tables in `db/queue_schema.rb`, `db/schema.rb`, `db/structure.sql`, and the queue database instead of requiring `db/queue_schema.rb`
- README documents operational usage: doctor, CI, HTTP health, and runtime process checks

## [1.0.0] - 2026-07-09

### Added

- Stable public API guarantee documented in README
- Gemspec packaging via `git ls-files` for reproducible releases

### Changed

- Deprecations now target removal in `2.0` per semver policy

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
