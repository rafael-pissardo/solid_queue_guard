# frozen_string_literal: true

module SolidQueueGuard
  module MissionControl
    # @api private
    module NavigationExtension
      def navigation_sections
        super.tap do |sections|
          sections[:guard] = ['Guard', guard_dashboard_path]
        end
      end

      private

      def guard_dashboard_path
        application_solid_queue_guard_dashboard_path(@application)
      end
    end
  end
end
