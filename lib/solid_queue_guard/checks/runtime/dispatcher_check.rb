# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class DispatcherCheck < Base
        def call
          with_queue_database do
            dispatchers = SolidQueue::Process.where(kind: 'Dispatcher')
            due_count = SolidQueue::ScheduledExecution.due.count

            if dispatchers.none? && due_count.positive?
              failure(
                check_id,
                "#{due_count} scheduled job(s) are due but no dispatcher is running",
                suggestion: 'Start a dispatcher process or verify bin/jobs is running'
              )
            elsif due_count > config.scheduled_backlog_threshold
              warn(
                check_id,
                "#{due_count} scheduled executions are due (threshold: #{config.scheduled_backlog_threshold})",
                suggestion: 'Verify the dispatcher is keeping up with scheduled work'
              )
            else
              pass(check_id, "Dispatcher healthy (#{due_count} due scheduled executions)")
            end
          end
        end
      end
    end
  end
end
