# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class SchedulerConfigCheck < Base
        def call
          recurring_tasks = solid_queue_configuration.send(:recurring_tasks)
          scheduler_expected = solid_queue_configuration.send(:schedulers).any?

          return pass('scheduler_config', 'No recurring tasks configured') if recurring_tasks.empty?

          if scheduler_expected
            pass('scheduler_config', "Recurring scheduler is configured (#{recurring_tasks.size} tasks)")
          elsif solid_queue_configuration.send(:skip_recurring_tasks?)
            warn(
              'scheduler_config',
              'Recurring tasks defined but recurring execution is skipped',
              suggestion: 'Unset SOLID_QUEUE_SKIP_RECURRING and ensure scheduler process runs'
            )
          else
            failure(
              'scheduler_config',
              'recurring.yml defines scheduled tasks but no scheduler is configured',
              suggestion: 'Ensure config/recurring.yml tasks have a :schedule key and scheduler is enabled'
            )
          end
        end
      end
    end
  end
end
