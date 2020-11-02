# frozen_string_literal: true

# lib/rack_middleware_metrics.rb
require 'rack_middleware_metrics/version'
require 'rack_middleware_metrics/reporter'

require 'rack_middleware_metrics/railtie' if defined?(Rails)

# A minimalist Application Performance Monitoring (APM) library for Ruby on Rails.
module RackMiddlewareMetrics
end
