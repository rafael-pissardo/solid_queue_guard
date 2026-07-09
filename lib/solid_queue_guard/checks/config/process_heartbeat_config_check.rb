# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class ProcessHeartbeatConfigCheck < Base
        DEFAULT_HEARTBEAT_INTERVAL = 60.seconds
        DEFAULT_ALIVE_THRESHOLD = 5.minutes

        def call
          heartbeat_interval = SolidQueue.process_heartbeat_interval
          alive_threshold = SolidQueue.process_alive_threshold

          if heartbeat_interval == DEFAULT_HEARTBEAT_INTERVAL && alive_threshold == DEFAULT_ALIVE_THRESHOLD
            warn(
              "process_heartbeat_config",
              "Process heartbeat thresholds use defaults (interval: 60s, alive: 5m)",
              suggestion: "Consider customizing process_alive_threshold for your deployment latency requirements"
            )
          else
            pass(
              "process_heartbeat_config",
              "Process heartbeat interval: #{heartbeat_interval.inspect}, alive threshold: #{alive_threshold.inspect}"
            )
          end
        end
      end
    end
  end
end
