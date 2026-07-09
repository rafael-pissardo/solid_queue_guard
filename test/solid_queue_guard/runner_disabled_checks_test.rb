# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  class RunnerDisabledChecksTest < ActiveSupport::TestCase
    setup do
      @original_disabled = SolidQueueGuard.config.disabled_checks.dup
      SolidQueueGuard.config.disabled_checks = [:adapter]
    end

    teardown do
      SolidQueueGuard.config.disabled_checks = @original_disabled
    end

    test 'skips disabled checks' do
      report = Runner.new(scope: :config).run
      adapter = report.results.find { |result| result.id == 'adapter' }

      assert_predicate adapter, :skip?
      assert_includes adapter.message, 'disabled'
    end
  end
end
