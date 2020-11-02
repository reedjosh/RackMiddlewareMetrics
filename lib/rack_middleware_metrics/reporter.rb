# frozen_string_literal: true

# lib/rack_middleware_metrics/reporter.rb
#
# A minimal rack middleware metrics reporter.
require 'time'
require 'rack'
require 'md5_gen'
require 'uri'
require 'csv'

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

    def params_from env
      # Convert to semicolon delimiter.
      # Replace original semicolons with %3B the ASCII escape equivalent.
      # See https://www.december.com/html/spec/esccodes.html for more details.
      params = Hash[URI.decode_www_form(env['QUERY_STRING'])]
      params = params.map { |key, val| "#{ key }=#{ val }" }
      params.map { |param| param.gsub(';', '%3B') }.join(';')
    end

    def timed_call env
      start_time = Time.now
      response = @app.call(env)
      end_time = Time.now
      duration = end_time - start_time
      [*response, [start_time, end_time, duration]]
    end

    def append_data data
      CSV.open(@logpath, 'a') do |csv|
        csv << data
      end
    end

    def call env
      status, headers, body, timing = timed_call(env)

      query_params = params_from(env)
      uri = uri_from(env)
      thread_id =  Thread.current.object_id
      process_id = Process.pid
      md5 = MD5Gen.compute(body.to_s)

      append_data([*timing, uri, query_params, thread_id, process_id, md5])

      [status, headers, body]
    end
  end
end
