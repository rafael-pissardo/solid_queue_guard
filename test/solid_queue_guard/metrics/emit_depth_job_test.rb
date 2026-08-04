# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Metrics
    class EmitDepthJobTest < ActiveSupport::TestCase
      test 'perform delegates to DepthEmitter.emit!' do
        DepthEmitter.expects(:emit!).returns(true)

        EmitDepthJob.perform_now
      end

      test 'queue_as solid_queue_recurring' do
        assert_equal 'solid_queue_recurring', EmitDepthJob.new.queue_name
      end
    end
  end
end
