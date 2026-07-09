# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class FinishedJobsGrowthCheck < Base
        WINDOW = 24.hours
        GROWTH_THRESHOLD = 10_000

        def call
          with_queue_database do
            recent_finished = SolidQueue::Job.where(finished_at: WINDOW.ago..).count

            if recent_finished > GROWTH_THRESHOLD
              warn(
                check_id,
                "#{recent_finished} finished jobs in the last 24 hours",
                suggestion: 'Ensure a recurring cleanup task runs (SolidQueue::Job.clear_finished_in_batches)'
              )
            else
              pass(check_id, "#{recent_finished} finished jobs in the last 24 hours")
            end
          end
        end
      end
    end
  end
end
