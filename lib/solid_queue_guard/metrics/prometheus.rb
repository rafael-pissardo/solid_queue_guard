# frozen_string_literal: true

require 'fileutils'

module SolidQueueGuard
  module Metrics
    module Prometheus
      module_function

      def export(report)
        path = ENV.fetch('SOLID_QUEUE_GUARD_PROMETHEUS_FILE', Rails.root.join('tmp/solid_queue_guard.prom'))
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, render(report))
      end

      def render(report)
        lines = [
          '# TYPE solid_queue_guard_overall_status gauge',
          "solid_queue_guard_overall_status #{STATUS_VALUES.fetch(report.status)}",
          '# TYPE solid_queue_guard_check_status gauge'
        ]

        report.results.each do |result|
          value = CHECK_STATUS_VALUES.fetch(result.status)
          lines << "solid_queue_guard_check_status{check=\"#{result.id}\"} #{value}"
        end

        "#{lines.join("\n")}\n"
      end

      STATUS_VALUES = Exporter::STATUS_VALUES
      CHECK_STATUS_VALUES = Exporter::CHECK_STATUS_VALUES
    end
  end
end
