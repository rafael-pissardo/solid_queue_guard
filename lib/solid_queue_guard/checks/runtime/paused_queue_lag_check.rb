# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class PausedQueueLagCheck < Base
        def call
          with_queue_database do
            paused_queues = SolidQueue::Pause.pluck(:queue_name)
            return pass(check_id, 'No paused queues') if paused_queues.empty?

            growing = paused_queues.select do |queue_name|
              SolidQueue::ReadyExecution.exists?(queue_name: queue_name)
            end

            if growing.any?
              warn(
                check_id,
                "Paused queue(s) still have ready jobs: #{growing.join(', ')}",
                suggestion: 'Unpause queues or drain jobs before pausing'
              )
            else
              pass(check_id, "Paused queues have no ready backlog: #{paused_queues.join(', ')}")
            end
          end
        end
      end
    end
  end
end
