# solid_queue_guard

Production readiness checks and runtime guards for Rails [Solid Queue](https://github.com/rails/solid_queue).

> Mission Control shows what is happening. **solid_queue_guard** warns what is dangerous.

## Installation

```bash
bundle add solid_queue_guard
bin/rails solid_queue_guard:install
```

## Usage

```bash
bin/rails solid_queue_guard:doctor
bin/rails "solid_queue_guard:doctor[json]"
SOLID_QUEUE_GUARD_FORMAT=json bin/rails solid_queue_guard:doctor
SOLID_QUEUE_GUARD_STRICT=1 bin/rails solid_queue_guard:doctor
bin/rails solid_queue_guard:health
bin/rails solid_queue_guard:report
```

Optional HTTP mount (health endpoint ships in v0.2):

```ruby
mount SolidQueueGuard::Engine, at: "/solid_queue_guard"
```

## What `doctor` checks (v0.1)

- Active Job adapter is `:solid_queue`
- Queue database and `connects_to` configuration
- `db/queue_schema.rb` presence
- Worker thread count vs queue DB pool size
- Worker coverage for recurring/database queues
- Scheduler configuration vs `config/recurring.yml`
- Dangerous environment flags in production
- Process heartbeat threshold awareness
- Puma co-located Solid Queue plugin warning

## Roadmap

| Version | Focus |
| ------- | ----- |
| v0.1 | `doctor` configuration checks |
| v0.2 | Runtime health JSON, queue lag, dispatcher/blocked jobs |
| v0.3 | Slack, Datadog, webhook notifications |
| v0.4 | StatsD, Prometheus, OpenTelemetry metrics |
| v0.5 | Auto-recommendations for `queue.yml` |

## Development

```bash
bundle install
cd test/dummy && bin/setup
cd ../.. && bundle exec ruby -Itest test/**/*_test.rb
```

## License

MIT
