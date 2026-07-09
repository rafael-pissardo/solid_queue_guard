# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  class HealthControllerTest < ActionDispatch::IntegrationTest
    test 'health endpoint returns runtime status payload' do
      get '/solid_queue_guard/health'

      assert_response :success
      body = response.parsed_body
      assert_includes %w[healthy degraded unhealthy], body['status']
      assert body.key?('checks')
    end

    test 'health endpoint requires token when configured' do
      SolidQueueGuard.config.health_token = 'secret-token'

      get '/solid_queue_guard/health'
      assert_response :unauthorized

      get '/solid_queue_guard/health', headers: { 'X-Solid-Queue-Guard-Token' => 'secret-token' }
      assert_response :success
    ensure
      SolidQueueGuard.config.health_token = nil
    end
  end
end
