# frozen_string_literal: true

module SolidQueueGuard
  module MissionControl
    class BaseController < ::MissionControl::Jobs::ApplicationController
      helper DashboardHelper

      def _routes
        ::MissionControl::Jobs::Engine.routes
      end
    end
  end
end
