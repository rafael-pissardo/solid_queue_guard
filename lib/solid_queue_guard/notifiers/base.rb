# frozen_string_literal: true

module SolidQueueGuard
  module Notifiers
    class Base
      def self.deliver(_report)
        raise NotImplementedError, "Notification adapters ship in v0.3"
      end
    end

    class RailsLogger < Base; end
    class Slack < Base; end
    class Datadog < Base; end
    class Webhook < Base; end
  end
end
