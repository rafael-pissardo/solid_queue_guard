# frozen_string_literal: true

require "test_helper"

class SolidQueueGuard::QueueCoverageTest < ActiveSupport::TestCase
  test "wildcard workers cover any queue" do
    assert SolidQueueGuard::QueueCoverage.covers_all?([ "*" ], "mailers")
  end

  test "uncovered queues are reported" do
    uncovered = SolidQueueGuard::QueueCoverage.uncovered_queues(
      %w[default mailers],
      %w[default]
    )

    assert_equal %w[mailers], uncovered
  end
end
