# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Metrics
    class EventInstrumentationTest < ActiveSupport::TestCase
      setup do
        @original_emit = SolidQueueGuard.config.emit_event_metrics
        @original_env = Rails.env
        EventInstrumentation.reset!
        DogstatsdClient.reset!
      end

      teardown do
        SolidQueueGuard.config.emit_event_metrics = @original_emit
        Rails.stubs(:env).returns(@original_env)
        EventInstrumentation.reset!
        DogstatsdClient.reset!
      end

      test 'install! is a no-op when emit_event_metrics is false' do
        SolidQueueGuard.config.emit_event_metrics = false
        DogstatsdClient.expects(:available?).never

        EventInstrumentation.install!
      end

      test 'install! is a no-op outside production/staging' do
        SolidQueueGuard.config.emit_event_metrics = true
        Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('test'))
        DogstatsdClient.expects(:available?).never

        EventInstrumentation.install!
      end

      test 'install! is a no-op when dogstatsd-ruby is unavailable' do
        SolidQueueGuard.config.emit_event_metrics = true
        Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('production'))
        DogstatsdClient.stubs(:available?).returns(false)
        ActiveSupport::Notifications.expects(:subscribe).never

        EventInstrumentation.install!
      end

      test 'install! subscribes when enabled in production with dogstatsd' do
        SolidQueueGuard.config.emit_event_metrics = true
        Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('production'))
        DogstatsdClient.stubs(:available?).returns(true)

        ActiveSupport::Notifications.expects(:subscribe).at_least_once
        SolidQueue.expects(:on_worker_start).once
        SolidQueue.expects(:on_worker_stop).once
        SolidQueue.expects(:on_dispatcher_start).once
        SolidQueue.expects(:on_dispatcher_stop).once
        SolidQueue.expects(:on_scheduler_start).once
        SolidQueue.expects(:on_scheduler_stop).once

        EventInstrumentation.install!
      end
    end
  end
end
