# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Runtime
      class RecurringStaleCheckTest < ActiveSupport::TestCase
        setup do
          @original_checks = SolidQueueGuard.config.checks.deep_dup
          SolidQueueGuard.config.checks.recurring_stale = nil
          RecurringStaleCheck.any_instance.stubs(:queue_database_available?).returns(true)
        end

        teardown do
          SolidQueueGuard.config.checks = @original_checks
          RecurringStaleCheck.any_instance.unstub(:queue_database_available?)
          SolidQueue::RecurringTask.unstub(:static)
          SolidQueue::RecurringExecution.unstub(:where)
        end

        test 'passes when no recurring tasks are configured' do
          SolidQueue::RecurringTask.stubs(:static).returns([])

          result = RecurringStaleCheck.call

          assert_predicate result, :pass?
        end

        test 'uses schedule period so frequent tasks stale sooner than daily ones' do
          frequent = stub_task(
            key: 'every_five_minutes',
            previous_time: Time.utc(2026, 8, 3, 12, 0, 0),
            next_time: Time.utc(2026, 8, 3, 12, 5, 0)
          )
          daily = stub_task(
            key: 'once_a_day',
            previous_time: Time.utc(2026, 8, 2, 23, 0, 0),
            next_time: Time.utc(2026, 8, 3, 23, 0, 0)
          )
          SolidQueue::RecurringTask.stubs(:static).returns([frequent, daily])

          # Frequent last ran 20 minutes ago (2x five-minute period = 10 minutes → stale)
          # Daily last ran 12 hours ago (2x 24h = 48 hours → still fresh)
          stub_last_runs(
            'every_five_minutes' => 20.minutes.ago,
            'once_a_day' => 12.hours.ago
          )

          result = RecurringStaleCheck.call

          assert_predicate result, :warn?
          assert_includes result.message, 'every_five_minutes'
          refute_includes result.message, 'once_a_day'
        end

        test 'keeps weekly tasks fresh within two schedule periods' do
          weekly = stub_task(
            key: 'weekly_import',
            previous_time: Time.utc(2026, 7, 28, 6, 0, 0),
            next_time: Time.utc(2026, 8, 4, 6, 0, 0)
          )
          SolidQueue::RecurringTask.stubs(:static).returns([weekly])
          stub_last_runs('weekly_import' => 3.days.ago)

          result = RecurringStaleCheck.call

          assert_predicate result, :pass?
        end

        test 'honors per-task threshold overrides' do
          weekly = stub_task(
            key: 'weekly_import',
            previous_time: Time.utc(2026, 7, 28, 6, 0, 0),
            next_time: Time.utc(2026, 8, 4, 6, 0, 0)
          )
          SolidQueue::RecurringTask.stubs(:static).returns([weekly])
          SolidQueueGuard.config.checks.recurring_stale = { thresholds: { weekly_import: 2.days } }
          stub_last_runs('weekly_import' => 3.days.ago)

          result = RecurringStaleCheck.call

          assert_predicate result, :warn?
          assert_includes result.message, 'weekly_import'
        end

        test 'falls back to configured threshold when schedule period is unavailable' do
          task = stub(key: 'opaque')
          SolidQueue::RecurringTask.stubs(:static).returns([task])
          SolidQueueGuard.config.checks.recurring_stale = { threshold: 30.minutes }
          stub_last_runs('opaque' => 45.minutes.ago)

          result = RecurringStaleCheck.call

          assert_predicate result, :warn?
          assert_includes result.message, 'opaque'
        end

        private

        def stub_task(key:, previous_time:, next_time:)
          stub(key: key, previous_time: previous_time, next_time: next_time)
        end

        def stub_last_runs(last_runs)
          last_runs.each do |task_key, run_at|
            task_relation = stub
            SolidQueue::RecurringExecution.stubs(:where).with(task_key: task_key).returns(task_relation)
            task_relation.stubs(:maximum).with(:run_at).returns(run_at)
          end
        end
      end
    end
  end
end
