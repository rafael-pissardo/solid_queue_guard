# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Config
      class EnvFlagsCheckTest < ActiveSupport::TestCase
        test 'warns when recurring jobs are skipped in production' do
          Rails.env.stubs(:production?).returns(true)
          ENV['SOLID_QUEUE_SKIP_RECURRING'] = 'true'

          result = SolidQueueGuard::Checks::Config::EnvFlagsCheck.call

          assert_predicate result, :warn?
        ensure
          ENV.delete('SOLID_QUEUE_SKIP_RECURRING')
        end
      end
    end
  end
end
