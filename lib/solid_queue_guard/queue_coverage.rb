# frozen_string_literal: true

module SolidQueueGuard
  module QueueCoverage
    module_function

    def worker_queues_from_configuration(configuration = SolidQueue::Configuration.new)
      configuration.configured_processes
        .select { |process| process.kind == :worker }
        .flat_map { |process| parse_queues_option(process.attributes[:queues]) }
        .uniq
    end

    def covers_all?(worker_queues, required_queue)
      return true if worker_queues.include?("*")

      worker_queues.include?(required_queue)
    end

    def uncovered_queues(required_queues, worker_queues)
      required_queues.reject { |queue_name| covers_all?(worker_queues, queue_name) }
    end

    def parse_queues_option(value)
      case value
      when "*", nil
        [ "*" ]
      when String
        value.split(",").map(&:strip).reject(&:empty?)
      when Array
        value.map(&:to_s)
      else
        []
      end
    end
  end
end
