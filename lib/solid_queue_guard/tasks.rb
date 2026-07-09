# frozen_string_literal: true

namespace :solid_queue_guard do
  desc "Install Solid Queue Guard"
  task install: :environment do
    Rails::Command.invoke :generate, [ "solid_queue_guard:install" ]
  end

  desc "Run configuration and runtime diagnostics. Usage: doctor[json] or SOLID_QUEUE_GUARD_FORMAT=json"
  task :doctor, [ :format ] => :environment do |_task, args|
    SolidQueueGuard::CLI.run!(
      scope: :config,
      format: cli_format(args[:format]),
      strict: cli_strict
    )
  end

  desc "Print machine-readable health status"
  task health: :environment do
    SolidQueueGuard::CLI.run!(scope: :config, format: :json, strict: cli_strict)
  end

  desc "Print full diagnostic report. Usage: report[json]"
  task :report, [ :format ] => :environment do |_task, args|
    SolidQueueGuard::CLI.run!(
      scope: :all,
      format: cli_format(args[:format]),
      strict: cli_strict
    )
  end

  def cli_format(argument)
    (argument.presence || ENV.fetch("SOLID_QUEUE_GUARD_FORMAT", "text")).to_sym
  end

  def cli_strict
    SolidQueueGuard.config.strict?
  end
end
