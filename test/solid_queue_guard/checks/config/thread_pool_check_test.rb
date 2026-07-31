# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Config
      class ThreadPoolCheckTest < ActiveSupport::TestCase
        test 'fails when pool is smaller than required size' do
          stub_required_pool(12)
          SolidQueue::Configuration.any_instance.stubs(:workers_options).returns([{ threads: 10 }])
          SolidQueue::Record.connection_pool.stubs(:size).returns(5)

          result = SolidQueueGuard::Checks::Config::ThreadPoolCheck.call

          assert_predicate result, :fail?
          assert_includes result.suggestion, '12'
        end

        test 'passes when pool meets required size' do
          stub_required_pool(5)
          SolidQueue::Configuration.any_instance.stubs(:workers_options).returns([{ threads: 3 }])
          SolidQueue::Record.connection_pool.stubs(:size).returns(5)

          result = SolidQueueGuard::Checks::Config::ThreadPoolCheck.call

          assert_predicate result, :pass?
        end

        private

        def stub_required_pool(size)
          if SolidQueue::Configuration.private_method_defined?(:estimated_database_pool_size)
            SolidQueue::Configuration.any_instance.stubs(:estimated_database_pool_size).returns(size)
          else
            SolidQueue::Configuration.any_instance.stubs(:estimated_number_of_threads).returns(size)
          end
        end
      end
    end
  end
end
