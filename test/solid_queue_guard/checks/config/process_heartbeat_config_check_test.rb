# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Config
      class ProcessHeartbeatConfigCheckTest < ActiveSupport::TestCase
        test 'warns when heartbeat thresholds use defaults' do
          SolidQueue.stubs(:process_heartbeat_interval).returns(60.seconds)
          SolidQueue.stubs(:process_alive_threshold).returns(5.minutes)

          result = SolidQueueGuard::Checks::Config::ProcessHeartbeatConfigCheck.call

          assert_predicate result, :warn?
          assert_includes result.message, 'defaults'
        end

        test 'passes when heartbeat thresholds are customized' do
          SolidQueue.stubs(:process_heartbeat_interval).returns(30.seconds)
          SolidQueue.stubs(:process_alive_threshold).returns(10.minutes)

          result = SolidQueueGuard::Checks::Config::ProcessHeartbeatConfigCheck.call

          assert_predicate result, :pass?
          assert_includes result.message, '30 seconds'
        end
      end
    end
  end
end
