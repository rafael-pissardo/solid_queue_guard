# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module MissionControl
    class DashboardHelperTest < ActionView::TestCase
      include DashboardHelper

      test 'skip status uses dark tag for contrast on dark themes' do
        assert_equal 'is-dark', guard_modifier_for_status(:skip)
        assert_equal 'is-dark', guard_modifier_for_status('skip')
      end

      test 'known statuses keep semantic modifiers' do
        assert_equal 'is-success', guard_modifier_for_status(:pass)
        assert_equal 'is-warning', guard_modifier_for_status(:warn)
        assert_equal 'is-danger', guard_modifier_for_status(:fail)
      end

      test 'guard_status_tag renders skip with is-dark' do
        html = guard_status_tag(:skip)

        assert_includes html, 'tag is-dark'
        assert_includes html, 'Skip'
      end
    end
  end
end
