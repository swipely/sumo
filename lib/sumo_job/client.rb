# This class has the lowest-level interface to interact with the Sumo Job API.
class SumoJob::Client
  include SumoJob::Error

  attr_reader :creds, :cookie

  # The error message raised when the result can be parsed from Sumo.
  DEFAULT_ERROR_MESSAGE = 'Error sending API request'

  # Create a new `SumoJob::Client` with the given credentials.
  def initialize(creds = SumoJob.creds)
    @creds = creds.freeze
  end

  # Send a HTTP request to the server, handling any errors that may occur.
  def request(hash, &block)
    response = connection.request(add_headers(hash), &block)
    handle_errors!(response)
    set_cookie!(response)
    response.body
  end

  # Define methods for the HTTP methods used by the API (#get, #post, and
  # #delete).
  [:get, :post, :delete].each do |http_method|
    define_method(http_method) do |hash, &block|
      request(hash.merge(:method => http_method), &block)
    end
  end

  # Private functions that operate on the request and response.

  def add_headers(hash)
    hash.merge(:headers => default_headers.merge(hash[:headers] || {}))
  end
  private :add_headers

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
    @encoded_creds ||= Base64.encode64(creds).strip
  end
  private :encoded_creds

  def connection
    @connection ||= Excon.new(
      "https://api.sumologic.com/api/v#{SumoJob::SUMO_API_VERSION}"
    )
  end
  private :connection
end
