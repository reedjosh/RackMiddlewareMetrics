# frozen_string_literal: true

require_relative 'lib/rack_middleware_metrics/version'

Gem::Specification.new do |spec|
  spec.name          = 'rack_middleware_metrics'
  spec.version       = RackMiddlewareMetrics::VERSION
  spec.authors       = ['reedjosh']
  spec.email         = ['reedjosh@oregonstate.edu']

  spec.summary       = 'A rack based middleware that does fun/silly metrics reporting.'
  spec.homepage      = 'https://github.com/reedjosh/RackMiddlewareMetrics'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/reedjosh/RackMiddlewareMetrics'
  spec.metadata['changelog_uri'] = 'https://github.com/reedjosh/RackMiddlewareMetrics'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(File.expand_path('..', __FILE__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    end
  spec.add_dependency('helix_runtime', '~> 0.7.5')
  spec.add_dependency('rack', '~> 2.2.2')
  spec.add_dependency('rake', '~> 12.0')
  spec.bindir         = 'exe'
  spec.executables    = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths  = ['lib']
end
