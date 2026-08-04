# frozen_string_literal: true

require 'rails/generators/base'

module SolidQueueGuard
  module Generators
    class MetricsGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      RECURRING_SNIPPET = <<~YAML.freeze
        emit_solid_queue_depth_metrics:
          class: SolidQueueGuard::Metrics::EmitDepthJob
          queue: solid_queue_recurring
          schedule: every 15 seconds
      YAML

      CONFIG_SNIPPET = <<~RUBY.freeze

          # Operational Datadog metrics (requires dogstatsd-ruby)
          config.emit_depth_metrics = true
          config.emit_event_metrics = true
          # config.statsd_service_name = 'my-service' # or set DD_SERVICE
      RUBY

      desc 'Enables Solid Queue operational metrics (depth gauges + event counters) and wires recurring.yml'

      def enable_config_flags
        initializer = 'config/initializers/solid_queue_guard.rb'
        full_path = File.expand_path(initializer, destination_root)

        unless File.exist?(full_path)
          say_status :error, "#{initializer} not found — run solid_queue_guard:install first", :red
          return
        end

        contents = File.read(full_path)
        if contents.include?('emit_depth_metrics')
          say_status :identical, "#{initializer} already enables depth metrics", :blue
          return
        end

        inject_into_file initializer, before: /\nend\s*\z/ do
          CONFIG_SNIPPET
        end
      end

      def add_recurring_task
        relative = 'config/recurring.yml'
        path = File.expand_path(relative, destination_root)

        unless File.exist?(path)
          say_status :skip, "#{relative} not found", :yellow
          return
        end

        content = File.read(path)
        if content.include?('emit_solid_queue_depth_metrics')
          say_status :identical, "#{relative} already has emit_solid_queue_depth_metrics", :blue
          return
        end

        updated = insert_recurring_snippet(content)
        File.write(path, updated)
        say_status :insert, "#{relative} (emit_solid_queue_depth_metrics)", :green
      end

      def remind_dependency
        say <<~MSG

          Add to your Gemfile if missing:
            gem 'dogstatsd-ruby'

          Ensure a Solid Queue worker consumes the `solid_queue_recurring` queue,
          then deploy and verify:
            solid_queue.ready.count{service:<your-service>}
        MSG
      end

      private

      def insert_recurring_snippet(content)
        indented = RECURRING_SNIPPET.lines.map { |line| line == "\n" ? line : "  #{line}" }.join

        if content.match?(/^default:/)
          content.sub(/^(default:(?: &[\w]+)?\n(?:  .*\n)*)/) do |block|
            "#{block.rstrip}\n#{indented}"
          end
        else
          "#{content.rstrip}\n\n#{RECURRING_SNIPPET}"
        end
      end
    end
  end
end
