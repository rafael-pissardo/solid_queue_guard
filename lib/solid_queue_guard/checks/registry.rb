# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    # @api private
    class Registry
      CONFIG_CHECKS = [
        Config::AdapterCheck,
        Config::QueueDatabaseCheck,
        Config::ConnectsToCheck,
        Config::QueueSchemaCheck,
        Config::ThreadPoolCheck,
        Config::WorkerCoverageCheck,
        Config::SchedulerConfigCheck,
        Config::EnvFlagsCheck,
        Config::ProcessHeartbeatConfigCheck,
        Config::PumaColocatedCheck,
        Config::TopologyRecommendationCheck,
        Config::AsyncSupervisorConfigCheck
      ].freeze

      RUNTIME_CHECKS = [
        Runtime::QueueLagCheck,
        Runtime::StaleProcessCheck,
        Runtime::ProcessTopologyCheck,
        Runtime::DispatcherCheck,
        Runtime::ScheduledBacklogCheck,
        Runtime::BlockedJobsCheck,
        Runtime::OrphanedClaimsCheck,
        Runtime::FailedJobsCheck,
        Runtime::RecurringStaleCheck,
        Runtime::PausedQueueLagCheck,
        Runtime::PidfileCheck,
        Runtime::FinishedJobsGrowthCheck,
        Runtime::PumaPluginRuntimeCheck
      ].freeze

      class << self
        def check_id_for(check_class)
          check_class.check_id
        end

        def for(scope)
          case scope.to_sym
          when :config then CONFIG_CHECKS
          when :runtime then RUNTIME_CHECKS
          when :all then CONFIG_CHECKS + RUNTIME_CHECKS
          else
            raise ArgumentError, "Unknown scope: #{scope}"
          end
        end
      end
    end
  end
end
