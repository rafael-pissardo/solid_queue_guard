# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Metrics
    class DogstatsdClientTest < ActiveSupport::TestCase
      setup do
        @original_service = SolidQueueGuard.config.statsd_service_name
        DogstatsdClient.reset!
      end

      teardown do
        SolidQueueGuard.config.statsd_service_name = @original_service
        DogstatsdClient.reset!
      end

      test 'service_name prefers config over ENV' do
        SolidQueueGuard.config.statsd_service_name = 'from-config'
        with_env('DD_SERVICE' => 'from-env') do
          assert_equal 'from-config', DogstatsdClient.service_name
        end
      end

      test 'service_name falls back to DD_SERVICE' do
        SolidQueueGuard.config.statsd_service_name = nil
        with_env('DD_SERVICE' => 'dd-service', 'SOLID_QUEUE_GUARD_SERVICE' => nil) do
          assert_equal 'dd-service', DogstatsdClient.service_name
        end
      end

      test 'default_tags include env and service' do
        SolidQueueGuard.config.statsd_service_name = 'my-app'
        tags = DogstatsdClient.default_tags

        assert_includes tags, "env:#{Rails.env}"
        assert_includes tags, 'service:my-app'
      end

      test 'NullStatsd responds to gauge increment timing flush' do
        client = DogstatsdClient::NullStatsd.new

        assert_nil client.gauge('x', 1)
        assert_nil client.increment('x')
        assert_nil client.timing('x', 1)
        assert_nil client.flush
      end

      def with_env(overrides)
        previous = overrides.keys.index_with { |key| ENV.fetch(key, nil) }
        overrides.each do |key, value|
          if value.nil?
            ENV.delete(key)
          else
            ENV[key] = value
          end
        end
        yield
      ensure
        previous.each do |key, value|
          if value.nil?
            ENV.delete(key)
          else
            ENV[key] = value
          end
        end
      end
    end
  end
end
