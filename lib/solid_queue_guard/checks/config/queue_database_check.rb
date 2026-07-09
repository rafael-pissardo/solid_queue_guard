# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class QueueDatabaseCheck < Base
        def call
          config = Rails.application.config.database_configuration
          env_config = config[Rails.env]

          if env_config.is_a?(Hash) && env_config.key?('queue')
            pass('queue_database', 'Queue database configured in database.yml')
          else
            failure(
              'queue_database',
              "No queue database entry in database.yml for #{Rails.env}",
              suggestion: 'Add a queue database configuration for Solid Queue'
            )
          end
        end
      end
    end
  end
end
