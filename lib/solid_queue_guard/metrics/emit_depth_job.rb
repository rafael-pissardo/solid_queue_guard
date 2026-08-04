# frozen_string_literal: true

module SolidQueueGuard
  module Metrics
    # Host apps have ApplicationJob; this gem job inherits ActiveJob::Base directly.
    class EmitDepthJob < ::ActiveJob::Base # rubocop:disable Rails/ApplicationJob
      queue_as :solid_queue_recurring

      def perform
        DepthEmitter.emit!
      end
    end
  end
end
