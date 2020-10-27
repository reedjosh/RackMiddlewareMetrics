# frozen_string_literal: true

# lib/metrics_reporter.rb
#
# A minimal rack middleware metrics reporter.
require 'time'
require 'rack'
require 'md5_gen'

APP_ROOT ||= Pathname.new(__FILE__).parent.parent.parent

module RackMiddlewareMetrics
  # The metrics reporter middleware.
  class Reporter
    def initialize app, logpath: nil
      @app = app
      @logpath = :logpath.nil? ? Pathname.new(logpath) : (APP_ROOT / 'log.csv')
    end

    def call env
      start_time = Time.now
      status, headers, body = @app.call(env)
      end_time = Time.now
      duration = start_time - end_time
      query_params = env['QUERY_STRING']
      uri = "#{ env['rack.url_scheme'] }://#{ env['SERVER_NAME'] }"\
            ":#{ env['SERVER_PORT'] }#{ env['PATH_INFO'] }"
      thread_id =  Thread.current.object_id
      process_id = Process.pid
      md5 = MD5Gen.compute(body.join)
      logline = [start_time, end_time, duration, uri, query_params, thread_id, process_id, md5].join(',') + "\n"
      @logpath.open(mode: 'a') { |logfile| logfile.write(logline) }

      [status, headers, body]
    end
  end
end