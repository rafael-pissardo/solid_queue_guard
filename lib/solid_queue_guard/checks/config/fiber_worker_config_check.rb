# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class FiberWorkerConfigCheck < Base
        def call
          fiber_workers = solid_queue_configuration.send(:workers_options).select do |worker|
            worker.key?(:fibers)
          end

          return pass(check_id, 'No fiber workers configured') if fiber_workers.empty?

          requirements_failure || valid_result(fiber_workers)
        end

        private

        def requirements_failure
          unless solid_queue_supports_fibers?
            return failure(
              check_id,
              'Fiber workers require Solid Queue 1.6 or newer',
              suggestion: 'Upgrade to Solid Queue 1.6+ or configure worker threads'
            )
          end

          unless OptionalDependency.require!('async/semaphore', 'async')
            return failure(
              check_id,
              'Fiber workers require the async gem',
              suggestion: 'Add gem "async" to your Gemfile'
            )
          end

          return if ActiveSupport::IsolatedExecutionState.isolation_level == :fiber

          failure(
            check_id,
            'Fiber workers require fiber-scoped isolated execution state',
            suggestion: 'Set config.active_support.isolation_level = :fiber'
          )
        end

        def valid_result(fiber_workers)
          max_fibers = fiber_workers.filter_map { |worker| worker[:fibers] }.max
          pass(
            check_id,
            "Fiber worker configuration is valid (max fibers: #{max_fibers})",
            metadata: { max_fibers: max_fibers }
          )
        end

        def solid_queue_supports_fibers?
          Gem::Version.new(SolidQueue::VERSION) >= Gem::Version.new('1.6.0')
        end
      end
    end
  end
end
