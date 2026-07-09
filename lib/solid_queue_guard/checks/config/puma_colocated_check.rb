# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class PumaColocatedCheck < Base
        def call
          return pass(check_id, 'No config/puma.rb found') unless PumaPluginSupport.puma_config_path.exist?

          if PumaPluginSupport.puma_plugin_enabled?
            if Rails.env.production?
              warn(
                check_id,
                'Solid Queue Puma plugin is enabled in production',
                suggestion: 'Run Solid Queue in a dedicated job process for better isolation and memory management'
              )
            else
              pass(check_id, 'Solid Queue Puma plugin detected (non-production environment)')
            end
          else
            pass(check_id, 'Solid Queue is not co-located with Puma')
          end
        end
      end
    end
  end
end
