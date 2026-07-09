# frozen_string_literal: true

module SolidQueueGuard
  class Engine < ::Rails::Engine
    isolate_namespace SolidQueueGuard

    rake_tasks do
      load 'solid_queue_guard/tasks.rb'
    end

    config.solid_queue_guard = ActiveSupport::OrderedOptions.new

    initializer 'solid_queue_guard.config' do
      SolidQueueGuard.configure do |guard_config|
        config.solid_queue_guard.each do |name, value|
          guard_config.public_send("#{name}=", value)
        end
      end
    end
  end
end
