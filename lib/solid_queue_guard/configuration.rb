# frozen_string_literal: true

module SolidQueueGuard
  class Configuration
    attr_accessor :enabled,
                  :queue_lag_thresholds,
                  :failed_jobs_threshold,
                  :stale_process_threshold,
                  :health_token,
                  :strict_mode,
                  :health_cache_ttl,
                  :scheduled_backlog_threshold,
                  :integrate_rails_health,
                  :notify_with

    def initialize
      @enabled = true
      @queue_lag_thresholds = { default: 5.minutes }
      @failed_jobs_threshold = 20
      @stale_process_threshold = 5.minutes
      @health_token = nil
      @strict_mode = false
      @health_cache_ttl = 15.seconds
      @scheduled_backlog_threshold = 100
      @integrate_rails_health = false
      @notify_with = [:rails_logger]
    end

    def strict?
      strict_mode || ActiveModel::Type::Boolean.new.cast(ENV.fetch('SOLID_QUEUE_GUARD_STRICT', nil))
    end
  end
end
