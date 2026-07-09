# frozen_string_literal: true

module SolidQueueGuard
  module Recommendations
    class Topology
      def self.analyze(configuration: SolidQueue::Configuration.new)
        new(configuration: configuration).analyze
      end

      def initialize(configuration:)
        @configuration = configuration
      end

      def analyze
        recommendations = []
        recommendations.concat(worker_recommendations)
        recommendations.concat(pool_recommendations)
        recommendations.uniq
      end

      private

      attr_reader :configuration

      def worker_recommendations
        worker_queues = QueueCoverage.worker_queues_from_configuration(configuration)
        uncovered = uncovered_queues(worker_queues)
        return [] if uncovered.empty?

        ["Add worker coverage for: #{uncovered.join(', ')}"]
      end

      def pool_recommendations
        required_threads = configuration.estimated_number_of_threads
        pool_size = SolidQueue::Record.connection_pool&.size
        return [] if pool_size.nil? || required_threads <= pool_size

        ["Increase queue DB pool to at least #{required_threads + 2} (currently #{pool_size})"]
      rescue StandardError
        []
      end

      def uncovered_queues(assigned_queues)
        observed = observed_queues
        (observed - assigned_queues).sort
      end

      def observed_queues
        return [] unless database_available?

        SolidQueue::Job.distinct.pluck(:queue_name)
      rescue StandardError
        []
      end

      def database_available?
        SolidQueue::Record.connection_pool&.with_connection(&:active?)
      rescue StandardError
        false
      end
    end
  end
end
