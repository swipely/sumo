module Sumo
  # This class contains the logic to find the user's credentials from a
  # configuration file. By default, the file is `~/.sumo_creds`.
  class Config
    include Error

    # Message generated when there is an error with the config file.
    BAD_CONFIG_FILE_MESSAGE = <<-EOS.gsub(/^\s+\|/, '')
      |:message
      |
      |sumo-search now expects its config file (located at :config_file) to
      |be valid YAML. Below is an example of a valid config file:
      |
      |backend:
      |  email: backend@example.com
      |  password: trustno1
      |frontend:
      |  email: frontend@example.com
      |  password: test-pass-1
      |
      |By default, the 'default' credential in :config_file will be used. To
      |change this behavior, set the $SUMO_CREDENTIAL environment varibale
      |to the credential you would like to use. In the above example, setting
      |$SUMO_CREDENTIAL to 'frontend' would allow you to access the account
      |with the email 'frontend@example.com' and password 'test-pass-1'.
    EOS

    attr_reader :config_file

    # Given an optional `String`, sets and freezes the `@config_file` instance
    # variable, as long as it's a valid file path.
    def initialize(config_file = CONFIG_FILE)
      @config_file = File.expand_path(config_file).freeze
    end

    # Load the credentials, raising an any errors that occur.
    def load_creds!
      @creds ||= load_file[cred_key]
      fail NoCredsFound, "#{cred_key} not found in #{config_file}" unless @creds
      @creds
    end

    # Load the credentials, returning nil if an error occurs.
    def load_creds
      load_creds!
    rescue
      nil
    end

    # Get the credentials from the environment.
    def cred_key
      @cred_key = ENV['SUMO_CREDENTIAL'] || 'default'
    end
    private :cred_key

    # Get the credentials from the configuration file.
    def load_file
      if File.exist?(config_file)
        parse_file
      else
        fail NoCredsFound, bad_config_file("#{config_file} does not exist.")
      end
    end
    private :load_file

    # Parse the configuration file, raising an error if it is invalid YAML.
    def parse_file
      creds = YAML.load_file(config_file)
      return creds if creds.is_a?(Hash)
      fail NoCredsFound, bad_config_file("#{config_file} is not valid YAML.")
    end
    private :parse_file

    def bad_config_file(message)
      BAD_CONFIG_FILE_MESSAGE
        .gsub(':message', message)
        .gsub(':config_file', config_file)
    end
    private :bad_config_file
  end
end
