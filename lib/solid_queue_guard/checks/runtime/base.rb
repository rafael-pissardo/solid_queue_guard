# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Runtime
      class Base < Checks::Base
        NOT_IMPLEMENTED_MESSAGE = "Runtime check not implemented until v0.2"

        def call
          skip(check_id, NOT_IMPLEMENTED_MESSAGE)
        end

        private
          def check_id
            self.class.name.demodulize.underscore.delete_suffix("_check")
          end
      end
    end
  end
end
