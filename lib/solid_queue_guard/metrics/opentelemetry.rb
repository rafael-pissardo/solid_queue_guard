# frozen_string_literal: true

module SolidQueueGuard
  module Metrics
    module OpenTelemetry
      module_function

      def export(report)
        return unless defined?(::OpenTelemetry)

        meter = ::OpenTelemetry.meter_provider.meter('solid_queue_guard')
        gauge = meter.create_gauge('solid_queue.guard.overall_status', unit: 'status')
        gauge.record(Exporter::STATUS_VALUES.fetch(report.status))
      rescue StandardError
        nil
      end
    end
  end
end
