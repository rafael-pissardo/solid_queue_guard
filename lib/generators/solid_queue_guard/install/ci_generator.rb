# frozen_string_literal: true

require 'rails/generators/base'

module SolidQueueGuard
  module Generators
    module Install
      class CiGenerator < Rails::Generators::Base
        source_root File.expand_path('templates', __dir__)

        desc 'Adds a GitHub Actions workflow that runs solid_queue_guard:doctor in CI'

        def copy_workflow
          template 'solid_queue_guard.yml', '.github/workflows/solid_queue_guard.yml'
        end
      end
    end
  end
end
