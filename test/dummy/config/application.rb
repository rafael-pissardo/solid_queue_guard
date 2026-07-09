# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "propshaft"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
require "solid_queue"
require "solid_queue_guard"
require "mission_control/jobs"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.active_job.queue_adapter = :solid_queue
    config.assets.paths << MissionControl::Jobs::Engine.root.join('app/assets/stylesheets')
    config.assets.paths << MissionControl::Jobs::Engine.root.join('app/javascript')
  end
end
