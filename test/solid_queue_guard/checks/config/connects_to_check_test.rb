# frozen_string_literal: true

require "test_helper"

class SolidQueueGuard::Checks::Config::ConnectsToCheckTest < ActiveSupport::TestCase
  test "passes when connects_to points at queue database" do
    result = SolidQueueGuard::Checks::Config::ConnectsToCheck.call

    assert_predicate result, :pass?
    assert_equal "connects_to", result.id
  end

  test "fails when connects_to is missing" do
    original = Rails.application.config.solid_queue.connects_to
    Rails.application.config.solid_queue.connects_to = nil

    result = SolidQueueGuard::Checks::Config::ConnectsToCheck.call

    assert_predicate result, :fail?
  ensure
    Rails.application.config.solid_queue.connects_to = original
  end
end
