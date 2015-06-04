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

  attr_writer :creds, :config, :client
  module_function :creds=, :config=, :client=

  # Define top-level functions.

  module_function

  # Credentials loaded from the configuration file.
  def creds
    @creds ||= config.load_creds!
  end

  # The default config for the gem.
  def config
    @config ||= Sumo::Config.new
  end

  # The default client for the gem.
  def client
    @client ||= Sumo::Client.new
  end

  # Create a new search.
  def search(*args)
    Sumo::Search.create(*args)
  end
end
