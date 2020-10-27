# frozen_string_literal: true

#  examples/thin_rack_app.rb
#
#  Just a simple example of running with thin.
require 'lib/rack_middleware_metrics'
require 'rack'

# A simple rack app for example.
class RackApp
  def self.call _env
    [200, { some_header: 'a value' }, ['Hi!']]
  end
end

app =
  Rack::Builder.app do
    use(RackMiddlewareMetrics::Reporter)
    run(RackApp)
  end

handler = Rack::Handler::Thin
handler.run(app, Port: 8082)
