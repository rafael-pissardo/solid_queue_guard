# frozen_string_literal: true

module SolidQueueGuard
  class HealthController < ApplicationController
    def show
      render json: { status: "not_implemented", message: "HTTP health checks ship in v0.2" }, status: :not_implemented
    end
  end
end
