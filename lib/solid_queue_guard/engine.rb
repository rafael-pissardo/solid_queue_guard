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
        guard_config.validate!
      end
    end

    initializer 'solid_queue_guard.rails_health' do
      next unless SolidQueueGuard.config.integrate_rails_health

      ActiveSupport.on_load(:action_controller_base) do
        Rails::HealthController.class_eval do
          def solid_queue_guard_status
            SolidQueueGuard::Health::Cache.fetch[:status]
          end
        end
      end
    end

    initializer 'solid_queue_guard.mission_control' do
      config.after_initialize do
        next unless SolidQueueGuard.config.integrate_mission_control

        if defined?(::MissionControl::Jobs)
          SolidQueueGuard::MissionControl::Integration.install!
        else
          Rails.logger.warn(
            '[solid_queue_guard] integrate_mission_control is enabled but mission_control-jobs is not loaded'
          )
        end
      end

      config.to_prepare do
        next unless SolidQueueGuard.config.integrate_mission_control
        next unless defined?(::MissionControl::Jobs)

        SolidQueueGuard::MissionControl::Integration.install_navigation!
      end
    end
  end
end
