# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  class ObservabilityTest < ActiveSupport::TestCase
    setup do
      @original_callback = SolidQueueGuard.config.on_status_change
      SolidQueueGuard.config.on_status_change = nil
    end

    teardown do
      SolidQueueGuard.config.on_status_change = @original_callback
    end

    test 'notify_status_change invokes callback on transition' do
      calls = []
      SolidQueueGuard.config.on_status_change = lambda do |previous, current, report|
        calls << [previous, current, report.status]
      end

      report = Report.new([
                            Check::Result.new(id: 'adapter', status: :fail, message: 'bad')
                          ])

      Observability.notify_status_change(report, previous_status: :healthy)

      assert_equal [%i[healthy unhealthy unhealthy]], calls
    end

    test 'notify_status_change skips when status unchanged' do
      calls = []
      SolidQueueGuard.config.on_status_change = ->(*args) { calls << args }

      report = Report.new([
                            Check::Result.new(id: 'adapter', status: :pass, message: 'ok')
                          ])

      Observability.notify_status_change(report, previous_status: :healthy)

      assert_empty calls
    end
  end
end
