# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class AdapterCheck < Base
        def call
          adapter = Rails.application.config.active_job.queue_adapter

          if adapter.to_sym == :solid_queue
            pass("adapter", "Active Job adapter is :solid_queue")
          else
            fail(
              "adapter",
              "Active Job adapter is #{adapter.inspect}, expected :solid_queue",
              suggestion: "Set config.active_job.queue_adapter = :solid_queue"
            )
          end
        end
      end
    end
  end
end
