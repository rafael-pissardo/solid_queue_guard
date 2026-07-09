# frozen_string_literal: true

SolidQueueGuard.configure do |config|
  config.enabled = Rails.env.production?

  config.queue_lag_thresholds = {
    critical: 30.seconds,
    default: 5.minutes,
    mailers: 15.minutes
  }

  config.failed_jobs_threshold = 20
  config.stale_process_threshold = 5.minutes
  config.health_cache_ttl = 15.seconds
  config.scheduled_backlog_threshold = 100

  # config.disabled_checks = [:pidfile]
  # config.checks.queue_lag = { threshold: 10.minutes }
  # config.checks.failed_jobs = { threshold: 5, enabled: true }
  # config.degraded_http_status = 207
  # config.unhealthy_http_status = 503

  # config.health_token = ENV["SOLID_QUEUE_GUARD_TOKEN"]
  # config.integrate_rails_health = true
  # config.notify_with = [:rails_logger, :slack, :datadog, :webhook]
  # config.metrics_backends = [:statsd, :prometheus, :opentelemetry]
end
