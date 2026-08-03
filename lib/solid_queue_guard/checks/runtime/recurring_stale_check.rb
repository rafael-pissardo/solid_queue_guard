# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class RecurringStaleCheck < Base
        DEFAULT_MULTIPLIER = 2

        def call
          with_queue_database do
            tasks = SolidQueue::RecurringTask.static
            return pass(check_id, 'No recurring tasks configured') if tasks.none?

            stale_tasks = tasks.select { |task| stale?(task) }

            if stale_tasks.any?
              warn(
                check_id,
                "#{stale_tasks.size} recurring task(s) may be stale: #{stale_tasks.map(&:key).join(', ')}",
                suggestion: 'Verify the scheduler process is running'
              )
            else
              pass(check_id, 'Recurring tasks have recent executions')
            end
          end
        end

        private

        def stale?(task)
          last_run = SolidQueue::RecurringExecution.where(task_key: task.key).maximum(:run_at)
          last_run.nil? || last_run < expected_staleness_for(task).ago
        end

        def expected_staleness_for(task)
          override = per_task_threshold(task.key)
          return override if override

          period = schedule_period_for(task)
          return period * multiplier if period

          fallback_threshold
        end

        def per_task_threshold(task_key)
          thresholds = config.check_setting(:recurring_stale, :thresholds, nil)
          return unless thresholds

          thresholds[task_key.to_sym] || thresholds[task_key.to_s]
        end

        def schedule_period_for(task)
          return unless task.respond_to?(:previous_time) && task.respond_to?(:next_time)

          previous = task.previous_time
          nxt = task.next_time
          return unless previous && nxt

          seconds = nxt - previous
          return unless seconds.positive?

          seconds.seconds
        rescue StandardError
          nil
        end

        def multiplier
          config.check_setting(:recurring_stale, :multiplier, DEFAULT_MULTIPLIER)
        end

        def fallback_threshold
          config.check_setting(:recurring_stale, :threshold, config.stale_process_threshold * 2)
        end
      end
    end
  end
end
