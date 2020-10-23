# lib/tasks/helix_runtime.rake
require 'helix_runtime/build_task'

HelixRuntime::BuildTask.new()

task default: :build
