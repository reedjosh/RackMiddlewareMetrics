# frozen_string_literal: true

# spec/lib/metrics_reporter_spec.rb
#
# TODO: Find a more idomatic way to spoof a rack app. I'm sure there's something out there...
require 'rack_middleware_metrics'
#require 'spec_helper'
require 'rack'
require 'time'

APP_ROOT ||= Pathname.new(__FILE__).parent.parent.parent

# A simple rack app for testing.
class RackApp
  def self.call _env
    sleep(1)
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

  before(:each) { TESTOUTPUT_LOGFILE.delete if TESTOUTPUT_LOGFILE.exist? }
  after(:each) { TESTOUTPUT_LOGFILE.delete if TESTOUTPUT_LOGFILE.exist? }

  let(:file) { TESTOUTPUT_LOGFILE }

  it 'writes a correct logline to a new csv logfile' do
    expect(file).not_to(exist)
    @metrics_reporter.call(TEST_ENV)
    expect(file).to(exist)
    row = CSV.read(TESTOUTPUT_LOGFILE)[0]
    timing = row[0, 3]
    rest = row[3, row.length]
    start_time, end_time, duration = timing
    expect(Time.parse(end_time)).to(be > Time.parse(start_time))
    expect(Float(duration).round).to(eq(1))
    expected_uri = 'https://www.google.com:443/search'
    expected_params = 'q=anandtech usb;rlz=1C1GCEA_enUS779US779;oq=anandtech usb;'\
                      'aqs=chrome..69i57j0i22i30i457.3039j0j4;sourceid=chrome;ie=UTF-8'
    expected_pid =  Process.pid.to_s
    expected_md5 = '43551e34e03d1227e7582ec74b88c508'
    expect(rest[0]).to(eq(expected_uri))
    expect(rest[1]).to(eq(expected_params))
    expect(rest[3]).to(eq(expected_pid))
    expect(rest[4]).to(eq(expected_md5))
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
