# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class ProcessTopologyCheck < Base
        EXPECTED_KINDS = %w[Supervisor Worker Dispatcher Scheduler].freeze

        def call
          with_queue_database do
            kinds = SolidQueue::Process.distinct.pluck(:kind)
            missing = EXPECTED_KINDS - kinds

            if missing == EXPECTED_KINDS
              warn(check_id, 'No Solid Queue processes are running',
                   suggestion: 'Start bin/jobs or the Solid Queue supervisor')
            elsif missing.include?('Worker')
              warn(check_id, 'No worker processes detected',
                   suggestion: 'Ensure workers are configured in queue.yml and running')
            elsif missing.include?('Dispatcher') && scheduled_work_expected?
              warn(check_id, 'No dispatcher process detected with scheduled work configured')
            else
              pass(check_id, "Solid Queue processes running: #{kinds.sort.join(', ')}")
            end
          end
        end

        private

        def scheduled_work_expected?
          solid_queue_configuration.send(:recurring_tasks).any? ||
            SolidQueue::ScheduledExecution.exists?
        rescue StandardError
          false
        end
      end
    end
  end
end
