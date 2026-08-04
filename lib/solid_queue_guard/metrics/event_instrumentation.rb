# frozen_string_literal: true

module SolidQueueGuard
  module Metrics
    # Subscribes to Active Job notifications and Solid Queue lifecycle hooks.
    # Opt-in via config.emit_event_metrics = true.
    module EventInstrumentation
      class << self
        def install!
          return if @installed
          return unless SolidQueueGuard.config.emit_event_metrics
          return unless %w[production staging].include?(Rails.env.to_s)
          return unless DogstatsdClient.available?

          subscribe_active_job!
          subscribe_solid_queue_lifecycle!
          @installed = true
        end

        def reset!
          @installed = false
        end

        private

        def subscribe_active_job!
          ActiveSupport::Notifications.subscribe('enqueue.active_job') do |event|
            job = event.payload.fetch(:job)
            DogstatsdClient.statsd.increment(
              'solid_queue.jobs.enqueued',
              tags: DogstatsdClient.job_tags(job)
            )
          end

          ActiveSupport::Notifications.subscribe('perform.active_job') do |event|
            job = event.payload.fetch(:job)
            status = event.payload[:exception_object] || event.payload[:exception] ? 'error' : 'success'
            tags = [*DogstatsdClient.job_tags(job), "status:#{status}"]

            DogstatsdClient.statsd.increment('solid_queue.jobs.performed', tags:)
            DogstatsdClient.statsd.timing('solid_queue.job.duration_ms', event.duration, tags:)
          end

          %w[enqueue_retry retry_stopped discard].each do |event_name|
            ActiveSupport::Notifications.subscribe("#{event_name}.active_job") do |event|
              job = event.payload.fetch(:job)
              DogstatsdClient.statsd.increment(
                "solid_queue.jobs.#{event_name}",
                tags: DogstatsdClient.job_tags(job)
              )
            end
          end
        end

        def subscribe_solid_queue_lifecycle!
          {
            worker: %i[on_worker_start on_worker_stop],
            dispatcher: %i[on_dispatcher_start on_dispatcher_stop],
            scheduler: %i[on_scheduler_start on_scheduler_stop]
          }.each do |kind, (start_hook, stop_hook)|
            SolidQueue.public_send(start_hook) do |process|
              DogstatsdClient.statsd.gauge(
                'solid_queue.process.active',
                1,
                tags: DogstatsdClient.process_tags(kind, process)
              )
            end
            SolidQueue.public_send(stop_hook) do |process|
              DogstatsdClient.statsd.gauge(
                'solid_queue.process.active',
                0,
                tags: DogstatsdClient.process_tags(kind, process)
              )
            end
          end
        end
      end
    end
  end
end
