# frozen_string_literal: true

module SolidQueueGuard
  module Metrics
    class EmitDepthJob < ActiveJob::Base
      queue_as :solid_queue_recurring

      def perform
        DepthEmitter.emit!
      end
    end
  end
end
