$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

require 'rake'
require 'sumo'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: [:spec, :quality]

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new(:quality)
