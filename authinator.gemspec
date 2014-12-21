# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authinator/version'

Gem::Specification.new do |spec|
  spec.name          = 'authinator'
  spec.version       = Authinator::VERSION
  spec.authors       = ['Alexander Bradner']
  spec.email         = ['alex@bradner.net']
  spec.summary       = 'Single-Sign-On for the front and rails backend of a Single-Page-App'
  # spec.description   = ''
  spec.homepage      = 'https://github.com/abradner/authinator'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'oauth2', '~> 1.0'
  # spec.add_runtime_dependency 'doorkeeper',     '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rubocop'
end
