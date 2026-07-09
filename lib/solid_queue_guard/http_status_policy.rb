# frozen_string_literal: true

module SolidQueueGuard
  # @api private
  module HttpStatusPolicy
    module_function

    STATUS_MAP = {
      ok: :ok,
      success: :ok,
      200 => :ok,
      multi_status: :multi_status,
      207 => :multi_status,
      service_unavailable: :service_unavailable,
      unavailable: :service_unavailable,
      503 => :service_unavailable
    }.freeze

    def resolve(status)
      key = status.is_a?(Integer) ? status : status.to_sym
      STATUS_MAP.fetch(key, :ok)
    end

    def for_report_status(report_status, config: SolidQueueGuard.config)
      case report_status.to_s
      when 'unhealthy'
        resolve(config.unhealthy_http_status)
      when 'degraded'
        resolve(config.degraded_http_status)
      else
        :ok
      end
    end
  end
end
