module Sumo
  # This class has the lowest-level interface to interact with the Sumo Job API.
  class Client
    include Error

    attr_reader :email, :password, :cookie
    attr_writer :cookie

    # The error message raised when the result can be parsed from Sumo.
    DEFAULT_ERROR_MESSAGE = 'Error sending API request'

    # Create a new `Client` with the given credentials.
    def initialize(credentials = Sumo.creds)
      @email = credentials['email'].freeze
      @password = credentials['password'].freeze
    end

    # Send a HTTP request to the server, handling any errors that may occur.
    def request(hash, &block)
      response = connection.request(add_defaults(hash), &block)
      handle_errors!(response)
      self.cookie = response.headers['Set-Cookie'] || cookie
      response.body
    end

    # Define methods for the HTTP methods used by the API (#get, #post, and
    # #delete).
    [:get, :post, :delete].each do |http_method|
      define_method(http_method) do |hash, &block|
        request(hash.merge(method: http_method), &block)
      end
    end

    # Private functions that operate on the request and response.

    private

    def add_defaults(hash)
      hash.merge(
        headers: default_headers.merge(hash[:headers] || {}),
        path: "/api/v#{API_VERSION}#{hash[:path]}"
      )
    end

    def handle_errors!(response)
      error =
        if response.status.between?(400, 499)
          ClientError
        elsif response.status.between?(500, 599)
          ServerError
        end
      fail error, extract_error_message(response.body) if error
    end

    def extract_error_message(body)
      JSON.parse(body)['message'] || DEFAULT_ERROR_MESSAGE
    rescue
      DEFAULT_ERROR_MESSAGE
    end

    def default_headers
      {
        'Authorization' => "Basic #{encoded_creds}",
        'Content-Type' => 'application/json',
        'Cookie' => cookie,
        'Accept' => 'application/json'
      }.reject { |_, value| value.nil? }
    end

    def encoded_creds
      @encoded_creds ||= Base64.urlsafe_encode64(creds).strip
    end

    def creds
      [email, password].join(':')
    end

    def connection
      @connection ||= Excon.new('https://api.sumologic.com')
    end
  end
end
