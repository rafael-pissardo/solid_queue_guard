# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class ThreadPoolCheck < Base
        def call
          required_pool = ConfigurationSizing.estimated_database_pool_size(solid_queue_configuration)
          pool_size = SolidQueue::Record.connection_pool&.size

          return skip('thread_pool', 'Queue database connection pool is not available') if pool_size.nil?

          execution_mode, max_worker_capacity = largest_worker_details
          metadata = {
            execution_mode => max_worker_capacity,
            pool: pool_size,
            required: required_pool
          }
          message = "Worker #{execution_mode}: #{max_worker_capacity}, queue DB pool: #{pool_size}"

          if pool_size >= required_pool
            pass(
              'thread_pool',
              message,
              metadata: metadata
            )
          else
            failure(
              'thread_pool',
              message,
              suggestion: "Increase queue DB pool to at least #{required_pool} or reduce worker #{execution_mode}",
              metadata: metadata
            )
          end
        end

        private

        def largest_worker_details
          workers = solid_queue_configuration.send(:workers_options)
          largest_worker = workers.max_by { |worker| worker_capacity(worker) } || {}

          [execution_mode(largest_worker), worker_capacity(largest_worker)]
        end

        def execution_mode(worker)
          worker.key?(:fibers) ? :fibers : :threads
        end

        def worker_capacity(worker)
          worker[:fibers] || worker.fetch(:threads, 3)
        end
      end
    end
  end
end
