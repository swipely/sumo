# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sumo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Swipely, Inc.']
  gem.email         = %w(tomhulihan@swipely.com)
  gem.description   = 'A simple REST client for the Sumo Search Job API'
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/swipely/sumo'
  gem.license       = 'MIT'
  gem.files         = `git ls-files`.lines.to_a
  gem.executables   = gem.files.grep(%r{^bin/}).map(&File.method(:basename))
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'sumo-search'
  gem.require_paths = %w(lib)
  gem.version       = Sumo::VERSION
  gem.add_dependency 'excon', '~> 0.45.3'
  gem.add_dependency 'clamp', '~> 0.6.5'
  gem.add_dependency 'json'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'vcr', '>= 2.7.0'
  gem.add_development_dependency 'codeclimate-test-reporter'
end
