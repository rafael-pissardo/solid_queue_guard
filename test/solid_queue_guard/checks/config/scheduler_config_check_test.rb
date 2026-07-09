# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Config
      class SchedulerConfigCheckTest < ActiveSupport::TestCase
        test 'passes when no recurring tasks are configured' do
          configuration = stub_recurring_configuration(recurring_tasks: {}, schedulers: [], skip_recurring: false)

          result = SolidQueueGuard::Checks::Config::SchedulerConfigCheck.call

          assert_predicate result, :pass?
          assert_includes result.message, 'No recurring tasks'
        ensure
          restore_solid_queue_configuration_stub(configuration)
        end

        test 'passes when recurring tasks have a scheduler' do
          configuration = stub_recurring_configuration(
            recurring_tasks: { 'clear_finished_jobs' => {} },
            schedulers: [{ polling_interval: 1 }],
            skip_recurring: false
          )

          result = SolidQueueGuard::Checks::Config::SchedulerConfigCheck.call

          assert_predicate result, :pass?
          assert_includes result.message, 'scheduler'
        ensure
          restore_solid_queue_configuration_stub(configuration)
        end

        test 'fails when recurring tasks exist without a scheduler' do
          configuration = stub_recurring_configuration(
            recurring_tasks: { 'billing' => {} },
            schedulers: [],
            skip_recurring: false
          )

          result = SolidQueueGuard::Checks::Config::SchedulerConfigCheck.call

          assert_predicate result, :fail?
          assert_includes result.message, 'no scheduler'
        ensure
          restore_solid_queue_configuration_stub(configuration)
        end

        test 'warns when recurring tasks are skipped' do
          configuration = stub_recurring_configuration(
            recurring_tasks: { 'billing' => {} },
            schedulers: [],
            skip_recurring: true
          )

          result = SolidQueueGuard::Checks::Config::SchedulerConfigCheck.call

          assert_predicate result, :warn?
          assert_includes result.suggestion, 'SOLID_QUEUE_SKIP_RECURRING'
        ensure
          restore_solid_queue_configuration_stub(configuration)
        end

        private

        def stub_recurring_configuration(recurring_tasks:, schedulers:, skip_recurring:)
          configuration = mock('solid_queue_configuration')
          configuration.stubs(:recurring_tasks).returns(recurring_tasks)
          configuration.stubs(:schedulers).returns(schedulers)
          configuration.stubs(:skip_recurring_tasks?).returns(skip_recurring)
          SolidQueueGuard::Checks::Base.any_instance.stubs(:solid_queue_configuration).returns(configuration)
          configuration
        end

        def restore_solid_queue_configuration_stub(configuration)
          SolidQueueGuard::Checks::Base.any_instance.unstub(:solid_queue_configuration) if configuration
        end
      end
    end
  end
end
