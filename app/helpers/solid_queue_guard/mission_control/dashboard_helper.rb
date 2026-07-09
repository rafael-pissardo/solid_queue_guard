# frozen_string_literal: true

module SolidQueueGuard
  module MissionControl
    module DashboardHelper
      def guard_modifier_for_status(status)
        case status.to_s
        when 'healthy', 'pass' then 'is-success'
        when 'degraded', 'warn' then 'is-warning'
        when 'unhealthy', 'fail' then 'is-danger'
        else 'is-light'
        end
      end

      def guard_status_tag(status, label: nil)
        tag.span(label || status.to_s.titleize, class: "tag #{guard_modifier_for_status(status)}")
      end

      def guard_check_label(check)
        check[:id].to_s.tr('_', ' ').titleize
      end

      def guard_metric_value(value)
        value.nil? ? '—' : value
      end

      def guard_format_duration(seconds)
        return '—' if seconds.nil?

        distance_of_time_in_words(0, seconds.to_i, include_seconds: true)
      end
    end
  end
end
