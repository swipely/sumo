require 'base64'
require 'excon'
require 'json'

# This is the top level module for the gem. It is used as a namespace and holds
# top-level convenience functions.
module SumoJob
  # Define global constants.
  DEFAULT_CONFIG_FILE = File.expand_path('~/.sumo_creds').freeze

  # Require sub-modules.
  require 'sumo_job/error'
  require 'sumo_job/config'
  require 'sumo_job/client'

  # Define top-level functions.

  # The default config for the gem.
  def config
    @config ||= SumoJob::Config.new
  end
  module_function :config

  # Reset the default config for the gem.
  def config=(new_config)
    @config = new_config
  end
  module_function :config=

  # The default client for the gem.
  def client
    @client ||= SumoJob::Client.new
  end
  module_function :client

  # Reset the default client for the gem.
  def client=(new_client)
    @client = new_client
  end
  module_function :client=
end
