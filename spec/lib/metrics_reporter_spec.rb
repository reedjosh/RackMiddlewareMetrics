# frozen_string_literal: true

# spec/lib/metrics_reporter_spec.rb
#
# TODO: Find a more idomatic way to spoof a rack app. I'm sure there's something out there...
require 'metrics_reporter'
require 'spec_helper'
require 'rack'

APP_ROOT ||= Pathname.new(__FILE__).parent.parent

# A simple rack app for testing.
class RackApp
  def self.call _env
    [200, { 'Content-Type' => 'text/html' }, ['Hi!']] # rubocop:disable Style/StringHashKeys
  end
end

TESTOUTPUT_LOGFILE = (APP_ROOT / 'log.csv')

describe MetricsReporter do
  before(:all) do
    # Ensure no testing logfile exists.
    (APP_ROOT / 'log.csv').delete if (APP_ROOT / 'log.csv').exist?

    # Create metrics reporter only once.
    @metrics_reporter = MetricsReporter.new(RackApp, logpath: TESTOUTPUT_LOGFILE)
  end

  let(:file) { TESTOUTPUT_LOGFILE }

  it 'writes a timespan to a new csv logfile' do
    @metrics_reporter.call(ENV)
  end

  it { expect(file).to(exist) }

  it 'appends to currently existing logfile' do
    @metrics_reporter.call(ENV)
    expect(TESTOUTPUT_LOGFILE.readlines.count).to(eq(2))
    @metrics_reporter.call(ENV)
    expect(TESTOUTPUT_LOGFILE.readlines.count).to(eq(3))
  end

  after(:all) do
    # Cleanup testing logfile.
    (APP_ROOT / 'log.csv').delete rescue Errno::ENOENT
  end
end
