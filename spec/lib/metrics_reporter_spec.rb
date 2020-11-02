# frozen_string_literal: true

# spec/lib/metrics_reporter_spec.rb
#
# TODO: Find a more idomatic way to spoof a rack app. I'm sure there's something out there...
require 'rack_middleware_metrics'
require 'spec_helper'
require 'rack'

APP_ROOT ||= Pathname.new(__FILE__).parent.parent.parent

# A simple rack app for testing.
class RackApp
  def self.call _env
    [200, { SomeHeaderParam: 'someval' }, ['Hi!']]
  end
end

# Create a test env var from url string.
TEST_URL = 'https://www.google.com/search?q=anandtech+usb&rlz=1C1GCEA_enUS779US779'\
           '&oq=anandtech+usb&aqs=chrome..69i57j0i22i30i457.3039j0j4&sourceid=chrome&ie=UTF-8'
TEST_ENV = Rack::MockRequest.env_for(TEST_URL)

TESTOUTPUT_LOGFILE = (APP_ROOT / 'log.csv')

describe RackMiddlewareMetrics::Reporter do # rubocop:disable Metrics/BlockLength
  before(:all) do
    @metrics_reporter = RackMiddlewareMetrics::Reporter.new(RackApp, logpath: TESTOUTPUT_LOGFILE)
  end

  before(:each) do TESTOUTPUT_LOGFILE.delete if TESTOUTPUT_LOGFILE.exist? end
  after(:each) do TESTOUTPUT_LOGFILE.delete if TESTOUTPUT_LOGFILE.exist? end

  let(:file) { TESTOUTPUT_LOGFILE }

  it 'writes a timespan to a new csv logfile' do
    expect(file).not_to(exist)
    @metrics_reporter.call(TEST_ENV)
    expect(file).to(exist)
  end


  it 'appends to logfile' do
    @metrics_reporter.call(TEST_ENV)
    expect(TESTOUTPUT_LOGFILE.readlines.count).to(eq(1))
    @metrics_reporter.call(TEST_ENV)
    expect(TESTOUTPUT_LOGFILE.readlines.count).to(eq(2))
    @metrics_reporter.call(TEST_ENV)
    expect(TESTOUTPUT_LOGFILE.readlines.count).to(eq(3))
  end

  it 'parses uri parameters into semicolon delimited pairs' do
    # Use params with semicolon in a value.
    # Semicolons are escaped to %3B (ASCII equivalent).
    # See https://www.december.com/html/spec/esccodes.html for details.
    raw_params = 'q=fast+usb+driv;e&rlz=1C1GCEA_enUS779US779&oq=fast+usb+drive' \
                 '&aqs=chrome..69i57j0j0i22i30l6.3257j1j4&sourceid=chrome&ie=UTF-8'
    expected_result = 'q=fast usb driv%3Be;rlz=1C1GCEA_enUS779US779;oq=fast usb drive;' \
                      'aqs=chrome..69i57j0j0i22i30l6.3257j1j4;sourceid=chrome;ie=UTF-8'

    fake_env = { 'QUERY_STRING' => raw_params } # rubocop:disable Style/StringHashKeys
    result = @metrics_reporter.params_from(fake_env)
    expect(result).to(eq(expected_result))
  end
end
