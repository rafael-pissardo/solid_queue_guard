# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      module DatabaseSupport
        private

        def queue_database_available?
          pool = SolidQueue::Record.connection_pool
          return false if pool.nil?

          pool.with_connection(&:active?)
        rescue StandardError
          false
        end

        def with_queue_database
          return skip(check_id, 'Queue database is not available') unless queue_database_available?

          yield
        rescue StandardError => e
          skip(check_id, "Queue database query failed: #{e.class}")
        end

        def config
          SolidQueueGuard.config
        end

        def lag_threshold_for(queue_name)
          thresholds = config.queue_lag_thresholds
          thresholds[queue_name.to_sym] || thresholds[queue_name] || thresholds[:default]
        end
      end
    end
  end
end
