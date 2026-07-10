# frozen_string_literal: true

module SolidQueueGuard
  module Metrics
    module OpenTelemetry
      module_function

      def export(report)
        return unless OptionalDependency.require!('opentelemetry-sdk', 'opentelemetry-sdk')

        meter = ::OpenTelemetry.meter_provider.meter('solid_queue_guard')
        overall_gauge = meter.create_gauge('solid_queue.guard.overall_status', unit: 'status')
        overall_gauge.record(STATUS_VALUES.fetch(report.status))

        check_gauge = meter.create_gauge('solid_queue.guard.check_status', unit: 'status')
        report.results.each do |result|
          check_gauge.record(CHECK_STATUS_VALUES.fetch(result.status), attributes: { 'check.id' => result.id })
        end
      rescue StandardError => e
        Rails.logger.warn("[solid_queue_guard] OpenTelemetry export failed: #{e.class}: #{e.message}")
      end

      STATUS_VALUES = Exporter::STATUS_VALUES
      CHECK_STATUS_VALUES = Exporter::CHECK_STATUS_VALUES
    end
  end
end
