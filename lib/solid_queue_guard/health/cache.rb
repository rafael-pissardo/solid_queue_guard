# frozen_string_literal: true

module SolidQueueGuard
  module Health
    class Cache
      def self.fetch
        new.fetch
      end

      def fetch
        Rails.cache.fetch(cache_key, expires_in: SolidQueueGuard.config.health_cache_ttl) do
          build_payload
        end
      end

      private

      def cache_key
        'solid_queue_guard/health'
      end

      def build_payload
        report = Runner.new(scope: :all).run
        Payload.new(report).to_h
      end
    end
  end
end
