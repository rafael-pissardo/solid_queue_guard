# frozen_string_literal: true

module SolidQueueGuard
  # @api private
  module OptionalDependency
    module_function

    def require!(feature, gem_name = feature)
      require feature
      true
    rescue LoadError
      log_missing(gem_name)
      false
    end

    def log_missing(gem_name)
      return unless defined?(Rails) && Rails.logger

      Rails.logger.warn(
        "[solid_queue_guard] Optional dependency #{gem_name} is not installed. " \
        'Add it to your Gemfile to enable this integration.'
      )
    end
  end
end
