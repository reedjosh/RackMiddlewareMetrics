# Metrics Reporter
A minimalist Application Performance Monitoring (APM) library for Ruby on Rails.

Reports: 
    - The time that the request enters the middleware.
    - The time that it leaves the middleware.
    - Request path
    - The request's parameter list.
    - MD5 hash value of the rendered output.
    - Current thread and process ids.

Appends to a CSV file. 

The location and name of the file are configurable by the user. 

Adds itself to the hosting Ruby on Rails application using Railties AND the agent

Does MD5 calculation in Rust.

Getting Started


## Etc... Notes
Create a Gem that can be added to a Ruby on Rails project.
Add the Gem to an open source Ruby on Rails project (RedMine, Discourse, etc) and generate a performance metrics CSV file.
Project Requirements

The Rack middleware should be implemented as a Railtie
The middleware should generate a CSV file with the following fields:
Request Time: the timestamp when the request enters the middleware
Response Time: the timestamp when the request leaves the middleware
Elapsed Time: the time betwen request and response
Path: the URI of the request
Params: a semi-colon delimited list of GET parameters
MD5: the hashed value of the response body
Process ID: the process ID of the current request
Thread ID: the thread ID of the current request
The filename and path of the generated CSV file should be configurable by the user of the Gem
Optional: generate the MD5 hash in C or Rust (Helix is an option).
Write unit tests in RSpec and, optionally, add add it to Travis CI.
Write a README that explains what you built and how to use it.
Goals: We are interested in how you write idiomatic and well-tested ruby code in a gem that could
be shared among many Ruby on Rails projects particularly when some of the logic must be
implemented in non-ruby code. rvm or rbenv is your friend if you want to test
in multiple ruby versions.
