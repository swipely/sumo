# This class has the lowest-level interface to interact with the Sumo Job API.
class Sumo::Client
  include Sumo::Error

  attr_reader :email, :password, :cookie

  REDIRECT_STATUSES = [301, 302, 303, 307, 308]

  # The error message raised when the result can be parsed from Sumo.
  DEFAULT_ERROR_MESSAGE = 'Error sending API request'

  # Create a new `Sumo::Client` with the given credentials.
  def initialize(credentials = Sumo.creds)
    @email = credentials['email'].freeze
    @password = credentials['password'].freeze
  end

  # Send a request to the API and retrieve processed data.
  def request(hash, &block)
    handle_request(hash, &block).body
  end

  # Send a HTTP request to the server, handling any errors that may occur.
  def handle_request(hash, endpoint = nil, depth = 0, &block)
    response = connection(endpoint).request(add_defaults(hash), &block)

    if REDIRECT_STATUSES.include?(response.status) &&
       response.headers['Location']
      response = handle_redirect(response, hash, depth, &block)
    end

    handle_errors!(response)
    set_cookie!(response)
    response
  end
  private :handle_request

  # Define methods for the HTTP methods used by the API (#get, #post, and
  # #delete).
  [:get, :post, :delete].each do |http_method|
    define_method(http_method) do |hash, &block|
      request(hash.merge(:method => http_method), &block)
    end
  end

  # Private functions that operate on the request and response.

  def add_defaults(hash)
    hash[:headers] = default_headers.merge(hash[:headers] || {})
    hash[:path] = "/api/v#{Sumo::API_VERSION}#{hash[:path]}" unless
      hash[:path].index("/api/v#{Sumo::API_VERSION}") == 0
    hash
  end
  private :add_defaults

  # Recursively handle redirection up to 10 level depth
  def handle_redirect(response, hash, depth, &block)
    fail 'Too many redirections.' if depth > 9

    endpoint = response.headers['Location']
               .match(%r{^(https://.+\.[a-z]+)/}).to_a[1]

    depth += 1
    # I tried to blindly follow redirection path, but it omits the job ID.
    # hash[:path] = path
    handle_request(hash, endpoint, depth, &block)
  end
  private :handle_redirect

  def handle_errors!(response)
    case response.status
    when 400..499 then raise ClientError, extract_error_message(response.body)
    when 500..599 then raise ServerError, extract_error_message(response.body)
    end
  end
  private :handle_errors!

  def set_cookie!(response)
    @cookie = response.headers['Set-Cookie'] || @cookie
  end
  private :set_cookie!

  def extract_error_message(body)
    JSON.parse(body)['message'] || DEFAULT_ERROR_MESSAGE
  rescue
    DEFAULT_ERROR_MESSAGE
  end
  private :extract_error_message

  def default_headers
    {
      'Authorization' => "Basic #{encoded_creds}",
      'Content-Type' => 'application/json',
      'Cookie' => cookie,
      'Accept' => 'application/json'
    }.reject { |_, value| value.nil? }
  end
  private :default_headers

  def encoded_creds
    @encoded_creds ||= Base64.encode64(creds).gsub(/\s+/, '')
  end
  private :encoded_creds

  def creds
    [email, password].join(':')
  end
  private :creds

  def connection(endpoint = nil)
    @connections ||= {}
    endpoint ||= 'https://api.sumologic.com'

    fail 'Base url out of allowed domain.' unless
      endpoint.match(%r{^https://.+\.sumologic\.com$})
    @connections[endpoint] ||= Excon.new(endpoint)
  end
  private :connection
end
