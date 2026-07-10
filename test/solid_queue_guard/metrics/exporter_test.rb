# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Metrics
    class ExporterTest < ActiveSupport::TestCase
      test 'prometheus render includes per-check metrics' do
        report = Report.new([
                              Check::Result.new(id: 'queue_lag', status: :warn, message: 'lag'),
                              Check::Result.new(id: 'adapter', status: :pass, message: 'ok')
                            ])

        output = Prometheus.render(report)

        assert_includes output, 'solid_queue_guard_check_status{check="queue_lag"} 1'
        assert_includes output, 'solid_queue_guard_check_status{check="adapter"} 0'
      end

      test 'statsd metric lines include per-check metrics' do
        report = Report.new([
                              Check::Result.new(id: 'queue_lag', status: :fail, message: 'lag')
                            ])

        lines = Statsd.metric_lines(report)

        assert_includes lines, 'solid_queue.guard.overall_status:2|g'
        assert_includes lines, 'solid_queue.guard.check_status:2|g|#queue_lag'
      end
    end
  end
end
