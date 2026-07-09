# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class QueueLagCheck < Base
        def call
          with_queue_database do
            lags = SolidQueue::ReadyExecution.group(:queue_name).minimum(:created_at)
            return pass(check_id, 'No jobs waiting in ready queues') if lags.empty?

            worst = lags.map do |queue_name, oldest|
              lag = Time.current - oldest
              { queue: queue_name, lag: lag, threshold: lag_threshold_for(queue_name) }
            end.max_by { |entry| entry[:lag] }

            if worst[:lag] > worst[:threshold]
              failure(
                check_id,
                "#{worst[:queue]} queue lag is #{worst[:lag].to_i} seconds",
                suggestion: "Investigate worker coverage and throughput for the #{worst[:queue]} queue",
                metadata: { queue_lag_seconds: worst[:lag].to_i, queue_name: worst[:queue] }
              )
            elsif worst[:lag] > worst[:threshold] / 2
              warn(
                check_id,
                "#{worst[:queue]} queue lag is #{worst[:lag].to_i} seconds",
                metadata: { queue_lag_seconds: worst[:lag].to_i, queue_name: worst[:queue] }
              )
            else
              pass(check_id, "Queue lag within thresholds (worst: #{worst[:queue]} at #{worst[:lag].to_i}s)")
            end
          end
        end
      end
    end
  end
end
