# frozen_string_literal: true

module SolidQueueGuard
  module Metrics
    # Shared Datadog StatsD client for operational gauges/counters.
    # Distinct from Metrics::Statsd (raw UDP export of guard check status).
    module DogstatsdClient
      module_function

      def statsd
        @statsd ||= build_client
      end

      def reset!
        @statsd = nil
        remove_instance_variable(:@available) if instance_variable_defined?(:@available)
      end

      def available?
        return @available if instance_variable_defined?(:@available)

        @available = OptionalDependency.require!('datadog/statsd', 'dogstatsd-ruby')
      end

      def service_name
        SolidQueueGuard.config.statsd_service_name.presence ||
          ENV['DD_SERVICE'].presence ||
          ENV['SOLID_QUEUE_GUARD_SERVICE'].presence
      end

      def default_tags
        tags = ["env:#{Rails.env}"]
        tags << "service:#{service_name}" if service_name
        tags
      end

      def job_tags(job)
        ["job_class:#{job.class.name}", "queue:#{job.queue_name}"]
      end

      def process_tags(kind, process)
        ["kind:#{kind}", "process:#{process.name}"]
      end

      def build_client
        return NullStatsd.new unless available?

        ::Datadog::Statsd.new(tags: default_tags)
      end
      private_class_method :build_client

      # No-op client when dogstatsd-ruby is not installed.
      class NullStatsd
        def increment(*) = nil
        def gauge(*) = nil
        def timing(*) = nil
        def flush = nil
      end
    end
  end
end
