# frozen_string_literal: true

module SolidQueueGuard
  class HealthController < ApplicationController
    before_action :authenticate_token!

    def show
      payload = Health::Cache.fetch
      status_code = http_status_for(payload[:status])

      render json: payload, status: status_code
    end

    private

    def authenticate_token!
      token = SolidQueueGuard.config.health_token
      return if token.blank?

      provided = request.headers['X-Solid-Queue-Guard-Token'].presence || params[:token]
      return if ActiveSupport::SecurityUtils.secure_compare(provided.to_s, token.to_s)

      render json: { status: 'unauthorized' }, status: :unauthorized
    end

    def http_status_for(status)
      HttpStatusPolicy.for_report_status(status)
    end
  end
end
