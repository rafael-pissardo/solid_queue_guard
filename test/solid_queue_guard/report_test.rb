# frozen_string_literal: true

require "test_helper"

class SolidQueueGuard::ReportTest < ActiveSupport::TestCase
  Result = SolidQueueGuard::Check::Result

  test "healthy when all checks pass" do
    report = SolidQueueGuard::Report.new([
      Result.new(id: "a", status: :pass, message: "ok")
    ])

    assert_equal :healthy, report.status
    assert_equal 0, report.exit_code
    assert_equal 0, report.exit_code(strict: true)
  end

  test "degraded when warnings exist" do
    report = SolidQueueGuard::Report.new([
      Result.new(id: "a", status: :warn, message: "careful")
    ])

    assert_equal :degraded, report.status
    assert_equal 0, report.exit_code
    assert_equal 1, report.exit_code(strict: true)
  end

  test "unhealthy when a check fails" do
    report = SolidQueueGuard::Report.new([
      Result.new(id: "a", status: :fail, message: "broken")
    ])

    assert_equal :unhealthy, report.status
    assert_equal 1, report.exit_code(strict: true)
  end
end
