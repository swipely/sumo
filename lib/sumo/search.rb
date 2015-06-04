module Sumo
  # This class represents a search job.
  class Search
    attr_reader :id, :client

    private_class_method :new

    # Create a new search job with the given query.
    def self.create(params = {}, client = Sumo.client)
      params[:timeZone] ||= params.delete(:time_zone) || params.delete(:tz)
      result = client.post(path: '/search/jobs', body: params.to_json)
      new(JSON.parse(result)['id'], client)
    end

    # Initialize a new `Search` with the given `id` and `client`.
    def initialize(id, client)
      @id = id
      @client = client
    end

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
      @messages ||= Collection.new(
        get_values: method(:get_messages),
        get_status: method(:status),
        count_key: 'messageCount'
      ).each
    end

    # Return an `Enumerator` containing each record found by the search.
    def records
      @records ||= Collection.new(
        get_values: method(:get_records),
        get_status: method(:status),
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

    private

    def extract_response(key, resp)
      JSON.parse(resp)[key].map { |hash| hash['map'] }
    end

    def base_path
      @base_path ||= "/search/jobs/#{id}"
    end
  end
end
