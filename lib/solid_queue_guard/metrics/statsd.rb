# frozen_string_literal: true

module SolidQueueGuard
  module Metrics
    module Statsd
      module_function

      def export(report)
        host = ENV.fetch('SOLID_QUEUE_GUARD_STATSD_HOST', '127.0.0.1')
        port = ENV.fetch('SOLID_QUEUE_GUARD_STATSD_PORT', 8125).to_i
        socket = UDPSocket.new
        metric_lines(report).each do |line|
          socket.send(line, 0, host, port)
        end
      ensure
        socket&.close
      end

      def metric_lines(report)
        [
          "solid_queue.guard.overall_status:#{STATUS_VALUES.fetch(report.status)}|g",
          *check_status_lines(report)
        ]
      end

      def check_status_lines(report)
        report.results.map do |result|
          value = CHECK_STATUS_VALUES.fetch(result.status)
          "solid_queue.guard.check_status:#{value}|g|##{result.id}"
        end
      end

      STATUS_VALUES = Exporter::STATUS_VALUES
      CHECK_STATUS_VALUES = Exporter::CHECK_STATUS_VALUES
    end
  end
end
