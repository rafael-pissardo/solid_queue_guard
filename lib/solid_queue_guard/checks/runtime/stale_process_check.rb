# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class StaleProcessCheck < Base
        def call
          with_queue_database do
            threshold = config.check_setting(:stale_process, :threshold, config.stale_process_threshold)
            stale = SolidQueue::Process.where(last_heartbeat_at: ...threshold.ago)

            if stale.none?
              pass(check_id, 'All Solid Queue processes have recent heartbeats')
            else
              failure(
                check_id,
                "#{stale.count} Solid Queue process(es) have stale heartbeats",
                suggestion: 'Restart the Solid Queue supervisor and verify workers are running',
                metadata: { stale_processes: stale.count }
              )
            end
          end
        end
      end
    end
  end
end
