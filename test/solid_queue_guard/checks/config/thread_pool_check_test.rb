# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Config
      class ThreadPoolCheckTest < ActiveSupport::TestCase
        test 'fails when pool is smaller than required threads' do
          SolidQueue::Configuration.any_instance.stubs(:estimated_number_of_threads).returns(12)
          SolidQueue::Configuration.any_instance.stubs(:workers_options).returns([{ threads: 10 }])
          SolidQueue::Record.connection_pool.stubs(:size).returns(5)

          result = SolidQueueGuard::Checks::Config::ThreadPoolCheck.call

          assert_predicate result, :fail?
          assert_includes result.suggestion, '12'
        end
      end
    end
  end
end
