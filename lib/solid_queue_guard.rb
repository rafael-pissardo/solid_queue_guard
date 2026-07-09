# frozen_string_literal: true

require 'solid_queue_guard/version'
require 'solid_queue_guard/engine'

require 'active_support'
require 'active_support/core_ext/numeric/time'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.inflector.inflect('cli' => 'CLI')
loader.ignore("#{__dir__}/solid_queue_guard/tasks.rb")
loader.ignore("#{__dir__}/generators")
loader.setup

module SolidQueueGuard
  class << self
    attr_accessor :configuration

    def deprecator
      @deprecator ||= ActiveSupport::Deprecation.new('0.2', 'SolidQueueGuard')
    end

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
      configuration
    end

    def config
      configuration || configure
    end

    def enabled?
      config.enabled
    end
  end
end
