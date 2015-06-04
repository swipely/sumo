# This class represents a search job.
class Sumo::Search
  attr_reader :id, :client

  # Create a new search job with the given query.
  def self.create(params = {}, client = Sumo.client)
    params[:timeZone] ||= params.delete(:time_zone) || params.delete(:tz)
    result = client.post(path: '/search/jobs', body: params.to_json)
    new(JSON.parse(result)['id'], client)
  end

  # Initialize a new `Sumo::Search` with the given `id` and `client`.
  def initialize(id, client)
    @id = id
    @client = client
  end
  private_class_method :new

  # Get the status of the search job.
  def status
    JSON.parse(client.get(path: base_path))
  end

  # Cancel the search job.
  def delete!
    client.delete(path: base_path)
    nil
  end

  # Return an `Enumerator` containing each message found by the search.
  def messages
    @messages ||= Sumo::Collection.new(
      get_values: proc { |hash| self.get_messages(hash) },
      get_status: proc { self.status },
      count_key: 'messageCount'
    ).each
  end

  # Return an `Enumerator` containing each record found by the search.
  def records
    @records ||= Sumo::Collection.new(
      get_values: proc { |hash| self.get_records(hash) },
      get_status: proc { self.status },
      count_key: 'recordCount'
    ).each
  end

  # Get the messages from the given offset and limit.
  def get_messages(query)
    resp = client.get(path: "#{base_path}/messages", query: query)
    extract_response('messages', resp)
  end

  # Get the records from the given offset and limit.
  def get_records(query)
    resp = client.get(path: "#{base_path}/records", query: query)
    extract_response('records', resp)
  end

  def extract_response(key, resp)
    JSON.parse(resp)[key].map { |hash| hash['map'] }
  end
  private :extract_response

  def base_path
    @base_path ||= "/search/jobs/#{id}"
  end
  private :base_path
end
