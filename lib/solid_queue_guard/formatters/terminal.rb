# frozen_string_literal: true

module SolidQueueGuard
  module Formatters
    class Terminal
      ICONS = { pass: "✅", warn: "⚠️", fail: "❌", skip: "⏭️" }.freeze

      def initialize(report)
        @report = report
      end

      def render
        lines = []
        lines << "SolidQueueGuard Report"
        lines << ""
        lines << "Status: #{report.status.to_s.upcase}"
        lines << ""
        lines << "Checks:"

        report.results.each do |result|
          icon = ICONS.fetch(result.status, "•")
          lines << "#{icon} #{result.message}"
        end

        if report.suggestions.any?
          lines << ""
          lines << "Suggested fixes:"
          report.suggestions.each { |suggestion| lines << "- #{suggestion}" }
        end

        lines.join("\n")
      end

      private
        attr_reader :report
    end
  end
end
