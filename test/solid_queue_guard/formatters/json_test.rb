# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  module Formatters
    class JsonTest < ActiveSupport::TestCase
      test 'renders report as json' do
        report = SolidQueueGuard::Report.new([
                                               SolidQueueGuard::Check::Result.new(id: 'adapter', status: :pass,
                                                                                  message: 'ok')
                                             ])

        output = SolidQueueGuard::Formatters::Json.new(report).render
        payload = JSON.parse(output)

        assert_equal 'healthy', payload['status']
        assert_equal 1, payload['checks'].size
      end
    end
  end
end
