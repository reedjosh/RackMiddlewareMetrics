[![Build Status](https://travis-ci.com/reedjosh/RackMiddlewareMetrics.svg?branch=main)](https://travis-ci.com/reedjosh/RackMiddlewareMetrics)
# Metrics Reporter
A minimalist Application Performance Monitoring (APM) library for Ruby on Rails.


The middleware generates a CSV file with the following fields:
- Request Time: the timestamp when the request enters the middleware
- Response Time: the timestamp when the response leaves the middleware
- Elapsed Time: the time betwen request and response
- Path: the URI of the request
- Params: a semi-colon delimited list of GET parameters
- MD5: the hash value of the response body
- Process ID: the process ID of the current request
- Thread ID: the thread ID of the current request

The location and name of the file are configurable by the user. 

Optionally: Does MD5 calculation in Rust if native extention is built.

## Getting Started

[Yard Docs](https://rubydoc.info/github/reedjosh/RackMiddlewareMetrics/main)

### Installation
Install from [ruby gems](https://rubygems.org/gems/rack_middleware_metrics)

`bundle add rack_middleware_metrics`

### Non-rails Setup
See [example](https://github.com/reedjosh/RackMiddlewareMetrics/blob/main/example/thin_rack_app.rb) for setup with rack directly.
```ruby
class RackApp
  def self.call _env
    [200, { some_header: 'a value' }, ['Hi!']]
  end
end

app =
  Rack::Builder.app do
    use(RackMiddlewareMetrics::Reporter, logpath: 'some_metrics_filepath.csv')
    run(RackApp)
  end

handler = Rack::Handler::Thin
handler.run(app, Port: 8082)
```

### Rails setup.
The middleware is automatically registered with Rails. But to configure the logpath add:
``` ruby
    config.rack_middleware_metrics.logpath = Rails.root / 'some_metrics_filepath.csv'
```
to `config/environments/*.rb`

## Etc... Notes
TODO: Add the Gem to an open source Ruby on Rails project (RedMine, Discourse, etc) and generate 
a performance metrics CSV file.

## Development

CI/CD is managed via [Travis CI](https://travis-ci.com/github/reedjosh/RackMiddlewareMetrics).

### Build and Test Manually
Build via:

`bundler install --path=vendor`

Run spec via:

`./bin/rspec`

### Build the Rust Extension
Install Rust if not present.

`curl https://sh.rustup.rs -sSf | sh -s -- -y`

`source $HOME/.cargo/env`

Build extension.

`./bin/rake build`

### PRs and Testing
A pull request will trigger builds for each of the Ruby versions supported against Ubuntu Xenial.

### Release
Releases from Travis are triggered whenever a commit to the main branch is tagged. Spec tests must pass for release to occur.
