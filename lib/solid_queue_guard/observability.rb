# frozen_string_literal: true

module SolidQueueGuard
  # @api private
  module Observability
    module_function

    def log_results(report)
      return unless logger

      report.results.each do |result|
        message = "[SolidQueueGuard] #{result.status} check #{result.id}: #{result.message}"
        case result.status
        when :skip, :pass then logger.debug(message)
        when :warn then logger.warn(message)
        when :fail then logger.error(message)
        end
      end
    end

    def notify_status_change(report, previous_status: nil)
      callback = SolidQueueGuard.config.on_status_change
      return unless callback.respond_to?(:call)

      current_status = report.status
      return if previous_status == current_status

      callback.call(previous_status, current_status, report)
    end

    def logger
      defined?(Rails) && Rails.logger
    end
  end
end
