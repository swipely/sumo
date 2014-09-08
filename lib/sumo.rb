require 'base64'
require 'clamp'
require 'excon'
require 'json'
require 'yaml'

# This is the top level module for the gem. It is used as a namespace and holds
# top-level convenience functions.
module Sumo
  # Define global constants.
  CONFIG_FILE = File.expand_path('~/.sumo_creds').freeze

  # Require sub-modules.
  require 'sumo/error'
  require 'sumo/config'
  require 'sumo/client'
  require 'sumo/search'
  require 'sumo/collection'
  require 'sumo/cli'
  require 'sumo/version'

  # Define top-level functions.

  module_function

  def creds
    @creds ||= config.load_creds!
  end

  def creds=(new_creds)
    @creds = new_creds
  end

  # The default config for the gem.
  def config
    @config ||= Sumo::Config.new
  end

  # Reset the default config for the gem.
  def config=(new_config)
    @config = new_config
  end

  # The default client for the gem.
  def client
    @client ||= Sumo::Client.new
  end

  # Reset the default client for the gem.
  def client=(new_client)
    @client = new_client
  end

  # Create a new search.
  def search(*args)
    Sumo::Search.create(*args)
  end
end
