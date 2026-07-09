# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  class CLITest < ActiveSupport::TestCase
    test 'parses strict flag from argv' do
      assert SolidQueueGuard::CLI.strict_flag?(['--strict'])
      assert_not SolidQueueGuard::CLI.strict_flag?([])
    end

    test 'parses json format from argv' do
      assert_equal :json, SolidQueueGuard::CLI.format_flag(['--format=json'])
      assert_equal :text, SolidQueueGuard::CLI.format_flag([])
    end

    test 'parses scope from argv' do
      assert_equal :all, SolidQueueGuard::CLI.scope_flag(['--scope=all'])
      assert_equal :config, SolidQueueGuard::CLI.scope_flag([])
    end
  end
end
