# frozen_string_literal: true

module SolidQueueGuard
  module Formatters
    class Json
      def initialize(report)
        @report = report
      end

      def render
        JSON.pretty_generate(report.to_h)
      end

      private
        attr_reader :report
    end
  end
end
