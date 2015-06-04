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
  autoload :CLI, 'sumo/cli'
  autoload :Client, 'sumo/client'
  autoload :Collection, 'sumo/collection'
  autoload :Config, 'sumo/config'
  autoload :Error, 'sumo/error'
  autoload :Search, 'sumo/search'
  autoload :VERSION, 'sumo/version'

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
