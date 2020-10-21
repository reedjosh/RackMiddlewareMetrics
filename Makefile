# TODO: Convert this to Rakefile to meet requirements.
.PHONY: gem clean deploy test publish bundle

export RUBYLIB := $(shell pwd)

export PATCH := 2
export MINOR := 1
export MAJOR := 1

gem:
	gem build metrics_reporter.gemspec

clean:
	-rm -rf .vendor
	-rm *gem
	-rm gemfile.lock
