# frozen_string_literal: true

module SolidQueueGuard
  module Health
    class Payload
      def initialize(report)
        @report = report
      end

      def to_h
        base = report.to_h.merge(
          queue_lag_seconds: queue_lag_seconds,
          failed_jobs_last_hour: failed_jobs_last_hour,
          dead_processes: dead_processes
        )

        base[:recommendations] = topology_recommendations if topology_recommendations.any?
        base
      end

      private

      attr_reader :report

      def queue_lag_seconds
        metadata_value('queue_lag') { |metadata| metadata[:queue_lag_seconds] }
      end

      def failed_jobs_last_hour
        metadata_value('failed_jobs') { |metadata| metadata[:failed_jobs_last_hour] } || 0
      end

      def dead_processes
        metadata_value('stale_process') { |metadata| metadata[:stale_processes] } || 0
      end

      def metadata_value(check_id)
        result = report.results.find { |entry| entry.id == check_id }
        metadata = result&.metadata || {}
        value = yield(metadata)
        value unless value.nil?
      end

      def topology_recommendations
        result = report.results.find { |entry| entry.id == 'topology_recommendation' }
        result&.metadata&.fetch(:recommendations, []) || []
      end
    end
  end
end
