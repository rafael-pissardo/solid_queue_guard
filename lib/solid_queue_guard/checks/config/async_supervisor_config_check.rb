# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class AsyncSupervisorConfigCheck < Base
        def call
          if PumaPluginSupport.async_supervisor_mode?
            warn(
              check_id,
              'Solid Queue supervisor is running in async mode',
              suggestion: [
                'Review thread and database pool sizing;',
                'the processes option in queue.yml is ignored in async mode'
              ].join(' '),
              metadata: { supervisor_mode: 'async' }
            )
          else
            pass(check_id, 'Solid Queue supervisor is running in fork mode')
          end
        end
      end
    end
  end
end
