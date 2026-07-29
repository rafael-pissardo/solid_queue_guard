# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      # Solid Queue prunes any process whose heartbeat is older than
      # process_alive_threshold, releasing the executions it had claimed. A live
      # worker that merely delayed a heartbeat is pruned the same way, so the
      # threshold must leave room for more than one missed beat.
      class ProcessHeartbeatConfigCheck < Base
        DEFAULT_MIN_MARGIN = 2

        def call
          return invalid_heartbeat_interval unless heartbeat_interval.positive?
          return alive_threshold_too_low if alive_threshold <= heartbeat_interval
          return margin_too_tight if margin < min_margin
          return guard_threshold_above_alive if stale_process_threshold > alive_threshold

          healthy_thresholds
        end

        private

        def healthy_thresholds
          pass(
            check_id,
            "Heartbeat interval: #{humanize(heartbeat_interval)}, " \
            "alive threshold: #{humanize(alive_threshold)} (#{margin.round(1)}x margin)",
            metadata: base_metadata
          )
        end

        def invalid_heartbeat_interval
          failure(
            check_id,
            'process_heartbeat_interval must be a positive duration',
            suggestion: 'Set SolidQueue.process_heartbeat_interval to a positive value (default: 60 seconds)',
            metadata: base_metadata
          )
        end

        def alive_threshold_too_low
          failure(
            check_id,
            "process_alive_threshold (#{humanize(alive_threshold)}) is not greater than " \
            "process_heartbeat_interval (#{humanize(heartbeat_interval)})",
            suggestion: "Raise process_alive_threshold to at least #{humanize(recommended_threshold)} " \
                        'so a single late heartbeat does not prune a live process',
            metadata: base_metadata
          )
        end

        def margin_too_tight
          warn(
            check_id,
            "process_alive_threshold (#{humanize(alive_threshold)}) tolerates less than " \
            "#{min_margin} heartbeats of #{humanize(heartbeat_interval)}",
            suggestion: "Raise process_alive_threshold to at least #{humanize(recommended_threshold)} " \
                        'so a single late heartbeat does not release claimed jobs',
            metadata: base_metadata
          )
        end

        def guard_threshold_above_alive
          warn(
            check_id,
            "Guard stale_process_threshold (#{humanize(stale_process_threshold)}) is above " \
            "process_alive_threshold (#{humanize(alive_threshold)})",
            suggestion: "Lower stale_process_threshold to at most #{humanize(alive_threshold)}; " \
                        'Solid Queue prunes dead process rows before Guard would report them as stale',
            metadata: base_metadata.merge(stale_process_threshold: stale_process_threshold)
          )
        end

        def heartbeat_interval
          @heartbeat_interval ||= SolidQueue.process_heartbeat_interval.to_i
        end

        def alive_threshold
          @alive_threshold ||= SolidQueue.process_alive_threshold.to_i
        end

        def stale_process_threshold
          @stale_process_threshold ||= guard_config.check_setting(
            :stale_process, :threshold, guard_config.stale_process_threshold
          ).to_i
        end

        def min_margin
          @min_margin ||= check_setting(:min_margin, DEFAULT_MIN_MARGIN)
        end

        def margin
          @margin ||= alive_threshold / heartbeat_interval.to_f
        end

        def recommended_threshold
          heartbeat_interval * min_margin
        end

        def base_metadata
          { heartbeat_interval: heartbeat_interval, alive_threshold: alive_threshold }
        end

        def humanize(seconds)
          ActiveSupport::Duration.build(seconds).inspect
        end
      end
    end
  end
end
