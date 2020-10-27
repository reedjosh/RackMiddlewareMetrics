# frozen_string_literal: true

# lib/rack_middleware_metrics/railtie.rb
module RackMiddlewareMetrics
  # Rails init...
  class Railtie < Rails::Railtie
    config.rack_middleware_metrics = ActiveSupport::HashWithIndifferentAccess.new
    initializer 'rack_middleware_metrics.configure_rails_initialization' do |app|
      config.rack_middleware_metrics[:logpath] =
        config.rack_middleware_metrics.fetch(:logpath, Rails.root / 'rack_metrics.csv')
      app.middleware.use(Reporter, config.rack_middleware_metrics)
    end
  end
end
