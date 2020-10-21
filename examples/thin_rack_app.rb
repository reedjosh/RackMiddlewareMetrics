# frozen_string_literal: true

#  examples/thin_rack_app.rb
#
#  Just a simple example of running with thin.
require 'lib/metrics_reporter'
require 'rack'

# A simple rack app for example.
class RackApp
  def self.call _env
    [200, { 'Content-Type' => 'text/html' }, ['Hi!']]
  end
end

app =
  Rack::Builder.app do
    use(MetricsReporter)
    run(RackApp)
  end

handler = Rack::Handler::Thin
handler.run(app, Port: 8082)
