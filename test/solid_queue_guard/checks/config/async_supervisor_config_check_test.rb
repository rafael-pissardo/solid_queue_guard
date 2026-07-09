# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Checks
    module Config
      class AsyncSupervisorConfigCheckTest < ActiveSupport::TestCase
        setup do
          @original_mode = ENV.fetch('SOLID_QUEUE_SUPERVISOR_MODE', nil)
        end

        teardown do
          if @original_mode.nil?
            ENV.delete('SOLID_QUEUE_SUPERVISOR_MODE')
          else
            ENV['SOLID_QUEUE_SUPERVISOR_MODE'] = @original_mode
          end
        end

        test 'passes in fork mode' do
          ENV['SOLID_QUEUE_SUPERVISOR_MODE'] = 'fork'

          result = AsyncSupervisorConfigCheck.call

          assert_predicate result, :pass?
        end

        test 'warns in async mode' do
          ENV['SOLID_QUEUE_SUPERVISOR_MODE'] = 'async'

          result = AsyncSupervisorConfigCheck.call

          assert_predicate result, :warn?
          assert_includes result.message, 'async mode'
        end
      end
    end
  end
end
