# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
require "solid_queue"
require "solid_queue_guard"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.active_job.queue_adapter = :solid_queue
  end
end
