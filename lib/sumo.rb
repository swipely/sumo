require 'base64'
require 'clamp'
require 'excon'
require 'json'

# This is the top level module for the gem. It is used as a namespace and holds
# top-level convenience functions.
module Sumo
  # Define global constants.
  DEFAULT_CONFIG_FILE = File.expand_path('~/.sumo_creds').freeze

  # Require sub-modules.
  require 'sumo/error'
  require 'sumo/config'
  require 'sumo/client'
  require 'sumo/search'
  require 'sumo/collection'
  require 'sumo/cli'
  require 'sumo/version'

  # Define top-level functions.

  def creds
    @creds ||= config.load_creds!
  end
  module_function :creds

  def creds=(new_creds)
    @creds = new_creds
  end
  module_function :creds=

  # The default config for the gem.
  def config
    @config ||= Sumo::Config.new
  end
  module_function :config

  # Reset the default config for the gem.
  def config=(new_config)
    @config = new_config
  end
  module_function :config=

  # The default client for the gem.
  def client
    @client ||= Sumo::Client.new
  end
  module_function :client

  # Reset the default client for the gem.
  def client=(new_client)
    @client = new_client
  end
  module_function :client=

  # Create a new search.
  def search(*args)
    Sumo::Search.new(*args)
  end
  module_function :search
end
