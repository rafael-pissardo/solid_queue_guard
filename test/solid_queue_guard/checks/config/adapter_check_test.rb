# frozen_string_literal: true

require "test_helper"

class SolidQueueGuard::Checks::Config::AdapterCheckTest < ActiveSupport::TestCase
  test "passes with solid_queue adapter" do
    result = SolidQueueGuard::Checks::Config::AdapterCheck.call

    assert_predicate result, :pass?
  end

  test "fails with async adapter" do
    Rails.application.config.active_job.queue_adapter = :async

    result = SolidQueueGuard::Checks::Config::AdapterCheck.call

    assert_predicate result, :fail?
  ensure
    Rails.application.config.active_job.queue_adapter = :solid_queue
  end
end
