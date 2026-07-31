# frozen_string_literal: true

module SolidQueueGuard
  # Reads Solid Queue's estimated queue-DB pool requirement across gem versions.
  #
  # Solid Queue 1.6 renamed the private helper from +estimated_number_of_threads+
  # to +estimated_database_pool_size+ (fiber workers need a different estimate).
  # Both return the same value for classic thread workers: max capacity + 2.
  module ConfigurationSizing
    module_function

    def estimated_database_pool_size(configuration = SolidQueue::Configuration.new)
      if configuration.respond_to?(:estimated_database_pool_size, true)
        configuration.send(:estimated_database_pool_size)
      elsif configuration.respond_to?(:estimated_number_of_threads, true)
        configuration.send(:estimated_number_of_threads)
      else
        raise NoMethodError,
              'SolidQueue::Configuration has neither estimated_database_pool_size ' \
              'nor estimated_number_of_threads'
      end
    end
  end
end
