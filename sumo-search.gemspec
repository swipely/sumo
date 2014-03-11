# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sumo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Swipely, Inc."]
  gem.email         = %w{tomhulihan@swipely.com}
  gem.description   = %q{A simple REST client for the Sumo Search Job API}
  gem.summary       = %q{A simple REST client for the Sumo Search Job API}
  gem.homepage      = 'https://github.com/swipely/sumo-job'
  gem.license       = 'MIT'
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'sumo-search'
  gem.require_paths = %w{lib}
  gem.version       = Sumo::VERSION
  gem.add_dependency 'excon', '>= 0.32'
  gem.add_dependency 'clamp', '>= 0.6.3'
  gem.add_dependency 'json'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'cane'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'vcr', '>= 2.7.0'
end
