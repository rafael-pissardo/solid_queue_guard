# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class OrphanedClaimsCheck < Base
        def call
          with_queue_database do
            alive_process_ids = SolidQueue::Process.pluck(:id)
            orphaned = SolidQueue::ClaimedExecution.where.not(process_id: alive_process_ids)

            if orphaned.none?
              pass(check_id, 'No orphaned claimed executions')
            else
              warn(
                check_id,
                "#{orphaned.count} claimed execution(s) belong to dead processes",
                suggestion: 'Restart workers; Solid Queue maintenance should release orphaned claims'
              )
            end
          end
        end
      end
    end
  end
end
