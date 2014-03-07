require 'excon'

# This is the top level module for the gem. It is used as a namespace and holds
# top-level convenience functions.
module SumoJob
  # Define global constants.
  DEFAULT_CONFIG_FILE = File.expand_path('~/.sumo_creds').freeze

  # Require sub-modules.
  require 'sumo_job/error'
  require 'sumo_job/config'
end
