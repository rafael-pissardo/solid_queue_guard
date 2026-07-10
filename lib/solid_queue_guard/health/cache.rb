# frozen_string_literal: true

module SolidQueueGuard
  module Health
    # @api private
    class Cache
      def self.fetch
        new.fetch
      end

      def fetch
        Rails.cache.fetch(cache_key, expires_in: SolidQueueGuard.config.health_cache_ttl) do
          build_payload(previous_status: read_cached_status)
        end
      end

      private

      def cache_key
        'solid_queue_guard/health'
      end

      def read_cached_status
        Rails.cache.read(cache_key)&.dig(:status)
      end

      def build_payload(previous_status: nil)
        report = Runner.new(scope: :all).run
        Observability.notify_status_change(report, previous_status: previous_status&.to_sym)
        Payload.new(report).to_h
      end
    end
  end
end
