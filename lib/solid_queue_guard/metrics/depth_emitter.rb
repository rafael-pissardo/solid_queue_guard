# frozen_string_literal: true

module SolidQueueGuard
  module Metrics
    # Snapshot gauges answering "are jobs stuck right now?"
    # (same DB source as Mission Control /jobs).
    module DepthEmitter
      module_function

      def emit!
        return unless enabled?

        emit_ready_gauges!
        emit_execution_gauges!
        statsd.flush if statsd.respond_to?(:flush)
      end

      def enabled?
        SolidQueueGuard.config.emit_depth_metrics &&
          %w[production staging].include?(Rails.env.to_s)
      end

      def statsd
        DogstatsdClient.statsd
      end

      def emit_ready_gauges!
        ready_counts = SolidQueue::ReadyExecution.group(:queue_name).count
        oldest_by_queue = SolidQueue::ReadyExecution.group(:queue_name).minimum(:created_at)

        if ready_counts.empty?
          statsd.gauge('solid_queue.ready.count', 0)
          statsd.gauge('solid_queue.ready.oldest_age_seconds', 0)
          return
        end

        emit_ready_counts!(ready_counts)
        emit_ready_ages!(oldest_by_queue)
      end

      def emit_ready_counts!(ready_counts)
        ready_counts.each do |queue_name, count|
          statsd.gauge('solid_queue.ready.count', count, tags: ["queue:#{queue_name}"])
        end
      end

      def emit_ready_ages!(oldest_by_queue)
        now = Time.current
        oldest_by_queue.each do |queue_name, created_at|
          age = created_at ? [(now - created_at).to_i, 0].max : 0
          statsd.gauge('solid_queue.ready.oldest_age_seconds', age, tags: ["queue:#{queue_name}"])
        end
      end

      def emit_execution_gauges!
        statsd.gauge('solid_queue.failed.count', SolidQueue::FailedExecution.count)
        statsd.gauge('solid_queue.claimed.count', SolidQueue::ClaimedExecution.count)
        statsd.gauge('solid_queue.scheduled.count', SolidQueue::ScheduledExecution.count)
      end
    end
  end
end
