# frozen_string_literal: true

module SolidQueueGuard
  class Configuration
    class ValidationError < StandardError; end

    HTTP_STATUS_OPTIONS = HttpStatusPolicy::STATUS_MAP.keys.freeze

    attr_accessor :enabled,
                  :queue_lag_thresholds,
                  :failed_jobs_threshold,
                  :stale_process_threshold,
                  :health_token,
                  :strict_mode,
                  :health_cache_ttl,
                  :scheduled_backlog_threshold,
                  :integrate_rails_health,
                  :integrate_mission_control,
                  :notify_with,
                  :metrics_backends,
                  :disabled_checks,
                  :checks,
                  :degraded_http_status,
                  :unhealthy_http_status,
                  :on_status_change

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
      @integrate_mission_control = false
      @notify_with = [:rails_logger]
      @metrics_backends = []
      @disabled_checks = []
      @checks = ActiveSupport::OrderedOptions.new
      @degraded_http_status = :ok
      @unhealthy_http_status = :service_unavailable
      @on_status_change = nil
    end

    def validate!
      validate_http_status!(:degraded_http_status, degraded_http_status)
      validate_http_status!(:unhealthy_http_status, unhealthy_http_status)
      validate_duration!(:stale_process_threshold, stale_process_threshold)
      validate_duration!(:health_cache_ttl, health_cache_ttl)
      validate_positive_integer!(:failed_jobs_threshold, failed_jobs_threshold)
      validate_positive_integer!(:scheduled_backlog_threshold, scheduled_backlog_threshold)
      validate_callback!(:on_status_change, on_status_change)
      self
    end

    def strict?
      strict_mode || ActiveModel::Type::Boolean.new.cast(ENV.fetch('SOLID_QUEUE_GUARD_STRICT', nil))
    end

    def check_enabled?(check_id)
      id = check_id.to_sym
      return false if disabled_checks.map(&:to_sym).include?(id)

      settings = check_settings_for(id)
      return true if settings.nil?

      enabled_value = settings[:enabled]
      enabled_value = settings['enabled'] if enabled_value.nil?
      enabled_value != false
    end

    def check_settings_for(check_id)
      checks[check_id.to_sym] || checks[check_id.to_s]
    end

    def check_setting(check_id, key, default = nil)
      settings = check_settings_for(check_id)
      return default unless settings

      value = settings[key]
      value = settings[key.to_sym] if value.nil?
      value.nil? ? default : value
    end

    private

    def validate_http_status!(attribute, value)
      return if HTTP_STATUS_OPTIONS.include?(normalize_http_status_key(value))

      raise ValidationError,
            "#{attribute} must be one of #{HTTP_STATUS_OPTIONS.inspect}, got #{value.inspect}"
    end

    def normalize_http_status_key(value)
      value.is_a?(Integer) ? value : value.to_sym
    end

    def validate_duration!(attribute, value)
      return if value.is_a?(ActiveSupport::Duration) && value.positive?

      raise ValidationError, "#{attribute} must be a positive ActiveSupport::Duration"
    end

    def validate_positive_integer!(attribute, value)
      return if value.is_a?(Integer) && value.positive?

      raise ValidationError, "#{attribute} must be a positive Integer"
    end

    def validate_callback!(attribute, value)
      return if value.nil? || value.respond_to?(:call)

      raise ValidationError, "#{attribute} must respond to #call"
    end
  end
end
