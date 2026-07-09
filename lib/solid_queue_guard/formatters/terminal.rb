# frozen_string_literal: true

module SolidQueueGuard
  module Formatters
    # @api private
    class Terminal
      ICONS = { pass: '✅', warn: '⚠️', fail: '❌', skip: '⏭️' }.freeze

      def initialize(report)
        @report = report
      end

      def render
        [
          'SolidQueueGuard Report',
          '',
          "Status: #{report.status.to_s.upcase}",
          '',
          'Checks:',
          *check_lines,
          *suggestion_lines
        ].join("\n")
      end

      private

      attr_reader :report

      def check_lines
        report.results.reject(&:skip?).map do |result|
          icon = ICONS.fetch(result.status, '•')
          "#{icon} #{result.message}"
        end
      end

      def suggestion_lines
        return [] unless report.suggestions.any?

        ['', 'Suggested fixes:', *report.suggestions.map { |suggestion| "- #{suggestion}" }]
      end
    end
  end
end
