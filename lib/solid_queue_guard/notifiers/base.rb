# frozen_string_literal: true

module SolidQueueGuard
  module Notifiers
    # @api private
    class Base
      def self.deliver(report)
        Notifier.deliver(:rails_logger, report)
      end
    end
  end
end
