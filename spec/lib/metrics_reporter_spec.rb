# frozen_string_literal: true

# spec/lib/metrics_reporter_spec.rb
#
# TODO: Find a more idomatic way to spoof a rack app. I'm sure there's something out there...
require 'metrics_reporter'
require 'spec_helper'
require 'rack'

APP_ROOT ||= Pathname.new(__FILE__).parent.parent

ENV = Rack::MockRequest.env_for("http://example.com:8080/slug", {"REMOTE_ADDR" => "10.10.10.10"})

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
    described_class.new(RackApp).call(ENV)
  end
  it { expect(file).to(exist) }
end
