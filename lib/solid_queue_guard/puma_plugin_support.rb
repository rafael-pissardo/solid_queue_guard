# frozen_string_literal: true

module SolidQueueGuard
  # @api private
  module PumaPluginSupport
    module_function

    PUMA_PLUGIN_PATTERN = /plugin\s+:?solid_queue/
    ASYNC_MODE_PATTERN = /solid_queue_mode\s+:?async/

    def puma_config_path
      Rails.root.join('config/puma.rb')
    end

    def puma_config_content
      return unless puma_config_path.exist?

      puma_config_path.read
    end

    def puma_plugin_enabled?
      content = puma_config_content
      content.present? && content.match?(PUMA_PLUGIN_PATTERN)
    end

    def puma_async_mode?
      content = puma_config_content
      content.present? && content.match?(ASYNC_MODE_PATTERN)
    end

    def async_supervisor_mode?
      ENV.fetch('SOLID_QUEUE_SUPERVISOR_MODE', 'fork').casecmp('async').zero? || puma_async_mode?
    end
  end
end
