# frozen_string_literal: true

module SolidQueueGuard
  module Metrics
    class Exporter
      STATUS_VALUES = { healthy: 0, degraded: 1, unhealthy: 2 }.freeze

      def self.export(report, backends: SolidQueueGuard.config.metrics_backends)
        new(report, backends: backends).export
      end

      def initialize(report, backends:)
        @report = report
        @backends = Array(backends)
      end

      def export
        backends.each { |backend| export_backend(backend) }
      end

      private

      attr_reader :report, :backends

      def export_backend(backend)
        case backend.to_sym
        when :statsd then Statsd.export(report)
        when :prometheus then Prometheus.export(report)
        when :opentelemetry then OpenTelemetry.export(report)
        end
      end
    end
  end
end
