# frozen_string_literal: true

module SolidQueueGuard
  module Metrics
    module Prometheus
      module_function

      def export(report)
        path = ENV.fetch('SOLID_QUEUE_GUARD_PROMETHEUS_FILE', Rails.root.join('tmp/solid_queue_guard.prom'))
        File.write(path, render(report))
      end

      def render(report)
        <<~PROM
          # TYPE solid_queue_guard_overall_status gauge
          solid_queue_guard_overall_status #{Exporter::STATUS_VALUES.fetch(report.status)}
        PROM
      end
    end
  end
end
