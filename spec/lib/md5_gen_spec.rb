# frozen_string_literal: true

# spec/lib/md5_gen_spec.rb
#
# Test that loading md5_gen can fallback to ruby MD5.
require 'spec_helper'
require 'rake'

APP_ROOT ||= Pathname.new(__FILE__).parent.parent.parent
EXT_LIB = APP_ROOT / 'lib/md5_ruby_ext'

describe 'MD5Gen' do
  # Make sure the lib isn't present at the begining of the test.
  skip it 'works with fallback md5 method' do
    expect{ load('lib/md5_gen.rb') }.to output(/Unable to load md5_ruby_ext\/native./).to_stderr
    md5 = MD5Gen.compute('blah')
    expect(md5).to(eq('6f1ed002ab5595859014ebf0951522d9'))
  end
  it 'works with rust md5 method' do
    # Verify loaded rust ext.
    expect{ load('lib/md5_gen.rb') }.not_to output(/Unable to load md5_ruby_ext\/native./).to_stderr

    md5 = MD5Gen.compute('blah')
    expect(md5).to(eq('6f1ed002ab5595859014ebf0951522d9'))
  end
end
