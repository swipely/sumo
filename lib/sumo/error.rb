module Sumo
  # This module holds all errors for the gem.
  module Error
    # This class is never thrown but can be used to catch all errors thrown in
    # the gem.
    class BaseError < StandardError; end

    # This is raised when credentials cannot be found.
    class NoCredsFound < BaseError; end

    # Raised when a 4xx-level response is returned by the API.
    class ClientError < BaseError; end

    # Raised when a 5xx-level response is returned by the API.
    class ServerError < BaseError; end
  end
end
