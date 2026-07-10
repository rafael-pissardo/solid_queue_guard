# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  class ConfigurationValidationTest < ActiveSupport::TestCase
    setup do
      @config = Configuration.new
    end

    test 'validate! accepts defaults' do
      assert @config.validate!
    end

    test 'validate! rejects invalid degraded_http_status' do
      @config.degraded_http_status = :not_a_status

      error = assert_raises(Configuration::ValidationError) { @config.validate! }
      assert_match(/degraded_http_status/, error.message)
    end

    test 'validate! rejects non-callable on_status_change' do
      @config.on_status_change = 'nope'

      assert_raises(Configuration::ValidationError) { @config.validate! }
    end

    test 'validate! accepts on_status_change callback' do
      @config.on_status_change = ->(_previous, _current, _report) {}

      assert @config.validate!
    end
  end
end
