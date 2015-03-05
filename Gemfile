source 'https://rubygems.org'

# Specify your gem's dependencies in authinator.gemspec
gemspec

gem 'rake'

group :test do
  gem 'coveralls'
  gem 'json', platforms: [:jruby, :ruby_18, :ruby_19]
  gem 'mime-types', '~> 2.4.0', platforms: [:jruby, :ruby_18]
  gem 'rack-test'
  gem 'rest-client', '~> 1.7.0', platforms: [:jruby, :ruby_18]
  gem 'rspec', '~> 3.2.0'
  gem 'rubocop', '>= 0.28', platforms: [:ruby_19, :ruby_20, :ruby_21]
  gem 'simplecov', '>= 0.9'
  gem 'webmock'
end

# gem 'abstract_google_client', path: '/Users/abradner/foogi/google_client', require: 'google_client'
gem 'abstract_google_client', github: 'abradner/google_client', require: 'google_client'
