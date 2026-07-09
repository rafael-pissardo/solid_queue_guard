# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class EnvFlagsCheck < Base
        def call
          if Rails.env.production? && ActiveModel::Type::Boolean.new.cast(ENV["SOLID_QUEUE_SKIP_RECURRING"])
            warn(
              "env_flags",
              "SOLID_QUEUE_SKIP_RECURRING=true in production",
              suggestion: "Remove SOLID_QUEUE_SKIP_RECURRING unless recurring jobs are intentionally disabled"
            )
          else
            pass("env_flags", "No dangerous Solid Queue environment flags detected")
          end
        end
      end
    end
  end
end
