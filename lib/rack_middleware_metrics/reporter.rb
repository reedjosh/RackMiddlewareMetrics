# frozen_string_literal: true

# lib/rack_middleware_metrics/reporter.rb
#
# A minimal rack middleware metrics reporter.
require 'time'
require 'rack'
require 'md5_gen'
require 'uri'
require 'csv'

module RackMiddlewareMetrics
  # The metrics reporter middleware.
  class Reporter
    # Initialize the reporter middleware.
    #
    # @param app [rack::RackApp] the app to add metrics reporting to.
    # @param *args [Array<any>, nil] arguments to pass through to the app.
    #   A hash passed as the final argument will be used as config options--of which :logpath
    #   can be used to specify the metrics reporter logpath.
    # @returns [Reporter] a new instance of Reporter.
    def initialize app, *args
      @app = app

      # Rack `use` only allows *args. Use either logpath passed via hash or default path.
      options = args.last.is_a?(Hash) ? args.last : {}
      @logpath = Pathname.new(options.fetch(:logpath, 'rack_metrics.csv'))
    end

    # Converts data from rack env object to uri.
    #
    # @param env [rack::ENV] the request env.
    # @return [String] the uri.
    def uri_from env
      "#{ env['rack.url_scheme'] }://#{ env['SERVER_NAME'] }"\
            ":#{ env['SERVER_PORT'] }#{ env['PATH_INFO'] }"
    end

    # Converts data from rack env object to semicolon delimited parameters.
    # Original semicolons escaped with %3B the ASCII equivalent.
    # See https://www.december.com/html/spec/esccodes.html for more details.
    #
    # @param env [rack::ENV] the request env.
    # @return [String] semicolon delimited parameters..
    def params_from env
      params = Hash[URI.decode_www_form(env['QUERY_STRING'])]
      params = params.map { |key, val| "#{ key }=#{ val }" }
      params.map { |param| param.gsub(';', '%3B') }.join(';')
    end

    # Run the request--call next step in middleware/server chain with added timing.
    #
    # @param env [rack::ENV] the request env.
    # @return [Array<Array<Objects>>] the response objects: [status, headers, body] plus
    #   added timing such that the final form is:
    #   [[status, headers, body], [start_time, end_time, duration]]
    def timed_call env
      start_time = Time.now
      response = @app.call(env)
      end_time = Time.now
      duration = end_time - start_time
      [*response, [start_time, end_time, duration]]
    end

    # Run the request--call next step in middleware/server chain with added timing.
    #
    # @param data [Array<objects>] metrics data to append to logfile.
    # @return [void]
    def append_data data
      CSV.open(@logpath, 'a') do |csv|
        csv << data
      end
    end

    # Main middleware entry and exit point. Logs metrics as specified.
    #
    # @param env [rack::ENV] the request env.
    # @return [Array<objects>] of the form: [status, headers, body]
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
