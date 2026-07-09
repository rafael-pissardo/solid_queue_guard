# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class ThreadPoolCheck < Base
        def call
          required_threads = solid_queue_configuration.send(:estimated_number_of_threads)
          pool_size = SolidQueue::Record.connection_pool&.size

          if pool_size.nil?
            return skip("thread_pool", "Queue database connection pool is not available")
          end

          max_worker_threads = solid_queue_configuration.send(:workers_options)
            .map { |options| options.fetch(:threads, 3) }.max || 1

          if pool_size >= required_threads
            pass(
              "thread_pool",
              "Worker threads: #{max_worker_threads}, queue DB pool: #{pool_size}",
              metadata: { threads: max_worker_threads, pool: pool_size, required: required_threads }
            )
          else
            fail(
              "thread_pool",
              "Worker threads: #{max_worker_threads}, queue DB pool: #{pool_size}",
              suggestion: "Increase queue DB pool to at least #{required_threads} or reduce worker threads",
              metadata: { threads: max_worker_threads, pool: pool_size, required: required_threads }
            )
          end
        end
      end
    end
  end
end
