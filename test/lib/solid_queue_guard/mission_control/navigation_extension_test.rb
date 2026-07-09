# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module MissionControl
    class NavigationExtensionTest < ActiveSupport::TestCase
      class FakeNavigationHelper
        include ::MissionControl::Jobs::NavigationHelper
        prepend SolidQueueGuard::MissionControl::NavigationExtension

        attr_accessor :application

        def initialize(application:)
          @application = application
        end

        def application_queues_path(application)
          "/jobs/applications/#{application}/queues"
        end

        def application_jobs_path(application, status)
          "/jobs/applications/#{application}/#{status}/jobs"
        end

        def application_workers_path(application)
          "/jobs/applications/#{application}/workers"
        end

        def application_recurring_tasks_path(application)
          "/jobs/applications/#{application}/recurring_tasks"
        end

        def supported_job_statuses
          [:failed]
        end

        def workers_exposed?
          false
        end

        def recurring_tasks_supported?
          false
        end

        def jobs_count_with_status(_status)
          0
        end
      end

      test 'adds guard section to navigation' do
        skip 'mission_control-jobs not available' unless defined?(::MissionControl::Jobs)

        helper = FakeNavigationHelper.new(application: 'app')
        sections = helper.navigation_sections

        assert_equal 'Guard', sections[:guard].first
        assert_match(%r{/jobs/guard\z}, sections[:guard].last)
      end
    end
  end
end
