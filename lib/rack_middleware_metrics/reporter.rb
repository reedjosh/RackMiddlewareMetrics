# frozen_string_literal: true

# lib/rack_middleware_metrics/reporter.rb
#
# A minimal rack middleware metrics reporter.
require 'time'
require 'rack'
require 'md5_gen'

# The main Gem...
module RackMiddlewareMetrics
  # The metrics reporter middleware.
  class Reporter
    def initialize app, *args
      @app = app

      # Rack `use` only allows *args. Use either logpath passed via hash or default path.
      options = args.last.is_a?(Hash) ? args.last : {}
      @logpath = Pathname.new(options.fetch(:logpath, 'rack_metrics.csv'))
    end

    def uri_from env
      "#{ env['rack.url_scheme'] }://#{ env['SERVER_NAME'] }"\
            ":#{ env['SERVER_PORT'] }#{ env['PATH_INFO'] }"
    end

    def timed_call env
      start_time = Time.now
      response = @app.call(env)
      end_time = Time.now
      duration = start_time - end_time
      [*response, [start_time, end_time, duration]]
    end

    def append_data data
      logline = "#{ data.join(',') }\n"
      @logpath.open(mode: 'a') { |logfile| logfile.write(logline) }
    end

    def call env
      status, headers, body, timing = timed_call(env)

      query_params = env['QUERY_STRING']
      uri = uri_from(env)
      thread_id =  Thread.current.object_id
      process_id = Process.pid
      md5 = MD5Gen.compute(body.to_s)

      append_data([*timing, uri, query_params, thread_id, process_id, md5])

      [status, headers, body]
    end
  end
end
