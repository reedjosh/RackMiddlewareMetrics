# frozen_string_literal: true

# Rakefile
require 'rake'
require 'rspec/core/rake_task'
import 'lib/tasks/helix_runtime.rake'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec.rb')
  t.rspec_opts = '--format documentation'
end

task :spec => :build
task default: :spec
