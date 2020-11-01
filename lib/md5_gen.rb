# frozen_string_literal: true

# lib/md5_gen.rb
require 'helix_runtime'
require('digest/md5')

begin
  require('md5_ruby_ext/native')
  EXT_LOADED = true
rescue LoadError
  warn('Unable to load md5_ruby_ext/native. Falling back to Ruby digest/md5. ' \
       'Please run `rake build` to build native extension.')
  EXT_LOADED = false
end

# Provides md5 compute function that either uses native extention or Ruby digest lib.
module MD5Gen
  # Define the underlying_compute_method based upon whether the rust extention is loaded.
  class << self
    if EXT_LOADED
      define_method(:underlying_compute_method) do |body|
        MRubyExt.compute(body)
      # Can only work on UTF-8 strings atm. Helix limitation.
      rescue TypeError
        Digest::MD5.hexdigest(body)
      end
    else
      define_method(:underlying_compute_method) do |body|
        Digest::MD5.hexdigest(body)
      end
    end
  end

  # Convert body string to MD5 hash.
  #
  # @param body [String] the body to be hashed.
  # @return [String] the hash of the body.
  def self.compute body
    underlying_compute_method(body)
  end
end
