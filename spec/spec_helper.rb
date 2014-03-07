$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rspec'
require 'sumo_job'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter = :documentation
  config.mock_with :rspec
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.tty = true
end
