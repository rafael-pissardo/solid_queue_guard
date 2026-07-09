# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'minitest'
require_relative 'dummy/config/environment'
require 'rails/test_help'
require 'mocha/minitest'

# Dummy app configures :solid_queue for runtime checks. Rails 7.1's ActiveJob test
# helper otherwise swaps in TestAdapter, which breaks Mission Control navigation.
class ActionDispatch::IntegrationTest
  def queue_adapter_for_test
    nil
  end
end
