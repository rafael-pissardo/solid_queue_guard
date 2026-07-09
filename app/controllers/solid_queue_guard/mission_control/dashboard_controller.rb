# frozen_string_literal: true

module SolidQueueGuard
  module MissionControl
    class DashboardController < BaseController
      def show
        @payload = Health::Cache.fetch
      end
    end
  end
end
