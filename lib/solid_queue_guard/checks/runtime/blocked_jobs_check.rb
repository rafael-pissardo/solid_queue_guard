# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class BlockedJobsCheck < Base
        def call
          with_queue_database do
            blocked = SolidQueue::BlockedExecution.count
            expired = SolidQueue::BlockedExecution.expired.count

            if expired.positive?
              warn(
                check_id,
                "#{expired} blocked job(s) have expired concurrency locks",
                suggestion: 'Verify concurrency release maintenance is running'
              )
            elsif blocked.positive?
              pass(check_id, "#{blocked} job(s) blocked by concurrency control")
            else
              pass(check_id, 'No blocked jobs')
            end
          end
        end
      end
    end
  end
end
