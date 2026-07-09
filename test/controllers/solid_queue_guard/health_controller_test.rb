# frozen_string_literal: true

require "test_helper"

class SolidQueueGuard::HealthControllerTest < ActionDispatch::IntegrationTest
  test "health endpoint returns not implemented in v0.1" do
    get "/solid_queue_guard/health"

    assert_response :not_implemented
    assert_equal "not_implemented", response.parsed_body["status"]
  end
end
