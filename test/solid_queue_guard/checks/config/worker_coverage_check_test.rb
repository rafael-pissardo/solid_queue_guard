# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Config
      class WorkerCoverageCheckTest < ActiveSupport::TestCase
        test 'fails when recurring task queue has no worker' do
          SolidQueueGuard::Checks::Config::WorkerCoverageCheck.any_instance.stubs(:recurring_queues).returns(%w[mailers])
          SolidQueueGuard::Checks::Config::WorkerCoverageCheck.any_instance.stubs(:worker_queue_names).returns(%w[default])

          result = SolidQueueGuard::Checks::Config::WorkerCoverageCheck.call

          assert_predicate result, :fail?
          assert_includes result.message, 'mailers'
        end
      end
    end
  end
end
