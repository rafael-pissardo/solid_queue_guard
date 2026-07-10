# Checks reference

Checks are grouped into **config** (static / pre-deploy) and **runtime** (live queue database).

Runtime checks **skip** (not pass) when the queue DB is unreachable or `connects_to` is missing.

Disable any check via `config.disabled_checks = [:check_id]` or per-check `config.checks.check_id = { enabled: false }`.

## Config checks

| ID | Catches |
| -- | ------- |
| `adapter` | Active Job not set to `:solid_queue` |
| `queue_database` | Missing `queue` entry in `database.yml` |
| `connects_to` | Solid Queue pointing at wrong DB / pool |
| `queue_schema` | Missing Solid Queue tables in schema files or queue DB |
| `thread_pool` | Worker `threads` > available queue DB connections |
| `worker_coverage` | Queues with no worker assigned |
| `scheduler_config` | `recurring.yml` tasks without a scheduler |
| `env_flags` | `SOLID_QUEUE_SKIP_RECURRING=true` in production |
| `process_heartbeat_config` | Default heartbeat thresholds may not fit deploy |
| `puma_colocated` | Solid Queue co-located with web in production |
| `topology_recommendation` | `queue.yml` worker and pool recommendations |
| `async_supervisor_config` | `async` mode with thread/pool sizing risks |

## Runtime checks

| ID | Catches |
| -- | ------- |
| `queue_lag` | Oldest ready job waiting too long |
| `stale_process` | Dead workers, dispatchers, schedulers (stale heartbeats) |
| `process_topology` | Missing Supervisor / Worker / Dispatcher / Scheduler roles |
| `dispatcher` | Scheduled jobs never becoming ready |
| `scheduled_backlog` | Large scheduled job backlog |
| `blocked_jobs` | Concurrency control silently holding jobs |
| `orphaned_claims` | Jobs claimed but not finished |
| `failed_jobs` | High failed job rate (1h window) |
| `recurring_stale` | Recurring tasks that stopped firing |
| `paused_queue_lag` | Lag on paused queues |
| `pidfile` | Supervisor PID file present but process dead |
| `finished_jobs_growth` | Unusual finished job table growth |
| `puma_plugin_runtime` | Puma plugin enabled but no active Solid Queue processes |

## Where checks apply

| Context | Config checks | Runtime checks |
| ------- | ------------- | -------------- |
| Local `doctor` | Primary value | Partial without `bin/jobs` |
| CI `--strict` | Primary value | Usually skip |
| Production `/health` | When DB up | Primary value |

## Runtime check details

### `process_topology`

Reads distinct `kind` from `solid_queue_processes`:

| Kind | Role |
| ---- | ---- |
| `Supervisor` | Parent process (`bin/jobs`) |
| `Worker` | Consumes ready jobs |
| `Dispatcher` | Moves scheduled jobs to ready |
| `Scheduler` | Runs recurring tasks |

Looks at **presence of records**, not heartbeat freshness.

### `stale_process`

Processes with `last_heartbeat_at` older than `stale_process_threshold` (default **5 minutes**).

### `queue_schema`

Does **not** require `db/queue_schema.rb`. Validates tables exist in any of:

- `db/queue_schema.rb`
- `db/schema.rb`
- `db/structure.sql`
- the connected queue database

### Listing check IDs programmatically

```ruby
SolidQueueGuard::Checks::Registry.catalog
# => { config: ["adapter", ...], runtime: ["queue_lag", ...] }
```

`Registry` is `@api private` but `catalog` is stable for tooling.
