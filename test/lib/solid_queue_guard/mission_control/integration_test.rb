# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module MissionControl
    class IntegrationTest < ActiveSupport::TestCase
      test 'installs guard route in mission control engine' do
        skip 'mission_control-jobs not available' unless defined?(::MissionControl::Jobs)

        SolidQueueGuard::MissionControl::Integration.install_routes!

        assert(
          ::MissionControl::Jobs::Engine.routes.routes.any? do |route|
            route.name == 'solid_queue_guard_dashboard'
          end
        )
      end

      test 'prepends navigation extension once' do
        skip 'mission_control-jobs not available' unless defined?(::MissionControl::Jobs)

        SolidQueueGuard::MissionControl::Integration.install_navigation!

        assert_includes ::MissionControl::Jobs::NavigationHelper.ancestors,
                        SolidQueueGuard::MissionControl::NavigationExtension
      end
    end
  end
end
