# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Config
      class FiberWorkerConfigCheckTest < ActiveSupport::TestCase
        test 'passes when no fiber workers are configured' do
          stub_workers([{ threads: 3 }])

          result = FiberWorkerConfigCheck.call

          assert_predicate result, :pass?
        end

        test 'fails when async is unavailable' do
          stub_workers([{ fibers: 100 }])
          FiberWorkerConfigCheck.any_instance.stubs(:solid_queue_supports_fibers?).returns(true)
          OptionalDependency.stubs(:require!).with('async/semaphore', 'async').returns(false)

          result = FiberWorkerConfigCheck.call

          assert_predicate result, :fail?
          assert_includes result.suggestion, 'gem "async"'
        end

        test 'fails when Solid Queue does not support fiber workers' do
          stub_workers([{ fibers: 100 }])
          FiberWorkerConfigCheck.any_instance.stubs(:solid_queue_supports_fibers?).returns(false)

          result = FiberWorkerConfigCheck.call

          assert_predicate result, :fail?
          assert_includes result.suggestion, 'Solid Queue 1.6'
        end

        test 'fails when isolated execution state is not fiber scoped' do
          stub_workers([{ fibers: 100 }])
          FiberWorkerConfigCheck.any_instance.stubs(:solid_queue_supports_fibers?).returns(true)
          OptionalDependency.stubs(:require!).with('async/semaphore', 'async').returns(true)
          ActiveSupport::IsolatedExecutionState.stubs(:isolation_level).returns(:thread)

          result = FiberWorkerConfigCheck.call

          assert_predicate result, :fail?
          assert_includes result.suggestion, 'isolation_level = :fiber'
        end

        test 'passes when fiber worker requirements are met' do
          stub_workers([{ fibers: 100 }])
          FiberWorkerConfigCheck.any_instance.stubs(:solid_queue_supports_fibers?).returns(true)
          OptionalDependency.stubs(:require!).with('async/semaphore', 'async').returns(true)
          ActiveSupport::IsolatedExecutionState.stubs(:isolation_level).returns(:fiber)

          result = FiberWorkerConfigCheck.call

          assert_predicate result, :pass?
          assert_equal 100, result.metadata[:max_fibers]
        end

        private

        def stub_workers(workers)
          SolidQueue::Configuration.any_instance.stubs(:workers_options).returns(workers)
        end
      end
    end
  end
end
