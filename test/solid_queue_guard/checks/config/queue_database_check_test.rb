# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Config
      class QueueDatabaseCheckTest < ActiveSupport::TestCase
        test 'passes when queue database is configured' do
          result = SolidQueueGuard::Checks::Config::QueueDatabaseCheck.call

          assert_predicate result, :pass?
        end

        test 'fails when queue database entry is missing' do
          Rails.application.config.stubs(:database_configuration).returns(
            { 'test' => { 'primary' => { 'adapter' => 'sqlite3' } } }
          )

          result = SolidQueueGuard::Checks::Config::QueueDatabaseCheck.call

          assert_predicate result, :fail?
          assert_includes result.message, 'queue database'
        end
      end
    end
  end
end
