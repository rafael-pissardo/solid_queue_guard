# frozen_string_literal: true

module SolidQueueGuard
  module Checks
    module Config
      class WorkerCoverageCheck < Base
        def call
          worker_queues = worker_queue_names
          required_queues = queues_requiring_workers

          uncovered = QueueCoverage.uncovered_queues(required_queues, worker_queues)

          if uncovered.empty?
            pass("worker_coverage", "All required queues have worker coverage")
          else
            fail(
              "worker_coverage",
              "No workers configured for: #{uncovered.join(', ')}",
              suggestion: "Add a worker for #{uncovered.join(', ')} in config/queue.yml",
              metadata: { uncovered_queues: uncovered, worker_queues: worker_queues }
            )
          end
        end

        private
          def worker_queue_names
            QueueCoverage.worker_queues_from_configuration(solid_queue_configuration)
          end

          def queues_requiring_workers
            (recurring_queues + database_queues).uniq
          end

          def recurring_queues
            solid_queue_configuration.recurring_tasks.filter_map(&:queue_name).uniq
          rescue StandardError
            []
          end

          def database_queues
            return [] unless SolidQueue::Record.connection_pool&.connected?

            SolidQueue::Job.distinct.pluck(:queue_name)
          rescue StandardError
            []
          end
      end
    end
  end
end
