# frozen_string_literal: true

module SolidQueueGuard
  module Metrics
    module Statsd
      module_function

      def export(report)
        require 'socket'
        host = ENV.fetch('SOLID_QUEUE_GUARD_STATSD_HOST', '127.0.0.1')
        port = ENV.fetch('SOLID_QUEUE_GUARD_STATSD_PORT', 8125).to_i
        socket = UDPSocket.new
        socket.send(metric_line(report), 0, host, port)
      ensure
        socket&.close
      end

      def metric_line(report)
        "solid_queue.guard.overall_status:#{STATUS_VALUES.fetch(report.status)}|g"
      end

      STATUS_VALUES = Exporter::STATUS_VALUES
    end
  end
end
