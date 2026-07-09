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
          Dir.mktmpdir do |dir|
            root = Pathname(dir)
            SolidQueueGuard::Checks::Config::PumaColocatedCheck.any_instance.stubs(:rails_root).returns(root)

            result = SolidQueueGuard::Checks::Config::PumaColocatedCheck.call

            assert_predicate result, :pass?
            assert_includes result.message, 'No config/puma.rb'
          end
        end

        test 'warns when puma plugin is enabled in production' do
          Rails.env.stubs(:production?).returns(true)

          Dir.mktmpdir do |dir|
            root = Pathname(dir)
            puma_config = root.join('config/puma.rb')
            puma_config.dirname.mkpath
            puma_config.write("plugin :solid_queue\n")

            SolidQueueGuard::Checks::Config::PumaColocatedCheck.any_instance.stubs(:rails_root).returns(root)

            result = SolidQueueGuard::Checks::Config::PumaColocatedCheck.call

            assert_predicate result, :warn?
            assert_includes result.suggestion, 'dedicated job process'
          end
        ensure
          Rails.env.unstub(:production?)
        end
      end
    end
  end
end
