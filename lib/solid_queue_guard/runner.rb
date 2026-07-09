# frozen_string_literal: true

module SolidQueueGuard
  # @api private
  class Runner
    def initialize(scope: :config, enabled: SolidQueueGuard.enabled?)
      @scope = scope
      @enabled = enabled
    end

    def run
      return Report.new([disabled_result]) unless enabled

      results = checks.map do |check_class|
        run_check(check_class)
      end

      Report.new(results)
    end

    private

    attr_reader :scope, :enabled

    def checks
      Checks::Registry.for(scope)
    end

    def run_check(check_class)
      check_class.call
    rescue StandardError => e
      Check::Result.new(
        id: check_class.name.demodulize.underscore,
        status: :fail,
        message: "Check raised an error: #{e.class}: #{e.message}"
      )
    end

    def disabled_result
      Check::Result.new(
        id: 'disabled',
        status: :skip,
        message: 'SolidQueueGuard is disabled'
      )
    end
  end
end
