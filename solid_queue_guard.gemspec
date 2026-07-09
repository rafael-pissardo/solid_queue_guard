# frozen_string_literal: true

require_relative "lib/solid_queue_guard/version"

Gem::Specification.new do |spec|
  spec.name        = "solid_queue_guard"
  spec.version     = SolidQueueGuard::VERSION
  spec.authors     = [ "Rafael Pissardo" ]
  spec.email       = [ "rpissardo@users.noreply.github.com" ]
  spec.homepage    = "https://github.com/rafael-pissardo/solid_queue_guard"
  spec.summary     = "Production readiness checks and runtime guards for Rails Solid Queue."
  spec.description = "Detect queue lag, dead workers, unsafe thread/pool configuration, and broken recurring jobs before they become incidents."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 3.1"

  rails_version = ">= 7.1"
  spec.add_dependency "activejob", rails_version
  spec.add_dependency "activerecord", rails_version
  spec.add_dependency "actionpack", rails_version
  spec.add_dependency "railties", rails_version
  spec.add_dependency "solid_queue", ">= 1.0"

  spec.add_development_dependency "debug"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "puma"
  spec.add_development_dependency "sqlite3"
end
