# frozen_string_literal: true

# lib/md5_gen.rb
#
# Provide md5 compute function that either uses native extention or Ruby digest lib.
require 'helix_runtime'
require('digest/md5')

module MD5Gen
  begin
    require('md5_ruby_ext/native')
    def MD5Gen.compute body
      MRubyExt.compute(body)
    # Can only work on UTF-8 strings atm. Helix limitation.
    rescue TypeError
      Digest::MD5.hexdigest(body)
    end
  rescue LoadError
    warn('Unable to load md5_ruby_ext/native. Falling back to Ruby digest/md5. ' \
         'Please run `rake build` to build native extension.')
    def MD5Gen.compute body # rubocop:disable Lint/DuplicateMethods
      Digest::MD5.hexdigest(body)
    end
  end
end
