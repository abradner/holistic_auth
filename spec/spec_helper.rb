require 'bundler/setup'
Bundler.setup

if RUBY_VERSION >= '1.9'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter,
  ]

  SimpleCov.start do
    minimum_coverage(76)
  end
end

require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require 'holistic_auth' # and any other gems you need

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include Rack::Test::Methods
  config.include WebMock::API

  # some (optional) config here
end
