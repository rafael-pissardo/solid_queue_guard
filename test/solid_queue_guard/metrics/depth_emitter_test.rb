# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Metrics
    class DepthEmitterTest < ActiveSupport::TestCase
      setup do
        @original_emit = SolidQueueGuard.config.emit_depth_metrics
        SolidQueueGuard.config.emit_depth_metrics = true
        # Autoload SQ models while Rails.env is still `test` (connects_to is env-sensitive).
        [SolidQueue::ReadyExecution, SolidQueue::FailedExecution,
         SolidQueue::ClaimedExecution, SolidQueue::ScheduledExecution]
        @statsd = mock('statsd')
        DogstatsdClient.stubs(:statsd).returns(@statsd)
        DepthEmitter.stubs(:enabled?).returns(true)
      end

      teardown do
        SolidQueueGuard.config.emit_depth_metrics = @original_emit
        DogstatsdClient.reset!
      end

      test 'enabled? is false when depth metrics disabled' do
        DepthEmitter.unstub(:enabled?)
        SolidQueueGuard.config.emit_depth_metrics = false

        assert_equal false, DepthEmitter.enabled?
      end

      test 'enabled? is false outside production/staging' do
        DepthEmitter.unstub(:enabled?)
        SolidQueueGuard.config.emit_depth_metrics = true

        assert_equal false, DepthEmitter.enabled?
      end

      test 'emit! returns false when not enabled' do
        DepthEmitter.stubs(:enabled?).returns(false)

        assert_nil DepthEmitter.emit!
      end

      test 'emit! sends zero gauges when ready queue is empty' do
        ready_relation = stub(count: {}, minimum: {})
        SolidQueue::ReadyExecution.stubs(:group).with(:queue_name).returns(ready_relation)
        SolidQueue::FailedExecution.stubs(:count).returns(0)
        SolidQueue::ClaimedExecution.stubs(:count).returns(0)
        SolidQueue::ScheduledExecution.stubs(:count).returns(0)

        @statsd.expects(:gauge).with('solid_queue.ready.count', 0)
        @statsd.expects(:gauge).with('solid_queue.ready.oldest_age_seconds', 0)
        @statsd.expects(:gauge).with('solid_queue.failed.count', 0)
        @statsd.expects(:gauge).with('solid_queue.claimed.count', 0)
        @statsd.expects(:gauge).with('solid_queue.scheduled.count', 0)
        @statsd.expects(:flush)

        DepthEmitter.emit!
      end

      test 'emit! sends per-queue ready depth and ages' do
        travel_to Time.zone.parse('2026-08-04 12:00:00 UTC') do
          ready_relation = stub
          ready_relation.stubs(:count).returns('default' => 2, 'mailers' => 1)
          ready_relation.stubs(:minimum).returns(
            'default' => 10.minutes.ago,
            'mailers' => 2.minutes.ago
          )
          SolidQueue::ReadyExecution.stubs(:group).with(:queue_name).returns(ready_relation)
          SolidQueue::FailedExecution.stubs(:count).returns(3)
          SolidQueue::ClaimedExecution.stubs(:count).returns(1)
          SolidQueue::ScheduledExecution.stubs(:count).returns(4)

          @statsd.expects(:gauge).with('solid_queue.ready.count', 2, tags: ['queue:default'])
          @statsd.expects(:gauge).with('solid_queue.ready.count', 1, tags: ['queue:mailers'])
          @statsd.expects(:gauge).with(
            'solid_queue.ready.oldest_age_seconds', 600, tags: ['queue:default']
          )
          @statsd.expects(:gauge).with(
            'solid_queue.ready.oldest_age_seconds', 120, tags: ['queue:mailers']
          )
          @statsd.expects(:gauge).with('solid_queue.failed.count', 3)
          @statsd.expects(:gauge).with('solid_queue.claimed.count', 1)
          @statsd.expects(:gauge).with('solid_queue.scheduled.count', 4)
          @statsd.expects(:flush)

          DepthEmitter.emit!
        end
      end
    end
  end
end
