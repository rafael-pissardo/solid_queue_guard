# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class ConnectsToCheck < Base
        def call
          connects_to = Rails.application.config.solid_queue.connects_to

          if connects_to.blank?
            return fail(
              "connects_to",
              "config.solid_queue.connects_to is not configured",
              suggestion: "Set config.solid_queue.connects_to = { database: { writing: :queue } }"
            )
          end

          writing = connects_to.dig(:database, :writing) || connects_to.dig("database", "writing")

          if writing.to_s != "queue"
            fail(
              "connects_to",
              "Solid Queue connects_to writing target is #{writing.inspect}, expected :queue",
              suggestion: "Point config.solid_queue.connects_to to the queue database"
            )
          elsif SolidQueue::Record.connection_pool.nil?
            fail("connects_to", "Solid Queue queue database connection pool is not available")
          else
            pass(
              "connects_to",
              "Solid Queue connects_to queue database (pool: #{SolidQueue::Record.connection_pool.size})"
            )
          end
        end
      end
    end
  end
end
