# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class ScheduledBacklogCheck < Base
        def call
          with_queue_database do
            due_count = SolidQueue::ScheduledExecution.due.count
            threshold = config.scheduled_backlog_threshold

            if due_count > threshold
              warn(
                check_id,
                "Scheduled backlog is #{due_count} (threshold: #{threshold})",
                suggestion: 'Check dispatcher health and scheduled job volume'
              )
            else
              pass(check_id, "Scheduled backlog is #{due_count}")
            end
          end
        end
      end
    end
  end
end
