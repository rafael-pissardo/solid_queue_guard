# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class FailedJobsCheck < Base
        WINDOW = 1.hour

        def call
          with_queue_database do
            count = SolidQueue::FailedExecution.where(created_at: WINDOW.ago..).count
            threshold = config.check_setting(:failed_jobs, :threshold, config.failed_jobs_threshold)

            if count > threshold
              warn(
                check_id,
                "#{count} failed job(s) in the last hour (threshold: #{threshold})",
                suggestion: 'Review failed jobs in Mission Control or solid_queue_failed_executions',
                metadata: { failed_jobs_last_hour: count }
              )
            else
              pass(check_id, "#{count} failed job(s) in the last hour")
            end
          end
        end
      end
    end
  end
end
