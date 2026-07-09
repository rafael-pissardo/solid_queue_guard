# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  class RunnerTest < ActiveSupport::TestCase
    test 'runs config checks' do
      report = SolidQueueGuard::Runner.new(scope: :config).run

      assert report.results.any?
      assert_includes report.results.map(&:id), 'adapter'
      assert_includes %i[healthy degraded unhealthy], report.status
    end

    test 'runs runtime checks against the queue database' do
      report = SolidQueueGuard::Runner.new(scope: :runtime).run

      assert report.results.any?
      assert_not report.results.all?(&:skip?)
      assert_includes report.results.map(&:id), 'queue_lag'
    end
  end
end
