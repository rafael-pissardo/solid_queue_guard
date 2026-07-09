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

  # config.health_token = ENV["SOLID_QUEUE_GUARD_TOKEN"]
  # config.notify_with = [ :rails_logger ]
end
