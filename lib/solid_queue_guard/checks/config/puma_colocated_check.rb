# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class PumaColocatedCheck < Base
        PUMA_PLUGIN_PATTERN = /plugin\s+:?solid_queue/

        def call
          puma_config = rails_root.join("config/puma.rb")

          unless puma_config.exist?
            return pass("puma_colocated", "No config/puma.rb found")
          end

          content = puma_config.read

          if content.match?(PUMA_PLUGIN_PATTERN)
            if Rails.env.production?
              warn(
                "puma_colocated",
                "Solid Queue Puma plugin is enabled in production",
                suggestion: "Run Solid Queue in a dedicated job process for better isolation and memory management"
              )
            else
              pass("puma_colocated", "Solid Queue Puma plugin detected (non-production environment)")
            end
          else
            pass("puma_colocated", "Solid Queue is not co-located with Puma")
          end
        end
      end
    end
  end
end
