[![Build Status](https://travis-ci.com/reedjosh/RackMiddlewareMetrics.svg?branch=main)](https://travis-ci.com/reedjosh/RackMiddlewareMetrics)
# Metrics Reporter
A minimalist Application Performance Monitoring (APM) library for Ruby on Rails.


The middleware generates a CSV file with the followinfg fields (no header):
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

## Example Output from Redmine Rails Project

| Start                   | End                     | Duration(S) | URI                          | Params               | Thread       | PID | MD5                             |
|-------------------------|-------------------------|-------------|------------------------------|----------------------|--------------|-----|---------------------------------|
|2020-10-27 13:32:46 -0700|2020-10-27 13:32:47 -0700|-0.698014072 |http://localhost:3000/        |                      |55890640      |18581|1724d0f493f9ed2e191d9aeb49df0f4c |
|2020-10-27 13:33:07 -0700|2020-10-27 13:33:07 -0700|-0.02697148  |http://localhost:3000/        |                      |70368509891620|18581|80eabd1e0373408b0a40b08b0eec6c3f |
|2020-10-28 09:40:16 -0700|2020-10-28 09:40:16 -0700|-0.717337538 |http://localhost:3000/        |                      |55777940      |16173|89ab1d3fcc2d9dcdef4a50d79e9dcaff |
|2020-10-28 09:40:41 -0700|2020-10-28 09:40:41 -0700|-0.103701273 |http://localhost:3000/projects|                      |55777940      |16173|d2ddd9efc455f83cb24060e6593d6c6c |
|2020-10-28 09:41:44 -0700|2020-10-28 09:41:44 -0700|-0.051811471 |http://localhost:3000/projects|blah=funk             |70368510966560|16173|eb2dacf2043e866a9e8925e53d471e6f |
|2020-10-28 09:44:02 -0700|2020-10-28 09:44:03 -0700|-0.831327261 |http://localhost:3000/projects|blah=funk;blah2=2funky|55777780      |17355|40895fa7af099cae3f48b27f149beb30 |


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
