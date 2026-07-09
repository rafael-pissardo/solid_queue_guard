# frozen_string_literal: true

module SolidQueueGuard
  module MissionControl
    module NavigationExtension
      def navigation_sections
        super.tap do |sections|
          sections[:guard] = ['Guard', guard_dashboard_path]
        end
      end

      private

      def guard_dashboard_path
        ::MissionControl::Jobs::Engine.routes.url_helpers.solid_queue_guard_dashboard_path
      end
    end
  end
end
