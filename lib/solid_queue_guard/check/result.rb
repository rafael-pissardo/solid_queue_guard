# frozen_string_literal: true

module SolidQueueGuard
  module Check
    class Result
      attr_reader :id, :status, :message, :suggestion, :metadata

      def initialize(id:, status:, message:, suggestion: nil, metadata: {})
        @id = id
        @status = status
        @message = message
        @suggestion = suggestion
        @metadata = metadata
      end

      def pass?
        status == :pass
      end

      def warn?
        status == :warn
      end

      def fail?
        status == :fail
      end

      def skip?
        status == :skip
      end

      def to_h
        {
          id: id,
          status: status.to_s,
          message: message,
          suggestion: suggestion,
          metadata: metadata
        }.compact
      end
    end
  end
end
