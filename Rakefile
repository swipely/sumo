$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

require 'rake'
require 'sumo_job'
require 'rspec/core/rake_task'
require 'cane/rake_task'

task :default => [:spec, :quality]

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

Cane::RakeTask.new(:quality) do |cane|
  cane.canefile = '.cane'
end
