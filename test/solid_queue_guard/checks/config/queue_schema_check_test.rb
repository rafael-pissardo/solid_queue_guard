# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Config
      class QueueSchemaCheckTest < ActiveSupport::TestCase
        test 'passes when queue schema exists' do
          result = SolidQueueGuard::Checks::Config::QueueSchemaCheck.call

          assert_predicate result, :pass?
        end

        test 'warns when queue schema is missing' do
          Dir.mktmpdir do |dir|
            root = Pathname(dir)
            SolidQueueGuard::Checks::Config::QueueSchemaCheck.any_instance.stubs(:rails_root).returns(root)

            result = SolidQueueGuard::Checks::Config::QueueSchemaCheck.call

            assert_predicate result, :warn?
            assert_includes result.suggestion, 'solid_queue:install'
          end
        end
      end
    end
  end
end
