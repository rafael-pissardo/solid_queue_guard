# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module MissionControl
    class DashboardControllerTest < ActionDispatch::IntegrationTest
      DEGRADED_PAYLOAD = {
        status: 'degraded',
        warnings: ['default queue lag is 120 seconds'],
        suggestions: ['Investigate worker coverage'],
        checks: [
          {
            id: 'queue_lag',
            status: 'warn',
            message: 'default queue lag is 120 seconds',
            suggestion: 'Investigate worker coverage'
          }
        ],
        queue_lag_seconds: 120,
        failed_jobs_last_hour: 3,
        dead_processes: 0
      }.freeze

      setup do
        skip 'mission_control-jobs not available' unless defined?(::MissionControl::Jobs)
      end

      test 'guard dashboard renders health payload' do
        SolidQueueGuard::Health::Cache.stubs(:fetch).returns(DEGRADED_PAYLOAD)

        get guard_dashboard_path

        assert_response :success
        assert_includes response.body, 'Guard'
        assert_includes response.body, 'Degraded'
        assert_includes response.body, 'Queue Lag'
        assert_includes response.body, 'default queue lag is 120 seconds'
        assert_includes response.body, 'Investigate worker coverage'
      ensure
        SolidQueueGuard::Health::Cache.unstub(:fetch)
      end

      test 'guard dashboard includes guard tab in navigation' do
        SolidQueueGuard::Health::Cache.stubs(:fetch).returns(status: 'healthy', checks: [])

        get guard_dashboard_path

        assert_response :success
        assert_includes response.body, 'is-active'
        assert_includes response.body, guard_dashboard_path.split('?').first
      ensure
        SolidQueueGuard::Health::Cache.unstub(:fetch)
      end

      test 'guard dashboard navigation links use application scoped mission control paths' do
        SolidQueueGuard::Health::Cache.stubs(:fetch).returns(status: 'healthy', checks: [])

        get guard_dashboard_path

        assert_response :success
        assert_includes response.body, '/jobs/applications/dummy/queues'
        assert_includes response.body, 'server_id=solid_queue'
      ensure
        SolidQueueGuard::Health::Cache.unstub(:fetch)
      end

      private

      def guard_dashboard_path
        application = ::MissionControl::Jobs.applications.first
        "/jobs/applications/#{application.to_param}/guard?server_id=#{application.servers.first.to_param}"
      end
    end
  end
end
