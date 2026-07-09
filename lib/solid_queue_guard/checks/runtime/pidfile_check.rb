# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class PidfileCheck < Base
        def call
          pidfile = ENV['SOLID_QUEUE_PIDFILE'] || default_pidfile
          return pass(check_id, 'No Solid Queue pidfile configured') if pidfile.blank?

          path = Pathname(pidfile)
          unless path.exist?
            return warn(check_id, "Pidfile not found at #{path}",
                        suggestion: 'Verify Solid Queue supervisor is running')
          end

          pid = path.read.strip.to_i
          if process_alive?(pid)
            pass(check_id, "Solid Queue supervisor pidfile present (pid #{pid})")
          else
            failure(check_id, "Pidfile exists but process #{pid} is not running",
                    suggestion: 'Restart the Solid Queue supervisor')
          end
        end

        private

        def default_pidfile
          rails_root.join('tmp/pids/solid_queue.pid').to_s
        end

        def process_alive?(pid)
          Process.getpgid(pid)
          true
        rescue Errno::ESRCH
          false
        end
      end
    end
  end
end
