# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  class HttpStatusPolicyTest < ActiveSupport::TestCase
    setup do
      @original_degraded = config.degraded_http_status
      @original_unhealthy = config.unhealthy_http_status
    end

    teardown do
      config.degraded_http_status = @original_degraded
      config.unhealthy_http_status = @original_unhealthy
    end

    test 'defaults degraded to ok and unhealthy to service unavailable' do
      assert_equal :ok, HttpStatusPolicy.for_report_status(:degraded)
      assert_equal :service_unavailable, HttpStatusPolicy.for_report_status(:unhealthy)
    end

    test 'supports custom degraded status' do
      config.degraded_http_status = 207

      assert_equal :multi_status, HttpStatusPolicy.for_report_status(:degraded)
    end

    private

    def config
      SolidQueueGuard.config
    end
  end
end
