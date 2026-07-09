# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    class Base
      def self.call(**options)
        new(**options).call
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

        def fail(id, message, **kwargs)
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
    end
  end
end
