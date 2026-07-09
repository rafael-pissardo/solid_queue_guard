# frozen_string_literal: true

module SolidQueueGuard
  module MissionControl
    class Integration
      class << self
        def install!
          install_routes!
          install_navigation!
        end

        def install_routes!
          return if routes_installed?

          ::MissionControl::Jobs::Engine.routes.append do
            get 'guard',
                controller: '/solid_queue_guard/mission_control/dashboard',
                action: 'show',
                as: :solid_queue_guard_dashboard
          end
        end

        def install_navigation!
          return unless defined?(::MissionControl::Jobs::NavigationHelper)
          return if navigation_installed?

          ::MissionControl::Jobs::NavigationHelper.prepend(NavigationExtension)
        end

        private

        def routes_installed?
          ::MissionControl::Jobs::Engine.routes.routes.any? do |route|
            route.name == 'solid_queue_guard_dashboard'
          end
        end

        def navigation_installed?
          ::MissionControl::Jobs::NavigationHelper.ancestors.include?(NavigationExtension)
        end
      end
    end
  end
end
