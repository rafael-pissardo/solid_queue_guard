# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class RecurringStaleCheck < Base
        def call
          with_queue_database do
            tasks = SolidQueue::RecurringTask.static
            return pass(check_id, 'No recurring tasks configured') if tasks.none?

            stale_tasks = tasks.select do |task|
              last_run = SolidQueue::RecurringExecution.where(task_key: task.key).maximum(:run_at)
              last_run.nil? || last_run < expected_staleness.ago
            end

            if stale_tasks.any?
              warn(
                check_id,
                "#{stale_tasks.size} recurring task(s) may be stale: #{stale_tasks.map(&:key).join(', ')}",
                suggestion: 'Verify the scheduler process is running'
              )
            else
              pass(check_id, 'Recurring tasks have recent executions')
            end
          end
        end

        private

        def expected_staleness
          config.check_setting(:recurring_stale, :threshold, config.stale_process_threshold * 2)
        end
      end
    end
  end
end
