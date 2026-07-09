# frozen_string_literal: true

require 'rails/generators/base'

module SolidQueueGuard
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Creates Solid Queue Guard initializer'

      def copy_initializer
        template 'solid_queue_guard.rb', 'config/initializers/solid_queue_guard.rb'
      end
    end
  end
end
