# frozen_string_literal: true

# lib/metrics_reporter.rb
#
# A minimal rack middleware metrics reporter.
require 'time'
require 'rack'

APP_ROOT ||= Pathname.new(__FILE__).parent.parent

# The metrics reporter middleware.
class MetricsReporter
  def initialize app, logpath: nil
    @app = app
    @logpath = :logpath.nil? ? Pathname.new(logpath) : (APP_ROOT / 'log.csv')
  end

  def call env
    start_time = Time.now
    status, headers, body = @app.call(env)
    end_time = Time.now
    duration = start_time - end_time
    @logpath.open(mode: 'a') { |logfile| logfile.write(duration) }

    [status, headers, body]
  end
end
