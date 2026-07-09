# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    # @api private
    class Base
      def self.call(**options)
        new(**options).call
      end

      def self.check_id
        name.demodulize.underscore.delete_suffix('_check')
      end

      def initialize(**options)
        @options = options
      end

      def call
        raise NotImplementedError
      end

      private

      attr_reader :options

      def pass(id, message, **kwargs)
        build_result(id, :pass, message, **kwargs)
      end

      def warn(id, message, **kwargs)
        build_result(id, :warn, message, **kwargs)
      end

      def failure(id, message, **kwargs)
        build_result(id, :fail, message, **kwargs)
      end

      def skip(id, message, **kwargs)
        build_result(id, :skip, message, **kwargs)
      end

      def build_result(id, status, message, suggestion: nil, metadata: {})
        Check::Result.new(id: id, status: status, message: message, suggestion: suggestion, metadata: metadata)
      end

      def rails_root
        Rails.root
      end

      def solid_queue_configuration
        @solid_queue_configuration ||= SolidQueue::Configuration.new
      end

      def check_id
        self.class.check_id
      end

      def guard_config
        SolidQueueGuard.config
      end

      def check_setting(key, default = nil)
        guard_config.check_setting(check_id, key, default)
      end
    end
  end
end
