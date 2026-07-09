# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  class CheckConfigurationTest < ActiveSupport::TestCase
    setup do
      @original_disabled = config.disabled_checks.dup
      @original_checks = config.checks.dup
    end

    teardown do
      config.disabled_checks = @original_disabled
      config.checks = @original_checks
    end

    test 'disabled_checks disables a check' do
      config.disabled_checks = [:pidfile]

      assert_not config.check_enabled?(:pidfile)
      assert config.check_enabled?(:queue_lag)
    end

    test 'per-check enabled false disables a check' do
      config.checks.pidfile = { enabled: false }

      assert_not config.check_enabled?(:pidfile)
    end

    test 'check_setting returns per-check overrides' do
      config.checks.failed_jobs = { threshold: 5 }

      assert_equal 5, config.check_setting(:failed_jobs, :threshold, 20)
    end

    private

    def config
      SolidQueueGuard.config
    end
  end
end
