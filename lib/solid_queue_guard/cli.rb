# frozen_string_literal: true

module SolidQueueGuard
  module CLI
    module_function

    def options(argv: ARGV)
      {
        strict: strict_flag?(argv),
        format: format_flag(argv),
        scope: scope_flag(argv)
      }
    end

    def run!(scope: nil, format: nil, strict: nil, argv: ARGV)
      scope ||= scope_flag(argv)
      format ||= format_flag(argv)
      strict = strict_flag?(argv) if strict.nil?

      report = Runner.new(scope: scope).run
      Notifier.deliver_all(report) if notify?(report)
      Metrics::Exporter.export(report) if SolidQueueGuard.config.metrics_backends.any?

      output = formatter_for(format).new(report).render

      $stdout.puts(output) unless output.empty?

      exit report.exit_code(strict: strict)
    end

    def formatter_for(format)
      case format.to_sym
      when :json then Formatters::Json
      else Formatters::Terminal
      end
    end

    def strict_flag?(argv)
      SolidQueueGuard.config.strict? || argv.include?('--strict')
    end

    def format_flag(argv)
      if (format_argument = argv.find { |argument| argument.start_with?('--format=') })
        format_argument.split('=', 2).last.to_sym
      else
        ENV.fetch('SOLID_QUEUE_GUARD_FORMAT', 'text').to_sym
      end
    end

    def scope_flag(argv)
      if (scope_argument = argv.find { |argument| argument.start_with?('--scope=') })
        scope_argument.split('=', 2).last.to_sym
      else
        ENV.fetch('SOLID_QUEUE_GUARD_SCOPE', 'config').to_sym
      end
    end

    def notify?(report)
      return false unless SolidQueueGuard.config.notify_with.any?

      report.status != :healthy
    end
  end
end
