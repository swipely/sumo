# This module holds all errors for the gem.
module SumoJob::Error
  # This class is never thrown but can be used to catch all errors thrown in the
  # gem.
  class BaseError < StandardError; end

  # This is raised when credentials cannot be found.
  class NoCredsFound < BaseError; end
end
