# frozen_string_literal: true

require_relative 'lib/solid_queue_guard/version'

Gem::Specification.new do |spec|
  spec.name        = 'solid_queue_guard'
  spec.version     = SolidQueueGuard::VERSION
  spec.authors     = ['Rafael Pissardo']
  spec.email       = ['rpissardo@users.noreply.github.com']
  spec.homepage    = 'https://github.com/rafael-pissardo/solid_queue_guard'
  spec.summary     = 'Production readiness checks and runtime guards for Rails Solid Queue.'
  spec.description = [
    'Detect queue lag, dead workers, unsafe thread/pool configuration,',
    'and broken recurring jobs before they become incidents.'
  ].join(' ')
  spec.license = 'MIT'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => 'https://github.com/rafael-pissardo/solid_queue_guard',
    'changelog_uri' => 'https://github.com/rafael-pissardo/solid_queue_guard/blob/main/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/rafael-pissardo/solid_queue_guard/issues',
    'documentation_uri' => 'https://github.com/rafael-pissardo/solid_queue_guard#readme',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |file|
      file.start_with?('test/', '.github/', 'docs/', 'script/', 'gemfiles/', 'Appraisals')
    end
  end

  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.1'

  rails_version = '>= 7.1', '< 9.0'

  spec.add_dependency 'actionpack', rails_version
  spec.add_dependency 'activejob', rails_version
  spec.add_dependency 'activerecord', rails_version
  spec.add_dependency 'activesupport', rails_version
  spec.add_dependency 'railties', rails_version
  spec.add_dependency 'solid_queue', '>= 1.0', '< 2.0'

  spec.add_development_dependency 'appraisal', '~> 2.5'
  spec.add_development_dependency 'debug'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'mocha', '>= 2.1'
  spec.add_development_dependency 'puma', '>= 6.0'
  spec.add_development_dependency 'rails', rails_version
  spec.add_development_dependency 'rubocop', '~> 1.75'
  spec.add_development_dependency 'rubocop-rails', '~> 2.30'
  spec.add_development_dependency 'sqlite3', '~> 2.1'
end
