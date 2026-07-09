# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Config
      class PumaColocatedCheckTest < ActiveSupport::TestCase
        test 'passes when solid queue is not co-located with puma' do
          result = SolidQueueGuard::Checks::Config::PumaColocatedCheck.call

          assert_predicate result, :pass?
          assert_includes result.message, 'not co-located'
        end

        test 'passes when puma config is missing' do
          PumaPluginSupport.stubs(:puma_config_path).returns(Pathname('/tmp/missing/puma.rb'))
          Pathname('/tmp/missing/puma.rb').stubs(:exist?).returns(false)

          result = SolidQueueGuard::Checks::Config::PumaColocatedCheck.call

          assert_predicate result, :pass?
          assert_includes result.message, 'No config/puma.rb'
        ensure
          PumaPluginSupport.unstub(:puma_config_path)
          Pathname('/tmp/missing/puma.rb').unstub(:exist?)
        end

        test 'warns when puma plugin is enabled in production' do
          Rails.env.stubs(:production?).returns(true)
          PumaPluginSupport.stubs(:puma_plugin_enabled?).returns(true)

          result = SolidQueueGuard::Checks::Config::PumaColocatedCheck.call

          assert_predicate result, :warn?
          assert_includes result.suggestion, 'dedicated job process'
        ensure
          Rails.env.unstub(:production?)
          PumaPluginSupport.unstub(:puma_plugin_enabled?)
        end
      end
    end
  end
end
