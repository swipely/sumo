# This class contains the logic to find the user's credentials in either an
# environment variable or a configuration file. If both exist and a
# configuration file has not been specified, the environment variable is
# preferred. If both exist and a config file has been specified, the config
# file is preferred.
#
# The environment varibale is called 'SUMO_CREDS'; the default configuration
# file is '~/.sumo_creds'.
class SumoJob::Config
  include SumoJob::Error

  attr_reader :config_file

  # Given an optional `String`, sets and freezes the `@config_file` instance
  # variable, as long as it's a valid file path.
  def initialize(config_file = SumoJob::DEFAULT_CONFIG_FILE)
    @config_file = File.expand_path(config_file).freeze
  end

  # Test if an alternate file has been specified.
  def file_specified?
    config_file != SumoJob::DEFAULT_CONFIG_FILE
  end

  # Get the credentials from the environment.
  def env_creds
    ENV['SUMO_CREDS']
  end

  # Get the credentials from the configuration file.
  def file_creds
    File.read(config_file).chomp if File.exists?(config_file)
  end

  # Load the credentials.
  def load_config
    @config ||= if file_specified?
      file_creds || env_creds
    else
      env_creds || file_creds
    end
  end

  # Load the credentials, raising an error if none are specified.
  def load_config!
    if (creds = load_config).nil?
      raise NoCredsFound, "No credentials were found, set ENV['SUMO_CREDS']."
    else
      creds
    end
  end
end
