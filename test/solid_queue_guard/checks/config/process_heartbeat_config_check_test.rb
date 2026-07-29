# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Config
      class ProcessHeartbeatConfigCheckTest < ActiveSupport::TestCase
        setup do
          @original_threshold = SolidQueueGuard.config.stale_process_threshold
          @original_checks = SolidQueueGuard.config.checks.dup
        end

        teardown do
          SolidQueueGuard.config.stale_process_threshold = @original_threshold
          SolidQueueGuard.config.checks = @original_checks
        end

        test 'passes with Solid Queue defaults' do
          stub_heartbeat(interval: 60.seconds, alive: 5.minutes)

          result = call

          assert_predicate result, :pass?
          assert_includes result.message, '5.0x margin'
        end

        test 'fails when alive threshold is not above the heartbeat interval' do
          stub_heartbeat(interval: 60.seconds, alive: 60.seconds)

          result = call

          assert_predicate result, :fail?
          assert_includes result.message, 'is not greater than'
          assert_includes result.suggestion, '2 minutes'
        end

        test 'warns when alive threshold tolerates less than two heartbeats' do
          stub_heartbeat(interval: 60.seconds, alive: 90.seconds)

          result = call

          assert_predicate result, :warn?
          assert_includes result.message, 'tolerates less than 2 heartbeats'
        end

        test 'honors a custom min_margin' do
          SolidQueueGuard.config.checks.process_heartbeat_config = { min_margin: 6 }
          stub_heartbeat(interval: 60.seconds, alive: 5.minutes)

          result = call

          assert_predicate result, :warn?
          assert_includes result.suggestion, '6 minutes'
        end

        test 'warns when guard stale_process_threshold is above the alive threshold' do
          SolidQueueGuard.config.stale_process_threshold = 10.minutes
          stub_heartbeat(interval: 60.seconds, alive: 5.minutes)

          result = call

          assert_predicate result, :warn?
          assert_includes result.message, 'Guard stale_process_threshold'
          assert_equal 600, result.metadata[:stale_process_threshold]
        end

        test 'fails when heartbeat interval is not positive' do
          stub_heartbeat(interval: 0, alive: 5.minutes)

          result = call

          assert_predicate result, :fail?
          assert_includes result.message, 'must be a positive duration'
        end

        private

        def stub_heartbeat(interval:, alive:)
          SolidQueue.stubs(:process_heartbeat_interval).returns(interval)
          SolidQueue.stubs(:process_alive_threshold).returns(alive)
        end

        def call
          SolidQueueGuard::Checks::Config::ProcessHeartbeatConfigCheck.call
        end
      end
    end
  end
end
