# frozen_string_literal: true

module SolidQueueGuard
  module Check
    Result = Data.define(:id, :status, :message, :suggestion, :metadata) do
      STATUSES = %i[pass warn fail skip].freeze

      def initialize(id:, status:, message:, suggestion: nil, metadata: {})
        super
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
