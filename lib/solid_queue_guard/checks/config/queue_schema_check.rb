# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class QueueSchemaCheck < Base
        def call
          schema_path = rails_root.join("db/queue_schema.rb")

          if schema_path.exist?
            pass("queue_schema", "db/queue_schema.rb exists")
          else
            warn(
              "queue_schema",
              "db/queue_schema.rb not found",
              suggestion: "Run bin/rails solid_queue:install to generate the queue schema"
            )
          end
        end
      end
    end
  end
end
