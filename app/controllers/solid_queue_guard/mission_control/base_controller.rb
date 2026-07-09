# frozen_string_literal: true

module SolidQueueGuard
  module MissionControl
    class BaseController < ::MissionControl::Jobs::ApplicationController
      helper DashboardHelper
    end
  end
end
