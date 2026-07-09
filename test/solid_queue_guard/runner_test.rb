# frozen_string_literal: true

require "test_helper"

class SolidQueueGuard::RunnerTest < ActiveSupport::TestCase
  test "runs config checks" do
    report = SolidQueueGuard::Runner.new(scope: :config).run

    assert report.results.any?
    assert_includes report.results.map(&:id), "adapter"
    assert_includes %i[healthy degraded unhealthy], report.status
  end

  test "runtime checks are skipped until v0.2" do
    report = SolidQueueGuard::Runner.new(scope: :runtime).run

    assert report.results.all?(&:skip?)
  end
end
