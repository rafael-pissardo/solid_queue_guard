# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Runtime
      class PumaPluginRuntimeCheckTest < ActiveSupport::TestCase
        test 'skips when puma plugin is not enabled' do
          PumaPluginSupport.stubs(:puma_plugin_enabled?).returns(false)

          result = PumaPluginRuntimeCheck.call

          assert_predicate result, :skip?
        ensure
          PumaPluginSupport.unstub(:puma_plugin_enabled?)
        end

        test 'fails when plugin is enabled but no active processes exist' do
          PumaPluginSupport.stubs(:puma_plugin_enabled?).returns(true)
          SolidQueueGuard::Checks::Runtime::PumaPluginRuntimeCheck.any_instance.stubs(:queue_database_available?).returns(true)
          SolidQueue::Process.stubs(:where).returns(stub(any?: false, count: 0, none?: true))

          result = PumaPluginRuntimeCheck.call

          assert_equal :fail, result.status
        ensure
          SolidQueueGuard::Checks::Runtime::PumaPluginRuntimeCheck.any_instance.unstub(:queue_database_available?)
          PumaPluginSupport.unstub(:puma_plugin_enabled?)
          SolidQueue::Process.unstub(:where)
        end
      end
    end
  end
end
