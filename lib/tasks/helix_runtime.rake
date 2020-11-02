# frozen_string_literal: true

# lib/tasks/helix_runtime.rake
require 'helix_runtime/build_task'

Dir.chdir(Pathname(__FILE__).parent) do
  HelixRuntime::BuildTask.new

  task default: :build
end
