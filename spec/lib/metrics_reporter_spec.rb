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
    [200, { 'Content-Type' => 'text/html' }, ['Hi!']]
  end
end

describe MetricsReporter do
  let(:file) { APP_ROOT / 'log.csv' }
  it { expect(file).not_to(exist) }
  it 'writes a timespan to csv logfile' do
    described_class.new(RackApp).call({ empty: 'env' })
  end
  it { expect(file).to(exist) }
end
