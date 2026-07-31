# frozen_string_literal: true

require 'test_helper'

module SolidQueueGuard
  class ConfigurationSizingTest < ActiveSupport::TestCase
    test 'prefers estimated_database_pool_size when present' do
      configuration = Object.new
      configuration.define_singleton_method(:respond_to?) do |method, include_private = false|
        method == :estimated_database_pool_size && include_private
      end
      configuration.define_singleton_method(:estimated_database_pool_size) { 11 }

      assert_equal 11, ConfigurationSizing.estimated_database_pool_size(configuration)
    end

    test 'falls back to estimated_number_of_threads on Solid Queue < 1.6' do
      configuration = Object.new
      configuration.define_singleton_method(:respond_to?) do |method, include_private = false|
        method == :estimated_number_of_threads && include_private
      end
      configuration.define_singleton_method(:estimated_number_of_threads) { 8 }

      assert_equal 8, ConfigurationSizing.estimated_database_pool_size(configuration)
    end

    test 'raises when neither sizing method exists' do
      configuration = Object.new
      configuration.define_singleton_method(:respond_to?) { |*| false }

      error = assert_raises(NoMethodError) do
        ConfigurationSizing.estimated_database_pool_size(configuration)
      end

      assert_match(/estimated_database_pool_size/, error.message)
    end
  end
end
