# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class PumaPluginRuntimeCheck < Base
        def call
          return skip(check_id, 'Solid Queue Puma plugin is not enabled') unless PumaPluginSupport.puma_plugin_enabled?

          with_queue_database do
            threshold = config.check_setting(:puma_plugin_runtime, :threshold, config.stale_process_threshold)
            active = SolidQueue::Process.where(last_heartbeat_at: threshold.ago..)

            if active.any?
              pass(
                check_id,
                "Solid Queue processes are active via Puma plugin (#{active.count} process(es))",
                metadata: { active_processes: active.count, supervisor_mode: supervisor_mode_label }
              )
            else
              failure(
                check_id,
                'Solid Queue Puma plugin is enabled but no active processes were found',
                suggestion: 'Verify the Puma plugin booted Solid Queue and workers are processing jobs',
                metadata: { supervisor_mode: supervisor_mode_label }
              )
            end
          end
        end

        private

        def supervisor_mode_label
          PumaPluginSupport.async_supervisor_mode? ? 'async' : 'fork'
        end
      end
    end
  end
end
