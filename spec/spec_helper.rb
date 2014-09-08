$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start unless ENV['CODECLIMATE_REPO_TOKEN'].nil?

require 'rspec'
require 'pry'
require 'sumo'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |file| require file }
