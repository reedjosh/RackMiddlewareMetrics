# frozen_string_literal: true

# lib/md5_ruby_ext.rb
require 'helix_runtime'

begin
  require('md5_ruby_ext/native')
rescue LoadError
  warn('Unable to load md5_ruby_ext/native. Please run `rake build`... Requires Rust/cargo.')
end
