# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class Base < Checks::Base
        include DatabaseSupport

        private

        def check_id
          self.class.name.demodulize.underscore.delete_suffix('_check')
        end
      end
    end
  end
end
