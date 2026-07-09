# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-07-09

### Added

- `solid_queue_guard:doctor` rake task for configuration readiness checks
- `solid_queue_guard:report` rake task for full diagnostic output (config + runtime placeholders)
- `solid_queue_guard:install` generator for the initializer
- JSON output via `SOLID_QUEUE_GUARD_FORMAT=json` or `doctor[json]`
- Strict CI mode via `SOLID_QUEUE_GUARD_STRICT=1` or `--strict`
- Configuration checks: adapter, queue database, `connects_to`, queue schema, thread pool, worker coverage, scheduler, environment flags, process heartbeat thresholds, and Puma co-location
- Runtime check scaffolding (skipped until v0.2)
- HTTP health endpoint placeholder mounted via `SolidQueueGuard::Engine`
