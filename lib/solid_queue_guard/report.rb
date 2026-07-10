# frozen_string_literal: true

module SolidQueueGuard
  class Report
    STATUSES = %i[healthy degraded unhealthy].freeze

    attr_reader :results

    def initialize(results)
      @results = results
    end

    def status
      return :unhealthy if results.any?(&:fail?)
      return :degraded if results.any?(&:warn?)

      :healthy
    end

    def warnings
      results.select(&:warn?).map(&:message)
    end

    def suggestions
      results.filter_map(&:suggestion).uniq
    end

    def exit_code(strict: false)
      return 1 if results.any?(&:fail?)
      return 1 if strict && results.any?(&:warn?)

      0
    end

    def to_h
      {
        status: status.to_s,
        warnings: warnings,
        suggestions: suggestions,
        status_counts: status_counts,
        checks: results.map(&:to_h)
      }
    end

    def status_counts
      results.group_by(&:status).transform_values(&:size)
    end
  end
end
