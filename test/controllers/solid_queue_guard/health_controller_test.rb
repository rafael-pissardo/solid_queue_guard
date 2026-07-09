# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  class HealthControllerTest < ActionDispatch::IntegrationTest
    test 'health endpoint returns runtime status payload' do
      SolidQueueGuard::Health::Cache.stubs(:fetch).returns(status: 'healthy', checks: [])

      get '/solid_queue_guard/health'

      assert_response :success
      body = response.parsed_body
      assert_includes %w[healthy degraded unhealthy], body['status']
      assert body.key?('checks')
    ensure
      SolidQueueGuard::Health::Cache.unstub(:fetch)
    end

    test 'health endpoint requires token when configured' do
      SolidQueueGuard.config.health_token = 'secret-token'
      SolidQueueGuard::Health::Cache.stubs(:fetch).returns(status: 'healthy', checks: [])

      get '/solid_queue_guard/health'
      assert_response :unauthorized

      get '/solid_queue_guard/health', headers: { 'X-Solid-Queue-Guard-Token' => 'secret-token' }
      assert_response :success
    ensure
      SolidQueueGuard.config.health_token = nil
      SolidQueueGuard::Health::Cache.unstub(:fetch)
    end

    test 'degraded status uses configured http status' do
      SolidQueueGuard.config.degraded_http_status = 207
      SolidQueueGuard::Health::Cache.stubs(:fetch).returns(status: 'degraded', checks: [])

      get '/solid_queue_guard/health'

      assert_response :multi_status
    ensure
      SolidQueueGuard.config.degraded_http_status = :ok
      SolidQueueGuard::Health::Cache.unstub(:fetch)
    end
  end
end
